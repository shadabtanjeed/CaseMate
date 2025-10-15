from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from ..utils.security import verify_token
from ..models.user import UserInDB
from bson import ObjectId
from ..db_async import find_one

security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> UserInDB:
    token = credentials.credentials
    user_id = verify_token(token, "access")

    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
        )

    # Try users then lawyers collection
    user = await find_one("users", {"_id": ObjectId(user_id)})
    if not user:
        user = await find_one("lawyers", {"_id": ObjectId(user_id)})

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Ensure _id is string for Pydantic compatibility
    user["_id"] = str(user["_id"])
    return UserInDB(**user)

async def get_current_active_user(
    current_user: UserInDB = Depends(get_current_user)
) -> UserInDB:
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user",
        )
    return current_user

async def get_current_lawyer(
    current_user: UserInDB = Depends(get_current_active_user)
) -> UserInDB:
    if current_user.role != "lawyer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized. Lawyer access required.",
        )
    if not current_user.is_approved:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your lawyer account is pending approval",
        )
    return current_user