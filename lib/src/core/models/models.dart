import 'dart:convert';
import 'dart:ui';

class GeoPoint {
  const GeoPoint({required this.lat, required this.lon});
  final double lat;
  final double lon;

  factory GeoPoint.fromJson(Map<String, dynamic> json) =>
      GeoPoint(lat: (json['lat'] as num).toDouble(), lon: (json['lon'] as num).toDouble());

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon};
}

class TimeSlot {
  TimeSlot({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
      );

  Map<String, dynamic> toJson() => {'start': start.toIso8601String(), 'end': end.toIso8601String()};
}

class Venue {
  Venue({
    required this.id,
    required this.name,
    required this.geo,
    required this.address,
    required this.amenities,
    required this.photos,
    required this.rating,
    this.policies,
  });

  final String id;
  final String name;
  final GeoPoint geo;
  final String address;
  final List<String> amenities;
  final List<String> photos;
  final double rating;
  final String? policies;

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'] as String,
        name: json['name'] as String,
        geo: GeoPoint.fromJson(json['geo'] as Map<String, dynamic>),
        address: json['address'] as String,
        amenities: (json['amenities'] as List? ?? const []).cast<String>(),
        photos: (json['photos'] as List? ?? const []).cast<String>(),
        rating: (json['rating'] as num).toDouble(),
        policies: json['policies'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'geo': geo.toJson(),
        'address': address,
        'amenities': amenities,
        'photos': photos,
        'rating': rating,
        'policies': policies,
      };
}

class Field {
  Field({
    required this.id,
    required this.venueId,
    required this.sport,
    required this.capacity,
    required this.pricePerHour,
    required this.availabilitySlots,
  });

  final String id;
  final String venueId;
  final String sport;
  final int capacity;
  final double pricePerHour;
  final List<TimeSlot> availabilitySlots;

  factory Field.fromJson(Map<String, dynamic> json) => Field(
        id: json['id'] as String,
        venueId: json['venueId'] as String,
        sport: json['sport'] as String,
        capacity: json['capacity'] as int,
        pricePerHour: (json['pricePerHour'] as num).toDouble(),
        availabilitySlots: (json['availabilitySlots'] as List? ?? const [])
            .map((e) => TimeSlot.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'venueId': venueId,
        'sport': sport,
        'capacity': capacity,
        'pricePerHour': pricePerHour,
        'availabilitySlots': availabilitySlots.map((e) => e.toJson()).toList(),
      };
}

class RoutePoint {
  RoutePoint({required this.lat, required this.lon});
  final double lat;
  final double lon;

  factory RoutePoint.fromJson(Map<String, dynamic> json) =>
      RoutePoint(lat: (json['lat'] as num).toDouble(), lon: (json['lon'] as num).toDouble());

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon};
}

class Event {
  Event({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.level,
    required this.requirements,
    required this.timeWindow,
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.capacity,
    required this.fee,
    required this.organizerId,
    List<String>? participants,
    List<RoutePoint>? route,
  })  : participants = participants ?? <String>[],
        route = route ?? <RoutePoint>[];

  final String id;
  final String type;
  final String title;
  final String description;
  final String level;
  final List<String> requirements;
  final String timeWindow;
  final DateTime startAt;
  final DateTime endAt;
  final GeoPoint location;
  final int capacity;
  final double fee;
  final String organizerId;
  final List<String> participants;
  final List<RoutePoint> route;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        level: json['level'] as String,
        requirements: (json['requirements'] as List? ?? const []).cast<String>(),
        timeWindow: json['timeWindow'] as String,
        startAt: DateTime.parse(json['startAt'] as String),
        endAt: DateTime.parse(json['endAt'] as String),
        location: GeoPoint.fromJson(json['location'] as Map<String, dynamic>),
        capacity: json['capacity'] as int,
        fee: (json['fee'] as num).toDouble(),
        organizerId: json['organizerId'] as String,
        participants: (json['participants'] as List?)?.cast<String>(),
        route: (json['route'] as List?)
                ?.map((e) => RoutePoint.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const <RoutePoint>[],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'description': description,
        'level': level,
        'requirements': requirements,
        'timeWindow': timeWindow,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'location': location.toJson(),
        'capacity': capacity,
        'fee': fee,
        'organizerId': organizerId,
        'participants': participants,
        'route': route.map((e) => e.toJson()).toList(),
      };

  List<Offset> get previewPoints {
    if (route.isEmpty) {
      return [
        const Offset(0.1, 0.8),
        const Offset(0.3, 0.2),
        const Offset(0.6, 0.5),
        const Offset(0.9, 0.3),
      ];
    }
    final minLat = route.map((e) => e.lat).reduce((a, b) => a < b ? a : b);
    final maxLat = route.map((e) => e.lat).reduce((a, b) => a > b ? a : b);
    final minLon = route.map((e) => e.lon).reduce((a, b) => a < b ? a : b);
    final maxLon = route.map((e) => e.lon).reduce((a, b) => a > b ? a : b);
    final latRange = (maxLat - minLat).abs().clamp(0.0001, double.infinity);
    final lonRange = (maxLon - minLon).abs().clamp(0.0001, double.infinity);
    return route
        .map(
          (p) => Offset(
            ((p.lon - minLon) / lonRange).clamp(0.0, 1.0),
            1 - ((p.lat - minLat) / latRange).clamp(0.0, 1.0),
          ),
        )
        .toList();
  }

