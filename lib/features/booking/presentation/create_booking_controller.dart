import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/repositories/booking_repository.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/time_slot.dart';
import '../../../core/services/providers.dart';
import '../../../shared/services/notifications.dart';

class CreateBookingController extends StateNotifier<AsyncValue<Booking?>> {
  CreateBookingController(this._read) : super(const AsyncValue.data(null));

  final Ref _read;

  BookingRepository get _repository => _read.read(bookingRepositoryProvider);

  Future<void> create({
    required String fieldId,
    required List<String> participantIds,
    required TimeSlot slot,
    required double price,
    required bool splitPayment,
  }) async {
    state = const AsyncValue.loading();
    try {
      final booking = await _repository.createBooking(
        fieldId: fieldId,
        participantIds: participantIds,
        slot: slot,
        price: price,
        splitPayment: splitPayment,
      );
      final reminderTime = booking.start.subtract(const Duration(minutes: 60));
      if (reminderTime.isAfter(DateTime.now())) {
        await notificationsService.scheduleReminder(
          id: booking.hashCode,
          scheduledAt: reminderTime,
          title: 'تذكير حجز',
          body: 'حجزك يبدأ الساعة ${booking.start.hour.toString().padLeft(2, '0')}:${booking.start.minute.toString().padLeft(2, '0')}',
        );
      }
      state = AsyncValue.data(booking);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final createBookingControllerProvider =
    StateNotifierProvider.autoDispose<CreateBookingController, AsyncValue<Booking?>>(
  (ref) => CreateBookingController(ref),
);
