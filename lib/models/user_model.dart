class UserModel {
  final String uid;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String bloodGroup;
  final int age;
  final String role; // 'İHH Çalışanı' or 'İK Çalışanı (Admin)'

  UserModel({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.age,
    required this.role,
  });

  String get fullName => '$name $surname';
  bool get isAdmin => role == 'İK Çalışanı (Admin)';

  // Factory to create from Map (from Firebase Realtime DB)
  factory UserModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      age: map['age'] is int ? map['age'] : int.tryParse(map['age']?.toString() ?? '0') ?? 0,
      role: map['role'] ?? 'İHH Çalışanı',
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
    );
  }
}
