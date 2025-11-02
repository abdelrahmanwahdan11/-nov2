import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../../application/stores/app_store.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/signals/signal.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/inbox/inbox_screen.dart';
import '../../screens/plan/plan_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/saved/saved_screen.dart';
import '../../widgets/coachmarks_overlay.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final GlobalKey _quickActionsKey = GlobalKey();
  final GlobalKey _searchBarKey = GlobalKey();
  final GlobalKey _planTabKey = GlobalKey();

  late final AppStore _store;

  @override
  void initState() {
    super.initState();
    _store = AppStore.instance;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final store = _store;
    final pages = [
      HomeScreen(
        quickActionsKey: _quickActionsKey,
        searchBarKey: _searchBarKey,
      ),
      const SavedScreen(),
      const PlanScreen(),
      const InboxScreen(),
      const ProfileScreen(),
    ];
    final labels = [
      l10n.t('home'),
      l10n.t('saved'),
      l10n.t('plan'),
      l10n.t('inbox'),
      l10n.t('profile'),
    ];

    return SignalBuilder<int>(
      signal: store.lastActiveTabSignal,
      builder: (context, index, _) {
        final scaffold = Scaffold(
          body: IndexedStack(index: index, children: pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (value) {
              store.setLastActiveTab(value);
            },
            items: [
              BottomNavigationBarItem(icon: const Icon(IconlyBold.home), label: labels[0]),
              BottomNavigationBarItem(icon: const Icon(IconlyBold.bookmark), label: labels[1]),
              BottomNavigationBarItem(
                icon: KeyedSubtree(
                  key: _planTabKey,
                  child: const Icon(IconlyBold.graph),
                ),
                label: labels[2],
              ),
              BottomNavigationBarItem(icon: const Icon(IconlyBold.message), label: labels[3]),
              BottomNavigationBarItem(icon: const Icon(IconlyBold.profile), label: labels[4]),
            ],
          ),
        );

        return SignalBuilder<bool>(
          signal: store.coachmarksSeenSignal,
          builder: (context, seen, __) {
            if (!seen && index != 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && store.lastActiveTabSignal.value != 0) {
                  store.setLastActiveTab(0);
                }
              });
            }

            return Stack(
              children: [
                scaffold,
                if (!seen)
                  CoachmarksOverlay(
                    steps: [
                      CoachmarkStep(
                        targetKey: _quickActionsKey,
                        message: l10n.t('coachmarks_tip_quick_actions'),
                      ),
                      CoachmarkStep(
                        targetKey: _searchBarKey,
                        message: l10n.t('coachmarks_tip_search'),
                      ),
                      CoachmarkStep(
                        targetKey: _planTabKey,
                        message: l10n.t('coachmarks_tip_plan'),
                      ),
                    ],
                    title: l10n.t('coachmarks_title'),
                    nextLabel: l10n.t('coachmarks_next'),
                    doneLabel: l10n.t('coachmarks_done'),
                    skipLabel: l10n.t('coachmarks_skip'),
                    onFinish: () {
                      store.setCoachmarksSeen(true);
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
