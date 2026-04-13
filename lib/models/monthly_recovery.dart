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

  factory MonthlyRecovery.fromJson(Map<String, dynamic> json) {
    return MonthlyRecovery(
      id: json['id'],
      loanId: json['loan_id'],
      month: json['month'],
      year: json['year'],
      principalDue: (json['principal_due'] as num?)?.toDouble() ?? 0.0,
      interest: (json['interest'] as num?)?.toDouble() ?? 0.0,
      penalInterest: (json['penal_interest'] as num?)?.toDouble() ?? 0.0,
      otherCharges: (json['other_charges'] as num?)?.toDouble() ?? 0.0,
      isReviewed: json['is_reviewed'] ?? false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loan_id': loanId,
      'month': month,
      'year': year,
      'principal_due': principalDue,
      'interest': interest,
      'penal_interest': penalInterest,
      'other_charges': otherCharges,
      'is_reviewed': isReviewed,
    };
  }

  double get totalRecovered => principalDue + interest + penalInterest + otherCharges;
}
