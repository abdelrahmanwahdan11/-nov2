import 'dart:async';

import '../../../core/data/hive/hive_boxes.dart';
import '../../../core/data/hive/hive_manager.dart';
import '../../../core/domain/repositories/venue_repository.dart';
import '../../../core/models/field.dart';
import '../../../core/models/venue.dart';

class VenueRepositoryImpl implements VenueRepository {
  VenueRepositoryImpl() : _manager = HiveManager.instance;

  final HiveManager _manager;

  @override
  Stream<List<Venue>> watchVenues() {
    final box = _manager.box<Venue>(HiveBoxes.venues);
    final controller = StreamController<List<Venue>>.broadcast();

    void emit() => controller.add(box.values.toList());

    emit();
    final sub = box.watch().listen((_) => emit());
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }

  @override
  Stream<List<Field>> watchFieldsByVenue(String venueId) {
    final fieldsBox = _manager.box<Field>(HiveBoxes.fields);
    final controller = StreamController<List<Field>>.broadcast();

    void emit() {
      final filtered = fieldsBox.values.where((field) => field.venueId == venueId).toList();
      controller.add(filtered);
    }

    emit();
    final sub = fieldsBox.watch().listen((_) => emit());
    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }
}
