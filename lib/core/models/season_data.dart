class SeasonActivity {
  final String title;
  final String description;

  SeasonActivity({
    required this.title,
    required this.description,
  });

  factory SeasonActivity.fromJson(Map<String, dynamic> json) {
    return SeasonActivity(
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}

class SeasonData {
  final int month;
  final String title;
  final String shortDescription;
  final String? fullInstructions;
  final List<SeasonActivity>? activities;

  SeasonData({
    required this.month,
    required this.title,
    required this.shortDescription,
    this.fullInstructions,
    this.activities,
  });

  factory SeasonData.fromJson(Map<String, dynamic> json) {
    return SeasonData(
      month: json['month'],
      title: json['title'],
      shortDescription: json['short_description'],
      fullInstructions: json['full_instructions'],
      activities: json['activities'] != null
          ? (json['activities'] as List)
              .map((activity) => SeasonActivity.fromJson(activity))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'title': title,
      'short_description': shortDescription,
      if (fullInstructions != null) 'full_instructions': fullInstructions,
      if (activities != null)
        'activities': activities!.map((activity) => activity.toJson()).toList(),
    };
  }
}
