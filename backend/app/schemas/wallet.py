from pydantic import BaseModel, Field
from typing import Optional, Literal
from datetime import datetime


class WalletOut(BaseModel):
    """Wallet balance information"""
    email: str
    role: Literal["lawyer", "platform"]
    current_balance: float = Field(default=0.0)
    total_earned: float = Field(default=0.0)
    total_withdrawn: float = Field(default=0.0)
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class WithdrawalRequestIn(BaseModel):
    """Request to withdraw money"""
    email: str
    amount: float = Field(..., gt=0, description="Amount to withdraw")
    bank_account: str
    bank_name: str
    account_holder_name: str
    notes: Optional[str] = None


class WithdrawalOut(BaseModel):
    """Withdrawal record"""
    withdrawal_id: str
    email: str
    amount: float
    status: Literal["pending", "approved", "rejected", "completed"]
    bank_account: str
    bank_name: str
    account_holder_name: str
    notes: Optional[str] = None
    requested_at: datetime
    processed_at: Optional[datetime] = None
    processed_by: Optional[str] = None  # Admin email

    class Config:
        from_attributes = True


class WithdrawalApprovalIn(BaseModel):
    """Admin approval/rejection of withdrawal"""
    status: Literal["approved", "rejected"]
    admin_email: str
    notes: Optional[str] = None