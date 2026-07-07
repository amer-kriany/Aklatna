import 'package:aklatna/core/widgets/AppBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Aklatna (أكلتنا) — Root shell for the 5 bottom-nav branches.
///
/// Used as the `builder` for a `StatefulShellRoute.indexedStack` in the
/// router config. `navigationShell` keeps each branch's Navigator (and
/// therefore each branch's Bloc state / scroll position) alive when
/// switching tabs — switching tabs does NOT rebuild the other branches.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    // goBranch with initialLocation: true pops back to the branch's root
    // route if the tab is already selected (e.g. tapping "Home" while on
    // Home resets its internal navigation stack).
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}