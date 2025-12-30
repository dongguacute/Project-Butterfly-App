class Plan {
  final int? id;
  final String title;
  final String subtitle;
  final double progress;
  final String iconName;
  final int colorValue;
  final String? planType;
  final double? thighCircumference;
  final double? calfCircumference;
  final bool? isThighClosed;
  final bool? isCalfClosed;

  Plan({
    this.id,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.iconName,
    required this.colorValue,
    this.planType,
    this.thighCircumference,
    this.calfCircumference,
    this.isThighClosed,
    this.isCalfClosed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'progress': progress,
      'iconName': iconName,
      'colorValue': colorValue,
      'planType': planType,
      'thighCircumference': thighCircumference,
      'calfCircumference': calfCircumference,
      'isThighClosed': isThighClosed == null ? null : (isThighClosed! ? 1 : 0),
      'isCalfClosed': isCalfClosed == null ? null : (isCalfClosed! ? 1 : 0),
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
      planType: map['planType'],
      thighCircumference: map['thighCircumference'],
      calfCircumference: map['calfCircumference'],
      isThighClosed: map['isThighClosed'] == null ? null : map['isThighClosed'] == 1,
      isCalfClosed: map['isCalfClosed'] == null ? null : map['isCalfClosed'] == 1,
    );
  }
}
