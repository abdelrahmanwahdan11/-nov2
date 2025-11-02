import '../../models/booking.dart';
import '../../models/field.dart';
import '../../models/time_slot.dart';

abstract class FieldRepository {
  Future<Field?> getFieldById(String fieldId);
  Future<bool> isSlotAvailable({
    required String fieldId,
    required TimeSlot slot,
  });
  Future<void> reserveSlot({
    required String fieldId,
    required Booking booking,
  });
}
