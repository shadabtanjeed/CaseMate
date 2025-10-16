
#auth_service.py
import string
from datetime import datetime, timedelta
from typing import Optional, Tuple
from bson import ObjectId
import random

from .email_service import email_service
from ..db_async import find_one, insert_one, update_one, delete_many
from pymongo.errors import DuplicateKeyError, PyMongoError
import logging
from ..models.user import UserInDB
from ..schemas.user import UserRegister
from ..utils.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    create_refresh_token,
    verify_token,
    create_password_reset_token,
    verify_password_reset_token,
)
from argon2 import PasswordHasher
from fastapi import HTTPException, status


class AuthService:
    _ph = PasswordHasher()
    @staticmethod
    async def register_user(user_data: UserRegister) -> UserInDB:
        # Check if email already exists in either collection
        existing_user = await find_one("users", {"email": user_data.email})
        if not existing_user:
            existing_user = await find_one("lawyers", {"email": user_data.email})
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered",
            )

        # Validate lawyer fields
        if user_data.role == "lawyer":
            if not user_data.license_id or not user_data.specialization:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="License ID and Specialization required for lawyers",
                )

        # Create user document
        user_dict = {
            "email": user_data.email,
            "hashed_password": AuthService._ph.hash(user_data.password),
            "full_name": user_data.full_name,
            "role": user_data.role,
            "is_active": True,
            "is_verified": True,
            "is_approved": True,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
            "phone": user_data.phone,  # Save phone number
            "location": user_data.location,  # Save location
            "education": getattr(user_data, 'education', None),
            "achievements": getattr(user_data, 'achievements', None),
        }

        # Add lawyer-specific fields
        if user_data.role == "lawyer":
            user_dict.update(
                {
                    "license_id": user_data.license_id,
                    "specialization": user_data.specialization,
                    "years_of_experience": user_data.years_of_experience or 0,
                    "bio": user_data.bio or "",
                    "rating": 0.0,
                    "total_cases": 0,
                }
            )

        try:
            collection_name = "lawyers" if user_data.role == "lawyer" else "users"
            result = await insert_one(collection_name, user_dict)
            # convert ObjectId to string for Pydantic model
            try:
                user_dict["_id"] = str(result.inserted_id)
            except Exception:
                user_dict["_id"] = result.inserted_id
            return UserInDB(**user_dict)
        except DuplicateKeyError:
            # Email already exists (unique index) — return a clear 400
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered",
            )
        except PyMongoError as e:
            logging.exception("Database error during user registration")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Database error during registration",
            )

    @staticmethod
    async def authenticate_user(email: str, password: str) -> Optional[UserInDB]:
        # Search both collections (users and lawyers)
        user = await find_one("users", {"email": email})
        if not user:
            user = await find_one("lawyers", {"email": email})

        if not user:
            return None

        if not verify_password(password, user["hashed_password"]):
            return None

        # Ensure _id is string for Pydantic compatibility
        user["_id"] = str(user["_id"])
        return UserInDB(**user)

    @staticmethod
    async def create_tokens(user_id: str) -> Tuple[str, str]:
        access_token = create_access_token(data={"sub": user_id})
        refresh_token = create_refresh_token(data={"sub": user_id})
        return access_token, refresh_token

    @staticmethod
    async def refresh_access_token(refresh_token: str) -> str:
        user_id = verify_token(refresh_token, "refresh")

        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token"
            )

        user = await find_one("users", {"_id": ObjectId(user_id)})
        if not user:
            user = await find_one("lawyers", {"_id": ObjectId(user_id)})

        if not user or not user.get("is_active"):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found or inactive",
            )

        new_access_token = create_access_token(data={"sub": user_id})
        return new_access_token


    @staticmethod
    async def change_password(user_id: str, old_password: str, new_password: str) -> bool:
        # Find user in either collection
        user = await find_one("users", {"_id": ObjectId(user_id)})
        collection = "users"
        if not user:
            user = await find_one("lawyers", {"_id": ObjectId(user_id)})
            collection = "lawyers"

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
            )

        if not verify_password(old_password, user["hashed_password"]):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, detail="Incorrect password"
            )

        hashed_password = AuthService._ph.hash(new_password)
        await update_one(
            collection,
            {"_id": user["_id"]},
            {"$set": {"hashed_password": hashed_password, "updated_at": datetime.utcnow()}},
        )

        return True

    @staticmethod
    def _generate_verification_code() -> str:
        """Generate a 6-digit verification code"""
        return ''.join(random.choices(string.digits, k=6))

    @staticmethod
    async def request_password_reset(email: str) -> bool:
        """Request password reset and send verification code via email"""
        # Search both collections
        user = await find_one("users", {"email": email})
        if not user:
            user = await find_one("lawyers", {"email": email})

        if not user:
            # Don't reveal if email exists or not for security
            return True

        # Generate 6-digit code
        verification_code = AuthService._generate_verification_code()

        # Store in password_reset_codes collection
        reset_data = {
            "email": email,
            "code": verification_code,
            "created_at": datetime.utcnow(),
            "expires_at": datetime.utcnow() + timedelta(minutes=15),  # 15 min expiry
            "used": False
        }

        try:
            # Delete any existing unused codes for this email
            await delete_many("password_reset_codes", {"email": email, "used": False})

            # Insert new code
            await insert_one("password_reset_codes", reset_data)

            # Send email with verification code
            await email_service.send_password_reset_code(email, verification_code)

            return True
        except Exception as e:
            logging.exception(f"Error creating password reset code: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to process password reset request"
            )

    @staticmethod
    async def verify_and_reset_password(email: str, code: str, new_password: str) -> bool:
        """Verify code and reset password"""
        # Find valid reset code
        reset_code = await find_one(
            "password_reset_codes",
            {
                "email": email,
                "code": code,
                "used": False,
                "expires_at": {"$gt": datetime.utcnow()}
            }
        )

        if not reset_code:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired verification code"
            )

        # Find user in either collection
        user = await find_one("users", {"email": email})
        collection = "users"
        if not user:
            user = await find_one("lawyers", {"email": email})
            collection = "lawyers"

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Update password
        hashed_password = AuthService._ph.hash(new_password)
        await update_one(
            collection,
            {"_id": user["_id"]},
            {
                "$set": {
                    "hashed_password": hashed_password,
                    "updated_at": datetime.utcnow()
                }
            }
        )

        # Mark code as used
        await update_one(
            "password_reset_codes",
            {"_id": reset_code["_id"]},
            {"$set": {"used": True}}
        )

        return True


auth_service = AuthService()