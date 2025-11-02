import 'package:flutter_test/flutter_test.dart';

import 'package:saha/core/models/booking.dart';
import 'package:saha/core/models/field.dart';
import 'package:saha/core/models/time_slot.dart';
import 'package:saha/core/models/enums.dart';

void main() {
  test('field availability respects existing bookings', () {
    final field = Field(
      id: 'field',
      venueId: 'venue',
      sport: Sport.football,
      capacity: 10,
      pricePerHour: 100,
      availabilitySlots: [
        TimeSlot(start: DateTime(2023, 1, 1, 8), end: DateTime(2023, 1, 1, 9)),
      ],
    );
    final booking = Booking(
      id: 'bk',
      fieldId: 'field',
      userIds: ['u1'],
      start: DateTime(2023, 1, 1, 8, 0),
      end: DateTime(2023, 1, 1, 9, 0),
      price: 100,
      status: BookingStatus.confirmed,
      splitPayment: false,
      payments: const {'u1': true},
    );

    final isAvailable = field.isSlotAvailable(
      TimeSlot(start: DateTime(2023, 1, 1, 8, 30), end: DateTime(2023, 1, 1, 9, 30)),
      [booking],
    );
    expect(isAvailable, isFalse);
  });
}
