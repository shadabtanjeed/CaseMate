import os
import json
import logging
from pathlib import Path
from typing import List, Dict, Optional, Any, cast
import numpy as np
import faiss
from sentence_transformers import SentenceTransformer
from groq import Groq
from dotenv import load_dotenv

# make sure environment vars are loaded before creating clients
load_dotenv()

# Groq client (may be None if API key missing)
_GROQ_API_KEY = os.environ.get("groq_api_key")
client = Groq(api_key=_GROQ_API_KEY) if _GROQ_API_KEY else None

# paths and model names (adjust paths as needed)
INDEX_PATH = Path("app/services/chatbot/data/faiss_index.index")
JSONL_PATH = Path("app/services/chatbot/data/processed_bd_law.jsonl")
EMBED_MODEL = "all-MiniLM-L6-v2"
GROQ_MODEL = "llama-3.3-70b-versatile"

# Do not perform heavy I/O or model loading at import time. Load lazily.
embed_model: Optional[SentenceTransformer] = None
docs: List[Dict] = []
index: Optional[faiss.Index] = None


def load_jsonl_docs(path: Path) -> List[Dict]:
    docs = []
    if not path.exists():
        print(f"⚠️  JSONL file not found: {path}")
        return docs
    with path.open("r", encoding="utf-8") as fh:
        for line in fh:
            if not line.strip():
                continue
            docs.append(json.loads(line))
    return docs


def load_faiss_index(p: Path) -> faiss.Index:
    if not p.exists():
        raise FileNotFoundError(f"FAISS index not found: {p}")
    return faiss.read_index(str(p))


def initialize(resources_path: Path = Path("data")) -> None:
    """Load docs, faiss index and embedding model. Safe to call multiple times."""
    global docs, index, embed_model
    if docs and index is not None and embed_model is not None:
        print(
            f"✓ Resources already initialized: {len(docs)} docs, index present, model loaded"
        )
        return

    print("🔄 Initializing chatbot resources...")
    jsonl = JSONL_PATH
    idxp = INDEX_PATH

    # load docs if present
    try:
        docs = load_jsonl_docs(jsonl)
        print(f"✓ Loaded {len(docs)} docs from {jsonl}")
    except Exception as e:
        print(f"❌ Error loading JSONL docs from {jsonl}: {e}")
        docs = []

    # load index if present
    try:
        index = load_faiss_index(idxp)
        print(f"✓ Loaded FAISS index from {idxp}")
    except FileNotFoundError:
        print(f"⚠️  FAISS index not found: {idxp}")
        index = None
    except Exception as e:
        print(f"❌ Error loading FAISS index from {idxp}: {e}")
        index = None

    # load embedding model
    if embed_model is None:
        try:
            embed_model = SentenceTransformer(EMBED_MODEL)
            print(f"✓ Loaded embedding model: {EMBED_MODEL}")
        except Exception as e:
            print(f"❌ Failed to load embedding model {EMBED_MODEL}: {e}")
            embed_model = None


def encode_query(query: str, normalize: bool = True) -> np.ndarray:
    # ensure resources are initialized
    if embed_model is None:
        print("🔄 Embedding model not loaded, initializing...")
        initialize()
    if embed_model is None:
        raise RuntimeError("Embedding model not available")

    print(f"🔍 Encoding query (length={len(query)} chars, normalize={normalize})")
    emb = embed_model.encode([query], convert_to_numpy=True).astype("float32")
    if normalize:
        faiss.normalize_L2(emb)
    print(f"✓ Query encoded to embedding shape: {emb.shape}")
    return emb


def retrieve_hits(query: str, top_k: int = 8) -> List[Dict]:
    # ensure resources are initialized
    if index is None or not docs:
        print("🔄 Index or docs not loaded, initializing...")
        initialize()
    if index is None or not docs:
        # No index/docs available yet
        print("⚠️  No FAISS index or docs available for retrieval")
        return []

    print(f"🔍 Retrieving top_k={top_k} hits for query: {query[:100]}")
    q = encode_query(query)
    D, I = cast(Any, index).search(q, top_k)
    hits = []
    for score, idx in zip(D[0].tolist(), I[0].tolist()):
        if idx < 0 or idx >= len(docs):
            print(f"⚠️  Skipping invalid index: {idx}")
            continue
        # assume index ordering matches JSONL ordering used when index was built
        meta_obj = docs[idx]
        hits.append({"score": float(score), "doc_index": idx, "doc": meta_obj})

    scores_str = [f"{h['score']:.4f}" for h in hits[:5]]
    print(f"✓ Retrieved {len(hits)} hits with scores: {scores_str}")
    return hits


