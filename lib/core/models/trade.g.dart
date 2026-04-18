// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TradeAdapter extends TypeAdapter<Trade> {
  @override
  final int typeId = 4;

  @override
  Trade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Trade(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      symbol: fields[2] as String,
      segment: fields[3] as TradeSegment,
      buyPrice: fields[4] as double,
      sellPrice: fields[5] as double,
      quantity: fields[6] as int,
      rrRatio: fields[7] as String,
      accountId: fields[8] as String,
      note: fields[9] as String?,
      screenshotPath: fields[10] as String?,
      tradeType: fields[11] as TradeType?,
      script: fields[12] as String?,
      optionType: fields[13] as OptionType?,
    );
  }

  @override
  void write(BinaryWriter writer, Trade obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.segment)
      ..writeByte(4)
      ..write(obj.buyPrice)
      ..writeByte(5)
      ..write(obj.sellPrice)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.rrRatio)
      ..writeByte(8)
      ..write(obj.accountId)
      ..writeByte(9)
      ..write(obj.note)
      ..writeByte(10)
      ..write(obj.screenshotPath)
      ..writeByte(11)
      ..write(obj.tradeType)
      ..writeByte(12)
      ..write(obj.script)
      ..writeByte(13)
      ..write(obj.optionType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TradeSegmentAdapter extends TypeAdapter<TradeSegment> {
  @override
  final int typeId = 1;

  @override
  TradeSegment read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TradeSegment.equity;
      case 1:
        return TradeSegment.options;
      case 2:
        return TradeSegment.futures;
      default:
        return TradeSegment.equity;
    }
  }

  @override
  void write(BinaryWriter writer, TradeSegment obj) {
    switch (obj) {
      case TradeSegment.equity:
        writer.writeByte(0);
        break;
      case TradeSegment.options:
        writer.writeByte(1);
        break;
      case TradeSegment.futures:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OptionTypeAdapter extends TypeAdapter<OptionType> {
  @override
  final int typeId = 2;

  @override
  OptionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OptionType.ce;
      case 1:
        return OptionType.pe;
      default:
        return OptionType.ce;
    }
  }

  @override
  void write(BinaryWriter writer, OptionType obj) {
    switch (obj) {
      case OptionType.ce:
        writer.writeByte(0);
        break;
      case OptionType.pe:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TradeTypeAdapter extends TypeAdapter<TradeType> {
  @override
  final int typeId = 3;

  @override
  TradeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TradeType.intraday;
      case 1:
        return TradeType.swing;
      case 2:
        return TradeType.longterm;
      default:
        return TradeType.intraday;
    }
  }

  @override
  void write(BinaryWriter writer, TradeType obj) {
    switch (obj) {
      case TradeType.intraday:
        writer.writeByte(0);
        break;
      case TradeType.swing:
        writer.writeByte(1);
        break;
      case TradeType.longterm:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
