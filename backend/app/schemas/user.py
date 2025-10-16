
#user.py
from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr
    full_name: str


class UserRegister(UserBase):
    password: str = Field(..., min_length=6)
    role: str = Field(..., pattern="^(user|lawyer)$")

    # User-specific fields
    phone: Optional[str] = None
    location: Optional[str] = None

    # Lawyer-specific extra fields
    education: Optional[str] = None
    achievements: Optional[str] = None

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

    # User-specific fields
    phone: Optional[str] = None
    location: Optional[str] = None

    # Lawyer-specific fields
    license_id: Optional[str] = None
    specialization: Optional[str] = None
    years_of_experience: Optional[int] = None
    bio: Optional[str] = None
    education: Optional[str] = None
    achievements: Optional[str] = None
    rating: Optional[float] = None
    total_cases: Optional[int] = None

    class Config:
        from_attributes = True


class PasswordResetRequest(BaseModel):
    """Request password reset - sends verification code"""
    email: EmailStr


class PasswordReset(BaseModel):
    """Reset password with verification code"""
    email: EmailStr
    code: str = Field(..., min_length=6, max_length=6)
    new_password: str = Field(..., min_length=6)

    @field_validator('code')
    @classmethod
    def validate_code(cls, v):
        if not v.isdigit():
            raise ValueError('Code must contain only digits')
        return v


class PasswordChange(BaseModel):
    old_password: str
    new_password: str = Field(..., min_length=6)