class AgreementModel {
  final String id;
  final String companyName;
  final String category;
  final String discountRate;
  final String description;
  final String code;
  final String? logoUrl;

  AgreementModel({
    required this.id,
    required this.companyName,
    required this.category,
    required this.discountRate,
    required this.description,
    required this.code,
    this.logoUrl,
  });

  factory AgreementModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return AgreementModel(
      id: id,
      companyName: map['companyName'] ?? '',
      category: map['category'] ?? 'Diğer',
      discountRate: map['discountRate'] ?? '',
      description: map['description'] ?? '',
      code: map['code'] ?? '',
      logoUrl: map['logoUrl'],
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
    };
  }
}
