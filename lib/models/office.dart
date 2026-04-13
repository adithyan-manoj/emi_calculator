class Office {
  final String id;
  final String branchId;
  final String name;

  Office({
    required this.id,
    required this.branchId,
    required this.name,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'],
      branchId: json['branch_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'name': name,
    };
  }
}
