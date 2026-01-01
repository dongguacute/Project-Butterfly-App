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
  final bool? isThighHard;
  final bool? isCalfHard;
  final bool? isLegBoneStraight;
  final double? weight;
  final double? height;
  final String? reminderTime;
  final int currentDay;
  final String? targetLegShape;

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
    this.isThighHard,
    this.isCalfHard,
    this.isLegBoneStraight,
    this.weight,
    this.height,
    this.reminderTime,
    this.currentDay = 1,
    this.targetLegShape,
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
      'isThighHard': isThighHard == null ? null : (isThighHard! ? 1 : 0),
      'isCalfHard': isCalfHard == null ? null : (isCalfHard! ? 1 : 0),
      'isLegBoneStraight': isLegBoneStraight == null ? null : (isLegBoneStraight! ? 1 : 0),
      'weight': weight,
      'height': height,
      'reminderTime': reminderTime,
      'currentDay': currentDay,
      'targetLegShape': targetLegShape,
    };
  }

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      progress: (map['progress'] as num).toDouble(),
      iconName: map['iconName'],
      colorValue: map['colorValue'],
      planType: map['planType'],
      thighCircumference: map['thighCircumference'] != null ? (map['thighCircumference'] as num).toDouble() : null,
      calfCircumference: map['calfCircumference'] != null ? (map['calfCircumference'] as num).toDouble() : null,
      isThighClosed: map['isThighClosed'] == null ? null : map['isThighClosed'] == 1,
      isCalfClosed: map['isCalfClosed'] == null ? null : map['isCalfClosed'] == 1,
      isThighHard: map['isThighHard'] == null ? null : map['isThighHard'] == 1,
      isCalfHard: map['isCalfHard'] == null ? null : map['isCalfHard'] == 1,
      isLegBoneStraight: map['isLegBoneStraight'] == null ? null : map['isLegBoneStraight'] == 1,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
      reminderTime: map['reminderTime'],
      currentDay: map['currentDay'] ?? 1,
      targetLegShape: map['targetLegShape'],
    );
  }
}
