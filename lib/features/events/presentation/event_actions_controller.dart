import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/repositories/event_repository.dart';
import '../../../core/models/geo_point.dart';
import '../../../core/services/providers.dart';

class EventActionsController {
  EventActionsController(this._ref);

  final Ref _ref;

  EventRepository get _repository => _ref.read(eventRepositoryProvider);

  Future<void> join(String eventId, String userId) {
    return _repository.joinEvent(eventId, userId);
  }

  Future<void> leave(String eventId, String userId) {
    return _repository.leaveEvent(eventId, userId);
  }

  Future<bool> canCheckInQr(String eventId, DateTime timestamp) {
    return _repository.canCheckInWithQr(eventId, timestamp);
  }

  Future<bool> canCheckInGps(String eventId, GeoPoint point) {
    return _repository.canCheckInWithGps(eventId, point);
  }
}

final eventActionsProvider = Provider((ref) => EventActionsController(ref));
