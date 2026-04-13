class MonthlyRecovery {
  final String id;
  final String loanId;
  final int month;
  final int year;
  final double principalDue;
  final double interest;
  final double penalInterest;
  final double otherCharges;
  final bool isReviewed;

  MonthlyRecovery({
    required this.id,
    required this.loanId,
    required this.month,
    required this.year,
    required this.principalDue,
    required this.interest,
    this.penalInterest = 0.0,
    this.otherCharges = 0.0,
    this.isReviewed = false,
  });

  double get totalRecovered => principalDue + interest + penalInterest + otherCharges;
}
