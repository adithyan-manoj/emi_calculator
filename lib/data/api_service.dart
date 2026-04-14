import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/office.dart';
import '../models/customer.dart';
import '../models/loan.dart';
import '../models/monthly_recovery.dart';

class ApiService {
  late final Dio _dio;
  
  // Using 127.0.0.1 because adb reverse maps the phone directly to the PC
  // final String _baseUrl = 'http://192.168.1.74:8000';
  final String _baseUrl = 'https://emi-calculator-q4hs.onrender.com/';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  // --- Offices ---
  Future<List<Office>> getOffices() async {
    final response = await _dio.get('offices/');
    return (response.data as List).map((e) => Office.fromJson(e)).toList();
  }

  Future<Office> createOffice(Office office) async {
    final response = await _dio.post('offices/', data: office.toJson());
    return Office.fromJson(response.data);
  }

  Future<void> deleteOffice(String officeId) async {
    await _dio.delete('offices/$officeId');
  }

  // --- Customers ---
  Future<List<Customer>> getCustomers({String? officeId}) async {
    final response = await _dio.get('customers/', queryParameters: officeId != null ? {'office_id': officeId} : null);
    return (response.data as List).map((e) => Customer.fromJson(e)).toList();
  }

  Future<Customer> createCustomer(Customer customer) async {
    final response = await _dio.post('customers/', data: customer.toJson());
    return Customer.fromJson(response.data);
  }

  Future<void> deleteCustomer(String customerId) async {
    await _dio.delete('customers/$customerId');
  }

  // --- Loans ---
  Future<List<Loan>> getLoans({String? customerId}) async {
    final response = await _dio.get('loans/', queryParameters: customerId != null ? {'customer_id': customerId} : null);
    return (response.data as List).map((e) => Loan.fromJson(e)).toList();
  }

  Future<Loan> createLoan(Loan loan) async {
    final response = await _dio.post('loans/', data: loan.toJson());
    return Loan.fromJson(response.data);
  }

  Future<void> deleteLoan(String loanId) async {
    await _dio.delete('loans/$loanId');
  }

  // --- Recoveries ---
  Future<List<MonthlyRecovery>> getRecoveries({int? month, int? year}) async {
    final Map<String, dynamic> query = {};
    if (month != null) query['month'] = month;
    if (year != null) query['year'] = year;
    
    final response = await _dio.get('recoveries/', queryParameters: query);
    return (response.data as List).map((e) => MonthlyRecovery.fromJson(e)).toList();
  }

  Future<String> generateDrafts(int month, int year, {String? officeId, String? branchId}) async {
    final Map<String, dynamic> query = {'month': month, 'year': year};
    final id = officeId ?? branchId;
    if (id != null) query['office_id'] = id;
    
    final response = await _dio.post('recoveries/generate', queryParameters: query);
    return response.data['message'] as String;
  }

  Future<MonthlyRecovery> updateRecovery(
    String id, 
    {double? principalDue, double? interest, double? penalInt, double? others}
  ) async {
    final Map<String, dynamic> query = {};
    if (principalDue != null) query['principal_due'] = principalDue;
    if (interest != null) query['interest'] = interest;
    if (penalInt != null) query['penal_interest'] = penalInt;
    if (others != null) query['other_charges'] = others;

    final response = await _dio.patch(
      'recoveries/$id', 
      queryParameters: query
    );
    return MonthlyRecovery.fromJson(response.data);
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
