import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/market/presentation/pages/home_page.dart';
import '../../features/market/presentation/pages/splash_page.dart';

abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';

  static const String registerName = 'register';
  static const String homeName = 'home';
}

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    // 登录状态变化时重新跑一遍 redirect。
    refreshListenable: _BlocRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStatus status = authBloc.state.status;
      final String location = state.matchedLocation;
      final bool atAuthFlow =
          location == AppRoutes.login || location == AppRoutes.register;

      if (status == AuthStatus.unknown) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }
      if (status == AuthStatus.unauthenticated) {
        return atAuthFlow ? null : AppRoutes.login;
      }
      return atAuthFlow || location == AppRoutes.splash ? AppRoutes.home : null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.registerName,
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (BuildContext context, GoRouterState state) =>
            const HomePage(),
      ),
    ],
  );
}

/// 把 Bloc 的状态流桥接成 GoRouter 需要的 Listenable。
class _BlocRefreshStream extends ChangeNotifier {
  _BlocRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((dynamic _) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
