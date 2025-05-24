enum SeasonStatus {
  planning,
  active,
  completed
}

class Season {
  final String id;
  final String farmId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final SeasonStatus status;
  final List<String> noteIds;
  final List<String> taskIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Season({
    required this.id,
    required this.farmId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.noteIds,
    required this.taskIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'],
      farmId: json['farmId'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: SeasonStatus.values.byName(json['status']),
      noteIds: List<String>.from(json['noteIds']),
      taskIds: List<String>.from(json['taskIds']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'noteIds': noteIds,
      'taskIds': taskIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Season copyWith({
    String? id,
    String? farmId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    SeasonStatus? status,
    List<String>? noteIds,
    List<String>? taskIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Season(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      noteIds: noteIds ?? this.noteIds,
      taskIds: taskIds ?? this.taskIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
