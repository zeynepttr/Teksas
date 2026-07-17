class AgreementModel {
  final String id;
  final String companyName;
  final String category;
  final String discountRate;
  final String description;
  final String code;
  final String? logoUrl;
  final bool isPermanent;
  final String? endDate; // Format YYYY-MM-DD

  AgreementModel({
    required this.id,
    required this.companyName,
    required this.category,
    required this.discountRate,
    required this.description,
    required this.code,
    this.logoUrl,
    required this.isPermanent,
    this.endDate,
  });

  // Calculate remaining days or status description
  String get durationLabel {
    if (isPermanent) {
      return "Süresiz Anlaşma";
    }
    if (endDate == null || endDate!.isEmpty) {
      return "Süresiz Anlaşma";
    }
    try {
      final parsedEndDate = DateTime.parse(endDate!);
      final now = DateTime.now();
      // Reset hours to compare only days
      final endDay = DateTime(parsedEndDate.year, parsedEndDate.month, parsedEndDate.day);
      final today = DateTime(now.year, now.month, now.day);
      final difference = endDay.difference(today).inDays;

      if (difference < 0) {
        return "Sona Ermiş";
      } else if (difference == 0) {
        return "Bugün Sona Eriyor";
      } else {
        return "$difference Gün Kaldı";
      }
    } catch (_) {
      return "Süreli Anlaşma";
    }
  }

  bool get isExpired {
    if (isPermanent) return false;
    if (endDate == null || endDate!.isEmpty) return false;
    try {
      final parsedEndDate = DateTime.parse(endDate!);
      final now = DateTime.now();
      final endDay = DateTime(parsedEndDate.year, parsedEndDate.month, parsedEndDate.day);
      final today = DateTime(now.year, now.month, now.day);
      return endDay.isBefore(today);
    } catch (_) {
      return false;
    }
  }

  factory AgreementModel.fromMap(Map<dynamic, dynamic> map, String id) {
    bool defaultIsPermanent = true;
    String? defaultEndDate;
    if (id == 'agr_1') {
      defaultIsPermanent = false;
      defaultEndDate = '2026-08-10';
    } else if (id == 'agr_4') {
      defaultIsPermanent = false;
      defaultEndDate = '2026-07-10';
    } else if (id == 'agr_5') {
      defaultIsPermanent = false;
      defaultEndDate = '2026-07-25';
    }

    return AgreementModel(
      id: id,
      companyName: map['companyName'] ?? '',
      category: map['category'] ?? 'Diğer',
      discountRate: map['discountRate'] ?? '',
      description: map['description'] ?? '',
      code: map['code'] ?? '',
      logoUrl: map['logoUrl'],
      isPermanent: map['isPermanent'] is bool
          ? map['isPermanent']
          : (map['isPermanent'] != null
              ? (map['isPermanent'].toString() == 'true')
              : defaultIsPermanent),
      endDate: map['endDate'] ?? defaultEndDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'category': category,
      'discountRate': discountRate,
      'description': description,
      'code': code,
      'logoUrl': logoUrl,
      'isPermanent': isPermanent,
      'endDate': endDate,
    };
  }
}
