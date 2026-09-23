import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'bottom_nav.dart';

/// Scaffold shared by the tabbed screens; the [navigationShell] is the
/// `IndexedStack` go_router maintains for the Home and Map branches.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNav(
        currentIndex: navigationShell.currentIndex,
        onSelect: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab again scrolls it back to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
