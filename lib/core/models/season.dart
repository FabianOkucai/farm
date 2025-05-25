enum SeasonStatus { active, completed, cancelled }

class Season {
  final String id;
  final String farmId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final SeasonStatus status;
  final int currentMonth;
  final DateTime lastUpdated;

  Season({
    required this.id,
    required this.farmId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.currentMonth,
    required this.lastUpdated,
  });

  Season copyWith({
    String? id,
    String? farmId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    SeasonStatus? status,
    int? currentMonth,
    DateTime? lastUpdated,
  }) {
    return Season(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      currentMonth: currentMonth ?? this.currentMonth,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: SeasonStatus.values.firstWhere(
        (e) => e.toString() == 'SeasonStatus.${json['status']}',
      ),
      currentMonth: json['current_month'] as int,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'current_month': currentMonth,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
