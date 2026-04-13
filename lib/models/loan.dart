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
    this.status = 'ACTIVE',
  });
}
