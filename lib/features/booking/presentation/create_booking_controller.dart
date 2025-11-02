import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/repositories/booking_repository.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/time_slot.dart';
import '../../../core/services/providers.dart';
import '../../../core/domain/repositories/notification_repository.dart';
import '../../../core/domain/repositories/wallet_repository.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/notification_item.dart';
import '../../../core/models/wallet_tx.dart';
import '../../../shared/services/notifications.dart';

class CreateBookingController extends StateNotifier<AsyncValue<Booking?>> {
  CreateBookingController(this._read) : super(const AsyncValue.data(null));

  final Ref _read;

  BookingRepository get _repository => _read.read(bookingRepositoryProvider);
  NotificationRepository get _notificationRepository => _read.read(notificationRepositoryProvider);
  WalletRepository get _walletRepository => _read.read(walletRepositoryProvider);

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
      await _notificationRepository.upsertNotification(
        NotificationItem(
          id: 'ntf_${booking.id}',
          userId: participantIds.first,
          title: 'تم إنشاء حجز جديد',
          body: 'تم حفظ حجزك للملعب ${booking.fieldId}.',
          createdAt: DateTime.now(),
          type: 'booking',
        ),
      );
      state = AsyncValue.data(booking);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> markParticipantPaid({
    required Booking booking,
    required String userId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final alreadyPaid = booking.payments[userId] ?? false;
      final wasFullyPaid = booking.payments.values.isNotEmpty && booking.payments.values.every((paid) => paid);
      final updated = booking.markParticipantPaid(userId);
      await _repository.updateBooking(updated);

      if (!alreadyPaid && updated.payments[userId] == true) {
        final share = booking.price / booking.userIds.length;
        final tx = WalletTx(
          id: 'tx_${booking.id}_$userId_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          amount: share,
          type: WalletType.debit,
          createdAt: DateTime.now(),
          note: 'حصة حجز ${booking.fieldId}',
        );
        await _walletRepository.addTransaction(tx);
      }

      if (!wasFullyPaid && updated.payments.values.every((paid) => paid)) {
        final organizerId = booking.userIds.first;
        final share = booking.price / booking.userIds.length;
        final creditTx = WalletTx(
          id: 'tx_${booking.id}_credit_${DateTime.now().millisecondsSinceEpoch}',
          userId: organizerId,
          amount: share * booking.userIds.length,
          type: WalletType.credit,
          createdAt: DateTime.now(),
          note: 'تم تأكيد حجز ${booking.fieldId}',
        );
        await _walletRepository.addTransaction(creditTx);
        await _notificationRepository.upsertNotification(
          NotificationItem(
            id: 'ntf_${booking.id}_confirmed',
            userId: organizerId,
            title: 'اكتمل الدفع',
            body: 'تم تأكيد الحجز بعد اكتمال الدفع.',
            createdAt: DateTime.now(),
            type: 'booking',
          ),
        );
      }

      state = AsyncValue.data(updated);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final createBookingControllerProvider =
    StateNotifierProvider.autoDispose<CreateBookingController, AsyncValue<Booking?>>(
  (ref) => CreateBookingController(ref),
);
