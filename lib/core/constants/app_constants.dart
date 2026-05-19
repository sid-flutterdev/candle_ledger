import 'package:intl/intl.dart';

class AppConstants {
  static const String appVersion = "1.0.0";
  static const String appName = "candle ledger";
}

extension DoubleFormat on double {
  String get toPercentStr {
    if (this == toInt()) {
      return toInt().toString();
    }
    return toStringAsFixed(2);
  }

  String get toCurrencyStr {
    if (this == toInt()) {
      return NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(this);
    }
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(this);
  }
}
