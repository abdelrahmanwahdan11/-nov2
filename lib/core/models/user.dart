import 'enums.dart';

class User {
  const User({
    required this.id,
    required this.name,
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    required this.level,
    required this.preferences,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      level: levelFromString(json['level'] as String),
      preferences: (json['preferences'] as List<dynamic>? ?? []).cast<String>(),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  final String id;
  final String name;
  final String? gender;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final Level level;
  final List<String> preferences;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'age': age,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'level': level.name,
        'preferences': preferences,
        'avatarUrl': avatarUrl,
      };
}
