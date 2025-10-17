from pydantic import BaseModel, field_validator
from typing import Optional
from datetime import datetime


class AppointmentIn(BaseModel):
    lawyer_email: str
    user_email: str
    date: str  # Format: "DD MMM YYYY" (e.g., "22 Oct 2025")
    start_time: str  # Format: HH:MM
    end_time: str  # Format: HH:MM
    case_type: str
    description: str
    consultation_type: str  # 'chat', 'video', 'voice'

    @field_validator("date", mode="before")
    @classmethod
    def validate_date(cls, v):
        """Validate and return date string (parsing happens in service)"""
        if isinstance(v, str):
            try:
                # Validate "22 Oct 2025" format
                datetime.strptime(v, "%d %b %Y")
                return v
            except ValueError:
                # Try ISO format as fallback
                try:
                    datetime.strptime(v, "%Y-%m-%d")
                    return v
                except ValueError:
                    raise ValueError(
                        f"Invalid date format: {v}. Expected 'DD MMM YYYY' or 'YYYY-MM-DD'"
                    )
        raise ValueError("Date must be a string")


class AppointmentOut(BaseModel):
    appointment_id: str
    lawyer_email: str
    user_email: str
    date: datetime  # Stored as ISODate in MongoDB (datetime compatible)
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
