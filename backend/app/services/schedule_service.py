from typing import Dict, Any
from ..db_async import find_one, insert_one, update_one


class ScheduleService:
    collection = "lawyer_schedules"

    @staticmethod
    async def get_schedule(email: str) -> Dict[str, Any] | None:
        return await find_one(ScheduleService.collection, {"email": email})

    @staticmethod
    async def upsert_schedule(email: str, payload: Dict[str, Any]):
        existing = await find_one(ScheduleService.collection, {"email": email})
        if existing:
            # Replace weekly_schedule (recurring pattern)
            await update_one(
                ScheduleService.collection,
                {"email": email},
                {"$set": {"weekly_schedule": payload.get("weekly_schedule", [])}},
            )
            return await find_one(ScheduleService.collection, {"email": email})
        else:
            doc = {
                "email": email,
                "weekly_schedule": payload.get("weekly_schedule", []),
            }
            await insert_one(ScheduleService.collection, doc)
            return await find_one(ScheduleService.collection, {"email": email})


schedule_service = ScheduleService()
