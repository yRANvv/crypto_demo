/// 行情页的静态配置。
abstract final class MarketConfig {
  static const List<String> tabs = <String>['市场', '动态', '牛人榜'];

  static const List<String> categories = <String>[
    '自选',
    '现货',
    '合约',
    '期权',
    '总览',
  ];

  /// 自选默认币种，顺序与设计稿一致。
  /// OKB 只有 CoinGecko 有，换币安数据源时会自动跳过。
  static const List<String> defaultWatchlistSymbols = <String>[
    'BNB',
    'ETH',
    'OKB',
    'XRP',
    'SOL',
    'DOGE',
    'ADA',
    'LINK',
  ];

  static const int listLimit = 30;
}
