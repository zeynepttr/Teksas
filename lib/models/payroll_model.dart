class PayrollModel {
  final String id;
  final String userId;
  final String userName;
  final String month;
  final int year;
  final double netSalary;
  final double allowances;
  final double deductions;
  final String status; // 'Paid', 'Pending'

  PayrollModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.month,
    required this.year,
    required this.netSalary,
    required this.allowances,
    required this.deductions,
    this.status = 'Paid',
  });

  factory PayrollModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return PayrollModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      month: map['month'] ?? '',
      year: map['year'] is int ? map['year'] : int.tryParse(map['year']?.toString() ?? '2026') ?? 2026,
      netSalary: map['netSalary'] is num ? (map['netSalary'] as num).toDouble() : double.tryParse(map['netSalary']?.toString() ?? '0.0') ?? 0.0,
      allowances: map['allowances'] is num ? (map['allowances'] as num).toDouble() : double.tryParse(map['allowances']?.toString() ?? '0.0') ?? 0.0,
      deductions: map['deductions'] is num ? (map['deductions'] as num).toDouble() : double.tryParse(map['deductions']?.toString() ?? '0.0') ?? 0.0,
      status: map['status'] ?? 'Paid',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'month': month,
      'year': year,
      'netSalary': netSalary,
      'allowances': allowances,
      'deductions': deductions,
      'status': status,
    };
  }
}
