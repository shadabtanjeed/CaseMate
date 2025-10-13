from pymongo import MongoClient
from .config import settings
from typing import Optional


class Database:
    client: Optional[MongoClient] = None


db = Database()


async def connect_to_mongo():
    """Connect using synchronous pymongo.MongoClient. This is quick and
    safe to call during FastAPI startup. Using sync client with async
    wrappers avoids motor compatibility issues on newer Python versions.
    """
    # MongoClient handles SRV URIs (dnspython should be installed)
    db.client = MongoClient(settings.MONGODB_URL)
    # Accessing server_info forces a connection attempt
    try:
        db.client.admin.command('ping')
    except Exception as e:
        # Let the exception propagate for visibility during startup
        raise
    print("Connected to MongoDB")


async def close_mongo_connection():
    if db.client:
        try:
            db.client.close()
        except Exception:
            pass
        print("Closed MongoDB connection")


def get_database():
    if db.client is None:
        raise RuntimeError("Database client not connected. Call connect_to_mongo() first.")
    return db.client[settings.DATABASE_NAME]