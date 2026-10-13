import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/coin.dart';

/// 币种图标：优先用内置资源，其次接口图片，最后字母色块。
class CoinAvatar extends StatelessWidget {
  const CoinAvatar({super.key, required this.coin, this.size = 36});

  final Coin coin;
  final double size;

  /// 内置图标的币种（来自开源包 cryptocurrency-icons），
  /// 图标 CDN 在部分网络下不可达，常用的直接用本地资源。
  static const Set<String> bundledSymbols = <String>{
    'BTC', 'ETH', 'BNB', 'XRP', 'SOL', 'DOGE', 'ADA', 'LINK',
    'TRX', 'AVAX', 'DOT', 'LTC', 'UNI', 'ATOM', 'ETC', 'FIL',
    'ICP', 'MATIC', 'BCH', 'XLM', 'ALGO', 'VET', 'THETA', 'EOS',
    'AAVE', 'COMP', 'MKR', 'SUSHI', 'CRV', 'SAND', 'MANA', 'GRT',
    'CHZ', 'ZIL', 'ZEC', 'XMR', 'XTZ', 'NEO', 'ONT', 'QTUM',
    'WAVES', '1INCH', 'YFI', 'KSM', 'DASH', 'NEXO', 'KCS', 'HT', 'LEO',
  };

  static const List<Color> _tints = <Color>[
    Color(0xFFF0B90B),
    Color(0xFF627EEA),
    Color(0xFF2F2F35),
    Color(0xFF23292F),
    Color(0xFF9945FF),
    Color(0xFFC2A633),
    Color(0xFF0D1E30),
    Color(0xFF2A5ADA),
  ];

  @override
  Widget build(BuildContext context) {
    final Widget fallback = _letterAvatar();
    final String symbol = coin.symbol.toUpperCase();

    if (bundledSymbols.contains(symbol)) {
      return Image.asset(
        'assets/coins/${symbol.toLowerCase()}.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) =>
            fallback,
      );
    }

    if (coin.imageUrl.isEmpty) {
      return fallback;
    }

    return ClipOval(
      child: Image.network(
        coin.imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) =>
            fallback,
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? progress,
        ) {
          if (progress == null) {
            return child;
          }
          return Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.chip,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _letterAvatar() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _tintFor(coin.symbol),
        shape: BoxShape.circle,
      ),
      child: Text(
        coin.symbol.isEmpty ? '?' : coin.symbol.substring(0, 1),
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Color _tintFor(String symbol) {
    if (symbol.isEmpty) {
      return _tints.first;
    }
    final int sum =
        symbol.codeUnits.fold<int>(0, (int total, int unit) => total + unit);
    return _tints[sum % _tints.length];
  }
}
