// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_history_bean.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppHistoryBeanAdapter extends TypeAdapter<AppHistoryBean> {
  @override
  final int typeId = 1;

  @override
  AppHistoryBean read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppHistoryBean(
      fields[0] as String,
      fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AppHistoryBean obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppHistoryBeanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
