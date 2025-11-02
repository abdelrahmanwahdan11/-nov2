import 'package:flutter_test/flutter_test.dart';
import 'package:saha/src/core/models/models.dart';

void main() {
  test('encode and decode events roundtrip', () {
    final original = [
      Event(
        id: 'e1',
        type: 'walk',
        title: 'Morning Walk',
        description: 'A gentle stroll',
        level: 'beginner',
        requirements: const ['Shoes'],
        timeWindow: 'morning',
        startAt: DateTime(2024, 1, 1, 8),
        endAt: DateTime(2024, 1, 1, 9),
        location: const GeoPoint(lat: 24.0, lon: 46.0),
        capacity: 10,
        fee: 0,
        organizerId: 'u1',
      ),
    ];

    final json = encodeList(original);
    final result = decodeList<Event>(json);

    expect(result.first.title, original.first.title);
    expect(result.first.checkinCode().length, 6);
  });
}
