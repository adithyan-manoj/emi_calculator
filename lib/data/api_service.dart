import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/office.dart';
import '../models/customer.dart';
import '../models/loan.dart';
import '../models/monthly_recovery.dart';

class ApiService {
  late final Dio _dio;
  
  // Use 10.0.2.2 for Android emulator to access localhost, otherwise localhost
  String get _baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (e) {
      // Platform.isAndroid throws on web
    }
    return 'http://127.0.0.1:8000';
  }

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  // --- Offices ---
  Future<List<Office>> getOffices() async {
    final response = await _dio.get('/offices/');
    return (response.data as List).map((e) => Office.fromJson(e)).toList();
  }

  Future<Office> createOffice(Office office) async {
    final response = await _dio.post('/offices/', data: office.toJson());
    return Office.fromJson(response.data);
  }

  // --- Customers ---
  Future<List<Customer>> getCustomers({String? officeId}) async {
    final response = await _dio.get('/customers/', queryParameters: officeId != null ? {'office_id': officeId} : null);
    return (response.data as List).map((e) => Customer.fromJson(e)).toList();
  }

  Future<Customer> createCustomer(Customer customer) async {
    final response = await _dio.post('/customers/', data: customer.toJson());
    return Customer.fromJson(response.data);
  }

  // --- Loans ---
  Future<List<Loan>> getLoans({String? customerId}) async {
    final response = await _dio.get('/loans/', queryParameters: customerId != null ? {'customer_id': customerId} : null);
    return (response.data as List).map((e) => Loan.fromJson(e)).toList();
  }

  Future<Loan> createLoan(Loan loan) async {
    final response = await _dio.post('/loans/', data: loan.toJson());
    return Loan.fromJson(response.data);
  }

  // --- Recoveries ---
  Future<List<MonthlyRecovery>> getRecoveries({int? month, int? year}) async {
    final Map<String, dynamic> query = {};
    if (month != null) query['month'] = month;
    if (year != null) query['year'] = year;
    
    final response = await _dio.get('/recoveries/', queryParameters: query);
    return (response.data as List).map((e) => MonthlyRecovery.fromJson(e)).toList();
  }

  Future<MonthlyRecovery> updateRecovery(String id, double penalInt, double others) async {
    final response = await _dio.patch(
      '/recoveries/$id', 
      queryParameters: {'penal_interest': penalInt, 'other_charges': others}
    );
    return MonthlyRecovery.fromJson(response.data);
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
