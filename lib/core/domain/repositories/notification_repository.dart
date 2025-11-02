import '../../models/notification_item.dart';

abstract class NotificationRepository {
  Stream<List<NotificationItem>> watchNotifications(String userId);
  Future<void> upsertNotification(NotificationItem notification);
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
}
