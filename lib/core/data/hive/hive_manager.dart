import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/booking.dart';
import '../../models/event.dart';
import '../../models/field.dart';
import '../../models/health_metric.dart';
import '../../models/models.dart';
import '../../models/story.dart';
import '../../models/user.dart';
import '../../models/venue.dart';
import '../../models/wallet_tx.dart';
import '../../models/notification_item.dart';
import 'adapters.dart';
import 'hive_boxes.dart';

const _metaBox = 'app_meta';
const _seedVersion = 1;

class HiveManager {
  HiveManager._();

  static final instance = HiveManager._();

  Future<void> init() async {
    await Hive.initFlutter();
    registerHiveAdapters();
    await _seedIfNeeded();
    await Future.wait([
      Hive.openBox<User>('users'),
      Hive.openBox<Venue>('venues'),
      Hive.openBox<Field>('fields'),
      Hive.openBox<Event>('events'),
      Hive.openBox<Booking>('bookings'),
      Hive.openBox<HealthMetric>('health_metrics'),
      Hive.openBox<Story>('stories'),
      Hive.openBox<WalletTx>('wallet'),
      Hive.openBox<NotificationItem>('notifications'),
    ]);
  }

  Box<T> box<T>(String name) => Hive.box<T>(name);

  Future<void> _seedIfNeeded() async {
    final metaBox = await Hive.openBox(_metaBox);
    final currentVersion = metaBox.get('seed_version', defaultValue: 0) as int;
    if (currentVersion >= _seedVersion) {
      return;
    }

    await Future.wait([
      _seedUsers(),
      _seedVenues(),
      _seedFields(),
      _seedEvents(),
      _seedStories(),
    ]);

    final firstUser = Hive.box<User>(HiveBoxes.users).values.firstOrNull;
    if (firstUser != null) {
      await metaBox.put('current_user_id', firstUser.id);
      final notificationsBox = await Hive.openBox<NotificationItem>(HiveBoxes.notifications);
      await notificationsBox.put(
        'ntf_seed_complete',
        NotificationItem(
          id: 'ntf_seed_complete',
          userId: firstUser.id,
          title: 'تم تجهيز بيانات ساحة',
          body: 'تم تحميل بيانات التجربة للعمل دون اتصال.',
          createdAt: DateTime.now(),
          read: false,
          type: 'system',
        ),
      );
    }

    await metaBox.put('seed_version', _seedVersion);
    await metaBox.put('seed_timestamp', DateTime.now().toIso8601String());
  }

  Future<void> _seedUsers() async {
    await _seedCollection<User>(
      'users',
      'assets/seed/users.json',
      (map) => User.fromJson(map),
    );
  }

  Future<void> _seedVenues() async {
    await _seedCollection<Venue>(
      'venues',
      'assets/seed/venues.json',
      (map) => Venue.fromJson(map),
    );
  }

  Future<void> _seedFields() async {
    await _seedCollection<Field>(
      'fields',
      'assets/seed/fields.json',
      (map) => Field.fromJson(map),
    );
  }

  Future<void> _seedEvents() async {
    await _seedCollection<Event>(
      'events',
      'assets/seed/events.json',
      (map) => Event.fromJson(map),
    );
  }

  Future<void> _seedStories() async {
    await _seedCollection<Story>(
      'stories',
      'assets/seed/stories.json',
      (map) => Story.fromJson(map),
    );
  }

  Future<void> _seedCollection<T>(
    String boxName,
    String assetPath,
    T Function(Map<String, dynamic>) mapper,
  ) async {
    final box = await Hive.openBox<T>(boxName);
    if (box.isNotEmpty) {
      await box.clear();
    }
    final jsonStr = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(jsonStr) as List<dynamic>;
    for (final item in decoded) {
      final map = Map<String, dynamic>.from(item as Map);
      final model = mapper(map);
      final id = map['id'] as String;
      await box.put(id, model);
    }
  }
}
