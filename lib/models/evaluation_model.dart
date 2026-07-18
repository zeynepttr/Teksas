class EvaluationModel {
  final String id;
  final String managerId;
  final String managerName;
  final String subordinateId;
  final String subordinateName;
  final int performanceScore; // 1-5
  final int leadershipScore; // 1-5
  final int cooperationScore; // 1-5
  final String feedback;
  final int year;
  final int timestamp;

  EvaluationModel({
    required this.id,
    required this.managerId,
    required this.managerName,
    required this.subordinateId,
    required this.subordinateName,
    required this.performanceScore,
    required this.leadershipScore,
    required this.cooperationScore,
    required this.feedback,
    required this.year,
    required this.timestamp,
  });

  factory EvaluationModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return EvaluationModel(
      id: id,
      managerId: map['managerId'] ?? '',
      managerName: map['managerName'] ?? '',
      subordinateId: map['subordinateId'] ?? '',
      subordinateName: map['subordinateName'] ?? '',
      performanceScore: map['performanceScore'] is int ? map['performanceScore'] : int.tryParse(map['performanceScore']?.toString() ?? '5') ?? 5,
      leadershipScore: map['leadershipScore'] is int ? map['leadershipScore'] : int.tryParse(map['leadershipScore']?.toString() ?? '5') ?? 5,
      cooperationScore: map['cooperationScore'] is int ? map['cooperationScore'] : int.tryParse(map['cooperationScore']?.toString() ?? '5') ?? 5,
      feedback: map['feedback'] ?? '',
      year: map['year'] is int ? map['year'] : int.tryParse(map['year']?.toString() ?? '2026') ?? 2026,
      timestamp: map['timestamp'] is int ? map['timestamp'] : int.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'managerId': managerId,
      'managerName': managerName,
      'subordinateId': subordinateId,
      'subordinateName': subordinateName,
      'performanceScore': performanceScore,
      'leadershipScore': leadershipScore,
      'cooperationScore': cooperationScore,
      'feedback': feedback,
      'year': year,
      'timestamp': timestamp,
    };
  }

  EvaluationModel copyWith({
    String? feedback,
    int? performanceScore,
    int? leadershipScore,
    int? cooperationScore,
  }) {
    return EvaluationModel(
      id: id,
      managerId: managerId,
      managerName: managerName,
      subordinateId: subordinateId,
      subordinateName: subordinateName,
      performanceScore: performanceScore ?? this.performanceScore,
      leadershipScore: leadershipScore ?? this.leadershipScore,
      cooperationScore: cooperationScore ?? this.cooperationScore,
      feedback: feedback ?? this.feedback,
      year: year,
      timestamp: timestamp,
    );
  }
}
