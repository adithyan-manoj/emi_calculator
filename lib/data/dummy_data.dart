import '../models/branch.dart';
import '../models/office.dart';
import '../models/customer.dart';
import '../models/loan.dart';
import '../models/monthly_recovery.dart';

class DummyData {
  static final List<Branch> branches = [
    Branch(id: 'b1', name: 'Kollam Main Branch'),
  ];

  static final List<Office> offices = [
    Office(id: 'o1', branchId: 'b1', name: 'Punalur PO'),
    Office(id: 'o2', branchId: 'b1', name: 'Kottarakkara PO'),
  ];

  static final List<Customer> customers = [
    Customer(id: 'c1', officeId: 'o1', memberNo: '101', name: 'John Doe'),
    Customer(id: 'c2', officeId: 'o1', memberNo: '102', name: 'Jane Smith'),
    Customer(id: 'c3', officeId: 'o2', memberNo: '201', name: 'Robert Brown'),
  ];

  static final List<Loan> loans = [
    Loan(
      id: 'l1',
      customerId: 'c1',
      accountNo: '15/25-26',
      principalOutstanding: 50000.0,
      baseEmiAmount: 5000.0,
    ),
    Loan(
      id: 'l2',
      customerId: 'c1',
      accountNo: '08/24-25',
      principalOutstanding: 15000.0,
      baseEmiAmount: 1500.0,
    ),
    Loan(
      id: 'l3',
      customerId: 'c2',
      accountNo: '01/25-26',
      principalOutstanding: 100000.0,
      baseEmiAmount: 12000.0,
    ),
  ];

  static final List<MonthlyRecovery> monthlyRecoveries = [
    MonthlyRecovery(
      id: 'm1',
      loanId: 'l1',
      month: 4,
      year: 2026,
      principalDue: 4500.0,
      interest: 500.0,
    ),
    MonthlyRecovery(
      id: 'm2',
      loanId: 'l2',
      month: 4,
      year: 2026,
      principalDue: 1400.0,
      interest: 100.0,
      penalInterest: 50.0, // Editing mockup
    ),
    MonthlyRecovery(
      id: 'm3',
      loanId: 'l3',
      month: 4,
      year: 2026,
      principalDue: 10000.0,
      interest: 2000.0,
    ),
  ];
}
