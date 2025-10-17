import asyncio
import logging
from typing import List
from ..database import get_database


class AppointmentService:
    async def get_appointments_for_user(self, user_email: str) -> List[dict]:
        db = get_database()

        def _query():
            # Return all appointments where user_email matches
            cursor = db['appointments'].find({'user_email': user_email}).sort([('date', -1)])
            return list(cursor)

        try:
            docs = await asyncio.to_thread(_query)
            # ensure types are JSON-serializable
            for d in docs:
                if '_id' in d:
                    try:
                        d['_id'] = str(d['_id'])
                    except Exception:
                        pass
            return docs
        except Exception:
            logging.exception('Error fetching appointments for user %s', user_email)
            raise


appointment_service = AppointmentService()
