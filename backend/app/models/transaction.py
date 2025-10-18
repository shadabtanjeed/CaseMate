from datetime import datetime
from typing import Optional


class Transaction:
    """Transaction model for MongoDB"""

    PLATFORM_FEE_PERCENTAGE = 0.20  # 20% platform fee

    def __init__(
            self,
            appointment_id: str,
            user_paid_amount: float,
            transaction_type: Optional[str] = None,
            payment_method: Optional[str] = None,
            ssl_transaction_id: Optional[str] = None,
            transaction_date: Optional[datetime] = None,
            transaction_id: Optional[str] = None,
    ):
        self.transaction_id = transaction_id
        self.appointment_id = appointment_id
        self.user_paid_amount = round(user_paid_amount, 2)

        # Calculate platform fee and lawyer amount
        self.platform_fee = round(user_paid_amount * self.PLATFORM_FEE_PERCENTAGE, 2)
        self.lawyer_received_amount = round(user_paid_amount - self.platform_fee, 2)

        self.transaction_date = transaction_date or datetime.utcnow()
        self.transaction_type = transaction_type
        self.payment_method = payment_method
        self.ssl_transaction_id = ssl_transaction_id

    def to_dict(self) -> dict:
        """Convert to dictionary for MongoDB insertion"""
        data = {
            "appointment_id": self.appointment_id,
            "user_paid_amount": self.user_paid_amount,
            "platform_fee": self.platform_fee,
            "lawyer_received_amount": self.lawyer_received_amount,
            "transaction_date": self.transaction_date,
        }

        if self.transaction_id:
            data["transaction_id"] = self.transaction_id

        if self.transaction_type:
            data["transaction_type"] = self.transaction_type

        if self.payment_method:
            data["payment_method"] = self.payment_method

        if self.ssl_transaction_id:
            data["ssl_transaction_id"] = self.ssl_transaction_id

        return data

    @staticmethod
    def from_dict(data: dict) -> "Transaction":
        """Create Transaction object from MongoDB document"""
        return Transaction(
            transaction_id=str(data.get("_id", "")),
            appointment_id=data.get("appointment_id"),
            user_paid_amount=data.get("user_paid_amount"),
            transaction_type=data.get("transaction_type"),
            payment_method=data.get("payment_method"),
            ssl_transaction_id=data.get("ssl_transaction_id"),
            transaction_date=data.get("transaction_date"),
        )