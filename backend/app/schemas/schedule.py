from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional


class TimeSlot(BaseModel):
    start: str  # Format: "HH:MM" (24-hour)
    end: str  # Format: "HH:MM" (24-hour)


class WeekdaySchedule(BaseModel):
    weekday: str  # Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    slots: List[TimeSlot] = []


class LawyerScheduleIn(BaseModel):
    email: str
    weekly_schedule: List[WeekdaySchedule] = []  # Recurring weekly pattern


class LawyerScheduleOut(LawyerScheduleIn):
    id: Optional[str] = Field(default=None, alias="_id")