def build_sources_block(hits: List[Dict], max_chars: int = 2000) -> str:
    blocks = []
    for i, h in enumerate(hits):
        doc = h["doc"]
        # prefer structured meta inside 'meta' if present
        meta = doc.get("meta") if isinstance(doc.get("meta"), dict) else doc
        law_title = (meta.get("law_title") or meta.get("Law Title") or "").strip()
        section_name = (
            meta.get("section_name") or meta.get("Section Name") or ""
        ).strip()
        section_id = meta.get("section_id") or meta.get("Section ID") or ""
        law_date = (
            meta.get("law_pass_date") or meta.get("law_pass_date") or ""
        ).strip()
        text = doc.get("text") or doc.get("_text_for_embed") or ""
        # fallback: combine header + clean_section_description
        if not text:
            header_parts = []
            if law_title:
                header_parts.append(f"Law Title: {law_title}")
            if law_date:
                header_parts.append(f"Law Date: {law_date}")
            if section_id:
                header_parts.append(f"Section ID: {section_id}")
            if section_name:
                header_parts.append(f"Section Name: {section_name}")
            header = "\n".join(header_parts)
            text = header + "\n\n" + (meta.get("clean_section_description") or "")
        # truncate to limit prompt size
        if len(text) > max_chars:
            text = text[:max_chars] + "..."
        header_label = f"title: {law_title}" if law_title else ""
        header_label += f" | id: {section_id}" if section_id else ""
        header_label += f" | date: {law_date}" if law_date else ""
        label = header_label or f"doc_index: {h['doc_index']}"
        blocks.append(f"[SOURCE {i}] {label}\n\n{text}")
    return "\n\n".join(blocks)


def is_general_question(question: str) -> bool:
    """Check if the question is a general greeting or basic query that doesn't require legal sources."""
    question_lower = question.lower().strip()

    # Greetings and basic interaction
    greetings = ["hi", "hello", "hey", "good morning", "good afternoon", "good evening"]
    if any(
        question_lower == greeting or question_lower.startswith(greeting + " ")
        for greeting in greetings
    ):
        return True

    # Identity questions
    identity_patterns = [
        "who are you",
        "what are you",
        "what is your name",
        "introduce yourself",
        "what can you do",
        "what do you do",
        "how can you help",
        "can you help",
        "what is this",
        "what is legalbot",
        "tell me about yourself",
    ]
    if any(pattern in question_lower for pattern in identity_patterns):
        return True

    return False


def ask_groq_general(
    question: str, context: Optional[str] = None, model: str = GROQ_MODEL
):
    """Answer general questions without legal sources, but maintain legal assistant context."""
    system = (
        "You are LegalBot, an AI legal assistant specializing in Bangladesh law. "
        "You help users understand legal concepts, laws, and their rights under Bangladesh legal system. "
        "For general questions and greetings, respond in a friendly and professional manner. "
        "Keep responses concise (2-3 sentences for greetings, 4-5 for capability questions). "
        "Always remind users that for specific legal advice, they should consult sources or a qualified lawyer."
    )

    user_prompt = f"Question: {question}"
    if context and context.strip():
        user_prompt = f"Context: {context}\n\n{user_prompt}"

    if client is None:
        return "Hello! I'm LegalBot, your AI legal assistant. I'm currently unavailable due to configuration issues."

    try:
        resp = client.chat.completions.create(
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": user_prompt},
            ],
            model=model,
            temperature=0.7,  # Slightly higher for natural conversation
        )
        answer = (
            getattr(resp.choices[0].message, "content", None)
            or "I'm here to help with legal questions!"
        )
        print(f"✓ General response generated: {answer[:100]}...")
        return answer
    except Exception as e:
        print(f"❌ Groq API call failed for general question: {e}")
        return "Hello! I'm LegalBot, your AI legal assistant for Bangladesh law. How can I help you today?"


