import '../entities/coin.dart';
import '../market_source.dart';

class MarketResult {
  const MarketResult({
    required this.coins,
    required this.source,
    this.notice,
  });

  final List<Coin> coins;

  /// 本次数据实际来自哪个来源。
  final MarketSource source;

  /// 需要提示给用户的说明，比如降级原因。
  final String? notice;

  bool get offline => source == MarketSource.snapshot;
}

abstract class MarketRepository {
  Future<MarketResult> loadMarkets();
}
