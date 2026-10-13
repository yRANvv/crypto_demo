import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// 牛人榜页：榜单占位 + 当前登录账号。
class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool demoAuth = getIt<AppConfig>().demoAuth;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState state) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: <Widget>[
            _AccountCard(user: state.user, demoAuth: demoAuth),
            const SizedBox(height: 28),
            const Row(
              children: <Widget>[
                Icon(
                  Icons.emoji_events_outlined,
                  size: 18,
                  color: AppColors.up,
                ),
                SizedBox(width: 8),
                Text(
                  '本周牛人榜',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: AppColors.chip,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: <Widget>[
                  Icon(
                    Icons.insights_outlined,
                    size: 30,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '榜单数据接入中',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBody,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '接入排行榜接口后即可展示',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user, required this.demoAuth});

  final AppUser? user;
  final bool demoAuth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.badge,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  user?.initial ?? '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user?.email ?? '未登录',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'UID: ${user?.uid ?? '-'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  demoAuth ? '本地演示鉴权' : '已连接 Firebase Auth',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthSignOutRequested()),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '退出登录',
                  style: TextStyle(fontSize: 13, color: AppColors.down),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
