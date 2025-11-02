import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_page.dart';
import '../../features/booking/presentation/booking_detail_page.dart';
import '../../features/create/presentation/create_page.dart';
import '../../features/events/presentation/event_detail_page.dart';
import '../../features/events/presentation/events_page.dart';
import '../../features/explore/presentation/explore_page.dart';
import '../../features/health/presentation/health_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/inbox/presentation/inbox_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/stories/presentation/stories_page.dart';
import '../../features/wallet/presentation/wallet_page.dart';
import '../../features/scan/presentation/scan_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(index);
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
                NavigationDestination(icon: Icon(Icons.map), label: 'استكشاف'),
                NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'إنشاء'),
                NavigationDestination(icon: Icon(Icons.mail_outline), label: 'الرسائل'),
                NavigationDestination(icon: Icon(Icons.person), label: 'حسابي'),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'booking/:fieldId',
                  name: 'booking_detail',
                  builder: (context, state) {
                    final fieldId = state.pathParameters['fieldId'] ?? 'unknown';
                    return BookingDetailPage(fieldId: fieldId);
                  },
                ),
                GoRoute(
                  path: 'stories',
                  name: 'stories',
                  builder: (context, state) => const StoriesPage(),
                ),
                GoRoute(
                  path: 'wallet',
                  name: 'wallet',
                  builder: (context, state) => const WalletPage(),
                ),
                GoRoute(
                  path: 'health',
                  name: 'health',
                  builder: (context, state) => const HealthPage(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/explore',
              name: 'explore',
              builder: (context, state) => const ExplorePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/create',
              name: 'create',
              builder: (context, state) => const CreatePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/inbox',
              name: 'inbox',
              builder: (context, state) => const InboxPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'event_detail',
            builder: (context, state) {
              final eventId = state.pathParameters['id'] ?? 'unknown';
              return EventDetailPage(eventId: eventId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) {
          final config = state.extra is ScanPageConfig ? state.extra as ScanPageConfig : null;
          return ScanPage(config: config);
        },
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
    ],
  );
});
