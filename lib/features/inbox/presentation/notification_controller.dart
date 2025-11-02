import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/repositories/notification_repository.dart';
import '../../../core/models/notification_item.dart';
import '../../../core/services/providers.dart';

class NotificationController extends StateNotifier<AsyncValue<void>> {
  NotificationController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  NotificationRepository get _repository => _ref.read(notificationRepositoryProvider);

  Future<void> markRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      state = const AsyncValue.data(null);
    }
  }

  Future<void> push(NotificationItem notification) async {
    try {
      await _repository.upsertNotification(notification);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
      state = const AsyncValue.data(null);
    }
  }
}

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, AsyncValue<void>>(
  (ref) => NotificationController(ref),
);
