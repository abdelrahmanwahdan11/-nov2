import '../../models/event.dart';
import '../../models/geo_point.dart';

abstract class EventRepository {
  Stream<List<Event>> watchEvents();
  Future<void> joinEvent(String eventId, String userId);
  Future<void> leaveEvent(String eventId, String userId);
  Future<bool> canCheckInWithQr(String eventId, DateTime timestamp);
  Future<bool> canCheckInWithGps(String eventId, GeoPoint currentLocation);
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
  });
}
