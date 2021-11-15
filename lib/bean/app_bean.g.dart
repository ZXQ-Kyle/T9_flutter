// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_bean.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppBeanAdapter extends TypeAdapter<AppBean> {
  @override
  final int typeId = 0;

  @override
  AppBean read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppBean(
      fields[0] as String,
      fields[1] as String,
      fields[2] as Uint8List,
      fields[3] as int,
      fields[4] as DateTime,
      fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppBean obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.openCount)
      ..writeByte(4)
      ..write(obj.lastUsed)
      ..writeByte(5)
      ..write(obj.shortPinyin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppBeanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
