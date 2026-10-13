import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/coin.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_state.dart';
import '../widgets/coin_list_tile.dart';

class NewsView extends StatelessWidget {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (BuildContext context, MarketState state) {
        if (state.coins.isEmpty) {
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

        final List<Coin> sorted = List<Coin>.of(state.coins)
          ..sort(
            (Coin a, Coin b) =>
                b.changePercent24h.compareTo(a.changePercent24h),
          );

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: <Widget>[
            const _SectionTitle(title: '24H 涨幅榜', accent: AppColors.up),
            for (final Coin coin in sorted.take(5)) CoinListTile(coin: coin),
            const SizedBox(height: 10),
            const _SectionTitle(title: '24H 跌幅榜', accent: AppColors.down),
            for (final Coin coin in sorted.reversed.take(5))
              CoinListTile(coin: coin),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.accent});

  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Row(
        children: <Widget>[
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
