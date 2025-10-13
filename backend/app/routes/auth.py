from fastapi import APIRouter, Depends, HTTPException, status
from ..schemas.user import (
    UserRegister, UserLogin, UserResponse,
    PasswordResetRequest, PasswordReset, PasswordChange
)
from ..schemas.token import Token, RefreshTokenRequest
from ..services.auth_service import auth_service
from ..services.email_service import email_service
from ..utils.dependencies import get_current_active_user
from ..models.user import UserInDB

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserRegister):
    """Register a new user or lawyer"""
    user = await auth_service.register_user(user_data)
    return UserResponse(
        id=str(user.id),
        email=user.email,
        full_name=user.full_name,
        role=user.role,
        is_active=user.is_active,
        is_verified=user.is_verified,
        is_approved=user.is_approved,
        created_at=user.created_at,
        license_id=user.license_id,
        specialization=user.specialization,
        years_of_experience=user.years_of_experience,
        bio=user.bio,
        rating=user.rating,
        total_cases=user.total_cases,
    )

@router.post("/login", response_model=Token)
async def login(credentials: UserLogin):
    """Login and get access/refresh tokens"""
    user = await auth_service.authenticate_user(credentials.email, credentials.password)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Account is inactive",
        )
    
    access_token, refresh_token = await auth_service.create_tokens(str(user.id))
    
    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
    )

@router.post("/refresh", response_model=dict)
async def refresh_token(token_data: RefreshTokenRequest):
    """Get new access token using refresh token"""
    new_access_token = await auth_service.refresh_access_token(token_data.refresh_token)
    return {"access_token": new_access_token}

@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: UserInDB = Depends(get_current_active_user)):
    """Get current user information"""
    return UserResponse(
        id=str(current_user.id),
        email=current_user.email,
        full_name=current_user.full_name,
        role=current_user.role,
        is_active=current_user.is_active,
        is_verified=current_user.is_verified,
        is_approved=current_user.is_approved,
        created_at=current_user.created_at,
        license_id=current_user.license_id,
        specialization=current_user.specialization,
        years_of_experience=current_user.years_of_experience,
        bio=current_user.bio,
        rating=current_user.rating,
        total_cases=current_user.total_cases,
    )

@router.post("/password-reset/request")
async def request_password_reset(reset_request: PasswordResetRequest):
    """Request password reset email"""
    reset_token = await auth_service.request_password_reset(reset_request.email)
    
    # Send email (currently just logs)
    await email_service.send_password_reset_email(reset_request.email, reset_token)
    
    return {
        "message": "If the email exists, a password reset link has been sent",
        "reset_token": reset_token  # Remove in production!
    }

@router.post("/password-reset/confirm")
async def reset_password(reset_data: PasswordReset):
    """Reset password using token"""
    await auth_service.reset_password(reset_data.token, reset_data.new_password)
    return {"message": "Password reset successful"}

@router.post("/password/change")
async def change_password(
    password_data: PasswordChange,
    current_user: UserInDB = Depends(get_current_active_user)
):
    """Change password for authenticated user"""
    await auth_service.change_password(
        str(current_user.id),
        password_data.old_password,
        password_data.new_password
    )
    return {"message": "Password changed successfully"}