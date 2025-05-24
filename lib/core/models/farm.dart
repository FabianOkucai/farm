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
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['farm_id'] ?? json['id'],
      name: json['name'],
      size: (json['size'] as num).toDouble(),
      district: json['district'],
      village: json['village'],
      farmerId: json['farmer_id'],
      plantingDate: DateTime.parse(json['planting_date']),
      currentSeasonMonth: json['current_season_month'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size': size,
      'district': district,
      'village': village,
      'farmer_id': farmerId,
      'planting_date': plantingDate.toIso8601String(),
      'current_season_month': currentSeasonMonth,
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
    );
  }
}
