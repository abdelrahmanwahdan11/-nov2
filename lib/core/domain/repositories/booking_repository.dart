import '../../models/booking.dart';
import '../../models/time_slot.dart';

abstract class BookingRepository {
  Stream<List<Booking>> watchUserBookings(String userId);
  Stream<List<Booking>> watchFieldBookings(String fieldId);
  Future<Booking> createBooking({
    required String fieldId,
    required List<String> participantIds,
    required TimeSlot slot,
    required double price,
    required bool splitPayment,
  });
  Future<void> updateBooking(Booking booking);
}
