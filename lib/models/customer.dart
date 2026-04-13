class Customer {
  final String id;
  final String officeId;
  final String memberNo;
  final String name;

  Customer({
    required this.id,
    required this.officeId,
    required this.memberNo,
    required this.name,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      officeId: json['office_id'],
      memberNo: json['member_no'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'office_id': officeId,
      'member_no': memberNo,
      'name': name,
    };
  }
}
