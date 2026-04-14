import os
from dotenv import load_dotenv
from fastapi import HTTPException
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Get the absolute path to the directory containing this file (backend/)
# and look for the .env in the same folder
env_path = os.path.join(os.path.dirname(__file__), ".env")
if os.path.exists(env_path):
    load_dotenv(dotenv_path=env_path)

SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

# Use a placeholder if the URL is missing to prevent import-time crashes
if SQLALCHEMY_DATABASE_URL is None:
    print("CRITICAL: DATABASE_URL is missing from environment variables!")
    SQLALCHEMY_DATABASE_URL = "postgresql://user:pass@localhost/dummy" 

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    if not SQLALCHEMY_DATABASE_URL or "dummy" in SQLALCHEMY_DATABASE_URL:
        print("ERROR: DATABASE_URL is missing or invalid!")
        raise HTTPException(
            status_code=500, 
            detail="Database connection not configured on Render. Please check Environment Variables."
        )
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
