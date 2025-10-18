from datetime import datetime
from typing import List, Optional
from bson import ObjectId
from pymongo.database import Database

from ..schemas.wallet import (
    WalletOut,
    WithdrawalRequestIn,
    WithdrawalOut,
    WithdrawalApprovalIn,
)


class WalletService:
    def __init__(self, db: Database):
        self.db = db
        self.wallets_collection = db["wallets"]
        self.withdrawals_collection = db["withdrawals"]
        self.transactions_collection = db["transactions"]

    def get_or_create_wallet(self, email: str, role: str = "lawyer") -> WalletOut:
        """Get wallet or create if doesn't exist"""
        wallet = self.wallets_collection.find_one({"email": email})

        if not wallet:
            wallet = {
                "email": email,
                "role": role,
                "current_balance": 0.0,
                "total_earned": 0.0,
                "total_withdrawn": 0.0,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow(),
            }
            self.wallets_collection.insert_one(wallet)

        return self._to_wallet_out(wallet)

    def get_wallet(self, email: str) -> Optional[WalletOut]:
        """Get wallet by email"""
        wallet = self.wallets_collection.find_one({"email": email})
        if wallet:
            return self._to_wallet_out(wallet)
        return None

    def request_withdrawal(self, withdrawal_request: WithdrawalRequestIn) -> WithdrawalOut:
        """Request a withdrawal"""
        wallet = self.get_or_create_wallet(withdrawal_request.email)

        if wallet.current_balance < withdrawal_request.amount:
            raise ValueError(
                f"Insufficient balance. Available: {wallet.current_balance}, "
                f"Requested: {withdrawal_request.amount}"
            )

        # Check for pending withdrawals
        pending = self.withdrawals_collection.find_one({
            "email": withdrawal_request.email,
            "status": "pending"
        })

        if pending:
            raise ValueError("You already have a pending withdrawal request")

        # Create withdrawal request
        withdrawal = {
            "email": withdrawal_request.email,
            "amount": withdrawal_request.amount,
            "status": "pending",
            "bank_account": withdrawal_request.bank_account,
            "bank_name": withdrawal_request.bank_name,
            "account_holder_name": withdrawal_request.account_holder_name,
            "notes": withdrawal_request.notes,
            "requested_at": datetime.utcnow(),
            "processed_at": None,
            "processed_by": None,
        }

        result = self.withdrawals_collection.insert_one(withdrawal)
        created_withdrawal = self.withdrawals_collection.find_one({"_id": result.inserted_id})

        return self._to_withdrawal_out(created_withdrawal)

    def get_user_withdrawals(self, email: str) -> List[WithdrawalOut]:
        """Get all withdrawals for a user"""
        withdrawals = list(
            self.withdrawals_collection.find({"email": email}).sort("requested_at", -1)
        )
        return [self._to_withdrawal_out(w) for w in withdrawals]

    def _to_wallet_out(self, wallet_doc: dict) -> WalletOut:
        """Convert MongoDB document to WalletOut schema"""
        return WalletOut(
            email=wallet_doc["email"],
            role=wallet_doc["role"],
            current_balance=wallet_doc["current_balance"],
            total_earned=wallet_doc["total_earned"],
            total_withdrawn=wallet_doc["total_withdrawn"],
            created_at=wallet_doc["created_at"],
            updated_at=wallet_doc["updated_at"],
        )

    def _to_withdrawal_out(self, withdrawal_doc: dict) -> WithdrawalOut:
        """Convert MongoDB document to WithdrawalOut schema"""
        return WithdrawalOut(
            withdrawal_id=str(withdrawal_doc["_id"]),
            email=withdrawal_doc["email"],
            amount=withdrawal_doc["amount"],
            status=withdrawal_doc["status"],
            bank_account=withdrawal_doc["bank_account"],
            bank_name=withdrawal_doc["bank_name"],
            account_holder_name=withdrawal_doc["account_holder_name"],
            notes=withdrawal_doc.get("notes"),
            requested_at=withdrawal_doc["requested_at"],
            processed_at=withdrawal_doc.get("processed_at"),
            processed_by=withdrawal_doc.get("processed_by"),
        )