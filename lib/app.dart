import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

/// 设计稿基准宽度，用于字号等比缩放。
const double _designWidth = 393;
const double _maxTextScale = 1.35;

class CryptoApp extends StatefulWidget {
  const CryptoApp({super.key});

  @override
  State<CryptoApp> createState() => _CryptoAppState();
}

class _CryptoAppState extends State<CryptoApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // 路由守卫要读登录状态，所以先建 Bloc 再建路由。
    _authBloc = getIt<AuthBloc>()..add(const AuthStarted());
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: '加密行情',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: _router,
        builder: (BuildContext context, Widget? child) =>
            _ScaleToWidth(child: child),
      ),
    );
  }
}

/// 按窗口宽度等比放大字号，避免宽屏下文字显得过小。
class _ScaleToWidth extends StatelessWidget {
  const _ScaleToWidth({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final double systemScale = media.textScaler.scale(100) / 100;
    final double widthScale =
        (media.size.width / _designWidth).clamp(1.0, _maxTextScale);

    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(
          (widthScale * systemScale).clamp(1.0, 1.6),
        ),
      ),
      child: ColoredBox(
        color: AppColors.background,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
