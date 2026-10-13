import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 二级筛选：自选 / 现货 / 合约 / 期权 / 总览，选中的显示为胶囊。
class MarketFilterBar extends StatelessWidget {
  const MarketFilterBar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    required this.onOpenWatchlistGroups,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onOpenWatchlistGroups;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      child: Row(
        children: <Widget>[
          for (int index = 0; index < categories.length; index++)
            Padding(
              padding: EdgeInsets.only(
                right: index == categories.length - 1 ? 0 : 14,
              ),
              child: index == selectedIndex
                  ? _SelectedChip(
                      label: categories[index],
                      // 选中的「自选」带下拉箭头，点开分组。
                      onTap: index == 0
                          ? onOpenWatchlistGroups
                          : () => onSelected(index),
                    )
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelected(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        child: Text(
                          categories[index],
                          style: const TextStyle(
                            fontSize: 15.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _SelectedChip extends StatelessWidget {
  const _SelectedChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 7, 8, 7),
        decoration: BoxDecoration(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
