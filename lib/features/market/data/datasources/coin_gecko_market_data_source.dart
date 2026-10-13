import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/coin_model.dart';
import 'market_remote_data_source.dart';

class CoinGeckoMarketDataSource implements MarketRemoteDataSource {
  CoinGeckoMarketDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<CoinModel>> fetchMarkets({int perPage = 100}) async {
    final Response<List<dynamic>> response = await _dio.get<List<dynamic>>(
      ApiEndpoints.coinGeckoMarkets,
      queryParameters: <String, dynamic>{
        'vs_currency': 'usd',
        'order': 'market_cap_desc',
        'per_page': perPage,
        'page': 1,
        'sparkline': false,
        'price_change_percentage': '24h',
      },
    );

    final List<dynamic> data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(CoinModel.fromJson)
        .toList(growable: false);
  }
}
