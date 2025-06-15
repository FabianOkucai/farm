class SeasonalMonth {
  final int month;
  final String title;
  final String shortDescription;
  final String fullInstructions;
  final List<String> activities;

  const SeasonalMonth({
    required this.month,
    required this.title,
    required this.shortDescription,
    required this.fullInstructions,
    required this.activities,
  });

  factory SeasonalMonth.fromJson(Map<String, dynamic> json) {
    return SeasonalMonth(
      month: json['month'] as int,
      title: json['title'] as String,
      shortDescription: json['short_description'] as String,
      fullInstructions: json['full_instructions'] as String,
      activities: (json['activities'] as List<dynamic>)
          .map((activity) => activity as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'title': title,
      'short_description': shortDescription,
      'full_instructions': fullInstructions,
      'activities': activities,
    };
  }

  // Get truncated description for cards (half of full instructions)
  String get truncatedInstructions {
    const maxLength = 150; // Adjust as needed
    if (fullInstructions.length <= maxLength) {
      return fullInstructions;
    }

    // Find the last space within the limit to avoid cutting words
    final truncated = fullInstructions.substring(0, maxLength);
    final lastSpace = truncated.lastIndexOf(' ');

    if (lastSpace > 0) {
      return '${truncated.substring(0, lastSpace)}...';
    }

    return '${truncated}...';
  }

  // Get month name
  String get monthName {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }

    return 'Month $month';
  }
}