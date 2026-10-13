import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/market_state.dart';

/// 表头：名称 / 成交额 / 最新价 / 今日涨跌，可点击排序。
class MarketTableHeader extends StatelessWidget {
  const MarketTableHeader({
    super.key,
    required this.sortField,
    required this.sortAscending,
    required this.onSort,
  });

  final MarketSortField sortField;
  final bool sortAscending;
  final ValueChanged<MarketSortField> onSort;

  static const int _nameFlex = 56;
  static const int _priceFlex = 22;
  static const int _changeFlex = 30;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: _nameFlex,
            child: Row(
              children: <Widget>[
                _HeaderCell(
                  label: '名称',
                  field: MarketSortField.name,
                  activeField: sortField,
                  ascending: sortAscending,
                  onSort: onSort,
                ),
                const SizedBox(width: 16),
                _HeaderCell(
                  label: '成交额',
                  field: MarketSortField.volume,
                  activeField: sortField,
                  ascending: sortAscending,
                  onSort: onSort,
                ),
              ],
            ),
          ),
          Expanded(
            flex: _priceFlex,
            child: _HeaderCell(
              label: '最新价',
              field: MarketSortField.price,
              activeField: sortField,
              ascending: sortAscending,
              onSort: onSort,
            ),
          ),
          Expanded(
            flex: _changeFlex,
            child: _HeaderCell(
              label: '今日涨跌',
              field: MarketSortField.change,
              activeField: sortField,
              ascending: sortAscending,
              onSort: onSort,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.field,
    required this.activeField,
    required this.ascending,
    required this.onSort,
  });

  final String label;
  final MarketSortField field;
  final MarketSortField activeField;
  final bool ascending;
  final ValueChanged<MarketSortField> onSort;

  @override
  Widget build(BuildContext context) {
    final bool active = activeField == field;
    final Color color =
        active ? AppColors.textPrimary : AppColors.textTertiary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSort(field),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: TextStyle(fontSize: 13, color: color)),
          const SizedBox(width: 2),
          Icon(
            active
                ? (ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down)
                : Icons.unfold_more,
            size: 14,
            color: color,
          ),
        ],
      ),
    );
  }
}
