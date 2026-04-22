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
    this.cloudScreenshotUrl,
  });

  @HiveField(14)
  final String? cloudScreenshotUrl;

  double get pnl => (sellPrice - buyPrice) * quantity;
  bool get isWin => pnl > 0;

  Map<String, dynamic> toFirestore(String userId) {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'symbol': symbol,
      'segment': segment.name,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'quantity': quantity,
      'rrRatio': rrRatio,
      'accountId': accountId,
      'note': note,
      'screenshotPath': screenshotPath,
      'cloudScreenshotUrl': cloudScreenshotUrl,
      'tradeType': tradeType?.name,
      'script': script,
      'optionType': optionType?.name,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory Trade.fromFirestore(Map<String, dynamic> map) {
    return Trade(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      symbol: map['symbol'] ?? '',
      segment: TradeSegment.values.firstWhere(
        (e) => e.name == map['segment'],
        orElse: () => TradeSegment.equity,
      ),
      buyPrice: (map['buyPrice'] ?? 0.0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      rrRatio: map['rrRatio'] ?? '',
      accountId: map['accountId'] ?? '',
      note: map['note'],
      screenshotPath: map['screenshotPath'],
      cloudScreenshotUrl: map['cloudScreenshotUrl'],
      tradeType: map['tradeType'] != null
          ? TradeType.values.firstWhere(
              (e) => e.name == map['tradeType'],
              orElse: () => TradeType.intraday,
            )
          : null,
      script: map['script'],
      optionType: map['optionType'] != null
          ? OptionType.values.firstWhere(
              (e) => e.name == map['optionType'],
              orElse: () => OptionType.ce,
            )
          : null,
    );
  }

  Trade copyWith({
    String? id,
    DateTime? date,
    String? symbol,
    TradeSegment? segment,
    double? buyPrice,
    double? sellPrice,
    int? quantity,
    String? rrRatio,
    String? accountId,
    String? note,
    String? screenshotPath,
    String? cloudScreenshotUrl,
    TradeType? tradeType,
    String? script,
    OptionType? optionType,
  }) {
    return Trade(
      id: id ?? this.id,
      date: date ?? this.date,
      symbol: symbol ?? this.symbol,
      segment: segment ?? this.segment,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      quantity: quantity ?? this.quantity,
      rrRatio: rrRatio ?? this.rrRatio,
      accountId: accountId ?? this.accountId,
      note: note ?? this.note,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      cloudScreenshotUrl: cloudScreenshotUrl ?? this.cloudScreenshotUrl,
      tradeType: tradeType ?? this.tradeType,
      script: script ?? this.script,
      optionType: optionType ?? this.optionType,
    );
  }
}
