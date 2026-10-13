import 'dart:async';

import '../../domain/entities/coin.dart';
import '../../domain/market_source.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_remote_data_source.dart';
import '../datasources/market_snapshot_data.dart';

/// auto 模式下首次加载并发探测两个来源，给 CoinGecko 一个 2.5 秒的优先窗口，
/// 避免网络不通时干等超时；全部失败则回落到内置快照。
class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({
    required this.coinGecko,
    required this.binance,
    required this.mode,
  });

  final MarketRemoteDataSource coinGecko;
  final MarketRemoteDataSource binance;
  final DataSourceMode mode;

  static const Duration _timeout = Duration(seconds: 12);
  static const Duration _coinGeckoPriority = Duration(milliseconds: 2500);

  MarketSource? _lastGoodSource;

  @override
  Future<MarketResult> loadMarkets() async {
    if (mode == DataSourceMode.auto && _lastGoodSource == null) {
      return _probeSources();
    }

    final List<MarketSource> order = _attemptOrder();
    for (int index = 0; index < order.length; index++) {
      final List<Coin>? coins = await _fetch(order[index]);
      if (coins == null) {
        continue;
      }
      return _success(
        order[index],
        coins,
        fallbackFrom: index == 0 ? null : order.first,
      );
    }
    return _snapshotResult();
  }

  Future<MarketResult> _probeSources() async {
    final Future<List<Coin>?> coinGeckoRequest = _fetch(MarketSource.coingecko);
    final Future<List<Coin>?> binanceRequest = _fetch(MarketSource.binance);

    final List<Coin>? preferred = await Future.any(<Future<List<Coin>?>>[
      coinGeckoRequest,
      Future<List<Coin>?>.delayed(_coinGeckoPriority, () => null),
    ]);
    if (preferred != null) {
      return _success(MarketSource.coingecko, preferred);
    }

    final List<Coin>? fallback = await binanceRequest;
    if (fallback != null) {
      return _success(
        MarketSource.binance,
        fallback,
        fallbackFrom: MarketSource.coingecko,
      );
    }

    // 币安也没数据，再给 CoinGecko 一次机会，最后才用快照。
    final List<Coin>? late = await coinGeckoRequest;
    return late != null
        ? _success(MarketSource.coingecko, late)
        : _snapshotResult();
  }

  /// 上次成功的来源优先，省掉每次重新探测的时间。
  List<MarketSource> _attemptOrder() {
    final List<MarketSource> configured = switch (mode) {
      DataSourceMode.coingecko => const <MarketSource>[MarketSource.coingecko],
      DataSourceMode.binance => const <MarketSource>[MarketSource.binance],
      DataSourceMode.auto => const <MarketSource>[
          MarketSource.coingecko,
          MarketSource.binance,
        ],
    };
    final MarketSource? last = _lastGoodSource;
    if (last == null || !configured.contains(last)) {
      return configured;
    }
    return <MarketSource>[
      last,
      ...configured.where((MarketSource source) => source != last),
    ];
  }

  Future<List<Coin>?> _fetch(MarketSource source) async {
    final MarketRemoteDataSource dataSource =
        source == MarketSource.binance ? binance : coinGecko;
    try {
      final List<Coin> coins =
          await dataSource.fetchMarkets().timeout(_timeout);
      return coins.isEmpty ? null : coins;
    } catch (_) {
      // 超时、连接失败、限流都视为该来源不可用。
      return null;
    }
  }

  MarketResult _success(
    MarketSource source,
    List<Coin> coins, {
    MarketSource? fallbackFrom,
  }) {
    _lastGoodSource = source;
    return MarketResult(
      coins: coins,
      source: source,
      notice: fallbackFrom == null
          ? null
          : '${fallbackFrom.label} 直连失败，当前为${source.label}实时行情',
    );
  }

  MarketResult _snapshotResult() {
    return const MarketResult(
      coins: MarketSnapshotData.coins,
      source: MarketSource.snapshot,
      notice: '行情接口均不可用，已切换到内置演示行情',
    );
  }
}
