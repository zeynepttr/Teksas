class LeaveRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String leaveType; // 'Yıllık İzin', 'Sağlık İzni', 'Mazeret İzni'
  final String startDate;
  final String endDate;
  final int durationDays;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final int timestamp;

  LeaveRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.reason,
    this.status = 'pending',
    required this.timestamp,
  });

  factory LeaveRequestModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return LeaveRequestModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      leaveType: map['leaveType'] ?? 'Yıllık İzin',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      durationDays: map['durationDays'] is int ? map['durationDays'] : int.tryParse(map['durationDays']?.toString() ?? '0') ?? 0,
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: map['timestamp'] is int ? map['timestamp'] : int.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'durationDays': durationDays,
      'reason': reason,
      'status': status,
      'timestamp': timestamp,
    };
  }

  LeaveRequestModel copyWith({
    String? status,
  }) {
    return LeaveRequestModel(
      id: id,
      userId: userId,
      userName: userName,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      durationDays: durationDays,
      reason: reason,
      status: status ?? this.status,
      timestamp: timestamp,
    );
  }
}
