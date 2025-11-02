import 'package:flutter_test/flutter_test.dart';

import 'package:saha/core/models/enums.dart';
import 'package:saha/core/models/event.dart';
import 'package:saha/core/models/geo_point.dart';

void main() {
  test('event attendees do not exceed capacity and avoid duplicates', () {
    final event = Event(
      id: 'e1',
      type: EventType.walk,
      title: 'Morning Walk',
      description: 'Test route',
      level: Level.beginner,
      requirements: const ['Shoes'],
      timeWindow: TimeWindow.morning,
      startAt: DateTime(2024, 1, 1, 6),
      endAt: DateTime(2024, 1, 1, 7),
      location: const GeoPoint(lat: 24.7, lon: 46.6),
      capacity: 2,
      fee: 0,
      organizerId: 'u1',
      attendeeIds: const ['u1'],
    );

    expect(event.attendeeIds.contains('u1'), isTrue);
    expect(event.attendeeIds.length < event.capacity, isTrue);

    final updated = event.copyWith(attendeeIds: [...event.attendeeIds, 'u2']);
    expect(updated.attendeeIds.length, equals(updated.capacity));

    final attemptingDuplicate = updated.attendeeIds.contains('u2');
    expect(attemptingDuplicate, isTrue);
    expect(updated.attendeeIds.contains('u3'), isFalse);
  });
}
