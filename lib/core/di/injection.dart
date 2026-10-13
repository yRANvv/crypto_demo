import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/demo_auth_remote_data_source.dart';
import '../../features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/market/data/datasources/binance_market_data_source.dart';
import '../../features/market/data/datasources/coin_gecko_market_data_source.dart';
import '../../features/market/data/repositories/market_repository_impl.dart';
import '../../features/market/domain/market_source.dart';
import '../../features/market/domain/repositories/market_repository.dart';
import '../../features/market/presentation/bloc/market_bloc.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies({required bool firebaseReady}) {
  final bool useFirebaseAuth = _resolveUseFirebaseAuth(firebaseReady);

  getIt
    ..registerSingleton<AppConfig>(
      AppConfig(firebaseReady: firebaseReady, demoAuth: !useFirebaseAuth),
    )
    ..registerLazySingleton<Dio>(DioClient.create)
    ..registerLazySingleton<CoinGeckoMarketDataSource>(
      () => CoinGeckoMarketDataSource(getIt<Dio>()),
    )
    // 币安是另一个域名，单独建一个 Dio。
    ..registerLazySingleton<BinanceMarketDataSource>(
      () => BinanceMarketDataSource(
        DioClient.create(baseUrl: ApiEndpoints.binance),
      ),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => useFirebaseAuth
          ? FirebaseAuthRemoteDataSource(FirebaseAuth.instance)
          : DemoAuthRemoteDataSource(),
    )
    ..registerLazySingleton<MarketRepository>(
      () => MarketRepositoryImpl(
        coinGecko: getIt<CoinGeckoMarketDataSource>(),
        binance: getIt<BinanceMarketDataSource>(),
        mode: DataSourceMode.parse(Defines.dataSource),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    )
    ..registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()))
    ..registerFactory<MarketBloc>(() => MarketBloc(getIt<MarketRepository>()));
}

/// AUTH_MODE 优先，没指定就看 Firebase 是否可用。
bool _resolveUseFirebaseAuth(bool firebaseReady) {
  if (Defines.authMode == 'demo') {
    return false;
  }
  if (Defines.authMode == 'firebase') {
    return true;
  }
  return firebaseReady;
}
