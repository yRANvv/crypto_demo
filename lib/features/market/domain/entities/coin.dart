import 'package:equatable/equatable.dart';

/// 币种行情。各数据源字段不同，统一映射成这个模型。
class Coin extends Equatable {
  const Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.volume24h,
    required this.changePercent24h,
  });

  final String id;

  /// 交易对基础币种，如 BNB。自选列表按它匹配，与数据源无关。
  final String symbol;

  final String name;
  final String imageUrl;

  /// 最新价（USD）。
  final double price;

  /// 24 小时成交额（USD）。
  final double volume24h;

  /// 今日涨跌幅（%）。
  final double changePercent24h;

  bool get isUp => changePercent24h >= 0;

  @override
  List<Object?> get props => <Object?>[
        id,
        symbol,
        name,
        imageUrl,
        price,
        volume24h,
        changePercent24h,
      ];
}
