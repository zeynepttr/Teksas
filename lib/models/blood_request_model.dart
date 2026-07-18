class BloodRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String userRole;
  final String bloodGroup;
  final String hospital;
  final int units;
  final String notes;
  final bool isUrgent;
  final String status; // 'active', 'completed'
  final int timestamp;

  BloodRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userRole,
    required this.bloodGroup,
    required this.hospital,
    required this.units,
    required this.notes,
    required this.isUrgent,
    required this.status,
    required this.timestamp,
  });

  factory BloodRequestModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return BloodRequestModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      userRole: map['userRole'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      hospital: map['hospital'] ?? '',
      units: map['units'] is int ? map['units'] : int.tryParse(map['units']?.toString() ?? '1') ?? 1,
      notes: map['notes'] ?? '',
      isUrgent: map['isUrgent'] is bool ? map['isUrgent'] : (map['isUrgent']?.toString().toLowerCase() == 'true'),
      status: map['status'] ?? 'active',
      timestamp: map['timestamp'] is int ? map['timestamp'] : int.tryParse(map['timestamp']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userRole': userRole,
      'bloodGroup': bloodGroup,
      'hospital': hospital,
      'units': units,
      'notes': notes,
      'isUrgent': isUrgent,
      'status': status,
      'timestamp': timestamp,
    };
  }

  BloodRequestModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? userRole,
    String? bloodGroup,
    String? hospital,
    int? units,
    String? notes,
    bool? isUrgent,
    String? status,
    int? timestamp,
  }) {
    return BloodRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userRole: userRole ?? this.userRole,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      hospital: hospital ?? this.hospital,
      units: units ?? this.units,
      notes: notes ?? this.notes,
      isUrgent: isUrgent ?? this.isUrgent,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
