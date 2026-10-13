import 'package:intl/intl.dart';

/// 行情数字格式化，风格与设计稿一致：
/// 成交额 `$2.28亿`、价格 `1,276.5`、涨跌 `+0.16%`。
abstract final class MarketFormatter {
  static const List<int> _scales = <int>[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  static final Map<int, NumberFormat> _grouped = <int, NumberFormat>{
    for (final int decimals in _scales)
      decimals: NumberFormat('#,##0.${'0' * decimals}', 'en_US'),
  };
  static final NumberFormat _plain = NumberFormat('0.00', 'en_US');
  static final NumberFormat _usd = NumberFormat('#,##0.00', 'en_US');

  static String volume(double value) {
    final double abs = value.abs();
    if (abs >= 1e8) {
      return '\$${_trim(value / 1e8, 2)}亿';
    }
    if (abs >= 1e4) {
      return '\$${_trim(value / 1e4, 2, grouped: true)}万';
    }
    return '\$${_trim(value, 2, grouped: true)}';
  }

  /// 最新价：按量级选择小数位，末尾的 0 去掉。
  static String price(double value) {
    final double abs = value.abs();
    final int decimals;
    if (abs >= 100) {
      decimals = 2;
    } else if (abs >= 10) {
      decimals = 3;
    } else if (abs >= 1) {
      decimals = 4;
    } else {
      decimals = _leadingZeros(abs) + 5;
    }
    return _trim(value, decimals, grouped: true);
  }

  /// 价格下方的美元指数价，固定小数位。
  static String indexPrice(double value) {
    if (value.abs() >= 1) {
      return '\$${_usd.format(value)}';
    }
    return '\$${value.toStringAsFixed(5)}';
  }

  static String percent(double value) {
    final String sign = value < 0 ? '-' : '+';
    return '$sign${value.abs().toStringAsFixed(2)}%';
  }

  static int _leadingZeros(double value) {
    double scaled = value;
    int zeros = 0;
    while (scaled < 0.1 && zeros < 6) {
      scaled *= 10;
      zeros++;
    }
    return zeros;
  }

  static String _trim(double value, int decimals, {bool grouped = false}) {
    final NumberFormat formatter = grouped
        ? (_grouped[decimals] ?? _plain)
        : NumberFormat('0.${'0' * decimals}', 'en_US');
    final String text = formatter.format(value);
    if (!text.contains('.')) {
      return text;
    }
    String trimmed = text.replaceFirst(RegExp(r'0+$'), '');
    if (trimmed.endsWith('.')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
