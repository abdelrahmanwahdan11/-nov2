import 'enums.dart';
import 'geo_point.dart';

class Event {
  const Event({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.level,
    required this.requirements,
    required this.timeWindow,
    required this.startAt,
    required this.endAt,
    this.route,
    required this.location,
    required this.capacity,
    required this.fee,
    required this.organizerId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      type: eventTypeFromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      level: levelFromString(json['level'] as String),
      requirements: (json['requirements'] as List<dynamic>).cast<String>(),
      timeWindow: timeWindowFromString(json['timeWindow'] as String),
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      route: (json['route'] as List<dynamic>?)
          ?.map((point) => GeoPoint.fromJson(point as Map<String, dynamic>))
          .toList(),
      location: GeoPoint.fromJson(json['location'] as Map<String, dynamic>),
      capacity: json['capacity'] as int,
      fee: (json['fee'] as num).toDouble(),
      organizerId: json['organizerId'] as String,
    );
  }

  final String id;
  final EventType type;
  final String title;
  final String description;
  final Level level;
  final List<String> requirements;
  final TimeWindow timeWindow;
  final DateTime startAt;
  final DateTime endAt;
  final List<GeoPoint>? route;
  final GeoPoint location;
  final int capacity;
  final double fee;
  final String organizerId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'level': level.name,
        'requirements': requirements,
        'timeWindow': timeWindow.name,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'route': route?.map((point) => point.toJson()).toList(),
        'location': location.toJson(),
        'capacity': capacity,
        'fee': fee,
        'organizerId': organizerId,
      };
}
