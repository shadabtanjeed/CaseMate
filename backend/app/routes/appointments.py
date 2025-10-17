from fastapi import APIRouter, HTTPException, status, Depends
from ..schemas.appointment import AppointmentIn, AppointmentOut, CaseIn, CaseOut
from ..services.appointment_service import appointment_service, case_service

router = APIRouter(prefix="/appointments", tags=["Appointments"])


@router.post("/create", response_model=dict)
async def create_appointment(appointment_data: AppointmentIn):
    """Create a new appointment and associated case"""
    try:
        # Use model_dump() for Pydantic V2 compatibility
        result = await appointment_service.create_appointment(
            appointment_data.model_dump()
        )
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create appointment: {str(e)}",
        )


@router.get("/{appointment_id}", response_model=dict)
async def get_appointment(appointment_id: str):
    """Get appointment details"""
    try:
        appointment = await appointment_service.get_appointment(appointment_id)
        if not appointment:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Appointment not found"
            )
        return appointment
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get appointment: {str(e)}",
        )


@router.get("/user/{user_email}")
async def get_user_appointments(user_email: str):
    """Get all appointments for a user"""
    try:
        appointments = await appointment_service.get_appointments_by_user(user_email)
        return {"appointments": appointments}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get appointments: {str(e)}",
        )


@router.get("/lawyer/{lawyer_email}")
async def get_lawyer_appointments(lawyer_email: str):
    """Get all appointments for a lawyer"""
    try:
        appointments = await appointment_service.get_appointments_by_lawyer(
            lawyer_email
        )
        return {"appointments": appointments}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get appointments: {str(e)}",
        )


@router.get("/lawyer/{lawyer_email}/date/{date}")
async def get_lawyer_appointments_by_date(lawyer_email: str, date: str):
    """Get appointments for a lawyer on a specific date (format: YYYY-MM-DD)"""
    try:
        appointments = await appointment_service.get_appointments_by_lawyer_and_date(
            lawyer_email, date
        )
        return {"appointments": appointments}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get appointments: {str(e)}",
        )


@router.put("/{appointment_id}/status")
async def update_appointment_status(appointment_id: str, is_finished: bool):
    """Update appointment status"""
    try:
        success = await appointment_service.update_appointment_status(
            appointment_id, is_finished
        )
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Appointment not found"
            )
        return {"success": True, "message": "Appointment status updated"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update appointment: {str(e)}",
        )


@router.get("/case/{case_id}")
async def get_case(case_id: str):
    """Get case details"""
    try:
        case = await case_service.get_case(case_id)
        if not case:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Case not found"
            )
        return case
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get case: {str(e)}",
        )


@router.get("/user/{user_email}/cases")
async def get_user_cases(user_email: str):
    """Get all cases for a user"""
    try:
        cases = await case_service.get_cases_by_user(user_email)
        return {"cases": cases}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get cases: {str(e)}",
        )


@router.get("/lawyer/{lawyer_email}/cases")
async def get_lawyer_cases(lawyer_email: str):
    """Get all cases for a lawyer"""
    try:
        cases = await case_service.get_cases_by_lawyer(lawyer_email)
        return {"cases": cases}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get cases: {str(e)}",
        )


@router.put("/{case_id}/status")
async def update_case_status(case_id: str, case_status: str):
    """Update case status"""
    try:
        success = await case_service.update_case_status(case_id, case_status)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Case not found"
            )
        return {"success": True, "message": "Case status updated"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update case: {str(e)}",
        )
