"""Meeting room management service for handling video consultations."""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Optional, Dict
from ..database import get_database

logger = logging.getLogger(__name__)


class MeetingService:
    """Service for managing meeting rooms and participants."""

    def __init__(self):
        self.room_expiration_hours = 24  # Rooms expire after 24 hours

    def _get_db(self):
        """Get database instance."""
        return get_database()

    async def create_meeting_room(
        self,
        appointment_id: str,
        lawyer_email: str,
        user_email: str,
        scheduled_time: str,
    ) -> Dict:
        """
        Create or get existing meeting room for an appointment.
        Returns meeting room data including unique room ID.
        """
        logger.info(f"🔵 create_meeting_room called for appointment: {appointment_id}")

        # Try to find existing meeting for this appointment
        logger.info(f"🔍 Checking for existing meeting...")
        existing_meeting = await self.get_meeting_by_appointment_id(appointment_id)
        if existing_meeting:
            logger.info(
                f"✅ Found existing meeting: room_id={existing_meeting['room_id']}"
            )
            return {
                "success": True,
                "room_id": existing_meeting["room_id"],
                "meeting_id": str(existing_meeting.get("_id", "")),
                "created": False,
            }

        # Create new meeting room
        logger.info(f"➕ Creating new meeting room...")
        room_id = f"casemate_{appointment_id}_{int(datetime.now().timestamp())}"
        logger.info(f"📍 Generated room_id: {room_id}")

        meeting = {
            "room_id": room_id,
            "appointment_id": appointment_id,
            "lawyer_email": lawyer_email,
            "user_email": user_email,
            "scheduled_time": scheduled_time,
            "created_at": datetime.now(),
            "active": False,
            "participants": [],
            "messages": [],
        }

        def _insert():
            logger.info(f"💾 Inserting meeting into MongoDB...")
            db = self._get_db()
            result = db["meetings"].insert_one(meeting)
            logger.info(f"✅ Meeting inserted with ID: {result.inserted_id}")
            return result

        result = await asyncio.to_thread(_insert)

        logger.info(
            f"✅ Meeting room created: room_id={room_id}, meeting_id={result.inserted_id}"
        )
        return {
            "success": True,
            "room_id": room_id,
            "meeting_id": str(result.inserted_id),
            "created": True,
        }

    async def get_meeting_by_appointment_id(
        self, appointment_id: str
    ) -> Optional[Dict]:
        """Get meeting details by appointment ID."""

        def _find():
            db = self._get_db()
            return db["meetings"].find_one({"appointment_id": appointment_id})

        return await asyncio.to_thread(_find)

    async def add_participant(
        self, room_id: str, email: str, name: str, user_type: str
    ) -> bool:
        """
        Add a participant to a meeting room.
        user_type: 'lawyer' or 'user'
        """
        logger.info(
            f"🔵 add_participant called: room_id={room_id}, email={email}, type={user_type}"
        )

        def _update():
            logger.info(f"💾 Updating meeting {room_id} with participant {email}...")
            db = self._get_db()
            result = db["meetings"].update_one(
                {"room_id": room_id},
                {
                    "$addToSet": {
                        "participants": {
                            "email": email,
                            "name": name,
                            "type": user_type,
                            "joined_at": datetime.now(),
                        }
                    },
                    "$set": {"active": True, "started_at": datetime.now()},
                },
            )
            matched = result.matched_count
            modified = result.modified_count
            logger.info(f"📊 Update result: matched={matched}, modified={modified}")
            return modified > 0

        result = await asyncio.to_thread(_update)
        logger.info(
            f"{'✅' if result else '❌'} Participant {'added' if result else 'not added'}"
        )
        return result

    async def remove_participant(self, room_id: str, email: str) -> bool:
        """Remove a participant from a meeting room."""

        def _remove():
            db = self._get_db()
            meeting = db["meetings"].find_one({"room_id": room_id})
            if not meeting:
                return False

            # Filter out the participant
            remaining_participants = [
                p for p in meeting.get("participants", []) if p.get("email") != email
            ]

            # If no participants left, mark room as inactive
            is_active = len(remaining_participants) > 0

            result = db["meetings"].update_one(
                {"room_id": room_id},
                {
                    "$set": {
                        "participants": remaining_participants,
                        "active": is_active,
                        "ended_at": datetime.now() if not is_active else None,
                    }
                },
            )
            return result.modified_count > 0

        return await asyncio.to_thread(_remove)

    async def get_meeting_status(self, room_id: str) -> Optional[Dict]:
        """Get current status of a meeting room."""

        def _get_status():
            db = self._get_db()
            meeting = db["meetings"].find_one({"room_id": room_id})
            if not meeting:
                return None

            return {
                "room_id": meeting["room_id"],
                "active": meeting.get("active", False),
                "participants_count": len(meeting.get("participants", [])),
                "participants": meeting.get("participants", []),
                "started_at": meeting.get("started_at"),
            }

        return await asyncio.to_thread(_get_status)

    async def check_room_has_participants(self, room_id: str) -> bool:
        """Check if room has any active participants."""

        def _check():
            db = self._get_db()
            meeting = db["meetings"].find_one({"room_id": room_id}, {"participants": 1})
            if not meeting:
                return False
            return len(meeting.get("participants", [])) > 0

        return await asyncio.to_thread(_check)

    async def save_meeting_record(
        self, room_id: str, duration_minutes: int, notes: str = ""
    ) -> bool:
        """Save final meeting record after call ends."""

        def _save():
            db = self._get_db()
            result = db["meetings"].update_one(
                {"room_id": room_id},
                {
                    "$set": {
                        "ended_at": datetime.now(),
                        "active": False,
                        "duration_minutes": duration_minutes,
                        "notes": notes,
                    }
                },
            )
            return result.modified_count > 0

        return await asyncio.to_thread(_save)

    async def cleanup_expired_meetings(self) -> int:
        """Remove expired meeting records."""

        def _cleanup():
            db = self._get_db()
            expiration_time = datetime.now() - timedelta(
                hours=self.room_expiration_hours
            )
            result = db["meetings"].delete_many(
                {"created_at": {"$lt": expiration_time}}
            )
            return result.deleted_count

        return await asyncio.to_thread(_cleanup)


# Singleton instance
meeting_service = MeetingService()
