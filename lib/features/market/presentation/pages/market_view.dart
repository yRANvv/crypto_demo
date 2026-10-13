import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/coin.dart';
import '../../domain/market_config.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';
import '../widgets/coin_list_tile.dart';
import '../widgets/market_bottom_bar.dart';
import '../widgets/market_filter_bar.dart';
import '../widgets/market_table_header.dart';
import '../widgets/watchlist_sheet.dart';

/// 市场页：二级筛选 + 表头 + 行情列表 + 底部操作栏。
class MarketView extends StatelessWidget {
  const MarketView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (BuildContext context, MarketState state) {
        return Column(
          children: <Widget>[
            MarketFilterBar(
              categories: MarketConfig.categories,
              selectedIndex: state.categoryIndex,
              onSelected: (int index) => context
                  .read<MarketBloc>()
                  .add(MarketCategorySelected(index)),
              onOpenWatchlistGroups: () => _openGroupSheet(context),
            ),
            MarketTableHeader(
              sortField: state.sortField,
              sortAscending: state.sortAscending,
              onSort: (MarketSortField field) =>
                  context.read<MarketBloc>().add(MarketSortRequested(field)),
            ),
            if (state.notice != null) _NoticeBanner(message: state.notice!),
            Expanded(child: _MarketList(state: state)),
            SafeArea(
              top: false,
              child: MarketBottomBar(
                onAddCoinPair: () =>
                    _openWatchlistSheet(context, WatchlistSheetMode.add),
                onEditWatchlist: () =>
                    _openWatchlistSheet(context, WatchlistSheetMode.edit),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openWatchlistSheet(BuildContext context, WatchlistSheetMode mode) {
    _showSheet(context, WatchlistSheet(mode: mode));
  }

  void _openGroupSheet(BuildContext context) {
    _showSheet(context, const WatchlistGroupSheet());
  }

  /// 弹窗在新路由里，拿不到上层的 Provider，所以显式带上 Bloc。
  void _showSheet(BuildContext context, Widget child) {
    final MarketBloc bloc = context.read<MarketBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => BlocProvider<MarketBloc>.value(
        value: bloc,
        child: child,
      ),
    );
  }
}

class _MarketList extends StatelessWidget {
  const _MarketList({required this.state});

  final MarketState state;

  @override
  Widget build(BuildContext context) {
    if (state.status != MarketStatus.success && state.coins.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.up,
          ),
        ),
      );
    }

    if (state.categoryIndex == 3) {
      return const _EmptyState(
        icon: Icons.timeline_outlined,
        title: '期权行情',
        subtitle: '期权行情暂未开放，敬请期待',
      );
    }

    final List<Coin> coins = state.visibleCoins;
    if (coins.isEmpty) {
      return _EmptyState(
        icon: Icons.search_off_outlined,
        title: state.query.trim().isEmpty ? '自选列表为空' : '没有匹配的行情',
        subtitle: state.query.trim().isEmpty ? '点击下方「添加币对」开始自选' : '试试其它关键词',
      );
    }

    return RefreshIndicator(
      color: AppColors.up,
      backgroundColor: AppColors.chip,
      onRefresh: () => _refresh(context),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 2, bottom: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: coins.length,
        itemBuilder: (BuildContext context, int index) =>
            CoinListTile(coin: coins[index]),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final MarketBloc bloc = context.read<MarketBloc>();
    final int previous = bloc.state.loadCount;
    bloc.add(const MarketRefreshed());
    await bloc.stream
        .firstWhere((MarketState next) => next.loadCount != previous)
        .timeout(const Duration(seconds: 20), onTimeout: () => bloc.state);
  }
}

class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.cloud_off, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                context.read<MarketBloc>().add(const MarketRefreshed()),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                '重试',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.up,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 34, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
