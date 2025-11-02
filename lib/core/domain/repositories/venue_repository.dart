import '../../models/field.dart';
import '../../models/venue.dart';

abstract class VenueRepository {
  Stream<List<Venue>> watchVenues();
  Stream<List<Field>> watchFieldsByVenue(String venueId);
}
