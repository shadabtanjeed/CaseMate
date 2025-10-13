from datetime import datetime
from typing import Optional, Tuple
from bson import ObjectId
from ..db_async import find_one, insert_one, update_one
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
        # Check if user exists
        existing_user = await find_one("users", {"email": user_data.email})
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
            result = await insert_one("users", user_dict)
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
        user = await find_one("users", {"email": email})

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

        if not user or not user.get("is_active"):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found or inactive",
            )

        new_access_token = create_access_token(data={"sub": user_id})
        return new_access_token

    @staticmethod
    async def request_password_reset(email: str) -> str:
        user = await find_one("users", {"email": email})

        # Always return success even if user doesn't exist (security)
        if not user:
            return create_password_reset_token(email)

        reset_token = create_password_reset_token(email)
        return reset_token

    @staticmethod
    async def reset_password(token: str, new_password: str) -> bool:
        email = verify_password_reset_token(token)

        if email is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired reset token",
            )

        user = await find_one("users", {"email": email})

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
            )

        hashed_password = AuthService._ph.hash(new_password)
        await update_one(
            "users",
            {"_id": user["_id"]},
            {"$set": {"hashed_password": hashed_password, "updated_at": datetime.utcnow()}},
        )

        return True

    @staticmethod
    async def change_password(user_id: str, old_password: str, new_password: str) -> bool:
        user = await find_one("users", {"_id": ObjectId(user_id)})

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
            "users",
            {"_id": user["_id"]},
            {"$set": {"hashed_password": hashed_password, "updated_at": datetime.utcnow()}},
        )

        return True


auth_service = AuthService()