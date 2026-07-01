
class GroupModel {
  final String id;
  final String name;
  final int memberCount;
  final String progressLabel;
  final double progressValue;

  GroupModel({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.progressLabel,
    required this.progressValue,
  });


  String get percentageText => '${(progressValue * 100).toInt()}%';

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      progressLabel: json['progressLabel'] ?? '',
      progressValue: (json['progressValue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}