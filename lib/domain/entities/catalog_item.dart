enum CatalogType {
  venue,
  streetWorkout,
  walkRoute,
  challenge,
  training,
}

class CatalogItem {
  CatalogItem({
    required this.id,
    required this.type,
    required this.title,
    required this.imageUrl,
    this.sport,
    this.city,
    this.pricePerHour,
    this.level,
    this.lat,
    this.lon,
    this.fee,
    this.time,
    this.distanceKm,
    this.pace,
    this.metric,
    this.goal,
    this.durationMinutes,
    this.kcal,
  });

  final String id;
  final CatalogType type;
  final String title;
  final String imageUrl;
  final String? sport;
  final String? city;
  final double? pricePerHour;
  final String? level;
  final double? lat;
  final double? lon;
  final double? fee;
  final String? time;
  final double? distanceKm;
  final String? pace;
  final String? metric;
  final String? goal;
  final int? durationMinutes;
  final int? kcal;

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    final type = _parseType(json['type'] as String);
    final goalValue = json['goal'];
    return CatalogItem(
      id: json['id'] as String,
      type: type,
      title: json['title'] as String,
      imageUrl: json['img'] as String,
      sport: json['sport'] as String?,
      city: json['city'] as String?,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble(),
      level: json['level'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      fee: (json['fee'] as num?)?.toDouble(),
      time: json['time'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      pace: json['pace'] as String?,
      metric: json['metric'] as String?,
      goal: goalValue == null ? null : goalValue.toString(),
      durationMinutes: (json['duration_min'] as num?)?.toInt(),
      kcal: (json['kcal'] as num?)?.toInt(),
    );
  }

  static CatalogType _parseType(String raw) {
    switch (raw) {
      case 'venue':
        return CatalogType.venue;
      case 'street_workout':
        return CatalogType.streetWorkout;
      case 'walk_route':
        return CatalogType.walkRoute;
      case 'challenge':
        return CatalogType.challenge;
      case 'training':
        return CatalogType.training;
      default:
        return CatalogType.training;
    }
  }
}
