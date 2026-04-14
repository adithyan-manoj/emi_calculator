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
    final api = ref.watch(apiServiceProvider);
    
    // Fetch all core data in parallel for stability and speed
    try {
      final results = await Future.wait([
        api.getOffices(),
        api.getCustomers(),
        api.getLoans(),
        api.getRecoveries(),
      ]);

      return AppState(
        offices: results[0] as List<Office>,
        customers: results[1] as List<Customer>,
        loans: results[2] as List<Loan>,
        monthlyRecoveries: results[3] as List<MonthlyRecovery>,
      );
    } catch (e) {
      // Re-throw so Riverpod handles the error state correctly
      rethrow;
    }
  }

  Future<void> addBranch(String name) async {
    if (name.trim().isEmpty) return;
    
    final newOffice = Office(id: const Uuid().v4(), branchId: 'b1', name: name);
    final api = ref.read(apiServiceProvider);
    final savedOffice = await api.createOffice(newOffice);

    state = state.whenData((current) => current.copyWith(
      offices: [...current.offices, savedOffice]
    ));
  }

  Future<void> deleteBranch(String officeId) async {
    final api = ref.read(apiServiceProvider);
    await api.deleteOffice(officeId);
    state = state.whenData((current) => current.copyWith(
      offices: current.offices.where((o) => o.id != officeId).toList()
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

  Future<void> deleteEmployee(String customerId) async {
    final api = ref.read(apiServiceProvider);
    await api.deleteCustomer(customerId);
    state = state.whenData((current) => current.copyWith(
      customers: current.customers.where((c) => c.id != customerId).toList()
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

  Future<void> deleteLoan(String loanId) async {
    final api = ref.read(apiServiceProvider);
    await api.deleteLoan(loanId);
    state = state.whenData((current) => current.copyWith(
      loans: current.loans.where((l) => l.id != loanId).toList()
    ));
  }

  Future<void> updateDraft(
    String draftId, 
    {double? principalDue, double? interest, double? penalInt, double? others}
  ) async {
    final api = ref.read(apiServiceProvider);
    final updatedDraft = await api.updateRecovery(
      draftId, 
      principalDue: principalDue, 
      interest: interest, 
      penalInt: penalInt, 
      others: others
    );

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

  Future<String> generateDrafts(int month, int year) async {
    final api = ref.read(apiServiceProvider);
    final msg = await api.generateDrafts(month, year);
    
    // Refresh recoveries
    final recoveries = await api.getRecoveries();
    state = state.whenData((current) => current.copyWith(monthlyRecoveries: recoveries));
    return msg;
  }
}

final appStateProvider = AsyncNotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);
