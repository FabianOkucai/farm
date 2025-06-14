class Farm {
  final String id;
  final String name;
  final double size;
  final String district;
  final String village;
  final String farmerId;
  final DateTime plantingDate;
  final int currentSeasonMonth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool isSynced;
  final bool isDeleted;

  Farm({
    required this.id,
    required this.name,
    required this.size,
    required this.district,
    required this.village,
    required this.farmerId,
    required this.plantingDate,
    required this.currentSeasonMonth,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isSynced = true,
    this.isDeleted = false,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'].toString(), // ✅ FIX: Convert int to String
      name: json['name'] as String,
      size: (json['size'] as num).toDouble(),
      district: json['district'] as String,
      village: json['village'] as String,
      farmerId: json['farmer_id'].toString(), // ✅ FIX: Convert int to String
      plantingDate: DateTime.parse(json['planting_date'] as String),
      currentSeasonMonth: json['current_season_month'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      isSynced: json['is_synced'] as bool? ?? true,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'district': district,
      'village': village,
      'farmer_id': farmerId,
      'planting_date': plantingDate.toIso8601String(),
      'current_season_month': currentSeasonMonth,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_synced': isSynced,
      'is_deleted': isDeleted,
    };
  }

  Farm copyWith({
    String? id,
    String? name,
    double? size,
    String? district,
    String? village,
    String? farmerId,
    DateTime? plantingDate,
    int? currentSeasonMonth,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Farm(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      district: district ?? this.district,
      village: village ?? this.village,
      farmerId: farmerId ?? this.farmerId,
      plantingDate: plantingDate ?? this.plantingDate,
      currentSeasonMonth: currentSeasonMonth ?? this.currentSeasonMonth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
