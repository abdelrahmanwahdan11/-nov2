import 'package:flutter_test/flutter_test.dart';

import 'package:saha/core/models/time_slot.dart';

void main() {
  test('detects overlapping time slots', () {
    final slotA = TimeSlot(
      start: DateTime(2023, 1, 1, 8, 0),
      end: DateTime(2023, 1, 1, 9, 0),
    );
    final slotB = TimeSlot(
      start: DateTime(2023, 1, 1, 8, 30),
      end: DateTime(2023, 1, 1, 9, 30),
    );
    final slotC = TimeSlot(
      start: DateTime(2023, 1, 1, 9, 0),
      end: DateTime(2023, 1, 1, 10, 0),
    );

    expect(slotA.overlaps(slotB), isTrue);
    expect(slotA.overlaps(slotC), isFalse);
  });
}
