import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saha/core/domain/repositories/notification_repository.dart';
import 'package:saha/core/models/enums.dart';
import 'package:saha/core/models/notification_item.dart';
import 'package:saha/core/models/user.dart';
import 'package:saha/core/services/providers.dart';
import 'package:saha/features/inbox/presentation/inbox_page.dart';

class _FakeNotificationRepository implements NotificationRepository {
  final List<NotificationItem> _store;

  _FakeNotificationRepository(this._store);

  @override
  Future<void> deleteNotification(String notificationId) async {}

  @override
  Stream<List<NotificationItem>> watchNotifications(String userId) {
    return Stream<List<NotificationItem>>.value(_store);
  }

  @override
  Future<void> markAsRead(String notificationId) async {}

  @override
  Future<void> upsertNotification(NotificationItem notification) async {}
}

void main() {
  testWidgets('InboxPage renders notification items', (tester) async {
    final notifications = [
      NotificationItem(
        id: 'n1',
        userId: 'u1',
        title: 'تنبيه مهم',
        body: 'تفاصيل محلية',
        createdAt: DateTime(2024, 1, 1, 12),
        read: false,
        type: 'event',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(
                const User(
                  id: 'u1',
                  name: 'مستخدم',
                  level: Level.beginner,
                  preferences: ['walk'],
                ),
              )),
          notificationsProvider.overrideWithProvider((ref, userId) {
            return StreamProvider((ref) => Stream<List<NotificationItem>>.value(notifications));
          }),
          notificationRepositoryProvider.overrideWithValue(_FakeNotificationRepository(notifications)),
        ],
        child: const MaterialApp(home: InboxPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تنبيه مهم'), findsOneWidget);
    expect(find.text('تفاصيل محلية'), findsOneWidget);
  });
}
