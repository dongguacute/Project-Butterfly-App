class Plan {
  final int? id;
  final String title;
  final String subtitle;
  final double progress;
  final String iconName;
  final int colorValue;

  Plan({
    this.id,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.iconName,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'progress': progress,
      'iconName': iconName,
      'colorValue': colorValue,
    };
  }

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      progress: map['progress'],
      iconName: map['iconName'],
      colorValue: map['colorValue'],
    );
  }
}
