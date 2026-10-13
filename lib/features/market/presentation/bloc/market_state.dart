import 'package:equatable/equatable.dart';

import '../../domain/entities/coin.dart';
import '../../domain/market_config.dart';
import '../../domain/market_source.dart';

enum MarketStatus { initial, loading, success }

enum MarketSortField { none, name, volume, price, change }

class MarketState extends Equatable {
  const MarketState({
    this.status = MarketStatus.initial,
    this.coins = const <Coin>[],
    this.watchlistSymbols = MarketConfig.defaultWatchlistSymbols,
    this.query = '',
    this.categoryIndex = 0,
    this.sortField = MarketSortField.none,
    this.sortAscending = false,
    this.source = MarketSource.snapshot,
    this.offline = false,
    this.notice,
    this.loadCount = 0,
  });

  final MarketStatus status;

  /// 接口返回的全量行情，筛选和排序都在本地做。
  final List<Coin> coins;

  /// 自选币种符号，顺序即展示顺序。
  final List<String> watchlistSymbols;

  final String query;
  final int categoryIndex;
  final MarketSortField sortField;
  final bool sortAscending;
  final MarketSource source;
  final bool offline;
  final String? notice;

  /// 每次加载自增，方便判断「刷新完成」。
  final int loadCount;

  MarketState copyWith({
    MarketStatus? status,
    List<Coin>? coins,
    List<String>? watchlistSymbols,
    String? query,
    int? categoryIndex,
    MarketSortField? sortField,
    bool? sortAscending,
    MarketSource? source,
    bool? offline,
    String? notice,
    bool clearNotice = false,
    int? loadCount,
  }) {
    return MarketState(
      status: status ?? this.status,
      coins: coins ?? this.coins,
      watchlistSymbols: watchlistSymbols ?? this.watchlistSymbols,
      query: query ?? this.query,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      source: source ?? this.source,
      offline: offline ?? this.offline,
      notice: clearNotice ? null : (notice ?? this.notice),
      loadCount: loadCount ?? this.loadCount,
    );
  }

  /// 当前筛选 + 搜索 + 排序之后的列表。
  List<Coin> get visibleCoins {
    final List<Coin> source = switch (categoryIndex) {
      0 => _watchlistCoins(),
      // 期权行情暂未接入
      3 => const <Coin>[],
      _ => coins.take(MarketConfig.listLimit).toList(growable: false),
    };

    final String keyword = query.trim().toLowerCase();
    final Iterable<Coin> filtered = keyword.isEmpty
        ? source
        : source.where(
            (Coin coin) =>
                coin.symbol.toLowerCase().contains(keyword) ||
                coin.name.toLowerCase().contains(keyword),
          );

    final List<Coin> result = filtered.toList();
    if (sortField == MarketSortField.none) {
      return result;
    }
    result.sort(_compare);
    return sortAscending ? result : result.reversed.toList();
  }

  /// 涨幅最高的币种，用于搜索框的热搜提示。
  Coin? get hotCoin {
    if (coins.isEmpty) {
      return null;
    }
    Coin best = coins.first;
    for (final Coin coin in coins) {
      if (coin.changePercent24h > best.changePercent24h) {
        best = coin;
      }
    }
    return best;
  }

  String get hotHint {
    final Coin? hot = hotCoin;
    return hot == null ? '当前热搜' : '${hot.symbol} 当前热搜';
  }

  bool isWatchlisted(String symbol) => watchlistSymbols.contains(symbol);

  List<Coin> watchlistCoins() => _watchlistCoins();

  List<Coin> nonWatchlistCoins() => coins
      .where((Coin coin) => !watchlistSymbols.contains(coin.symbol))
      .toList(growable: false);

  /// 按自选顺序取币种，数据源里没有的（比如币安的 OKB）直接跳过。
  List<Coin> _watchlistCoins() {
    final Map<String, Coin> bySymbol = <String, Coin>{
      for (final Coin coin in coins) coin.symbol: coin,
    };
    return <Coin>[
      for (final String symbol in watchlistSymbols)
        if (bySymbol.containsKey(symbol)) bySymbol[symbol]!,
    ];
  }

  int _compare(Coin a, Coin b) {
    switch (sortField) {
      case MarketSortField.name:
        return a.symbol.compareTo(b.symbol);
      case MarketSortField.volume:
        return a.volume24h.compareTo(b.volume24h);
      case MarketSortField.price:
        return a.price.compareTo(b.price);
      case MarketSortField.change:
        return a.changePercent24h.compareTo(b.changePercent24h);
      case MarketSortField.none:
        return 0;
    }
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        coins,
        watchlistSymbols,
        query,
        categoryIndex,
        sortField,
        sortAscending,
        source,
        offline,
        notice,
        loadCount,
      ];
}