def ask_groq_fallback(
    question: str, context: Optional[str] = None, model: str = GROQ_MODEL
):
    """Fallback to general legal knowledge when no sources found, focused on Bangladesh law."""
    print(f"🔄 Using fallback (general knowledge) for question: {question[:100]}...")

    system = (
        "You are LegalBot, an AI legal assistant specializing in Bangladesh law. "
        "The user asked a legal question, but no specific law sources were found in the database. "
        "Provide a helpful response using your general knowledge of Bangladesh legal system and common legal principles. "
        "IMPORTANT: Start with '⚠️ **Using general knowledge** (specific law sources not found)' "
        "Focus on Bangladesh law context when applicable. "
        "If you know relevant legal principles or common practices in Bangladesh, share them. "
        "Keep responses informative but always suggest consulting a qualified lawyer for specific legal advice. "
        "Format in markdown. Be concise but helpful (4-8 sentences)."
    )

    user_prompt = f"Question: {question}\n\n" "Please provide a helpful response."

    if context and context.strip():
        user_prompt = f"Context: {context}\n\n{user_prompt}"

    if client is None:
        return "I do not know"

    try:
        resp = client.chat.completions.create(
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": user_prompt},
            ],
            model=model,
            temperature=0.7,  # Slightly more creative for general knowledge
        )
        answer = getattr(resp.choices[0].message, "content", None) or "I do not know"
        print(
            f"✓ Fallback response generated (using general knowledge): {answer[:100]}..."
        )
        return answer
    except Exception as e:
        print(f"❌ Groq API call failed for fallback: {e}")
        return "I do not know"


def ask_groq(
    question: str, sources: str, context: Optional[str] = None, model: str = GROQ_MODEL
):
    system = (
        "You are an assistant that MUST answer questions using ONLY the provided SOURCES. "
        "If the answer is not explicit, but can be deduced using legal reasoning based on the principles in the sources, then do so. But mention that you are using reasoning. "
        "Do NOT hallucinate or invent facts. If the answer is not contained in the sources, reply exactly: I do not know.\n"
        "When you provide facts, cite the source label(s) you used in brackets e.g. [SOURCE 1]. Start source labels at [SOURCE 1]. "
        "Include source metadata (law title, section name, section id, passing date) when referencing a source."
    )

    # Build user prompt with optional context
    if context and context.strip():
        user_prompt = (
            f"CONVERSATION CONTEXT (for reference):\n{context}\n\n"
            f"CURRENT QUESTION:\n{question}\n\n"
            f"SOURCES:\n{sources}\n\n"
            "INSTRUCTIONS:\nAnswer the CURRENT QUESTION using ONLY the information in the SOURCES. "
            "Use the conversation context to understand the question better, but do NOT use context as factual information. "
            "Provide a concise answer. Cite sources after the answer in list format. "
            "If sources disagree, summarize the disagreement and cite the conflicting sources. "
            "Provide the response in markdown format."
        )
    else:
        user_prompt = (
            f"QUESTION:\n{question}\n\nSOURCES:\n{sources}\n\n"
            "INSTRUCTIONS:\nAnswer the question ONLY using the information in the SOURCES. Provide a concise answer. Cite sources after the answer in list format. "
            "If sources disagree, summarize the disagreement and cite the conflicting sources. "
            "Provide the response in markdown format."
        )
    # guard if Groq client not configured
    if client is None:
        print("⚠️  Groq client not configured (groq_api_key missing)")
        return "I do not know"

    print(
        f"🤖 Calling Groq API with model={model}, sources length={len(sources)} chars"
    )
    print(f"📄 Sources preview: {sources[:500]}...")

    try:
        resp = client.chat.completions.create(
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": user_prompt},
            ],
            model=model,
        )
        answer = getattr(resp.choices[0].message, "content", None) or "I do not know"
        print(f"✓ Groq API response received, answer length={len(answer)} chars")
        print(f"💬 Answer preview: {answer[:200]}...")
        return answer
    except Exception as e:
        print(f"❌ Groq API call failed: {e}")
        return "I do not know"


