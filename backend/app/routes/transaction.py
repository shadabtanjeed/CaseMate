from fastapi import APIRouter, Depends, HTTPException, status
from typing import List

from ..schemas.transaction import TransactionIn, TransactionOut, TransactionCalculation
from ..services.transaction_service import TransactionService
from ..database import get_database

router = APIRouter(prefix="/transactions", tags=["Transactions"])


def get_transaction_service(db=Depends(get_database)) -> TransactionService:
    """Dependency to get transaction service"""
    return TransactionService(db)


@router.post("/", response_model=TransactionOut, status_code=status.HTTP_201_CREATED)
async def create_transaction(
        transaction: TransactionIn,
        service: TransactionService = Depends(get_transaction_service),
):
    """
    Create a new transaction after successful payment

    - Calculates 20% platform fee
    - Remaining 80% goes to lawyer
    - Links to appointment
    """
    try:
        return service.create_transaction(transaction)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating transaction: {str(e)}")


@router.post("/calculate", response_model=TransactionCalculation)
async def calculate_transaction(
        user_paid_amount: float,
        service: TransactionService = Depends(get_transaction_service),
):
    """
    Calculate transaction breakdown without creating a transaction

    Useful for showing users the breakdown before payment
    """
    try:
        if user_paid_amount <= 0:
            raise HTTPException(status_code=400, detail="Amount must be greater than 0")

        return service.calculate_transaction_breakdown(user_paid_amount)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error calculating: {str(e)}")


@router.get("/{transaction_id}", response_model=TransactionOut)
async def get_transaction(
        transaction_id: str,
        service: TransactionService = Depends(get_transaction_service),
):
    """Get a specific transaction by ID"""
    transaction = service.get_transaction_by_id(transaction_id)

    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")

    return transaction


@router.get("/appointment/{appointment_id}", response_model=TransactionOut)
async def get_transaction_by_appointment(
        appointment_id: str,
        service: TransactionService = Depends(get_transaction_service),
):
    """Get transaction for a specific appointment"""
    transaction = service.get_transaction_by_appointment(appointment_id)

    if not transaction:
        raise HTTPException(
            status_code=404,
            detail=f"No transaction found for appointment: {appointment_id}"
        )

    return transaction


@router.get("/lawyer/{lawyer_email}", response_model=List[TransactionOut])
async def get_lawyer_transactions(
        lawyer_email: str,
        limit: int = 50,
        service: TransactionService = Depends(get_transaction_service),
):
    """Get all transactions for a lawyer"""
    return service.get_transactions_by_lawyer(lawyer_email, limit)


@router.get("/user/{user_email}", response_model=List[TransactionOut])
async def get_user_transactions(
        user_email: str,
        limit: int = 50,
        service: TransactionService = Depends(get_transaction_service),
):
    """Get all transactions for a user"""
    return service.get_transactions_by_user(user_email, limit)


@router.get("/lawyer/{lawyer_email}/earnings", response_model=dict)
async def get_lawyer_earnings(
        lawyer_email: str,
        service: TransactionService = Depends(get_transaction_service),
):
    """
    Get earnings summary for a lawyer

    Returns:
    - total_earned: Total amount earned (after platform fee)
    - total_transactions: Number of transactions
    - platform_fee_paid: Total platform fees paid
    """
    return service.get_lawyer_earnings_summary(lawyer_email)


@router.get("/", response_model=List[TransactionOut])
async def get_all_transactions(
        limit: int = 100,
        service: TransactionService = Depends(get_transaction_service),
):
    """Get all transactions (admin use)"""
    return service.get_all_transactions(limit)