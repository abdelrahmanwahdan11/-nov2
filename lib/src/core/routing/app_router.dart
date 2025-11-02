import 'package:flutter/material.dart';

import '../../features/booking/booking_detail_page.dart';
import '../../features/create/create_page.dart';
import '../../features/events/events_page.dart';
import '../../features/explore/explore_page.dart';
import '../../features/health/health_page.dart';
import '../../features/home/home_page.dart';
import '../../features/inbox/inbox_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/stories/stories_page.dart';
import '../../features/wallet/wallet_page.dart';

class AppRouter {
  static const initialRoute = '/';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/':
        page = const HomePage();
        break;
      case '/explore':
        page = const ExplorePage();
        break;
      case '/events':
        page = const EventsPage();
        break;
      case '/booking':
        page = BookingDetailPage(fieldId: settings.arguments as String?);
        break;
      case '/health':
        page = const HealthPage();
        break;
      case '/stories':
        page = const StoriesPage();
        break;
      case '/inbox':
        page = const InboxPage();
        break;
      case '/profile':
        page = const ProfilePage();
        break;
      case '/create':
        page = const CreatePage();
        break;
      case '/wallet':
        page = const WalletPage();
        break;
      default:
        page = const HomePage();
        break;
    }
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
