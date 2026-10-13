enum MarketSource {
  coingecko('CoinGecko'),
  binance('币安'),
  snapshot('内置演示数据');

  const MarketSource(this.label);

  final String label;
}

/// 数据源模式，由 --dart-define=DATA_SOURCE 指定。
enum DataSourceMode {
  /// 先 CoinGecko，失败自动降级到币安。
  auto,
  coingecko,
  binance;

  static DataSourceMode parse(String raw) {
    return switch (raw.trim().toLowerCase()) {
      'coingecko' || 'cg' => DataSourceMode.coingecko,
      'binance' || 'bn' => DataSourceMode.binance,
      _ => DataSourceMode.auto,
    };
  }
}
