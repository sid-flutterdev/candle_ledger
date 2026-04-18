import 'package:hive/hive.dart';

part 'trade.g.dart';

@HiveType(typeId: 1)
enum TradeSegment {
  @HiveField(0)
  equity,
  @HiveField(1)
  options,
  @HiveField(2)
  futures,
}

@HiveType(typeId: 2)
enum OptionType {
  @HiveField(0)
  ce,
  @HiveField(1)
  pe,
}

@HiveType(typeId: 3)
enum TradeType {
  @HiveField(0)
  intraday,
  @HiveField(1)
  swing,
  @HiveField(2)
  longterm,
}

@HiveType(typeId: 4)
class Trade extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String symbol;

  @HiveField(3)
  final TradeSegment segment;

  @HiveField(4)
  final double buyPrice;

  @HiveField(5)
  final double sellPrice;

  @HiveField(6)
  final int quantity;

  @HiveField(7)
  final String rrRatio;

  @HiveField(8)
  final String accountId;

  @HiveField(9)
  final String? note;

  @HiveField(10)
  final String? screenshotPath;

  // Equity specific
  @HiveField(11)
  final TradeType? tradeType;

  // Options specific
  @HiveField(12)
  final String? script;

  @HiveField(13)
  final OptionType? optionType;

  Trade({
    required this.id,
    required this.date,
    required this.symbol,
    required this.segment,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    required this.rrRatio,
    required this.accountId,
    this.note,
    this.screenshotPath,
    this.tradeType,
    this.script,
    this.optionType,
  });

  double get pnl => (sellPrice - buyPrice) * quantity;
  bool get isWin => pnl > 0;
}
