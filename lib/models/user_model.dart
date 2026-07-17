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
  final String extension; // Dahili No (e.g. "1402")
  final String employeeCode; // Çalışan Kodu (e.g. "IHH-283")
  final String department; // Birim / Departman (e.g. "Dış İlişkiler Birimi")

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
    required this.extension,
    required this.employeeCode,
    required this.department,
  });

  String get fullName => '$name $surname';
  bool get isAdmin => role.contains('Admin');

  // Factory to create from Map (from Firebase Realtime DB)
  factory UserModel.fromMap(Map<dynamic, dynamic> map, String id) {
    // Default mock dates: Admin Zeynep started ~2 years 3 months 10 days ago, others ~1 year 2 months ago
    final defaultDays = id.contains('admin') ? (365 * 2 + 30 * 3 + 10) : (365 + 30 * 2);
    final defaultTimestamp = DateTime.now().subtract(Duration(days: defaultDays)).millisecondsSinceEpoch;

    // Generate deterministic default code/extension/department if null
    final defaultExtension = (1000 + (id.hashCode.abs() % 9000)).toString();
    final defaultEmpCode = "IHH-${(100 + (id.hashCode.abs() % 900))}";
    
    final String defaultDept;
    final String roleStr = map['role'] ?? 'İHH Çalışanı';
    if (roleStr.contains('Admin')) {
      defaultDept = 'İnsan Kaynakları';
    } else if (map['email']?.toString().contains('medical') == true || 
               map['email']?.toString().contains('doctor') == true || 
               map['email']?.toString().contains('ayse') == true) {
      defaultDept = 'Sağlık Birimi';
    } else if (map['email']?.toString().contains('selim') == true || 
               map['email']?.toString().contains('psk') == true) {
      defaultDept = 'Psikolojik Destek';
    } else if (map['email']?.toString().contains('kemal') == true || 
               map['email']?.toString().contains('it') == true) {
      defaultDept = 'Bilgi Teknolojileri';
    } else if (map['email']?.toString().contains('hakan') == true) {
      defaultDept = 'Dış İlişkiler';
    } else {
      defaultDept = 'Saha Operasyonları';
    }

    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      age: map['age'] is int ? map['age'] : int.tryParse(map['age']?.toString() ?? '0') ?? 0,
      role: roleStr,
      joinTimestamp: map['joinTimestamp'] is int 
          ? map['joinTimestamp'] 
          : int.tryParse(map['joinTimestamp']?.toString() ?? '') ?? defaultTimestamp,
      extension: map['extension'] ?? defaultExtension,
      employeeCode: map['employeeCode'] ?? defaultEmpCode,
      department: map['department'] ?? defaultDept,
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
      'extension': extension,
      'employeeCode': employeeCode,
      'department': department,
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
    String? extension,
    String? employeeCode,
    String? department,
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
      extension: extension ?? this.extension,
      employeeCode: employeeCode ?? this.employeeCode,
      department: department ?? this.department,
    );
  }
}
