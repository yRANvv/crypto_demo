import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/coin.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';
import 'coin_avatar.dart';

enum WatchlistSheetMode { add, edit }

class WatchlistSheet extends StatelessWidget {
  const WatchlistSheet({super.key, required this.mode});

  final WatchlistSheetMode mode;

  @override
  Widget build(BuildContext context) {
    final bool adding = mode == WatchlistSheetMode.add;

    return BlocBuilder<MarketBloc, MarketState>(
      builder: (BuildContext context, MarketState state) {
        final List<Coin> coins =
            adding ? state.nonWatchlistCoins() : state.watchlistCoins();

        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.66,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      adding ? '添加币对' : '编辑自选',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adding ? '点击 + 加入自选' : '点击 − 从自选中移除',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: coins.isEmpty
                    ? Center(
                        child: Text(
                          adding
                              ? (state.offline
                                  ? '离线演示模式只包含设计稿中的币种\n联网后可以添加更多'
                                  : '暂无可添加的币种')
                              : '自选列表为空，先添加币对吧',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: coins.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Coin coin = coins[index];
                          return ListTile(
                            onTap: () => _toggle(context, state, coin),
                            leading: CoinAvatar(coin: coin, size: 34),
                            title: Text(
                              coin.symbol,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              coin.name,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Icon(
                              adding
                                  ? Icons.add_circle_outline
                                  : Icons.remove_circle_outline,
                              color: adding ? AppColors.up : AppColors.down,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggle(BuildContext context, MarketState state, Coin coin) {
    final List<Coin> updated = state.watchlistCoins();
    if (state.isWatchlisted(coin.symbol)) {
      updated.removeWhere((Coin item) => item.symbol == coin.symbol);
    } else {
      updated.add(coin);
    }
    context.read<MarketBloc>().add(MarketWatchlistUpdated(updated));
  }
}

/// 自选分组下拉，目前只有一个分组。
class WatchlistGroupSheet extends StatelessWidget {
  const WatchlistGroupSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (BuildContext context, MarketState state) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Text(
                  '自选分组',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              ListTile(
                leading: const Icon(Icons.bookmark, color: AppColors.up),
                title: const Text(
                  '我的自选',
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                ),
                trailing: Text(
                  '${state.watchlistCoins().length} 个币对',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
