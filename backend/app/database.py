#database.py
import asyncio
import logging
from pymongo import MongoClient
from .config import settings
from typing import Optional


class Database:
    client: Optional[MongoClient] = None


db = Database()

_logger = logging.getLogger(__name__)


async def connect_to_mongo():
    """Create a synchronous MongoClient on a background thread and ping the server.

    Performing the connection and ping on a thread avoids blocking the asyncio
    event loop during FastAPI's startup lifecycle. A short serverSelectionTimeoutMS
    is used so failures surface quickly.
    """

    def _connect():
        # Use a short server selection timeout so bad URIs don't hang for long
        client = MongoClient(settings.MONGODB_URL, serverSelectionTimeoutMS=30000)
        # force a connection attempt
        client.admin.command("ping")
        return client

    try:
        db.client = await asyncio.to_thread(_connect)
        _logger.info("Connected to MongoDB")
        print("Connected to MongoDB")
    except Exception:
        _logger.exception("Failed to connect to MongoDB during startup")
        # Re-raise so FastAPI startup fails visibly and the error is logged
        raise


async def close_mongo_connection():
    if db.client:
        try:
            await asyncio.to_thread(lambda: db.client.close())
        except Exception:
            _logger.exception("Error closing MongoDB connection")
        print("Closed MongoDB connection")


def get_database():
    if db.client is None:
        raise RuntimeError(
            "Database client not connected. Call connect_to_mongo() first."
        )
    return db.client[settings.DATABASE_NAME]
