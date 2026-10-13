/// 编译期开关，通过 --dart-define 注入（用法见 README）。
abstract final class Defines {
  /// CoinGecko 密钥：Demo 方案或 Pro 方案，二选一。
  static const String coinGeckoKey =
      String.fromEnvironment('COINGECKO_API_KEY');
  static const String coinGeckoProKey =
      String.fromEnvironment('COINGECKO_PRO_API_KEY');

  /// 自建反代地址，直连不通时使用。
  static const String coinGeckoBaseUrl =
      String.fromEnvironment('COINGECKO_BASE_URL');

  /// 本地 HTTP 代理，只有原生端生效（Web 的网络由浏览器接管）。
  static const String httpProxy = String.fromEnvironment('HTTP_PROXY');

  /// 行情来源：auto / coingecko / binance。
  static const String dataSource = String.fromEnvironment('DATA_SOURCE');

  /// 鉴权方式：auto / firebase / demo。
  static const String authMode = String.fromEnvironment('AUTH_MODE');

  static bool get useProApi => coinGeckoProKey.isNotEmpty;
}

/// 运行期状态，由 get_it 注入。
class AppConfig {
  const AppConfig({required this.firebaseReady, required this.demoAuth});

  /// Firebase 是否初始化成功。
  final bool firebaseReady;

  /// 当前是否在用本地演示鉴权（Firebase 未配置，或被 AUTH_MODE=demo 强制）。
  final bool demoAuth;
}
