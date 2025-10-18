from datetime import datetime
from typing import List, Optional
from bson import ObjectId
from pymongo.database import Database

from ..models.transaction import Transaction
from ..schemas.transaction import TransactionIn, TransactionOut, TransactionCalculation


class TransactionService:
    def __init__(self, db: Database):
        self.db = db
        self.collection = db["transactions"]
        self.wallets_collection = db["wallets"]

    def calculate_transaction_breakdown(self, user_paid_amount: float) -> TransactionCalculation:
        """Calculate transaction breakdown without creating a transaction"""
        platform_fee = round(user_paid_amount * Transaction.PLATFORM_FEE_PERCENTAGE, 2)
        lawyer_received_amount = round(user_paid_amount - platform_fee, 2)

        return TransactionCalculation(
            user_paid_amount=user_paid_amount,
            platform_fee=platform_fee,
            platform_fee_percentage=Transaction.PLATFORM_FEE_PERCENTAGE * 100,
            lawyer_received_amount=lawyer_received_amount,
        )

    def create_transaction(self, transaction_data: TransactionIn) -> TransactionOut:
        """Create a new transaction and credit lawyer wallet"""

        # Verify appointment exists
        appointment = self.db["appointments"].find_one(
            {"appointment_id": transaction_data.appointment_id}
        )

        if not appointment:
            raise ValueError(f"Appointment not found: {transaction_data.appointment_id}")

        # Check if transaction already exists for this appointment
        existing = self.collection.find_one(
            {"appointment_id": transaction_data.appointment_id}
        )

        if existing:
            raise ValueError(
                f"Transaction already exists for appointment: {transaction_data.appointment_id}"
            )

        # Create transaction object
        transaction = Transaction(
            appointment_id=transaction_data.appointment_id,
            user_paid_amount=transaction_data.user_paid_amount,
            transaction_type=transaction_data.payment_method,
            payment_method=transaction_data.payment_method,
            ssl_transaction_id=transaction_data.transaction_id,
        )

        # Insert into database
        result = self.collection.insert_one(transaction.to_dict())

        # Credit lawyer wallet
        lawyer_email = appointment.get("lawyer_email")
        if lawyer_email:
            self._credit_lawyer_wallet(lawyer_email, transaction.lawyer_received_amount)

        # Credit platform wallet
        self._credit_platform_wallet(transaction.platform_fee)

        # Retrieve and return
        created_transaction = self.collection.find_one({"_id": result.inserted_id})

        return self._to_transaction_out(created_transaction)

    def _credit_lawyer_wallet(self, lawyer_email: str, amount: float):
        """Credit amount to lawyer's wallet"""
        wallet = self.wallets_collection.find_one({"email": lawyer_email})

        if not wallet:
            # Create wallet if doesn't exist
            wallet = {
                "email": lawyer_email,
                "role": "lawyer",
                "current_balance": amount,
                "total_earned": amount,
                "total_withdrawn": 0.0,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow(),
            }
            self.wallets_collection.insert_one(wallet)
        else:
            # Update existing wallet
            self.wallets_collection.update_one(
                {"email": lawyer_email},
                {
                    "$inc": {
                        "current_balance": amount,
                        "total_earned": amount,
                    },
                    "$set": {"updated_at": datetime.utcnow()},
                },
            )

    def _credit_platform_wallet(self, amount: float):
        """Credit platform fee to platform wallet"""
        platform_wallet = self.wallets_collection.find_one({"email": "platform@system"})

        if not platform_wallet:
            # Create platform wallet if doesn't exist
            platform_wallet = {
                "email": "platform@system",
                "role": "platform",
                "current_balance": amount,
                "total_earned": amount,
                "total_withdrawn": 0.0,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow(),
            }
            self.wallets_collection.insert_one(platform_wallet)
        else:
            # Update existing platform wallet
            self.wallets_collection.update_one(
                {"email": "platform@system"},
                {
                    "$inc": {
                        "current_balance": amount,
                        "total_earned": amount,
                    },
                    "$set": {"updated_at": datetime.utcnow()},
                },
            )

    def get_transaction_by_id(self, transaction_id: str) -> Optional[TransactionOut]:
        """Get transaction by ID"""
        try:
            transaction = self.collection.find_one({"_id": ObjectId(transaction_id)})
            if transaction:
                return self._to_transaction_out(transaction)
            return None
        except Exception:
            return None

    def get_transaction_by_appointment(self, appointment_id: str) -> Optional[TransactionOut]:
        """Get transaction by appointment ID"""
        transaction = self.collection.find_one({"appointment_id": appointment_id})
        if transaction:
            return self._to_transaction_out(transaction)
        return None

    def get_transactions_by_lawyer(
            self,
            lawyer_email: str,
            limit: int = 50
    ) -> List[TransactionOut]:
        """Get all transactions for a lawyer (via appointments)"""
        # First get all appointments for this lawyer
        appointments = list(
            self.db["appointments"].find(
                {"lawyer_email": lawyer_email}
            ).limit(limit)
        )

        appointment_ids = [apt["appointment_id"] for apt in appointments]

        if not appointment_ids:
            return []

        # Get transactions for these appointments
        transactions = list(
            self.collection.find(
                {"appointment_id": {"$in": appointment_ids}}
            ).sort("transaction_date", -1)
        )

        return [self._to_transaction_out(t) for t in transactions]

    def get_transactions_by_user(
            self,
            user_email: str,
            limit: int = 50
    ) -> List[TransactionOut]:
        """Get all transactions for a user (via appointments)"""
        # First get all appointments for this user
        appointments = list(
            self.db["appointments"].find(
                {"user_email": user_email}
            ).limit(limit)
        )

        appointment_ids = [apt["appointment_id"] for apt in appointments]

        if not appointment_ids:
            return []

        # Get transactions for these appointments
        transactions = list(
            self.collection.find(
                {"appointment_id": {"$in": appointment_ids}}
            ).sort("transaction_date", -1)
        )

        return [self._to_transaction_out(t) for t in transactions]

    def get_all_transactions(self, limit: int = 100) -> List[TransactionOut]:
        """Get all transactions (admin use)"""
        transactions = list(
            self.collection.find().sort("transaction_date", -1).limit(limit)
        )
        return [self._to_transaction_out(t) for t in transactions]

    def get_lawyer_earnings_summary(self, lawyer_email: str) -> dict:
        """Get earnings summary for a lawyer"""
        transactions = self.get_transactions_by_lawyer(lawyer_email, limit=1000)

        total_earned = sum(t.lawyer_received_amount for t in transactions)
        total_transactions = len(transactions)

        return {
            "lawyer_email": lawyer_email,
            "total_earned": round(total_earned, 2),
            "total_transactions": total_transactions,
            "platform_fee_paid": round(
                sum(t.platform_fee for t in transactions), 2
            ),
        }

    def _to_transaction_out(self, transaction_doc: dict) -> TransactionOut:
        """Convert MongoDB document to TransactionOut schema"""
        return TransactionOut(
            transaction_id=str(transaction_doc["_id"]),
            appointment_id=transaction_doc["appointment_id"],
            user_paid_amount=transaction_doc["user_paid_amount"],
            platform_fee=transaction_doc["platform_fee"],
            lawyer_received_amount=transaction_doc["lawyer_received_amount"],
            transaction_date=transaction_doc["transaction_date"],
            transaction_type=transaction_doc.get("transaction_type"),
            payment_method=transaction_doc.get("payment_method"),
            ssl_transaction_id=transaction_doc.get("ssl_transaction_id"),
        )