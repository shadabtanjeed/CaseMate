from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class AppointmentIn(BaseModel):
    lawyer_email: str
    user_email: str
    date: str  # Format: YYYY-MM-DD
    start_time: str  # Format: HH:MM
    end_time: str  # Format: HH:MM
    case_type: str
    description: str
    consultation_type: str  # 'chat', 'video', 'voice'


class AppointmentOut(BaseModel):
    appointment_id: str
    lawyer_email: str
    user_email: str
    date: str
    start_time: str
    end_time: str
    is_finished: bool
    case_type: str
    description: str
    consultation_type: str
    created_at: Optional[datetime]

    class Config:
        from_attributes = True


class CaseIn(BaseModel):
    appointment_id: str
    lawyer_email: str
    user_email: str
    case_type: str
    description: str


class CaseOut(BaseModel):
    case_id: str
    appointment_id: str
    creation_date: datetime
    lawyer_email: str
    user_email: str
    status: str  # 'ongoing', 'completed'
    last_updated: datetime
    case_type: str
    description: str

    class Config:
        from_attributes = True
