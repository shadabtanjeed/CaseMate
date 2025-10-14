from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional

from ..services.chatbot.chatbot_service import initialize, run_inference


router = APIRouter(prefix="/chatbot", tags=["chatbot"])


class ChatRequest(BaseModel):
    message: str
    top_k: Optional[int] = 6
    score_threshold: Optional[float] = 0.18


@router.post("/chat")
async def chat_endpoint(req: ChatRequest):
    if not req.message or not req.message.strip():
        raise HTTPException(status_code=400, detail="Message is required")

    # ensure resources are initialized (index, model, etc.)
    try:
        initialize()
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to initialize chatbot resources: {e}"
        )

    try:
        result = run_inference(
            req.message,
            top_k=req.top_k or 6,
            score_threshold=req.score_threshold or 0.18,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Inference error: {e}")

    return result