  String checkinCode() {
    final base = id.hashCode ^ startAt.millisecondsSinceEpoch;
    final value = (base % 1000000).abs();
    return value.toString().padLeft(6, '0');
  }
}

class Story {
  Story({
    required this.id,
    required this.userId,
    required this.isPro,
    required this.mediaRef,
    required this.caption,
    required this.createdAt,
    required this.likes,
  });

  final String id;
  final String userId;
  final bool isPro;
  final String mediaRef;
  final String caption;
  final DateTime createdAt;
  int likes;

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        userId: json['userId'] as String,
        isPro: json['isPro'] as bool,
        mediaRef: (json['mediaUrl'] ?? json['mediaRef']) as String,
        caption: json['caption'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        likes: json['likes'] is int
            ? json['likes'] as int
            : (json['likes'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'isPro': isPro,
        'mediaRef': mediaRef,
        'caption': caption,
        'createdAt': createdAt.toIso8601String(),
        'likes': likes,
      };
}

class HealthMetric {
  HealthMetric({
    required this.id,
    required this.date,
    this.weightKg,
    this.steps,
    this.waterMl,
  });

  final String id;
  final DateTime date;
  final double? weightKg;
  final int? steps;
  final int? waterMl;

  factory HealthMetric.fromJson(Map<String, dynamic> json) => HealthMetric(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        steps: (json['steps'] as num?)?.toInt(),
        waterMl: (json['waterMl'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        'steps': steps,
        'waterMl': waterMl,
      };
}

class Booking {
  Booking({
    required this.id,
    required this.fieldId,
    required this.userIds,
    required this.start,
    required this.end,
    required this.price,
    required this.status,
    required this.splitPayment,
    Map<String, bool>? payments,
  }) : payments = payments ?? {for (final id in userIds) id: id == userIds.first};

  final String id;
  final String fieldId;
  final List<String> userIds;
  final DateTime start;
  final DateTime end;
  final double price;
  String status;
  final bool splitPayment;
  final Map<String, bool> payments;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        fieldId: json['fieldId'] as String,
        userIds: (json['userIds'] as List? ?? const []).cast<String>(),
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
        price: (json['price'] as num).toDouble(),
        status: json['status'] as String,
        splitPayment: json['splitPayment'] as bool,
        payments: (json['payments'] as Map?)?.map(
              (key, value) => MapEntry(key as String, value as bool),
            ) ??
            const {},
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fieldId': fieldId,
        'userIds': userIds,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'price': price,
        'status': status,
        'splitPayment': splitPayment,
        'payments': payments,
      };
}

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  bool read;

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        read: json['read'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };
}

class WalletTx {
  WalletTx({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String userId;
  final double amount;
  final String type;
  final DateTime createdAt;
  final String? note;

  factory WalletTx.fromJson(Map<String, dynamic> json) => WalletTx(
        id: json['id'] as String,
        userId: json['userId'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'amount': amount,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };
}

class User {
  User({
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

  final String id;
  final String name;
  final String? gender;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final String level;
  final List<String> preferences;
  final String? avatarUrl;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        gender: json['gender'] as String?,
        age: (json['age'] as num?)?.toInt(),
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        level: json['level'] as String? ?? 'beginner',
        preferences: (json['preferences'] as List? ?? const []).cast<String>(),
        avatarUrl: json['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'age': age,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'level': level,
        'preferences': preferences,
        'avatarUrl': avatarUrl,
      };
}

T? decodeOne<T>(String raw) {
  final decoded = jsonDecode(raw);
  return _decoderFor<T>()(decoded);
}

List<T> decodeList<T>(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List) return <T>[];
  final decoder = _decoderFor<T>();
  return decoded.map<T>((e) => decoder(e)).toList();
}

String encodeList<T>(List<T> list) => jsonEncode(list.map((e) => _encoderFor(e)).toList());

String encodeOne<T>(T value) => jsonEncode(_encoderFor(value));

typedef _JsonDecoder<T> = T Function(dynamic value);

_JsonDecoder<T> _decoderFor<T>() {
  if (T == Venue) {
    return (value) => Venue.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  if (T == Field) {
    return (value) => Field.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  if (T == Event) {
    return (value) => Event.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  if (T == Story) {
    return (value) => Story.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  if (T == HealthMetric) {
    return (value) => HealthMetric.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  if (T == Booking) {
    return (value) => Booking.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  if (T == NotificationItem) {
    return (value) => NotificationItem.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  if (T == WalletTx) {
    return (value) => WalletTx.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  if (T == User) {
    return (value) => User.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  if (T == GeoPoint) {
    return (value) => GeoPoint.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  if (T == TimeSlot) {
    return (value) => TimeSlot.fromJson(Map<String, dynamic>.from(value as Map)) as T;
  }
  return (value) => value as T;
}

dynamic _encoderFor(dynamic value) {
  if (value is Venue) return value.toJson();
  if (value is Field) return value.toJson();
  if (value is Event) return value.toJson();
  if (value is Story) return value.toJson();
  if (value is HealthMetric) return value.toJson();
  if (value is Booking) return value.toJson();
  if (value is NotificationItem) return value.toJson();
  if (value is WalletTx) return value.toJson();
  if (value is User) return value.toJson();
  if (value is GeoPoint) return value.toJson();
  if (value is TimeSlot) return value.toJson();
  if (value is RoutePoint) return value.toJson();
  return value;
}
