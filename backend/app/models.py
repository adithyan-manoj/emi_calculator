from sqlalchemy import Column, Integer, String, Float, ForeignKey, Date
from sqlalchemy.orm import relationship
from .database import Base

class Office(Base):
    __tablename__ = "offices"
    id = Column(String, primary_key=True)
    branch_id = Column(String)  # internal mapping
    name = Column(String, nullable=False)

    customers = relationship("Customer", back_populates="office")

class Customer(Base):
    __tablename__ = "customers"
    id = Column(String, primary_key=True)
    office_id = Column(String, ForeignKey("offices.id"))
    member_no = Column(String, nullable=False)
    name = Column(String, nullable=False)

    office = relationship("Office", back_populates="customers")
    loans = relationship("Loan", back_populates="customer")

class Loan(Base):
    __tablename__ = "loans"
    id = Column(String, primary_key=True)
    customer_id = Column(String, ForeignKey("customers.id"))
    account_no = Column(String, nullable=False)
    principal_outstanding = Column(Float, default=0.0)
    base_emi_amount = Column(Float, default=0.0)
    status = Column(String, default="Active")

    customer = relationship("Customer", back_populates="loans")
    recoveries = relationship("MonthlyRecovery", back_populates="loan")

class MonthlyRecovery(Base):
    __tablename__ = "monthly_recoveries"
    id = Column(String, primary_key=True)
    loan_id = Column(String, ForeignKey("loans.id"))
    month = Column(Integer, nullable=False)
    year = Column(Integer, nullable=False)
    principal_due = Column(Float, default=0.0)
    interest = Column(Float, default=0.0)
    penal_interest = Column(Float, default=0.0)
    other_charges = Column(Float, default=0.0)

    loan = relationship("Loan", back_populates="recoveries")
