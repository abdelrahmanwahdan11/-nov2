import 'package:flutter/material.dart';

import '../../application/stores/app_store.dart';
import '../../presentation/screens/ai/ai_stub_screen.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/booking/booking_screen.dart';
import '../../presentation/screens/catalog/catalog_screen.dart';
import '../../presentation/screens/challenges/event_detail_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/explore/explore_map_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/shared/home_shell.dart';
import '../../presentation/screens/story/story_viewer_screen.dart';
import '../../domain/entities/catalog_item.dart';

class RouteState {
  RouteState({
    required this.name,
    required this.path,
    Map<String, String>? params,
    Map<String, String>? query,
  })  : params = params ?? <String, String>{},
        query = query ?? <String, String>{};

  final String name;
  final String path;
  final Map<String, String> params;
  final Map<String, String> query;

  factory RouteState.fromLocation(String location) {
    final uri = Uri.parse(location);
    final segments = uri.pathSegments;
    final name = segments.isEmpty ? 'home' : segments.first;
    final params = <String, String>{};
    if (segments.length > 1) {
      params['id'] = segments[1];
    }
    final query = <String, String>{};
    uri.queryParameters.forEach((key, value) {
      query[key] = value;
    });
    final normalizedPath = uri.path.isEmpty ? '/$name' : uri.path;
    return RouteState(name: name, path: normalizedPath, params: params, query: query);
  }
}

class AppRouter extends ChangeNotifier {
  AppRouter._internal() {
    final store = AppStore.instance;
    final onboardingDone = store.onboardingDoneSignal.value;
    final authenticated = store.authenticatedSignal.value;
    final startPath = onboardingDone
        ? (authenticated ? '/home' : '/auth')
        : '/onboarding';
    _stack = [RouteState.fromLocation(startPath)];
  }

  static final AppRouter instance = AppRouter._internal();

  late List<RouteState> _stack;

  List<Page<dynamic>> buildPages() {
    return _stack.map(_buildPage).toList();
  }

  Page _buildPage(RouteState state) {
    final key = ValueKey(state.path);
    switch (state.name) {
      case 'onboarding':
        return MaterialPage(key: key, child: const OnboardingScreen());
      case 'auth':
        return MaterialPage(key: key, child: const AuthScreen());
      case 'home':
        return MaterialPage(key: key, child: const HomeShell());
      case 'catalog':
        final type = state.query['type'];
        return MaterialPage(
          key: key,
          child: CatalogScreen(initialType: _mapType(type)),
        );
      case 'explore':
        return MaterialPage(key: key, child: const ExploreMapScreen());
      case 'search':
        return MaterialPage(key: key, child: const SearchScreen());
      case 'booking':
        return MaterialPage(key: key, child: BookingScreen(venueId: state.params['id'] ?? ''));
      case 'event':
        return MaterialPage(key: key, child: EventDetailScreen(itemId: state.params['id'] ?? ''));
      case 'story':
        return MaterialPage(key: key, child: StoryViewerScreen(storyId: state.params['id'] ?? ''));
      case 'settings':
        return MaterialPage(key: key, child: const SettingsScreen());
      case 'ai':
        return MaterialPage(key: key, child: const AiStubScreen());
      default:
        return MaterialPage(key: key, child: const HomeShell());
    }
  }

  CatalogType? _mapType(String? raw) {
    switch (raw) {
      case 'venue':
        return CatalogType.venue;
      case 'street_workout':
        return CatalogType.streetWorkout;
      case 'walk_route':
        return CatalogType.walkRoute;
      case 'challenge':
        return CatalogType.challenge;
      case 'training':
        return CatalogType.training;
      default:
        return null;
    }
  }

  RouteState get current => _stack.last;

  void setRoot(String location) {
    final state = RouteState.fromLocation(location);
    _stack = [state];
    notifyListeners();
  }

  void push(String location) {
    final state = RouteState.fromLocation(location);
    if (_isBase(state.name)) {
      setRoot(location);
      return;
    }
    _stack = List<RouteState>.from(_stack)..add(state);
    notifyListeners();
  }

  void pop() {
    if (_stack.length > 1) {
      _stack.removeLast();
      notifyListeners();
    }
  }

  bool _isBase(String name) {
    return name == 'home' || name == 'auth' || name == 'onboarding';
  }
}

class SahaRouteInformationParser extends RouteInformationParser<RouteState> {
  @override
  Future<RouteState> parseRouteInformation(RouteInformation routeInformation) async {
    final location = routeInformation.location ?? '/home';
    return RouteState.fromLocation(location);
  }

  @override
  RouteInformation? restoreRouteInformation(RouteState configuration) {
    return RouteInformation(location: configuration.path);
  }
}

class SahaRouterDelegate extends RouterDelegate<RouteState>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteState> {
  SahaRouterDelegate(this.router) {
    router.addListener(notifyListeners);
  }

  final AppRouter router;
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  RouteState? get currentConfiguration => router.current;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: router.buildPages(),
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        router.pop();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(RouteState configuration) async {
    if (router._isBase(configuration.name)) {
      router.setRoot(configuration.path);
    } else {
      if (router._stack.isEmpty) {
        router.setRoot('/home');
      }
      router._stack = [router._stack.first, configuration];
      router.notifyListeners();
    }
  }

  @override
  void dispose() {
    router.removeListener(notifyListeners);
    super.dispose();
  }
}
