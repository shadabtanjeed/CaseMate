from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
import logging
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import asyncio
from .database import connect_to_mongo, close_mongo_connection
from .routes import auth, chatbot_routes, lawyers


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    # Try connecting to Mongo with a few retries and short backoff to handle
    # transient startup races (e.g., Docker container starting slightly later).
    retries = 3
    delay = 1
    last_exc = None
    for attempt in range(1, retries + 1):
        try:
            await connect_to_mongo()
            last_exc = None
            break
        except Exception as e:
            last_exc = e
            logging.warning("MongoDB connection attempt %s failed: %s", attempt, e)
            if attempt < retries:
                await asyncio.sleep(delay)
                delay *= 2
    if last_exc:
        # Let startup fail with the last exception so it's visible to the user
        raise last_exc
    yield
    # Shutdown
    await close_mongo_connection()


logging.basicConfig(level=logging.INFO)

app = FastAPI(
    title="Lawyer App API",
    description="Authentication and user management API",
    version="1.0.0",
    lifespan=lifespan,
)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    # If it's already an HTTPException, return its detail and status code
    from fastapi import HTTPException as FastAPIHTTPException

    if isinstance(exc, FastAPIHTTPException):
        logging.info(
            "HTTPException raised: %s %s %s", request.method, request.url, exc.detail
        )
        return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})

    # Log full traceback for unexpected errors and return a generic message
    logging.exception("Unhandled exception for %s %s", request.method, request.url)
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})


# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api")
app.include_router(chatbot_routes.router, prefix="/api")
app.include_router(lawyers.router, prefix="/api")


@app.get("/")
async def root():
    return {"message": "Lawyer App API is running"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
