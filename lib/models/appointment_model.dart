class AppointmentModel {
  final String id;
  final String userId;
  final String doctorName;
  final String role; // 'İş Yeri Hekimi' or 'Kurum Psikoloğu'
  final String city;
  final String date;
  final String time;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.doctorName,
    required this.role,
    required this.city,
    required this.date,
    required this.time,
    this.status = 'scheduled',
    this.notes,
  });

  factory AppointmentModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      userId: map['userId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      role: map['role'] ?? 'İş Yeri Hekimi',
      city: map['city'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'scheduled',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'doctorName': doctorName,
      'role': role,
      'city': city,
      'date': date,
      'time': time,
      'status': status,
      'notes': notes,
    };
  }
}
