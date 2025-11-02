import 'package:flutter_test/flutter_test.dart';

import 'package:saha/core/models/booking.dart';
import 'package:saha/core/models/enums.dart';

void main() {
  test('booking moves to confirmed when all participants pay', () {
    final booking = Booking(
      id: 'bk_1',
      fieldId: 'f1',
      userIds: ['u1', 'u2'],
      start: DateTime(2024, 1, 1, 10),
      end: DateTime(2024, 1, 1, 11),
      price: 200,
      status: BookingStatus.pending,
      splitPayment: true,
      payments: const {'u1': false, 'u2': false},
    );

    final afterFirst = booking.markParticipantPaid('u1');
    expect(afterFirst.status, BookingStatus.pending);
    expect(afterFirst.payments['u1'], isTrue);

    final afterSecond = afterFirst.markParticipantPaid('u2');
    expect(afterSecond.status, BookingStatus.confirmed);
    expect(afterSecond.payments.values.every((paid) => paid), isTrue);
  });
}
