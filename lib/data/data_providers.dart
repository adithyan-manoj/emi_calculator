import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/office.dart';
import '../models/customer.dart';
import '../models/loan.dart';
import '../models/monthly_recovery.dart';
import 'api_service.dart';

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

class AppStateNotifier extends AsyncNotifier<AppState> {
  @override
  Future<AppState> build() async {
    // Artificial delay to show off the professional loading screen
    await Future.delayed(const Duration(seconds: 2));

    final api = ref.watch(apiServiceProvider);
    
    final offices = await api.getOffices();
    final customers = await api.getCustomers();
    final loans = await api.getLoans();
    final recoveries = await api.getRecoveries();

    return AppState(
      offices: offices,
      customers: customers,
      loans: loans,
      monthlyRecoveries: recoveries,
    );
  }

  Future<void> addBranch(String name) async {
    if (name.trim().isEmpty) return;
    
    final newOffice = Office(id: const Uuid().v4(), branchId: 'b1', name: name);
    
    // Save to backend
    final api = ref.read(apiServiceProvider);
    final savedOffice = await api.createOffice(newOffice);

    // Update local state conditionally on success
    state = state.whenData((current) => current.copyWith(
      offices: [...current.offices, savedOffice]
    ));
  }

  Future<void> addEmployee(String branchId, String name, String memberNo) async {
    if (name.trim().isEmpty || memberNo.trim().isEmpty) return;
    
    final customer = Customer(id: const Uuid().v4(), officeId: branchId, memberNo: memberNo, name: name);
    
    final api = ref.read(apiServiceProvider);
    final savedCustomer = await api.createCustomer(customer);

    state = state.whenData((current) => current.copyWith(
      customers: [...current.customers, savedCustomer]
    ));
  }

  Future<void> addLoan(String customerId, String accountNo, double principalOS, double baseEmi) async {
    if (accountNo.trim().isEmpty) return;
    
    final loan = Loan(
      id: const Uuid().v4(), customerId: customerId, accountNo: accountNo, 
      principalOutstanding: principalOS, baseEmiAmount: baseEmi
    );
    
    final api = ref.read(apiServiceProvider);
    final savedLoan = await api.createLoan(loan);

    state = state.whenData((current) => current.copyWith(
      loans: [...current.loans, savedLoan]
    ));
  }

  Future<void> updateDraft(String draftId, double penalInt, double others) async {
    final api = ref.read(apiServiceProvider);
    final updatedDraft = await api.updateRecovery(draftId, penalInt, others);

    state = state.whenData((current) {
      final index = current.monthlyRecoveries.indexWhere((d) => d.id == draftId);
      if (index >= 0) {
        final newDrafts = List<MonthlyRecovery>.from(current.monthlyRecoveries);
        newDrafts[index] = updatedDraft;
        return current.copyWith(monthlyRecoveries: newDrafts);
      }
      return current;
    });
  }
}

final appStateProvider = AsyncNotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);
