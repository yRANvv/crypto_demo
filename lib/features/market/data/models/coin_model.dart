import '../../domain/entities/coin.dart';

/// CoinGecko /coins/markets 的返回结构。
class CoinModel extends Coin {
  const CoinModel({
    required super.id,
    required super.symbol,
    required super.name,
    required super.imageUrl,
    required super.price,
    required super.volume24h,
    required super.changePercent24h,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: _asString(json['id']),
      symbol: _asString(json['symbol']).toUpperCase(),
      name: _asString(json['name']),
      imageUrl: _asString(json['image']),
      price: _asDouble(json['current_price']),
      volume24h: _asDouble(json['total_volume']),
      changePercent24h: _asDouble(json['price_change_percentage_24h']),
    );
  }

  static String _asString(Object? value) => value is String ? value : '';

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}
