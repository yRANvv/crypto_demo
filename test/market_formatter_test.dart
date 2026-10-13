import 'package:crypto_demo/features/market/data/models/coin_model.dart';
import 'package:crypto_demo/core/utils/market_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketFormatter', () {
    test('成交额按 万 / 亿 缩写', () {
      expect(MarketFormatter.volume(228000000), r'$2.28亿');
      expect(MarketFormatter.volume(92963400), r'$9,296.34万');
      expect(MarketFormatter.volume(190000000), r'$1.9亿');
    });

    test('涨跌百分比带正负号', () {
      expect(MarketFormatter.percent(0.16), '+0.16%');
      expect(MarketFormatter.percent(-0.97), '-0.97%');
    });

    test('最新价按量级保留有效小数', () {
      expect(MarketFormatter.price(1276.5), '1,276.5');
      expect(MarketFormatter.price(0.20748), '0.20748');
      expect(MarketFormatter.price(19.401), '19.401');
    });
  });

  group('CoinModel', () {
    test('解析 CoinGecko 返回结构', () {
      final CoinModel coin = CoinModel.fromJson(<String, dynamic>{
        'id': 'binancecoin',
        'symbol': 'bnb',
        'name': 'BNB',
        'image': 'https://example.com/bnb.png',
        'current_price': 1276.5,
        'total_volume': 228000000,
        'price_change_percentage_24h': 0.16,
      });

      expect(coin.symbol, 'BNB');
      expect(coin.price, 1276.5);
      expect(coin.isUp, isTrue);
    });

    test('字段缺失时回退为 0，不抛异常', () {
      final CoinModel coin = CoinModel.fromJson(<String, dynamic>{});
      expect(coin.price, 0);
      expect(coin.volume24h, 0);
    });
  });
}
