import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/feed/presentation/feed_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/transition_screen.dart';
import '../../features/place/presentation/place_detail_screen.dart';
import '../../features/shell/presentation/app_shell.dart';

/// Route paths mirror the Next.js `app/` folder so the two clients stay
/// mentally interchangeable (`/feed`, `/map`, `/place/[id]`).
abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const preparing = '/preparing';
  static const feed = '/feed';
  static const map = '/map';

  static String place(String id) => '/place/${Uri.encodeComponent(id)}';
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            _fadePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.preparing,
        pageBuilder: (context, state) =>
            _fadePage(state, const TransitionScreen()),
      ),
      // Home and Map live in an IndexedStack so each tab keeps its scroll
      // position and the feed is not rebuilt when switching.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.feed,
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
        ],
      ),
      // Pushed on the root navigator so it covers the bottom nav, like the
      // web's full-screen detail page.
      GoRoute(
        path: '/place/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => PlaceDetailScreen(
          placeId: Uri.decodeComponent(state.pathParameters['id'] ?? ''),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 360),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
