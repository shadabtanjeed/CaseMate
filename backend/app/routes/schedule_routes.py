from fastapi import APIRouter, HTTPException, status
from ..schemas.schedule import LawyerScheduleIn, LawyerScheduleOut
from ..services.schedule_service import schedule_service

router = APIRouter(prefix="/lawyer/schedules", tags=["Schedules"])


@router.get("/{email}", response_model=LawyerScheduleOut)
async def get_schedule(email: str):
    doc = await schedule_service.get_schedule(email)
    if not doc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="No schedule found"
        )
    # ensure _id is string
    if doc.get("_id") is not None:
        try:
            doc["_id"] = str(doc["_id"])
        except Exception:
            pass
    return doc


@router.post("/{email}", response_model=LawyerScheduleOut)
async def upsert_schedule(email: str, payload: LawyerScheduleIn):
    # ensure email in payload matches path param
    if payload.email != email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Email mismatch"
        )
    doc = await schedule_service.upsert_schedule(email, payload.dict())
    if not doc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to save schedule",
        )
    if doc.get("_id") is not None:
        try:
            doc["_id"] = str(doc["_id"])
        except Exception:
            pass
    return doc
