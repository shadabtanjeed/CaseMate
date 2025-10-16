from ..database import get_database
from datetime import datetime
import uuid
import logging
import asyncio

_logger = logging.getLogger(__name__)


class AppointmentService:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def get_db(self):
        return get_database()

    async def create_appointment(self, appointment_data: dict):
        """Create a new appointment and associated case"""
        try:
            db = self.get_db()

            # Generate IDs
            appointment_id = str(uuid.uuid4())
            case_id = str(uuid.uuid4())

            # Create appointment document
            appointment_doc = {
                "appointment_id": appointment_id,
                "lawyer_email": appointment_data["lawyer_email"],
                "user_email": appointment_data["user_email"],
                "date": appointment_data["date"],
                "start_time": appointment_data["start_time"],
                "end_time": appointment_data["end_time"],
                "is_finished": False,
                "case_type": appointment_data["case_type"],
                "description": appointment_data["description"],
                "consultation_type": appointment_data.get("consultation_type", "video"),
                "created_at": datetime.utcnow(),
            }

            # Create case document
            case_doc = {
                "case_id": case_id,
                "appointment_id": appointment_id,
                "creation_date": datetime.utcnow(),
                "lawyer_email": appointment_data["lawyer_email"],
                "user_email": appointment_data["user_email"],
                "status": "ongoing",
                "last_updated": datetime.utcnow(),
                "case_type": appointment_data["case_type"],
                "description": appointment_data["description"],
            }

            # Insert into database
            appointments = db["appointments"]
            cases = db["cases"]

            result_appt = await self._insert_document(appointments, appointment_doc)
            result_case = await self._insert_document(cases, case_doc)

            if result_appt and result_case:
                return {
                    "appointment_id": appointment_id,
                    "case_id": case_id,
                    "success": True,
                    "message": "Appointment and case created successfully",
                }
            else:
                raise Exception("Failed to create appointment or case")

        except Exception as e:
            self.logger.error(f"Error creating appointment: {str(e)}")
            raise

    async def _insert_document(self, collection, document):
        """Helper to insert document synchronously on a thread"""
        import asyncio

        try:
            result = await asyncio.to_thread(collection.insert_one, document)
            return result.inserted_id is not None
        except Exception as e:
            self.logger.error(f"Error inserting document: {str(e)}")
            return False

    async def get_appointment(self, appointment_id: str):
        """Get a specific appointment"""
        try:
            db = self.get_db()
            appointments = db["appointments"]

            def _find():
                return appointments.find_one({"appointment_id": appointment_id})

            doc = await asyncio.to_thread(_find)
            if doc:
                doc["_id"] = str(doc.get("_id", ""))
            return doc
        except Exception as e:
            self.logger.error(f"Error getting appointment: {str(e)}")
            raise

    async def get_appointments_by_user(self, user_email: str):
        """Get all appointments for a user"""
        try:
            db = self.get_db()
            appointments = db["appointments"]

            def _find():
                return list(appointments.find({"user_email": user_email}))

            docs = await asyncio.to_thread(_find)
            for doc in docs:
                doc["_id"] = str(doc.get("_id", ""))
            return docs
        except Exception as e:
            self.logger.error(f"Error getting user appointments: {str(e)}")
            raise

    async def get_appointments_by_lawyer(self, lawyer_email: str):
        """Get all appointments for a lawyer"""
        try:
            db = self.get_db()
            appointments = db["appointments"]

            def _find():
                return list(appointments.find({"lawyer_email": lawyer_email}))

            docs = await asyncio.to_thread(_find)
            for doc in docs:
                doc["_id"] = str(doc.get("_id", ""))
            return docs
        except Exception as e:
            self.logger.error(f"Error getting lawyer appointments: {str(e)}")
            raise

    async def update_appointment_status(self, appointment_id: str, is_finished: bool):
        """Update appointment completion status"""
        try:
            db = self.get_db()
            appointments = db["appointments"]

            def _update():
                result = appointments.update_one(
                    {"appointment_id": appointment_id},
                    {"$set": {"is_finished": is_finished}},
                )
                return result.modified_count > 0

            success = await asyncio.to_thread(_update)
            return success
        except Exception as e:
            self.logger.error(f"Error updating appointment: {str(e)}")
            raise


class CaseService:
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def get_db(self):
        return get_database()

    async def get_case(self, case_id: str):
        """Get a specific case"""
        try:
            db = self.get_db()
            cases = db["cases"]

            def _find():
                return cases.find_one({"case_id": case_id})

            doc = await asyncio.to_thread(_find)
            if doc:
                doc["_id"] = str(doc.get("_id", ""))
            return doc
        except Exception as e:
            self.logger.error(f"Error getting case: {str(e)}")
            raise

    async def get_cases_by_user(self, user_email: str):
        """Get all cases for a user"""
        try:
            db = self.get_db()
            cases = db["cases"]

            def _find():
                return list(cases.find({"user_email": user_email}))

            docs = await asyncio.to_thread(_find)
            for doc in docs:
                doc["_id"] = str(doc.get("_id", ""))
            return docs
        except Exception as e:
            self.logger.error(f"Error getting user cases: {str(e)}")
            raise

    async def get_cases_by_lawyer(self, lawyer_email: str):
        """Get all cases for a lawyer"""
        try:
            db = self.get_db()
            cases = db["cases"]

            def _find():
                return list(cases.find({"lawyer_email": lawyer_email}))

            docs = await asyncio.to_thread(_find)
            for doc in docs:
                doc["_id"] = str(doc.get("_id", ""))
            return docs
        except Exception as e:
            self.logger.error(f"Error getting lawyer cases: {str(e)}")
            raise

    async def update_case_status(self, case_id: str, status: str):
        """Update case status"""
        try:
            db = self.get_db()
            cases = db["cases"]

            def _update():
                result = cases.update_one(
                    {"case_id": case_id},
                    {"$set": {"status": status, "last_updated": datetime.utcnow()}},
                )
                return result.modified_count > 0

            success = await asyncio.to_thread(_update)
            return success
        except Exception as e:
            self.logger.error(f"Error updating case: {str(e)}")
            raise


# Singleton instances
appointment_service = AppointmentService()
case_service = CaseService()
