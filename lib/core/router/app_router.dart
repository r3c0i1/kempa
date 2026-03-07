import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kempa/core/layout/main_layout.dart';
import 'package:kempa/features/auth/presentation/pages/splash_screen.dart';
import 'package:kempa/features/auth/presentation/pages/two_factor_page.dart';
import 'package:kempa/features/profile/presentation/pages/profile_page.dart';
import 'package:kempa/features/profile/presentation/pages/settings_page.dart';
import 'package:kempa/features/schedule/presentation/pages/schedule_page.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthBloc authBloc;
  final SplashController splashController;

  AppRouter(this.authBloc, this.splashController);

  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  late final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',

    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;

      if (authState is AuthInitialState ||
          authState is AuthCheckingState ||
          !splashController.animationDone) {
        return location == "/splash" ? null : "/splash";
      } 

      if (location == "/splash") {
        if (authState is AuthentificatedState) return "/schedule";
        return "/login";
      }

      if (authState is AuthTwoFactorState) {
        return location == "/two-factor" ? null : "/two-factor";
      }

      if (authState is AuthLoginState && authState.isLoading) {
        return null;
      }

      if (authState is AuthentificatedState) {
        if (location == "/login" || location == "/two-factor") {
          return "/schedule";
        }
        return null;
      }

      if (authState is AuthLoginState || authState is UnauthenticatedState) {
        if (location == '/login') return null;
        return '/login';
      }

      return null;
    },

    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(authBloc.stream),
      splashController,
    ]),

    routes: [
      GoRoute(path: '/splash', builder: (context, state) => SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      GoRoute(path: "/two-factor", builder: (context, state) => TwoFactorPage()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const SchedulePage()
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ProfilePage(),
            ),
            routes: [
              // Настройки — поверх shell (без bottom nav)
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: 'settings',
                builder: (context, state) => SettingsPage(),
              ),
            ],
          ),
        ],
      )
    ],
  );
}
