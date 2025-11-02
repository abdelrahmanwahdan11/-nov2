import 'package:flutter_test/flutter_test.dart';
import 'package:saha/src/core/models/models.dart';

void main() {
  test('event generates six digit check-in code', () {
    final event = Event(
      id: 'e1',
      type: 'walk',
      title: 'صباح نشيط',
      description: 'جولة قصيرة',
      level: 'beginner',
      requirements: const ['حذاء'],
      timeWindow: 'morning',
      startAt: DateTime(2024, 1, 1, 8),
      endAt: DateTime(2024, 1, 1, 9),
      location: const GeoPoint(lat: 24.7, lon: 46.7),
      capacity: 10,
      fee: 0,
      organizerId: 'u1',
    );

    final code = event.checkinCode();
    expect(code.length, 6);
    expect(int.tryParse(code), isNotNull);
  });
}
