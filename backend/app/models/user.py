
#models/user.py
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field
from bson import ObjectId


class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v, info=None):
        # Accept the extra 'info' arg pydantic v2 may provide.
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        # Return string form to make models simpler to work with across the codebase
        return str(ObjectId(v))

    @classmethod
    def __get_pydantic_json_schema__(cls, core_schema, handler):
        return {"type": "string"}


class UserInDB(BaseModel):
    # Store Mongo IDs as strings for simplicity when creating Pydantic models
    id: Optional[str] = Field(default=None, alias="_id")
    email: str
    hashed_password: str
    full_name: str
    role: str  # "user" or "lawyer"
    is_active: bool = True
    is_verified: bool = True  # Auto-verified for now
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    profile_image_url: Optional[str] = None
    # User-specific fields
    phone: Optional[str] = None
    location: Optional[str] = None
    education: Optional[str] = None
    achievements: Optional[str] = None

    # Lawyer-specific fields (optional)
    license_id: Optional[str] = None
    specialization: Optional[str] = None
    years_of_experience: Optional[int] = None
    bio: Optional[str] = None
    consultation_fee: Optional[float] = None
    rating: Optional[float] = None
    total_cases: Optional[int] = 0

    # For future admin approval
    is_approved: bool = True  # Auto-approved for now, can be changed

    class Config:
        populate_by_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
