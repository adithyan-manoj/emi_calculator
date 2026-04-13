import json
import uuid
import os
import sys

# Add the parent directory to sys.path so we can import from app
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), ".")))

from app.database import SessionLocal
from app import models

def populate_db():
    # Load extracted data
    data_path = os.path.join(os.path.dirname(__file__), "..", "extracted_data.json")
    with open(data_path, 'r') as f:
        data = json.load(f)

    db = SessionLocal()
    try:
        print("Starting database wipe...")
        # Order matters for foreign key constraints
        db.query(models.MonthlyRecovery).delete()
        db.query(models.Loan).delete()
        db.query(models.Customer).delete()
        db.query(models.Office).delete()
        db.commit()
        print("Database wiped successfully.")

        offices_created = 0
        customers_created = 0
        loans_created = 0

        for branch_name, records in data.items():
            if branch_name == "Unknown":
                continue
            
            # Create Office
            office_id = str(uuid.uuid4())
            db_office = models.Office(
                id=office_id,
                branch_id=branch_name.lower().replace(" ", "_"),
                name=branch_name
            )
            db.add(db_office)
            offices_created += 1

            # Track customers in this branch to avoid duplicates
            branch_customers = {}

            for rec in records:
                member_no = rec['member_no']
                customer_name = rec['name']
                
                # Check 0 values for Arun D etc.
                if rec['base_emi'] == 0 and rec['principal_os'] == 0:
                    # Depending on policy, we might skip, but let's include if they have a member no
                    print(f"Including {customer_name} despite 0 values.")

                if member_no not in branch_customers:
                    customer_id = str(uuid.uuid4())
                    db_customer = models.Customer(
                        id=customer_id,
                        office_id=office_id,
                        member_no=member_no,
                        name=customer_name
                    )
                    db.add(db_customer)
                    branch_customers[member_no] = customer_id
                    customers_created += 1
                
                # Create Loan
                loan_id = str(uuid.uuid4())
                db_loan = models.Loan(
                    id=loan_id,
                    customer_id=branch_customers[member_no],
                    account_no=rec['account_no'],
                    principal_outstanding=rec['principal_os'],
                    base_emi_amount=rec['base_emi'],
                    status="Active"
                )
                db.add(db_loan)
                loans_created += 1

        db.commit()
        print(f"Population complete: {offices_created} offices, {customers_created} customers, {loans_created} loans.")

    except Exception as e:
        db.rollback()
        print(f"Error during population: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    populate_db()
