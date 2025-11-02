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
    this.isMonthly = false,
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
      isMonthly: json['isMonthly'] as bool? ?? false,
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
  final bool isMonthly;

  HealthMetric copyWith({
    double? weightKg,
    double? waistCm,
    double? bodyFatPct,
    int? steps,
    int? calories,
    int? waterMl,
    bool? isMonthly,
    DateTime? date,
  }) {
    return HealthMetric(
      id: id,
      userId: userId,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      waterMl: waterMl ?? this.waterMl,
      isMonthly: isMonthly ?? this.isMonthly,
    );
  }

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
        'isMonthly': isMonthly,
      };
}
