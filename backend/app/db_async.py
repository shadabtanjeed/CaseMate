import asyncio
import logging
from typing import Any, Dict, Optional
from .database import get_database

logging.basicConfig(filename='logs/db_async.log', level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')


async def find_one(collection: str, filter: Dict) -> Optional[Dict[str, Any]]:
    db = get_database()
    coll = db[collection]
    try:
        return await asyncio.to_thread(lambda: coll.find_one(filter))
    except Exception as e:
        logging.exception('Error in find_one')
        raise


async def insert_one(collection: str, document: Dict) -> Any:
    db = get_database()
    coll = db[collection]
    try:
        return await asyncio.to_thread(lambda: coll.insert_one(document))
    except Exception as e:
        logging.exception('Error in insert_one')
        raise


async def update_one(collection: str, filter: Dict, update: Dict) -> Any:
    db = get_database()
    coll = db[collection]
    try:
        return await asyncio.to_thread(lambda: coll.update_one(filter, update))
    except Exception as e:
        logging.exception('Error in update_one')
        raise


async def delete_one(collection: str, filter: Dict) -> Any:
    db = get_database()
    coll = db[collection]
    try:
        return await asyncio.to_thread(lambda: coll.delete_one(filter))
    except Exception as e:
        logging.exception('Error in delete_one')
        raise


async def delete_many(collection: str, filter: Dict) -> Any:
    """Delete multiple documents from a collection"""
    db = get_database()
    coll = db[collection]
    try:
        return await asyncio.to_thread(lambda: coll.delete_many(filter))
    except Exception as e:
        logging.exception('Error in delete_many')
        raise