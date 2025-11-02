import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/notification_item.dart';
import '../../../core/services/providers.dart';

class InboxPage extends ConsumerWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('الرجاء اختيار مستخدم للاطلاع على التنبيهات'));
          }
          final notificationsAsync = ref.watch(notificationsProvider(user.id));
          return notificationsAsync.when(
            data: (notifications) => _NotificationsList(userId: user.id, notifications: notifications),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('خطأ: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error')),
      ),
    );
  }
}

class _NotificationsList extends ConsumerWidget {
  const _NotificationsList({required this.userId, required this.notifications});

  final String userId;
  final List<NotificationItem> notifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notifications.isEmpty) {
      return const Center(child: Text('لا توجد رسائل حالياً'));
    }
    final formatter = DateFormat('dd/MM HH:mm');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = notifications[index];
        return Card(
          child: ListTile(
            leading: Icon(item.read ? Icons.mark_email_read : Icons.mark_unread_chat_alt),
            title: Text(item.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.body),
                const SizedBox(height: 4),
                Text(formatter.format(item.createdAt), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: 'تمييز كمقروء',
                  onPressed: item.read
                      ? null
                      : () => ref.read(notificationRepositoryProvider).markAsRead(item.id),
                  icon: const Icon(Icons.done_all),
                ),
                IconButton(
                  tooltip: 'حذف',
                  onPressed: () => ref.read(notificationRepositoryProvider).deleteNotification(item.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
