import '../../../core/data/hive/hive_boxes.dart';
import '../../../core/data/hive/hive_manager.dart';
import '../../../core/domain/repositories/field_repository.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/field.dart';
import '../../../core/models/time_slot.dart';

class FieldRepositoryImpl implements FieldRepository {
  FieldRepositoryImpl() : _manager = HiveManager.instance;

  final HiveManager _manager;

  @override
  Future<Field?> getFieldById(String fieldId) async {
    return _manager.box<Field>(HiveBoxes.fields).get(fieldId);
  }

  @override
  Future<bool> isSlotAvailable({required String fieldId, required TimeSlot slot}) async {
    final box = _manager.box<Booking>(HiveBoxes.bookings);
    final existing = box.values.where((booking) => booking.fieldId == fieldId);
    final field = _manager.box<Field>(HiveBoxes.fields).get(fieldId);
    if (field == null) {
      return false;
    }
    return field.isSlotAvailable(slot, existing);
  }

  @override
  Future<void> reserveSlot({required String fieldId, required Booking booking}) async {
    final box = _manager.box<Booking>(HiveBoxes.bookings);
    await box.put(booking.id, booking);
  }
}
