import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/coin_model.dart';
import 'market_remote_data_source.dart';

/// 币安公开行情（data-api.binance.vision），无需 Key，作为 CoinGecko 的降级来源，
/// 字段映射成同一套 CoinModel。
class BinanceMarketDataSource implements MarketRemoteDataSource {
  BinanceMarketDataSource(this._dio);

  final Dio _dio;

  /// 主力币种，作为扩展清单失效时的兜底。
  static const List<String> _coreSymbols = <String>[
    'BTC', 'ETH', 'BNB', 'XRP', 'SOL', 'DOGE', 'ADA', 'LINK',
    'TRX', 'AVAX', 'DOT', 'LTC', 'UNI', 'ATOM', 'BCH',
  ];

  /// 展示币种清单（USDT 交易对，已实测全部有效）。
  ///
  /// 注意：symbols 参数里只要有一个已下架的币种，接口会整体返回 -1121，
  /// 所以这里只放稳定交易对，失败时再退回 _coreSymbols。
  static const List<String> symbols = <String>[
    ..._coreSymbols,
    'ETC', 'FIL', 'XLM', 'ALGO', 'VET', 'EOS', 'AAVE', 'NEO',
    'XTZ', 'ZEC', 'DASH', 'XMR', 'QTUM', 'ONT', 'KSM', 'COMP',
    'MKR', 'SUSHI', 'CRV', 'SAND', 'MANA', 'GRT', 'CHZ', 'ZIL',
    'YFI', '1INCH', 'THETA', 'ICP', 'NEXO',
  ];

  static const Map<String, String> _names = <String, String>{
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'BNB': 'BNB',
    'XRP': 'XRP',
    'SOL': 'Solana',
    'DOGE': 'Dogecoin',
    'ADA': 'Cardano',
    'LINK': 'Chainlink',
    'TRX': 'TRON',
    'AVAX': 'Avalanche',
    'DOT': 'Polkadot',
    'LTC': 'Litecoin',
    'UNI': 'Uniswap',
    'ATOM': 'Cosmos',
    'BCH': 'Bitcoin Cash',
    'ETC': 'Ethereum Classic',
    'FIL': 'Filecoin',
    'XLM': 'Stellar',
    'ALGO': 'Algorand',
    'VET': 'VeChain',
    'EOS': 'EOS',
    'AAVE': 'Aave',
    'NEO': 'Neo',
    'XTZ': 'Tezos',
    'ZEC': 'Zcash',
    'DASH': 'Dash',
    'XMR': 'Monero',
    'QTUM': 'Qtum',
    'ONT': 'Ontology',
    'KSM': 'Kusama',
    'COMP': 'Compound',
    'MKR': 'Maker',
    'SUSHI': 'SushiSwap',
    'CRV': 'Curve DAO',
    'SAND': 'The Sandbox',
    'MANA': 'Decentraland',
    'GRT': 'The Graph',
    'CHZ': 'Chiliz',
    'ZIL': 'Zilliqa',
    'YFI': 'yearn.finance',
    '1INCH': '1inch',
    'THETA': 'Theta',
    'ICP': 'Internet Computer',
    'NEXO': 'Nexo',
  };

  @override
  Future<List<CoinModel>> fetchMarkets({int perPage = 100}) async {
    List<dynamic> data;
    try {
      data = await _fetch(symbols);
    } on DioException {
      data = await _fetch(_coreSymbols);
    }

    final List<CoinModel> coins = <CoinModel>[
      for (final dynamic item in data)
        if (item is Map<String, dynamic>) _toCoin(item),
    ];
    coins.sort((CoinModel a, CoinModel b) => b.volume24h.compareTo(a.volume24h));
    return coins;
  }

  Future<List<dynamic>> _fetch(List<String> bases) async {
    final Response<List<dynamic>> response = await _dio.get<List<dynamic>>(
      ApiEndpoints.binanceTicker24h,
      queryParameters: <String, dynamic>{
        'symbols': jsonEncode(<String>[
          for (final String base in bases) '${base}USDT',
        ]),
      },
    );
    return response.data ?? const <dynamic>[];
  }

  CoinModel _toCoin(Map<String, dynamic> json) {
    final String pair = json['symbol'] as String? ?? '';
    final String base =
        pair.endsWith('USDT') ? pair.substring(0, pair.length - 4) : pair;
    return CoinModel(
      id: base.toLowerCase(),
      symbol: base,
      name: _names[base] ?? base,
      // 接口不提供图片，图标走本地资源。
      imageUrl: '',
      price: _toDouble(json['lastPrice']),
      volume24h: _toDouble(json['quoteVolume']),
      changePercent24h: _toDouble(json['priceChangePercent']),
    );
  }

  /// 币安接口的数值都是字符串。
  double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return value is String ? double.tryParse(value) ?? 0 : 0;
  }
}
