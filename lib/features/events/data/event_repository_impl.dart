import 'dart:async';
import 'dart:math';

import '../../../core/data/hive/hive_boxes.dart';
import '../../../core/data/hive/hive_manager.dart';
import '../../../core/domain/repositories/event_repository.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/event.dart';
import '../../../core/models/geo_point.dart';
import '../../../core/models/user.dart';

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl() : _manager = HiveManager.instance;

  final HiveManager _manager;

  @override
  Stream<List<Event>> watchEvents() {
    final box = _manager.box<Event>(HiveBoxes.events);
    final controller = StreamController<List<Event>>.broadcast();

    void emit() => controller.add(box.values.toList());

    emit();
    final sub = box.watch().listen((_) => emit());
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    final box = _manager.box<Event>(HiveBoxes.events);
    final event = box.get(eventId);
    final user = _manager.box<User>(HiveBoxes.users).get(userId);
    if (event == null || user == null) {
      throw StateError('حدث أو مستخدم غير موجود');
    }
    if (event.attendeeIds.contains(userId)) {
      return;
    }
    if (event.attendeeIds.length >= event.capacity) {
      throw StateError('السعة ممتلئة');
    }
    if (!_isLevelAllowed(user.level, event.level)) {
      throw StateError('المستوى غير مناسب');
    }
    if (!_matchesPreference(user, event)) {
      throw StateError('المتطلبات غير مستوفاة');
    }
    final updated = event.copyWith(
      attendeeIds: [...event.attendeeIds, userId],
      capacity: event.capacity,
    );
    await box.put(eventId, updated);
  }

  @override
  Future<void> leaveEvent(String eventId, String userId) async {
    final box = _manager.box<Event>(HiveBoxes.events);
    final event = box.get(eventId);
    if (event == null) {
      return;
    }
    if (!event.attendeeIds.contains(userId)) {
      return;
    }
    final updated = event.copyWith(
      attendeeIds: event.attendeeIds.where((id) => id != userId).toList(),
    );
    await box.put(eventId, updated);
  }

  @override
  Future<bool> canCheckInWithQr(String eventId, DateTime timestamp) async {
    final event = _manager.box<Event>(HiveBoxes.events).get(eventId);
    if (event == null) {
      return false;
    }
    final windowStart = event.startAt.subtract(const Duration(minutes: 15));
    final windowEnd = event.endAt.add(const Duration(minutes: 15));
    return timestamp.isAfter(windowStart) && timestamp.isBefore(windowEnd);
  }

  @override
  Future<bool> canCheckInWithGps(String eventId, GeoPoint currentLocation) async {
    final event = _manager.box<Event>(HiveBoxes.events).get(eventId);
    if (event == null) {
      return false;
    }
    final distance = _haversineMeters(
      event.location.lat,
      event.location.lon,
      currentLocation.lat,
      currentLocation.lon,
    );
    return distance <= 100;
  }

  @override
  Future<Event> createEvent({
    required EventType type,
    required String title,
    required String description,
    required Level level,
    required List<String> requirements,
    required TimeWindow timeWindow,
    required DateTime startAt,
    required DateTime endAt,
    required GeoPoint location,
    required int capacity,
    required double fee,
    required String organizerId,
  }) async {
    if (capacity <= 0) {
      throw StateError('يجب أن تكون السعة أكبر من صفر');
    }
    if (!endAt.isAfter(startAt)) {
      throw StateError('وقت النهاية يجب أن يكون بعد البداية');
    }
    final event = Event(
      id: 'e_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title,
      description: description,
      level: level,
      requirements: requirements,
      timeWindow: timeWindow,
      startAt: startAt,
      endAt: endAt,
      route: null,
      location: location,
      capacity: capacity,
      fee: fee,
      organizerId: organizerId,
      attendeeIds: const [],
    );
    await _manager.box<Event>(HiveBoxes.events).put(event.id, event);
    return event;
  }

  bool _matchesPreference(User user, Event event) {
    return user.preferences.any((pref) => pref.toLowerCase().contains(event.type.name));
  }

  bool _isLevelAllowed(Level userLevel, Level eventLevel) {
    const ranking = {Level.beginner: 0, Level.intermediate: 1, Level.advanced: 2};
    return ranking[userLevel]! >= ranking[eventLevel]!;
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double value) => value * pi / 180;
}
