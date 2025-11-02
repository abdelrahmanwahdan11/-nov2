import '../data/hive/hive_manager.dart';
import '../../shared/services/notifications.dart';

Future<void> bootstrap() async {
  await HiveManager.instance.init();
  await notificationsService.init();
  await _scheduleHealthReminder();
}

Future<void> _scheduleHealthReminder() async {
  final now = DateTime.now();
  DateTime target = DateTime(now.year, now.month, 3, 9);
  if (!target.isAfter(now)) {
    target = DateTime(now.year, now.month + 1, 3, 9);
  }
  await notificationsService.scheduleReminder(
    id: 9999,
    scheduledAt: target,
    title: 'تذكير القياسات الصحية',
    body: 'حان وقت تحديث قياساتك الشهرية في تطبيق ساحة',
  );
}
