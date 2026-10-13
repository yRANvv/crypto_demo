import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'proxy_configurator.dart' as proxy;

abstract final class ApiEndpoints {
  static const String coinGeckoDemo = 'https://api.coingecko.com/api/v3';
  static const String coinGeckoPro = 'https://pro-api.coingecko.com/api/v3';
  static const String coinGeckoMarkets = '/coins/markets';

  static const String binance = 'https://data-api.binance.vision';
  static const String binanceTicker24h = '/api/v3/ticker/24hr';
}

abstract final class DioClient {
  static Dio create({String? baseUrl}) {
    final Map<String, String> headers = <String, String>{
      'accept': 'application/json',
    };

    // CoinGecko 官方要求：Pro 用 x-cg-pro-api-key，Demo 用 x-cg-demo-api-key。
    if (Defines.coinGeckoProKey.isNotEmpty) {
      headers['x-cg-pro-api-key'] = Defines.coinGeckoProKey;
    } else if (Defines.coinGeckoKey.isNotEmpty) {
      headers['x-cg-demo-api-key'] = Defines.coinGeckoKey;
    }

    // 浏览器不允许脚本改 User-Agent，只在原生端设置。
    if (!kIsWeb) {
      headers['user-agent'] = 'crypto_demo/1.0';
    }

    final Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _coinGeckoBaseUrl(),
        headers: headers,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    if (Defines.httpProxy.isNotEmpty) {
      proxy.applyProxy(dio, Defines.httpProxy);
    }
    return dio;
  }

  static String _coinGeckoBaseUrl() {
    if (Defines.coinGeckoBaseUrl.isNotEmpty) {
      return Defines.coinGeckoBaseUrl;
    }
    return Defines.useProApi
        ? ApiEndpoints.coinGeckoPro
        : ApiEndpoints.coinGeckoDemo;
  }
}