def run_inference(
    question: str,
    context: Optional[str] = None,
    top_k: int = 6,
    score_threshold: float = 0.15,
):
    print("\n" + "=" * 80)
    print(f"🚀 INFERENCE START - Question: {question}")
    if context:
        print(f"📝 Context provided: {context[:200]}...")
    print(f"⚙️  Parameters: top_k={top_k}, score_threshold={score_threshold:.4f}")

    # Check if it's a general question (greeting, identity, etc.)
    if is_general_question(question):
        print("💬 Detected general question - responding without legal sources")
        answer = ask_groq_general(question, context=context)
        print("🏁 INFERENCE END (general response)")
        print("=" * 80 + "\n")
        return {"answer": answer, "hits": [], "type": "general"}

    # Use ONLY the question for retrieval (not context)
    hits = retrieve_hits(question, top_k=top_k)
    print(f"📊 Retrieved {len(hits)} raw hits before threshold filtering")

    if hits:
        top3_scores = [(h["doc_index"], f"{h['score']:.4f}") for h in hits[:3]]
        print(f"🎯 Top 3 hit scores BEFORE filtering: {top3_scores}")

    # filter by threshold
    hits_before_filter = len(hits)
    hits = [h for h in hits if h["score"] >= score_threshold]
    print(
        f"🔍 After threshold {score_threshold:.4f} filter: {len(hits)}/{hits_before_filter} hits remain"
    )

    if not hits:
        print("⚠️  No hits passed threshold filter - using general knowledge fallback")
        answer = ask_groq_fallback(question, context=context)
        print("🏁 INFERENCE END (fallback response)")
        print("=" * 80 + "\n")
        return {"answer": answer, "hits": [], "type": "fallback"}

    print(f"📝 Building sources block from {len(hits)} filtered hits")
    sources = build_sources_block(hits)
    print(f"✓ Sources block length: {len(sources)} chars")

    answer = ask_groq(question, sources, context=context)

    # If RAG returns "I do not know" or similar variations, try fallback
    answer_lower = answer.strip().lower()
    if (
        "i do not know" in answer_lower
        or "i don't know" in answer_lower
        or answer_lower == "i do not know."
        or answer_lower == "i don't know."
    ):
        print("⚠️  RAG returned 'I do not know' - trying general knowledge fallback")
        answer = ask_groq_fallback(question, context=context)
        print("🏁 INFERENCE END (fallback after RAG failure)")
        print("=" * 80 + "\n")
        return {"answer": answer, "hits": hits, "type": "fallback"}

    print(f"✅ Final answer: {answer[:100] if len(answer) > 100 else answer}...")
    print("🏁 INFERENCE END")
    print("=" * 80 + "\n")

    return {"answer": answer, "hits": hits, "type": "sourced"}


def format_user_friendly_answer(
    answer: str, hits: List[Dict], top_n: int = 3, excerpt_chars: int = 300
) -> str:
    # ... keep same behaviour as prior
    shown = hits[:top_n]
    source_lines = []
    cited_map = []
    for i, h in enumerate(shown, start=1):
        doc = h["doc"]
        meta = doc.get("meta") if isinstance(doc.get("meta"), dict) else doc
        title = (meta.get("law_title") or meta.get("Law Title") or "").strip()
        section = (meta.get("section_name") or meta.get("Section Name") or "").strip()
        sid = (meta.get("section_id") or meta.get("Section ID") or "").strip()
        date = (meta.get("law_pass_date") or meta.get("law_date") or "").strip()
        text = (
            (doc.get("text") or doc.get("_text_for_embed") or "")
            .replace("\n", " ")
            .strip()
        )
        snippet = (text[:excerpt_chars] + "…") if len(text) > excerpt_chars else text

        meta_parts = []
        if section:
            meta_parts.append(f"Section: {section}")
        if sid:
            meta_parts.append(f"ID: {sid}")
        if date:
            meta_parts.append(f"Date: {date}")
        meta_info = " — " + " | ".join(meta_parts) if meta_parts else ""

        title_display = title or "Source"
        source_lines.append(f"[{i}] {title_display}{meta_info}\n{snippet}".strip())

        cited_map.append(
            f"[{i}] {title_display}{(' — ' + ' | '.join(meta_parts)) if meta_parts else ''}"
        )

    parts = []
    parts.append("ANSWER (sourced):")
    parts.append(answer.strip() if isinstance(answer, str) else str(answer))
    parts.append("")
    return "\n".join(parts)


__all__ = [
    "initialize",
    "run_inference",
    "format_user_friendly_answer",
]
