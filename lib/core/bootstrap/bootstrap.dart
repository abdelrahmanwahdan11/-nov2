import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _seedVersion = 1;
const _metaBoxName = 'app_meta';

Future<void> bootstrap() async {
  await Hive.initFlutter();
  await _seedIfNeeded();
}

Future<void> _seedIfNeeded() async {
  final metaBox = await Hive.openBox(_metaBoxName);
  final currentVersion = metaBox.get('seed_version', defaultValue: 0) as int;
  if (currentVersion >= _seedVersion) {
    return;
  }

  await Future.wait([
    _seedCollection('venues', 'assets/seed/venues.json'),
    _seedCollection('events', 'assets/seed/events.json'),
    _seedCollection('users', 'assets/seed/users.json'),
    _seedCollection('stories', 'assets/seed/stories.json'),
    _seedCollection('fields', 'assets/seed/fields.json'),
  ]);

  await metaBox.put('seed_version', _seedVersion);
  await metaBox.put('seed_timestamp', DateTime.now().toIso8601String());
}

Future<void> _seedCollection(String boxName, String assetPath) async {
  final box = await Hive.openBox(boxName);
  if (box.isNotEmpty) {
    await box.clear();
  }
  final assetRaw = await rootBundle.loadString(assetPath);
  final decoded = jsonDecode(assetRaw) as List<dynamic>;
  for (final item in decoded) {
    final map = Map<String, dynamic>.from(item as Map);
    final id = map['id'] as String? ?? '${boxName}_${box.length}';
    await box.put(id, map);
  }
}
