from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
import logging
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from .database import connect_to_mongo, close_mongo_connection
from .routes import auth, chatbot_routes, schedule_routes


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await connect_to_mongo()
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
app.include_router(schedule_routes.router, prefix="/api")


@app.get("/")
async def root():
    return {"message": "Lawyer App API is running"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
