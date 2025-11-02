import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../../core/localization/app_localizations.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/inbox/inbox_screen.dart';
import '../../screens/plan/plan_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/saved/saved_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final pages = [
      const HomeScreen(),
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

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: [
          BottomNavigationBarItem(icon: const Icon(IconlyBold.home), label: labels[0]),
          BottomNavigationBarItem(icon: const Icon(IconlyBold.bookmark), label: labels[1]),
          BottomNavigationBarItem(icon: const Icon(IconlyBold.graph), label: labels[2]),
          BottomNavigationBarItem(icon: const Icon(IconlyBold.message), label: labels[3]),
          BottomNavigationBarItem(icon: const Icon(IconlyBold.profile), label: labels[4]),
        ],
      ),
    );
  }
}
