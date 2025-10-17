from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime
from decimal import Decimal


class TransactionIn(BaseModel):
    appointment_id: str
    user_paid_amount: float = Field(..., gt=0, description="Total amount paid by user")
    transaction_id: Optional[str] = None  # SSLCommerz transaction ID
    payment_method: Optional[str] = None  # e.g., "card", "mobile_banking", "bKash", "Nagad"

    @field_validator("user_paid_amount")
    @classmethod
    def validate_amount(cls, v):
        """Ensure amount is positive"""
        if v <= 0:
            raise ValueError("Amount must be greater than 0")
        return round(v, 2)


class TransactionOut(BaseModel):
    transaction_id: str
    appointment_id: str
    lawyer_received_amount: float
    user_paid_amount: float
    platform_fee: float
    transaction_date: datetime
    transaction_type: Optional[str] = None
    payment_method: Optional[str] = None
    ssl_transaction_id: Optional[str] = None  # Original SSLCommerz transaction ID

    class Config:
        from_attributes = True


class TransactionCalculation(BaseModel):
    """Helper model for transaction calculation breakdown"""
    user_paid_amount: float
    platform_fee: float
    platform_fee_percentage: float
    lawyer_received_amount: float