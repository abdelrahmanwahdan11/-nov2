import 'dart:convert';

class GeoPoint {
  const GeoPoint({required this.lat, required this.lon});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  factory GeoPoint.fromString(String value) {
    final parts = value.split(',');
    return GeoPoint(lat: double.parse(parts.first), lon: double.parse(parts.last));
  }

  final double lat;
  final double lon;

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon};

  @override
  String toString() => jsonEncode(toJson());
}
