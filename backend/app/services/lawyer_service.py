from typing import List, Optional
from datetime import datetime
from bson import ObjectId
from ..db_async import find_many, find_one
from ..models.user import UserInDB
import logging
from ..database import get_database
import asyncio


class LawyerService:
    @staticmethod
    async def search_lawyers(
        q: Optional[str] = None,
        specialization: Optional[str] = None,
        min_rating: Optional[float] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> List[UserInDB]:
        """Search lawyers collection using optional text q (name or specialization), specialization exact match, and minimum rating."""
        query = {"role": "lawyer"}

        if q:
            # case-insensitive search on full_name and specialization
            query["$or"] = [
                {"full_name": {"$regex": q, "$options": "i"}},
                {"specialization": {"$regex": q, "$options": "i"}},
            ]

        if specialization:
            # Use case-insensitive substring match so frontend values like
            # 'corporate' or 'Corporate Law' both match stored 'Corporate Law'
            query["specialization"] = {"$regex": specialization, "$options": "i"}

        if min_rating is not None:
            query["rating"] = {"$gte": min_rating}

        skip = (page - 1) * page_size

        try:
            logging.info("Searching lawyers with query=%s skip=%s limit=%s", query, skip, page_size)
            docs = await find_many("lawyers", query, skip=skip, limit=page_size, sort=[("rating", -1)])
            results = []
            for d in docs:
                try:
                    d["_id"] = str(d["_id"])
                except Exception:
                    pass
                results.append(UserInDB(**d))
            return results
        except Exception as e:
            logging.exception("Error searching lawyers: %s", e)
            raise

    async def get_lawyer_by_id(self, lawyer_id: str) -> Optional[UserInDB]:
        try:
            # assume lawyer_id is an ObjectId string
            oid = ObjectId(lawyer_id)
        except Exception:
            return None

        try:
            doc = await find_one("lawyers", {"_id": oid})
            if not doc:
                return None
            try:
                doc["_id"] = str(doc["_id"])
            except Exception:
                pass
            return UserInDB(**doc)
        except Exception:
            logging.exception("Error fetching lawyer by id %s", lawyer_id)
            raise

    async def get_unique_specializations(self) -> List[str]:
        try:
            db = get_database()

            def _distinct():
                # Use MongoDB distinct to get unique specializations for role=lawyer
                return list(db['lawyers'].distinct('specialization', {'role': 'lawyer'}))

            specs = await asyncio.to_thread(_distinct)
            # Filter out falsy and trim
            return [s.strip() for s in specs if s]
        except Exception:
            logging.exception('Error fetching unique specializations')
            raise


lawyer_service = LawyerService()
