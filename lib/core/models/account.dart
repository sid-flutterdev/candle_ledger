class Account {
  final String id;
  final String name;
  final String broker;
  final double initialBalance;
  final double liquidBalance;
  final double investedBalance;
  final int iconIndex;
  final int colorHex;

  Account({
    required this.id,
    required this.name,
    required this.broker,
    required this.initialBalance,
    required this.liquidBalance,
    required this.investedBalance,
    required this.iconIndex,
    required this.colorHex,
  });

  double get totalBalance => liquidBalance + investedBalance;

  Map<String, dynamic> toFirestore(String userId) {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'broker': broker,
      'initialBalance': initialBalance,
      'liquidBalance': liquidBalance,
      'investedBalance': investedBalance,
      'iconIndex': iconIndex,
      'colorHex': colorHex,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory Account.fromFirestore(Map<String, dynamic> map) {
    return Account(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      broker: map['broker'] ?? '',
      initialBalance: (map['initialBalance'] ?? 0.0).toDouble(),
      liquidBalance: (map['liquidBalance'] ?? 0.0).toDouble(),
      investedBalance: (map['investedBalance'] ?? 0.0).toDouble(),
      iconIndex: map['iconIndex'] ?? 0,
      colorHex: map['colorHex'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Account copyWith({
    String? id,
    String? name,
    String? broker,
    double? initialBalance,
    double? liquidBalance,
    double? investedBalance,
    int? iconIndex,
    int? colorHex,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      broker: broker ?? this.broker,
      initialBalance: initialBalance ?? this.initialBalance,
      liquidBalance: liquidBalance ?? this.liquidBalance,
      investedBalance: investedBalance ?? this.investedBalance,
      iconIndex: iconIndex ?? this.iconIndex,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
