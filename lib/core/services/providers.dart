import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hive/hive_manager.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/repositories/event_repository.dart';
import '../domain/repositories/field_repository.dart';
import '../domain/repositories/health_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/story_repository.dart';
import '../domain/repositories/venue_repository.dart';
import '../domain/repositories/wallet_repository.dart';
import '../models/booking.dart';
import '../models/event.dart';
import '../models/field.dart';
import '../models/health_metric.dart';
import '../models/story.dart';
import '../models/user.dart';
import '../models/venue.dart';
import '../models/wallet_tx.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/booking/data/booking_repository_impl.dart';
import '../../features/booking/data/field_repository_impl.dart';
import '../../features/booking/data/venue_repository_impl.dart';
import '../../features/events/data/event_repository_impl.dart';
import '../../features/health/data/health_repository_impl.dart';
import '../../features/inbox/data/notification_repository_impl.dart';
import '../../features/stories/data/story_repository_impl.dart';
import '../../features/wallet/data/wallet_repository_impl.dart';

final hiveManagerProvider = Provider((ref) => HiveManager.instance);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  return VenueRepositoryImpl();
});

final fieldRepositoryProvider = Provider<FieldRepository>((ref) {
  return FieldRepositoryImpl();
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final fieldRepo = ref.watch(fieldRepositoryProvider);
  return BookingRepositoryImpl(fieldRepo);
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl();
});

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepositoryImpl();
});

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepositoryImpl();
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).watchCurrentUser();
});

final venuesProvider = StreamProvider<List<Venue>>((ref) {
  return ref.watch(venueRepositoryProvider).watchVenues();
});

final fieldsByVenueProvider = StreamProvider.family<List<Field>, String>((ref, venueId) {
  return ref.watch(venueRepositoryProvider).watchFieldsByVenue(venueId);
});

final fieldDetailProvider = FutureProvider.family<Field?, String>((ref, fieldId) {
  return ref.watch(fieldRepositoryProvider).getFieldById(fieldId);
});

final userBookingsProvider = StreamProvider.family<List<Booking>, String>((ref, userId) {
  return ref.watch(bookingRepositoryProvider).watchUserBookings(userId);
});

final fieldBookingsProvider = StreamProvider.family<List<Booking>, String>((ref, fieldId) {
  return ref.watch(bookingRepositoryProvider).watchFieldBookings(fieldId);
});

final eventsProvider = StreamProvider<List<Event>>((ref) {
  return ref.watch(eventRepositoryProvider).watchEvents();
});

final healthMetricsProvider = StreamProvider.family<List<HealthMetric>, String>((ref, userId) {
  return ref.watch(healthRepositoryProvider).watchMetrics(userId);
});

final storiesProvider = StreamProvider<List<Story>>((ref) {
  return ref.watch(storyRepositoryProvider).watchStories();
});

final walletProvider = StreamProvider.family<List<WalletTx>, String>((ref, userId) {
  return ref.watch(walletRepositoryProvider).watchTransactions(userId);
});

final notificationsProvider = StreamProvider.family((ref, String userId) {
  return ref.watch(notificationRepositoryProvider).watchNotifications(userId);
});
