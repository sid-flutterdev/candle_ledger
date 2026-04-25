enum TradeSegment {
  equity,
  options,
  futures,
}

enum OptionType {
  ce,
  pe,
}

enum TradeDirection {
  long,
  short,
}

enum TradeType {
  intraday,
  swing,
  longterm,
}

class Trade {
  final String id;
  final DateTime date;
  final String symbol;
  final TradeSegment segment;
  final double buyPrice;
  final double sellPrice;
  final int quantity;
  final double charges; // New field
  final String rrRatio;
  final String accountId;
  final String? note;
  final String? screenshotPath;
  final TradeDirection? direction; // New field
  final String? startTime; // New field (Time as string HH:mm)
  final String? endTime; // New field (Time as string HH:mm)

  // Equity specific
  final TradeType? tradeType;

  // Options specific
  final String? script;
  final OptionType? optionType;

  Trade({
    required this.id,
    required this.date,
    required this.symbol,
    required this.segment,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    this.charges = 0.0,
    required this.rrRatio,
    required this.accountId,
    this.note,
    this.screenshotPath,
    this.direction,
    this.startTime,
    this.endTime,
    this.tradeType,
    this.script,
    this.optionType,
    this.cloudScreenshotUrl,
  });

  final String? cloudScreenshotUrl;

  double get grossPnl => (sellPrice - buyPrice) * quantity;

  double get pnl => grossPnl - charges; // Net PnL
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
      'charges': charges,
      'rrRatio': rrRatio,
      'accountId': accountId,
      'note': note,
      'screenshotPath': screenshotPath,
      'cloudScreenshotUrl': cloudScreenshotUrl,
      'tradeType': tradeType?.name,
      'direction': direction?.name,
      'startTime': startTime,
      'endTime': endTime,
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
      charges: (map['charges'] ?? 0.0).toDouble(),
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
      direction: map['direction'] != null
          ? TradeDirection.values.firstWhere(
              (e) => e.name == map['direction'],
              orElse: () => TradeDirection.long,
            )
          : null,
      startTime: map['startTime'],
      endTime: map['endTime'],
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
    double? charges,
    String? rrRatio,
    String? accountId,
    String? note,
    String? screenshotPath,
    String? cloudScreenshotUrl,
    TradeType? tradeType,
    TradeDirection? direction,
    String? startTime,
    String? endTime,
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
      charges: charges ?? this.charges,
      rrRatio: rrRatio ?? this.rrRatio,
      accountId: accountId ?? this.accountId,
      note: note ?? this.note,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      cloudScreenshotUrl: cloudScreenshotUrl ?? this.cloudScreenshotUrl,
      tradeType: tradeType ?? this.tradeType,
      direction: direction ?? this.direction,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      script: script ?? this.script,
      optionType: optionType ?? this.optionType,
    );
  }
}
