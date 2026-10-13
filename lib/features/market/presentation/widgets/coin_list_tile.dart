import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/market_formatter.dart';
import '../../domain/entities/coin.dart';
import 'coin_avatar.dart';

/// 行情列表行：币种 / 成交额 / 最新价 / 今日涨跌。
class CoinListTile extends StatelessWidget {
  const CoinListTile({super.key, required this.coin});

  final Coin coin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 56,
            child: Row(
              children: <Widget>[
                CoinAvatar(coin: coin),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              '${coin.symbol} / USDT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const _LeverageBadge(),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        MarketFormatter.volume(coin.volume24h),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 价格可能很长（比如 BTC 的 82,690.00），缩放而不是省略。
                _ScaledText(
                  text: MarketFormatter.price(coin.price),
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                _ScaledText(
                  text: MarketFormatter.indexPrice(coin.price),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 30,
            child: Align(
              alignment: Alignment.centerRight,
              child: ChangePill(changePercent: coin.changePercent24h),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaledText extends StatelessWidget {
  const _ScaledText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text, maxLines: 1, style: style),
    );
  }
}

class ChangePill extends StatelessWidget {
  const ChangePill({super.key, required this.changePercent});

  final double changePercent;

  @override
  Widget build(BuildContext context) {
    final bool up = changePercent >= 0;
    return Container(
      width: 94,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: up ? AppColors.up : AppColors.down,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        MarketFormatter.percent(changePercent),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _LeverageBadge extends StatelessWidget {
  const _LeverageBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.badge,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '10x',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
