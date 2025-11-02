import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/i18n/strings.dart';
import '../../core/state/app_scope.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final locale = state.locale;
    final notifications = state.notifications;

    return Scaffold(
      appBar: AppBar(title: Text(Strings.of(locale, 'inbox'))),
      body: notifications.isEmpty
          ? Center(child: Text(Strings.of(locale, 'empty_notifications')))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  child: ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.body),
                    leading: Icon(notification.read ? Icons.mark_email_read : Icons.mark_email_unread),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.done),
                          tooltip: 'تمييز كمقروء',
                          onPressed: () => state.markNotificationRead(notification.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'حذف',
                          onPressed: () => state.removeNotification(notification.id),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms, delay: (index * 60).ms).moveY(begin: 8, end: 0);
              },
            ),
    );
  }
}
