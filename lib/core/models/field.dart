import 'enums.dart';
import 'time_slot.dart';

class Field {
  const Field({
    required this.id,
    required this.venueId,
    required this.sport,
    required this.capacity,
    required this.pricePerHour,
    required this.availabilitySlots,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] as String,
      venueId: json['venueId'] as String,
      sport: sportFromString(json['sport'] as String),
      capacity: json['capacity'] as int,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      availabilitySlots: (json['availabilitySlots'] as List<dynamic>)
          .map((slot) => TimeSlot.fromJson(slot as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String venueId;
  final Sport sport;
  final int capacity;
  final double pricePerHour;
  final List<TimeSlot> availabilitySlots;

  Map<String, dynamic> toJson() => {
        'id': id,
        'venueId': venueId,
        'sport': sport.name,
        'capacity': capacity,
        'pricePerHour': pricePerHour,
        'availabilitySlots': availabilitySlots.map((slot) => slot.toJson()).toList(),
      };
}
