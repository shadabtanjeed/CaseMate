from fastapi import APIRouter, Depends, HTTPException, status, Body
from pydantic import BaseModel
import logging
from ..services.meeting_service import meeting_service
from ..utils.dependencies import get_current_user_email

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/meetings", tags=["Meetings"])


# Request/Response schemas
class CreateMeetingRequest(BaseModel):
    appointment_id: str
    lawyer_email: str
    user_email: str
    scheduled_time: str


class JoinMeetingRequest(BaseModel):
    name: str
    user_type: str  # 'lawyer' or 'user'


class EndMeetingRequest(BaseModel):
    duration_minutes: int = 0
    notes: str = ""


@router.post("/create-room")
async def create_meeting_room(
    request: CreateMeetingRequest,
    current_user_email: str = Depends(get_current_user_email),
):
    """
    Create a new meeting room for an appointment or get existing one.
    Either lawyer or user can initiate this.
    """
    logger.info("🔵 POST /api/meetings/create-room endpoint called")
    logger.info(f"📦 Request received: {request.dict()}")
    logger.info(f"👤 Current user: {current_user_email}")

    try:
        logger.info("⏳ Calling meeting_service.create_meeting_room()...")
        result = await meeting_service.create_meeting_room(
            appointment_id=request.appointment_id,
            lawyer_email=request.lawyer_email,
            user_email=request.user_email,
            scheduled_time=request.scheduled_time,
        )
        logger.info(f"✅ Meeting created successfully: {result}")
        return result
    except Exception as e:
        logger.error(f"❌ Error creating meeting room: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating meeting room: {str(e)}",
        )


@router.get("/room/{room_id}/status")
async def get_meeting_status(
    room_id: str, current_user_email: str = Depends(get_current_user_email)
):
    """Get current status of a meeting room."""
    try:
        status_info = await meeting_service.get_meeting_status(room_id)
        if not status_info:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Meeting room not found",
            )
        return status_info
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching meeting status: {str(e)}",
        )


@router.post("/room/{room_id}/join")
async def join_meeting(
    room_id: str,
    request: JoinMeetingRequest,
    current_user_email: str = Depends(get_current_user_email),
):
    """
    Join a meeting room. Tracks participant and marks room as active.
    user_type should be 'lawyer' or 'user'
    """
    logger.info(f"🔵 POST /api/meetings/room/{room_id}/join endpoint called")
    logger.info(f"📦 Request: name={request.name}, user_type={request.user_type}")
    logger.info(f"👤 Current user: {current_user_email}")

    if request.user_type not in ["lawyer", "user"]:
        logger.warning(f"⚠️ Invalid user_type: {request.user_type}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="user_type must be 'lawyer' or 'user'",
        )

    try:
        logger.info(f"⏳ Adding participant to room {room_id}...")
        success = await meeting_service.add_participant(
            room_id=room_id,
            email=current_user_email,
            name=request.name,
            user_type=request.user_type,
        )
        if not success:
            logger.warning(f"❌ Room {room_id} not found")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Meeting room not found",
            )
        logger.info(f"✅ Participant added successfully to room {room_id}")
        return {"success": True, "message": "Joined meeting successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error joining meeting: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error joining meeting: {str(e)}",
        )


@router.post("/room/{room_id}/leave")
async def leave_meeting(
    room_id: str, current_user_email: str = Depends(get_current_user_email)
):
    """Leave a meeting room. If no participants left, marks room as inactive."""
    try:
        success = await meeting_service.remove_participant(
            room_id=room_id, email=current_user_email
        )
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Meeting room not found",
            )
        return {"success": True, "message": "Left meeting successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error leaving meeting: {str(e)}",
        )


@router.get("/room/{room_id}/has-participants")
async def check_room_participants(
    room_id: str, current_user_email: str = Depends(get_current_user_email)
):
    """Check if a room has any active participants."""
    try:
        has_participants = await meeting_service.check_room_has_participants(room_id)
        return {"room_id": room_id, "has_participants": has_participants}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error checking room participants: {str(e)}",
        )


@router.post("/room/{room_id}/end")
async def end_meeting(
    room_id: str,
    request: EndMeetingRequest,
    current_user_email: str = Depends(get_current_user_email),
):
    """End a meeting and save the record."""
    try:
        success = await meeting_service.save_meeting_record(
            room_id=room_id,
            duration_minutes=request.duration_minutes,
            notes=request.notes,
        )
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Meeting room not found",
            )
        return {"success": True, "message": "Meeting ended and recorded"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error ending meeting: {str(e)}",
        )


@router.post("/cleanup")
async def cleanup_expired_meetings(
    current_user_email: str = Depends(get_current_user_email),
):
    """Clean up expired meeting records. Admin only."""
    try:
        deleted_count = await meeting_service.cleanup_expired_meetings()
        return {"success": True, "deleted_count": deleted_count}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error cleaning up meetings: {str(e)}",
        )
