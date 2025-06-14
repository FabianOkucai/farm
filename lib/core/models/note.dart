class Note {
  final String id;
  final String title;
  final String content;
  final String farmId;
  final String? seasonId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.farmId,
    this.seasonId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isSynced = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'].toString(), // ✅ FIX: Convert int to String
      title: json['title'] as String,
      content: json['content'] as String,
      farmId: json['farmId'].toString(), // ✅ FIX: Convert int to String
      seasonId: json['seasonId']?.toString(), // ✅ FIX: Convert int to String (nullable)
      userId: json['userId'].toString(), // ✅ FIX: Convert int to String
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'farmId': farmId,
      'seasonId': seasonId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
    };
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? farmId,
    String? seasonId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      farmId: farmId ?? this.farmId,
      seasonId: seasonId ?? this.seasonId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
