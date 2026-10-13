import '../models/coin_model.dart';

abstract class MarketRemoteDataSource {
  Future<List<CoinModel>> fetchMarkets({int perPage});
}
