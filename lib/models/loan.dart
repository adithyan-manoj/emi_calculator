class Loan {
  final String id;
  final String customerId;
  final String accountNo;
  final double principalOutstanding;
  final double baseEmiAmount;
  final String status;

  Loan({
    required this.id,
    required this.customerId,
    required this.accountNo,
    required this.principalOutstanding,
    required this.baseEmiAmount,
    this.status = 'Active',
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      customerId: json['customer_id'],
      accountNo: json['account_no'],
      principalOutstanding: (json['principal_outstanding'] as num?)?.toDouble() ?? 0.0,
      baseEmiAmount: (json['base_emi_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'account_no': accountNo,
      'principal_outstanding': principalOutstanding,
      'base_emi_amount': baseEmiAmount,
      'status': status,
    };
  }
}
