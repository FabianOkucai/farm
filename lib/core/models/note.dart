// lib/core/models/note.dart
enum NoteSyncStatus { pending, synced, failed }

class Note {
  final String id; // Local ID (always exists)
  final String? serverId; // Backend ID (null until synced)
  final String title;
  final String content;
  final String farmId;
  final String? seasonId;
  final String userId; // This will be the farmer UUID
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  final NoteSyncStatus syncStatus;
  final bool isDeleted;

  Note({
    required this.id,
    this.serverId,
    required this.title,
    required this.content,
    required this.farmId,
    this.seasonId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    this.syncStatus = NoteSyncStatus.pending,
    this.isDeleted = false,
  });

  // Create from backend response
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['local_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      serverId: json['id']?.toString(),
      title: json['title'] as String,
      content: json['content'] as String,
      farmId: json['farm_id']?.toString() ?? json['farmId']?.toString() ?? '',
      seasonId: json['season_id']?.toString() ?? json['seasonId']?.toString(),
      userId: json['farmer_id']?.toString() ?? json['userId']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
      syncedAt: json['synced_at'] != null ? DateTime.parse(json['synced_at']) : null,
      syncStatus: _parseSyncStatus(json['sync_status']),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  // Convert to format for backend sync
  Map<String, dynamic> toSyncJson() {
    return {
      'local_id': id,
      'title': title,
      'content': content,
      'farm_id': farmId,
      'season_id': seasonId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert for local storage
  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'server_id': serverId,
      'title': title,
      'content': content,
      'farm_id': farmId,
      'season_id': seasonId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'sync_status': syncStatus.toString().split('.').last,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  // Create from local storage
  factory Note.fromLocalJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      serverId: json['server_id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      farmId: json['farm_id'] as String,
      seasonId: json['season_id'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncedAt: json['synced_at'] != null ? DateTime.parse(json['synced_at'] as String) : null,
      syncStatus: _parseSyncStatus(json['sync_status']),
      isDeleted: (json['is_deleted'] as int?) == 1,
    );
  }

  static NoteSyncStatus _parseSyncStatus(dynamic status) {
    if (status == null) return NoteSyncStatus.pending;

    switch (status.toString()) {
      case 'synced':
        return NoteSyncStatus.synced;
      case 'failed':
        return NoteSyncStatus.failed;
      case 'pending':
      default:
        return NoteSyncStatus.pending;
    }
  }

  Note copyWith({
    String? id,
    String? serverId,
    String? title,
    String? content,
    String? farmId,
    String? seasonId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    NoteSyncStatus? syncStatus,
    bool? isDeleted,
  }) {
    return Note(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      content: content ?? this.content,
      farmId: farmId ?? this.farmId,
      seasonId: seasonId ?? this.seasonId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // Utility getters
  bool get isSynced => syncStatus == NoteSyncStatus.synced;
  bool get isPending => syncStatus == NoteSyncStatus.pending;
  bool get hasFailed => syncStatus == NoteSyncStatus.failed;
  bool get needsSync => syncStatus != NoteSyncStatus.synced && !isDeleted;
}