class Badges {
  final String code;
  final String name;
  final String description;
  final DateTime awardedAt;
  final bool isNew;

  Badges({
    required this.code,
    required this.name,
    required this.description,
    required this.awardedAt,
    this.isNew = false,
  });

  factory Badges.fromJson(Map<String, dynamic> json) {
    return Badges(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      awardedAt: DateTime.tryParse(json['awardedAt'] ?? '') ?? DateTime.now(),
      isNew: json['isNew'] ?? false,
    );
  }
  
  String get emoji {
    switch (code) {
      case 'FIRST_5K': return '🥇';
      case 'STREAK_7': return '⚡';
      case 'STREAK_30': return '🔥';
      case 'WEEKLY_20KM': return '🔋';
      case 'MONTHLY_100KM': return '🌍';
      default: return '🏅';
    }
  }
}