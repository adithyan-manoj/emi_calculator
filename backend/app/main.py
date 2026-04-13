from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import uuid
from . import models, schemas
from .database import SessionLocal, engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Loan Recovery API")

@app.get("/")
def read_root():
    return {"message": "Loan Recovery API is running"}

# --- Branch/Office Endpoints ---
@app.get("/offices/", response_model=List[schemas.Office])
def read_offices(db: Session = Depends(get_db)):
    return db.query(models.Office).all()

@app.post("/offices/", response_model=schemas.Office)
def create_office(office: schemas.OfficeBase, db: Session = Depends(get_db)):
    db_office = models.Office(**office.model_dump())
    db.add(db_office)
    db.commit()
    db.refresh(db_office)
    return db_office

@app.delete("/offices/{office_id}", status_code=204)
def delete_office(office_id: str, db: Session = Depends(get_db)):
    db_office = db.query(models.Office).filter(models.Office.id == office_id).first()
    if not db_office:
        raise HTTPException(status_code=404, detail="Office not found")
    db.delete(db_office)
    db.commit()
    return None

# --- Customer Endpoints ---
@app.get("/customers/", response_model=List[schemas.Customer])
def read_customers(office_id: str = None, db: Session = Depends(get_db)):
    query = db.query(models.Customer)
    if office_id:
        query = query.filter(models.Customer.office_id == office_id)
    return query.all()

@app.post("/customers/", response_model=schemas.Customer)
def create_customer(customer: schemas.CustomerBase, db: Session = Depends(get_db)):
    db_customer = models.Customer(**customer.model_dump())
    db.add(db_customer)
    db.commit()
    db.refresh(db_customer)
    return db_customer

@app.delete("/customers/{customer_id}", status_code=204)
def delete_customer(customer_id: str, db: Session = Depends(get_db)):
    db_customer = db.query(models.Customer).filter(models.Customer.id == customer_id).first()
    if not db_customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    db.delete(db_customer)
    db.commit()
    return None

# --- Loan Endpoints ---
@app.get("/loans/", response_model=List[schemas.Loan])
def read_loans(customer_id: str = None, db: Session = Depends(get_db)):
    query = db.query(models.Loan)
    if customer_id:
        query = query.filter(models.Loan.customer_id == customer_id)
    return query.all()

@app.post("/loans/", response_model=schemas.Loan)
def create_loan(loan: schemas.LoanBase, db: Session = Depends(get_db)):
    db_loan = models.Loan(**loan.model_dump())
    db.add(db_loan)
    db.commit()
    db.refresh(db_loan)
    return db_loan

@app.delete("/loans/{loan_id}", status_code=204)
def delete_loan(loan_id: str, db: Session = Depends(get_db)):
    db_loan = db.query(models.Loan).filter(models.Loan.id == loan_id).first()
    if not db_loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    db.delete(db_loan)
    db.commit()
    return None

# --- Recovery Endpoints ---
@app.get("/recoveries/", response_model=List[schemas.MonthlyRecovery])
def read_recoveries(month: int = None, year: int = None, db: Session = Depends(get_db)):
    query = db.query(models.MonthlyRecovery)
    if month:
        query = query.filter(models.MonthlyRecovery.month == month)
    if year:
        query = query.filter(models.MonthlyRecovery.year == year)
    return query.all()

@app.post("/recoveries/", response_model=schemas.MonthlyRecovery)
def create_recovery(recovery: schemas.MonthlyRecoveryBase, db: Session = Depends(get_db)):
    db_recovery = models.MonthlyRecovery(**recovery.model_dump())
    db.add(db_recovery)
    db.commit()
    db.refresh(db_recovery)
    return db_recovery

@app.post("/recoveries/generate")
def generate_drafts(month: int, year: int, db: Session = Depends(get_db)):
    loans = db.query(models.Loan).filter(models.Loan.status.in_(['Active', 'ACTIVE'])).all()
    created_drafts = []
    
    for loan in loans:
        # Check if draft exists
        existing = db.query(models.MonthlyRecovery).filter(
            models.MonthlyRecovery.loan_id == loan.id,
            models.MonthlyRecovery.month == month,
            models.MonthlyRecovery.year == year
        ).first()
        
        if not existing:
            new_draft = models.MonthlyRecovery(
                id=str(uuid.uuid4()),
                loan_id=loan.id,
                month=month,
                year=year,
                principal_due=loan.base_emi_amount, # Setting base EMI to principal by default
                interest=0.0,
                penal_interest=0.0,
                other_charges=0.0,
            )
            db.add(new_draft)
            created_drafts.append(new_draft)
    
    db.commit()
    return {"message": f"{len(created_drafts)} drafts generated"}

@app.patch("/recoveries/{recovery_id}", response_model=schemas.MonthlyRecovery)
def update_recovery(
    recovery_id: str, 
    principal_due: float = None,
    interest: float = None,
    penal_interest: float = None, 
    other_charges: float = None, 
    db: Session = Depends(get_db)
):
    db_recovery = db.query(models.MonthlyRecovery).filter(models.MonthlyRecovery.id == recovery_id).first()
    if not db_recovery:
        raise HTTPException(status_code=404, detail="Recovery not found")
    
    if principal_due is not None:
        db_recovery.principal_due = principal_due
    if interest is not None:
        db_recovery.interest = interest
    if penal_interest is not None:
        db_recovery.penal_interest = penal_interest
    if other_charges is not None:
        db_recovery.other_charges = other_charges
        
    db.commit()
    db.refresh(db_recovery)
    return db_recovery
