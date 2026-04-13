import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/cards/presentation/pages/home_page.dart';
import '../../features/cards/presentation/pages/add_card_page.dart';
import '../../features/cards/presentation/pages/review_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
import '../components/main_shell.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          final location = state.uri.path;
          final currentIndex = location == '/stats' ? 1 : 0;
          return MainShell(
            currentIndex: currentIndex,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/stats',
            name: 'stats',
            builder: (context, state) => const StatsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/add',
        name: 'add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddCardPage(),
      ),
      GoRoute(
        path: '/review',
        name: 'review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReviewPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
