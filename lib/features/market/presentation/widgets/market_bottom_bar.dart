import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 底部操作栏：添加币对 | 编辑自选。
class MarketBottomBar extends StatelessWidget {
  const MarketBottomBar({
    super.key,
    required this.onAddCoinPair,
    required this.onEditWatchlist,
  });

  final VoidCallback onAddCoinPair;
  final VoidCallback onEditWatchlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _BarAction(
            icon: Icons.add_box_outlined,
            label: '添加币对',
            onTap: onAddCoinPair,
          ),
          Container(
            width: 1,
            height: 18,
            color: AppColors.divider,
            margin: const EdgeInsets.symmetric(horizontal: 26),
          ),
          _BarAction(
            icon: Icons.edit_outlined,
            label: '编辑自选',
            onTap: onEditWatchlist,
          ),
        ],
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 19, color: AppColors.textBody),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(fontSize: 15.5, color: AppColors.textBody),
          ),
        ],
      ),
    );
  }
}
