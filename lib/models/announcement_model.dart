class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String type; // 'event', 'wedding', 'celebration', 'agreement', 'general'
  final String? date;
  final String? location;
  final String author;
  final String? authorId;
  final int timestamp;
  final Map<String, bool> attendees; // UID -> joined status
  final String status; // 'approved', 'pending', 'rejected'

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.type,
    this.date,
    this.location,
    required this.author,
    this.authorId,
    required this.timestamp,
    this.attendees = const {},
    this.status = 'approved',
  });

  bool get isEvent => type == 'event';
  int get attendeeCount => attendees.values.where((v) => v).length;

  bool hasJoined(String uid) => attendees[uid] == true;

  factory AnnouncementModel.fromMap(Map<dynamic, dynamic> map, String id) {
    // Parse attendees map safely
    Map<String, bool> parsedAttendees = {};
    if (map['attendees'] is Map) {
      map['attendees'].forEach((key, value) {
        parsedAttendees[key.toString()] = value == true;
      });
    }

    return AnnouncementModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      type: map['type'] ?? 'general',
      date: map['date'],
      location: map['location'],
      author: map['author'] ?? 'Anonim',
      authorId: map['authorId'],
      timestamp: map['timestamp'] is int ? map['timestamp'] : int.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch,
      attendees: parsedAttendees,
      status: map['status'] ?? 'approved',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type,
      'date': date,
      'location': location,
      'author': author,
      'authorId': authorId,
      'timestamp': timestamp,
      'attendees': attendees,
      'status': status,
    };
  }

  AnnouncementModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? type,
    String? date,
    String? location,
    String? author,
    String? authorId,
    int? timestamp,
    Map<String, bool>? attendees,
    String? status,
  }) {
    return AnnouncementModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      date: date ?? this.date,
      location: location ?? this.location,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      timestamp: timestamp ?? this.timestamp,
      attendees: attendees ?? this.attendees,
      status: status ?? this.status,
    );
  }
}
