from pydantic import BaseModel
from typing import List, Optional

class OfficeBase(BaseModel):
    id: str
    branch_id: str
    name: str

class Office(OfficeBase):
    class Config:
        from_attributes = True

class CustomerBase(BaseModel):
    id: str
    office_id: str
    member_no: str
    name: str

class Customer(CustomerBase):
    class Config:
        from_attributes = True

class LoanBase(BaseModel):
    id: str
    customer_id: str
    account_no: str
    principal_outstanding: float
    base_emi_amount: float
    status: str

class Loan(LoanBase):
    class Config:
        from_attributes = True

class MonthlyRecoveryBase(BaseModel):
    id: str
    loan_id: str
    month: int
    year: int
    principal_due: float
    interest: float
    penal_interest: float
    other_charges: float

class MonthlyRecovery(MonthlyRecoveryBase):
    @property
    def total_recovered(self) -> float:
        return self.principal_due + self.interest + self.penal_interest + self.other_charges

    class Config:
        from_attributes = True
