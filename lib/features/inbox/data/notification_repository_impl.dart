import 'dart:async';
import 'package:collection/collection.dart';

import '../../../core/data/hive/hive_boxes.dart';
import '../../../core/data/hive/hive_manager.dart';
import '../../../core/domain/repositories/notification_repository.dart';
import '../../../core/models/notification_item.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl() : _manager = HiveManager.instance;

  final HiveManager _manager;

  @override
  Stream<List<NotificationItem>> watchNotifications(String userId) {
    final box = _manager.box<NotificationItem>(HiveBoxes.notifications);
    final controller = StreamController<List<NotificationItem>>.broadcast();

    void emit() {
      final notifications = box.values
          .where((item) => item.userId == userId)
          .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
          .toList();
      controller.add(notifications);
    }

    emit();
    final sub = box.watch().listen((_) => emit());
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  @override
  Future<void> upsertNotification(NotificationItem notification) async {
    await _manager.box<NotificationItem>(HiveBoxes.notifications).put(notification.id, notification);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final box = _manager.box<NotificationItem>(HiveBoxes.notifications);
    final existing = box.get(notificationId);
    if (existing == null) {
      return;
    }
    await box.put(notificationId, existing.copyWith(read: true));
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _manager.box<NotificationItem>(HiveBoxes.notifications).delete(notificationId);
  }
}
