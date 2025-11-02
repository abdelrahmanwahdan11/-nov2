import '../../models/event.dart';
import '../../models/geo_point.dart';

abstract class EventRepository {
  Stream<List<Event>> watchEvents();
  Future<void> joinEvent(String eventId, String userId);
  Future<void> leaveEvent(String eventId, String userId);
  Future<bool> canCheckInWithQr(String eventId, DateTime timestamp);
  Future<bool> canCheckInWithGps(String eventId, GeoPoint currentLocation);
}
