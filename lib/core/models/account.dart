import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String broker;

  @HiveField(3)
  final double initialBalance;

  @HiveField(4)
  final double liquidBalance;

  @HiveField(5)
  final double investedBalance;

  @HiveField(6)
  final int iconIndex;

  @HiveField(7)
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
}
