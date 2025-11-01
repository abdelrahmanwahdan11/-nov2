class HealthMetric {
  const HealthMetric({
    required this.id,
    required this.userId,
    required this.date,
    this.weightKg,
    this.waistCm,
    this.bodyFatPct,
    this.steps,
    this.calories,
    this.waterMl,
  });

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      waistCm: (json['waist_cm'] as num?)?.toDouble(),
      bodyFatPct: (json['body_fat_pct'] as num?)?.toDouble(),
      steps: json['steps'] as int?,
      calories: json['calories'] as int?,
      waterMl: json['water_ml'] as int?,
    );
  }

  final String id;
  final String userId;
  final DateTime date;
  final double? weightKg;
  final double? waistCm;
  final double? bodyFatPct;
  final int? steps;
  final int? calories;
  final int? waterMl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'weight_kg': weightKg,
        'waist_cm': waistCm,
        'body_fat_pct': bodyFatPct,
        'steps': steps,
        'calories': calories,
        'water_ml': waterMl,
      };
}
