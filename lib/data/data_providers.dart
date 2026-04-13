import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dummy_data.dart';
import '../models/office.dart';
import '../models/customer.dart';
import '../models/loan.dart';
import '../models/monthly_recovery.dart';

class AppState {
  final List<Office> offices;
  final List<Customer> customers;
  final List<Loan> loans;
  final List<MonthlyRecovery> monthlyRecoveries;

  AppState({
    required this.offices,
    required this.customers,
    required this.loans,
    required this.monthlyRecoveries,
  });

  AppState copyWith({
    List<Office>? offices,
    List<Customer>? customers,
    List<Loan>? loans,
    List<MonthlyRecovery>? monthlyRecoveries,
  }) {
    return AppState(
      offices: offices ?? this.offices,
      customers: customers ?? this.customers,
      loans: loans ?? this.loans,
      monthlyRecoveries: monthlyRecoveries ?? this.monthlyRecoveries,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState(
    offices: List.from(DummyData.offices),
    customers: List.from(DummyData.customers),
    loans: List.from(DummyData.loans),
    monthlyRecoveries: List.from(DummyData.monthlyRecoveries),
  ));

  void addBranch(String name) {
    if (name.trim().isEmpty) return;
    final newOffice = Office(id: const Uuid().v4(), branchId: 'b1', name: name);
    state = state.copyWith(offices: [...state.offices, newOffice]);
  }

  void addEmployee(String branchId, String name, String memberNo) {
    if (name.trim().isEmpty || memberNo.trim().isEmpty) return;
    final customer = Customer(id: const Uuid().v4(), officeId: branchId, memberNo: memberNo, name: name);
    state = state.copyWith(customers: [...state.customers, customer]);
  }

  void addLoan(String customerId, String accountNo, double principalOS, double baseEmi) {
    if (accountNo.trim().isEmpty) return;
    final loan = Loan(
      id: const Uuid().v4(), customerId: customerId, accountNo: accountNo, 
      principalOutstanding: principalOS, baseEmiAmount: baseEmi
    );
    state = state.copyWith(loans: [...state.loans, loan]);
  }

  void updateDraft(String draftId, double penalInt, double others) {
    final index = state.monthlyRecoveries.indexWhere((d) => d.id == draftId);
    if (index >= 0) {
      final updatedDraft = MonthlyRecovery(
         id: state.monthlyRecoveries[index].id,
         loanId: state.monthlyRecoveries[index].loanId,
         month: state.monthlyRecoveries[index].month,
         year: state.monthlyRecoveries[index].year,
         principalDue: state.monthlyRecoveries[index].principalDue,
         interest: state.monthlyRecoveries[index].interest,
         penalInterest: penalInt,
         otherCharges: others,
      );
      final newDrafts = List<MonthlyRecovery>.from(state.monthlyRecoveries);
      newDrafts[index] = updatedDraft;
      state = state.copyWith(monthlyRecoveries: newDrafts);
    }
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) => AppStateNotifier());
