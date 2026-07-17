class ListingModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category; // 'iPhone', 'Araç', 'Emlak', 'Elektronik', etc.
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final int timestamp;
  final String status; // 'active', 'sold'
  final bool isFavorite;

  ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.timestamp,
    this.status = 'active',
    this.isFavorite = false,
  });

  bool get isActive => status == 'active';

  factory ListingModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return ListingModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] is num ? (map['price'] as num).toDouble() : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      category: map['category'] ?? 'Genel',
      imageUrl: map['imageUrl'] ?? 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=400&auto=format&fit=crop',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerPhone: map['sellerPhone'] ?? '',
      timestamp: map['timestamp'] is int ? map['timestamp'] : int.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch,
      status: map['status'] ?? 'active',
      isFavorite: map['isFavorite'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'timestamp': timestamp,
      'status': status,
      'isFavorite': isFavorite,
    };
  }

  ListingModel copyWith({
    String? title,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    String? sellerId,
    String? sellerName,
    String? sellerPhone,
    int? timestamp,
    String? status,
    bool? isFavorite,
  }) {
    return ListingModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
