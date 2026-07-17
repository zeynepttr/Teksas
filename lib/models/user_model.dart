class UserModel {
  final String uid;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String bloodGroup;
  final int age;
  final String role; // 'İHH Çalışanı' or 'İK Çalışanı (Admin)'
  final int joinTimestamp; // Milliseconds since epoch for starting work at Hane/IHH

  UserModel({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.age,
    required this.role,
    required this.joinTimestamp,
  });

  String get fullName => '$name $surname';
  bool get isAdmin => role == 'İK Çalışanı (Admin)';

  // Factory to create from Map (from Firebase Realtime DB)
  factory UserModel.fromMap(Map<dynamic, dynamic> map, String id) {
    // Default mock dates: Admin Zeynep started ~2 years 3 months 10 days ago, others ~1 year 2 months ago
    final defaultDays = id.contains('admin') ? (365 * 2 + 30 * 3 + 10) : (365 + 30 * 2);
    final defaultTimestamp = DateTime.now().subtract(Duration(days: defaultDays)).millisecondsSinceEpoch;

    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      age: map['age'] is int ? map['age'] : int.tryParse(map['age']?.toString() ?? '0') ?? 0,
      role: map['role'] ?? 'İHH Çalışanı',
      joinTimestamp: map['joinTimestamp'] is int ? map['joinTimestamp'] : int.tryParse(map['joinTimestamp']?.toString() ?? '') ?? defaultTimestamp,
    );
  }

  // Convert to Map for database write
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'age': age,
      'role': role,
      'joinTimestamp': joinTimestamp,
    };
  }

  UserModel copyWith({
    String? name,
    String? surname,
    String? email,
    String? phone,
    String? bloodGroup,
    int? age,
    String? role,
    int? joinTimestamp,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      age: age ?? this.age,
      role: role ?? this.role,
      joinTimestamp: joinTimestamp ?? this.joinTimestamp,
    );
  }
}
