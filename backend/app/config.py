from pydantic_settings import BaseSettings
from typing import Optional
from dotenv import load_dotenv
import os

# Load .env file explicitly
load_dotenv()


class Settings(BaseSettings):
    # MongoDB
    MONGODB_URL: str
    DATABASE_NAME: str

    # JWT
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Email Configuration
    EMAIL_SENDER: str
    EMAIL_PASSWORD: str
    EMAIL_SENDER_NAME: str = "Legal Platform"
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 465

    class Config:
        env_file = ".env"
        extra = "ignore"  # This allows extra fields in .env without errors


settings = Settings()