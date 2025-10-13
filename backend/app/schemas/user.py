from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    full_name: str

class UserRegister(UserBase):
    password: str = Field(..., min_length=6)
    role: str = Field(..., pattern="^(user|lawyer)$")
    
    # Lawyer-specific fields
    license_id: Optional[str] = None
    specialization: Optional[str] = None
    years_of_experience: Optional[int] = None
    bio: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(UserBase):
    id: str
    role: str
    is_active: bool
    is_verified: bool
    is_approved: bool
    created_at: datetime
    
    # Lawyer-specific fields
    license_id: Optional[str] = None
    specialization: Optional[str] = None
    years_of_experience: Optional[int] = None
    bio: Optional[str] = None
    rating: Optional[float] = None
    total_cases: Optional[int] = None

    class Config:
        from_attributes = True

class PasswordResetRequest(BaseModel):
    email: EmailStr

class PasswordReset(BaseModel):
    token: str
    new_password: str = Field(..., min_length=6)

class PasswordChange(BaseModel):
    old_password: str
    new_password: str = Field(..., min_length=6)