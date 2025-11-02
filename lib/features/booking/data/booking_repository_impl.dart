import 'dart:async';
import 'package:collection/collection.dart';

import '../../../core/data/hive/hive_boxes.dart';
import '../../../core/data/hive/hive_manager.dart';
import '../../../core/domain/repositories/booking_repository.dart';
import '../../../core/domain/repositories/field_repository.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/time_slot.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._fieldRepository) : _manager = HiveManager.instance;

  final HiveManager _manager;
  final FieldRepository _fieldRepository;

  @override
  Stream<List<Booking>> watchUserBookings(String userId) {
    final box = _manager.box<Booking>(HiveBoxes.bookings);
    final controller = StreamController<List<Booking>>.broadcast();

    void emit() {
      final bookings = box.values.where((booking) => booking.userIds.contains(userId)).sorted((a, b) => a.start.compareTo(b.start)).toList();
      controller.add(bookings);
    }

    emit();
    final sub = box.watch().listen((_) => emit());
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  @override
  Stream<List<Booking>> watchFieldBookings(String fieldId) {
    final box = _manager.box<Booking>(HiveBoxes.bookings);
    final controller = StreamController<List<Booking>>.broadcast();

    void emit() {
      final bookings = box.values.where((booking) => booking.fieldId == fieldId).sorted((a, b) => a.start.compareTo(b.start)).toList();
      controller.add(bookings);
    }

    emit();
    final sub = box.watch().listen((_) => emit());
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  @override
  Future<Booking> createBooking({
    required String fieldId,
    required List<String> participantIds,
    required TimeSlot slot,
    required double price,
    required bool splitPayment,
  }) async {
    final available = await _fieldRepository.isSlotAvailable(fieldId: fieldId, slot: slot);
    if (!available) {
      throw StateError('الوقت المختار غير متاح');
    }

    final payments = <String, bool>{
      for (final id in participantIds) id: !splitPayment,
    };

    final booking = Booking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      fieldId: fieldId,
      userIds: participantIds,
      start: slot.start,
      end: slot.end,
      price: price,
      status: participantIds.length > 1 && splitPayment ? BookingStatus.pending : BookingStatus.confirmed,
      splitPayment: splitPayment,
      payments: payments,
    );

    await _fieldRepository.reserveSlot(fieldId: fieldId, booking: booking);
    return booking;
  }

  @override
  Future<Booking?> getBookingById(String id) async {
    return _manager.box<Booking>(HiveBoxes.bookings).get(id);
  }

  @override
  Future<bool> canCheckInBooking(String bookingId, String userId, DateTime timestamp) async {
    final booking = _manager.box<Booking>(HiveBoxes.bookings).get(bookingId);
    if (booking == null) {
      return false;
    }
    if (!booking.userIds.contains(userId)) {
      return false;
    }
    final windowStart = booking.start.subtract(const Duration(minutes: 15));
    final windowEnd = booking.end.add(const Duration(minutes: 15));
    if (timestamp.isBefore(windowStart) || timestamp.isAfter(windowEnd)) {
      return false;
    }
    return booking.status != BookingStatus.cancelled;
  }

  @override
  Future<void> updateBooking(Booking booking) async {
    await _manager.box<Booking>(HiveBoxes.bookings).put(booking.id, booking);
  }
}
