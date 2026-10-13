import '../models/coin_model.dart';

/// 设计稿行情快照，所有接口都不可用时使用。
abstract final class MarketSnapshotData {
  static const List<CoinModel> coins = <CoinModel>[
    CoinModel(
      id: 'binancecoin',
      symbol: 'BNB',
      name: 'BNB',
      imageUrl: '',
      price: 1276.5,
      volume24h: 228000000,
      changePercent24h: 0.16,
    ),
    CoinModel(
      id: 'ethereum',
      symbol: 'ETH',
      name: 'Ethereum',
      imageUrl: '',
      price: 4151.45,
      volume24h: 1003000000,
      changePercent24h: 0.38,
    ),
    CoinModel(
      id: 'okb',
      symbol: 'OKB',
      name: 'OKB',
      imageUrl: '',
      price: 183.88,
      volume24h: 92963400,
      changePercent24h: -0.97,
    ),
    CoinModel(
      id: 'ripple',
      symbol: 'XRP',
      name: 'XRP',
      imageUrl: '',
      price: 2.5596,
      volume24h: 190000000,
      changePercent24h: -1.08,
    ),
    CoinModel(
      id: 'solana',
      symbol: 'SOL',
      name: 'Solana',
      imageUrl: '',
      price: 205.99,
      volume24h: 420000000,
      changePercent24h: 4.87,
    ),
    CoinModel(
      id: 'dogecoin',
      symbol: 'DOGE',
      name: 'Dogecoin',
      imageUrl: '',
      price: 0.20748,
      volume24h: 338000000,
      changePercent24h: -1.27,
    ),
    CoinModel(
      id: 'cardano',
      symbol: 'ADA',
      name: 'Cardano',
      imageUrl: '',
      price: 0.7129,
      volume24h: 37902700,
      changePercent24h: -0.43,
    ),
    CoinModel(
      id: 'chainlink',
      symbol: 'LINK',
      name: 'Chainlink',
      imageUrl: '',
      price: 19.401,
      volume24h: 27827400,
      changePercent24h: -1.71,
    ),
  ];
}
