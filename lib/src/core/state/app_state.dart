import 'dart:math';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../storage/local_store.dart';

class AppState extends ChangeNotifier {
  AppState({required this.store});

  final LocalStore store;

  bool darkMode = false;
  String locale = 'ar';

  List<Venue> venues = const [];
  List<Field> fields = const [];
  List<Event> events = const [];
  List<Story> stories = const [];
  List<Booking> bookings = const [];
  List<NotificationItem> notifications = const [];
  List<WalletTx> wallet = const [];
  List<User> users = const [];
  List<HealthMetric> healthMetrics = const [];
  User? currentUser;

  Future<void> bootstrap() async {
    darkMode = store.getBool('darkMode') ?? false;
    locale = store.getString('locale') ?? 'ar';
    await _ensureSeed();
    await _loadAll();
    currentUser ??= users.isNotEmpty ? users.first : null;
    if (currentUser != null && store.get<User>('currentUser') == null) {
      store.setModel('currentUser', currentUser!);
    }
    notifyListeners();
  }

  Future<void> _ensureSeed() async {
    if (store.getString('seed_loaded') == '1') return;
    await store.seedFromAssets({
      'venues': 'assets/seed/venues.json',
      'fields': 'assets/seed/fields.json',
      'events': 'assets/seed/events.json',
      'stories': 'assets/seed/stories.json',
      'users': 'assets/seed/users.json',
    });
    store.setString('bookings', '[]');
    store.setString('notifications', '[]');
    store.setString('wallet', '[]');
    store.setString('health_metrics', '[]');
    store.setString('seed_loaded', '1');
  }

  Future<void> _loadAll() async {
    venues = store.getList<Venue>('venues');
    fields = store.getList<Field>('fields');
    events = store.getList<Event>('events');
    stories = store.getList<Story>('stories');
    bookings = store.getList<Booking>('bookings');
    notifications = store.getList<NotificationItem>('notifications');
    wallet = store.getList<WalletTx>('wallet');
    users = store.getList<User>('users');
    healthMetrics = store.getList<HealthMetric>('health_metrics');
    currentUser = store.get<User>('currentUser');
  }

  void toggleDark() {
    darkMode = !darkMode;
    store.setBool('darkMode', darkMode);
    notifyListeners();
  }

  void setLocale(String code) {
    if (code == locale) return;
    locale = code;
    store.setString('locale', code);
    notifyListeners();
  }

  void setCurrentUser(String id) {
    try {
      currentUser = users.firstWhere((u) => u.id == id);
      store.setModel('currentUser', currentUser!);
      notifyListeners();
    } catch (_) {
      // ignore invalid ids
    }
  }

  void joinEvent(String eventId, String userId) {
    final idx = events.indexWhere((e) => e.id == eventId);
    if (idx == -1) return;
    final event = events[idx];
    if (event.participants.contains(userId)) {
      _notify('تنبيه', 'تم تسجيل حضورك مسبقًا في ${event.title}');
      return;
    }
    if (event.participants.length >= event.capacity) {
      _notify('ممتلئ', 'لا توجد أماكن متاحة في ${event.title}');
      return;
    }
    event.participants.add(userId);
    events = [...events];
    store.saveList('events', events);
    _notify('انضمام ناجح', 'تم انضمامك إلى ${event.title}');
    notifyListeners();
  }

  void leaveEvent(String eventId, String userId) {
    final idx = events.indexWhere((e) => e.id == eventId);
    if (idx == -1) return;
    final event = events[idx];
    if (event.participants.remove(userId)) {
      events = [...events];
      store.saveList('events', events);
      notifyListeners();
    }
  }

  void addBooking(Booking booking) {
    bookings = [...bookings, booking];
    store.saveList('bookings', bookings);
    _notify('حجز مؤكد', 'تم إنشاء الحجز بنجاح');
    notifyListeners();
  }

  void updateBookingPayments(String bookingId, String userId, bool paid) {
    final idx = bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return;
    final booking = bookings[idx];
    booking.payments[userId] = paid;
    final everyonePaid = booking.payments.values.every((value) => value);
    if (everyonePaid) {
      booking.status = 'confirmed';
      _notify('دفع مكتمل', 'تم تأكيد الحجز بالكامل');
    }
    bookings = [...bookings];
    store.saveList('bookings', bookings);
    notifyListeners();
  }

  void splitPayConfirmAll(String bookingId) {
    final idx = bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return;
    final booking = bookings[idx];
    booking.status = 'confirmed';
    bookings = [...bookings];
    store.saveList('bookings', bookings);
    notifyListeners();
  }

  void addStoryLike(String storyId) {
    final idx = stories.indexWhere((s) => s.id == storyId);
    if (idx == -1) return;
    stories[idx].likes += 1;
    stories = [...stories];
    store.saveList('stories', stories);
    notifyListeners();
  }

  void addEvent(Event event) {
    events = [event, ...events];
    store.saveList('events', events);
    notifyListeners();
  }

  void addHealthMetric(HealthMetric metric) {
    healthMetrics = [metric, ...healthMetrics];
    store.saveList('health_metrics', healthMetrics);
    notifyListeners();
  }

  void addNotification(NotificationItem item) {
    notifications = [item, ...notifications];
    store.saveList('notifications', notifications);
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    notifications[idx].read = true;
    notifications = [...notifications];
    store.saveList('notifications', notifications);
    notifyListeners();
  }

  void removeNotification(String id) {
    notifications = notifications.where((n) => n.id != id).toList();
    store.saveList('notifications', notifications);
    notifyListeners();
  }

  double walletBalance(String userId) {
    final credits = wallet.where((tx) => tx.userId == userId && tx.type == 'credit').fold<double>(0, (a, b) => a + b.amount);
    final debits = wallet.where((tx) => tx.userId == userId && tx.type == 'debit').fold<double>(0, (a, b) => a + b.amount);
    return credits - debits;
  }

  void addWalletTx(WalletTx tx) {
    wallet = [tx, ...wallet];
    store.saveList('wallet', wallet);
    notifyListeners();
  }

  void _notify(String title, String body) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    addNotification(
      NotificationItem(
        id: id,
        title: title,
        body: body,
        createdAt: DateTime.now(),
        read: false,
      ),
    );
  }

  List<Event> staggeredEvents() {
    final shuffled = [...events];
    shuffled.sort((a, b) => a.startAt.compareTo(b.startAt));
    return shuffled;
  }

  List<Offset> mockRoute() {
    final rand = Random();
    return List.generate(6, (index) => Offset(index / 5, rand.nextDouble()));
  }
}
