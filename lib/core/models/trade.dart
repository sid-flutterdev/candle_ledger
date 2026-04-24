enum TradeSegment {
  equity,
  options,
  futures,
}

enum OptionType {
  ce,
  pe,
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
  final String rrRatio;
  final String accountId;
  final String? note;
  final String? screenshotPath;

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
    required this.rrRatio,
    required this.accountId,
    this.note,
    this.screenshotPath,
    this.tradeType,
    this.script,
    this.optionType,
    this.cloudScreenshotUrl,
  });

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
