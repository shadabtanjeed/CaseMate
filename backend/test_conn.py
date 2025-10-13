import asyncio
from app.database import connect_to_mongo, get_database, close_mongo_connection


async def main():
    await connect_to_mongo()
    db = get_database()
    print("DB object:", db)
    try:
        # db.command is synchronous (pymongo). Run it in a thread.
        ping = await asyncio.to_thread(lambda: db.command({"ping": 1}))
        print("Ping result:", ping)
    finally:
        await close_mongo_connection()


if __name__ == "__main__":
    asyncio.run(main())
