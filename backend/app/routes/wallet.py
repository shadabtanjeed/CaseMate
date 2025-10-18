from fastapi import APIRouter, Depends, HTTPException, status
from typing import List

from ..schemas.wallet import (
    WalletOut,
    WithdrawalRequestIn,
    WithdrawalOut,
)
from ..services.wallet_service import WalletService
from ..database import get_database

# Remove /api prefix - it's added in main.py
router = APIRouter(prefix="/wallet", tags=["Wallet & Withdrawals"])


def get_wallet_service(db=Depends(get_database)) -> WalletService:
    """Dependency to get wallet service"""
    return WalletService(db)


@router.get("/{email}", response_model=WalletOut)
async def get_wallet(
        email: str,
        service: WalletService = Depends(get_wallet_service),
):
    """
    Get wallet balance for a lawyer or platform

    Returns current balance, total earned, and total withdrawn
    """
    wallet = service.get_or_create_wallet(email)
    return wallet


@router.post("/withdraw", response_model=WithdrawalOut, status_code=status.HTTP_201_CREATED)
async def request_withdrawal(
        withdrawal: WithdrawalRequestIn,
        service: WalletService = Depends(get_wallet_service),
):
    """
    Request a withdrawal from wallet

    - Checks if sufficient balance exists
    - Creates a pending withdrawal request
    - Requires admin approval before funds are deducted
    """
    try:
        return service.request_withdrawal(withdrawal)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error requesting withdrawal: {str(e)}")


@router.get("/withdrawals/{email}", response_model=List[WithdrawalOut])
async def get_user_withdrawals(
        email: str,
        service: WalletService = Depends(get_wallet_service),
):
    """Get all withdrawal requests for a user"""
    return service.get_user_withdrawals(email)