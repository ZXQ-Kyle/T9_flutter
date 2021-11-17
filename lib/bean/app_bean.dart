import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'app_bean.g.dart';

//flutter packages pub run build_runner build --delete-conflicting-outputs

@HiveType(typeId: 0)
class AppBean extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final Uint8List icon;

  @HiveField(3)
  int openCount;

  @HiveField(4)
  DateTime lastUsed;

  @HiveField(5)
  final String shortPinyin;

  AppBean(
    this.packageName,
    this.name,
    this.icon,
    this.openCount,
    this.lastUsed,
    this.shortPinyin,
  );

  @override
  String toString() {
    return 'AppBean{packageName: $packageName, name: $name, icon: , openCount: $openCount, lastUsed: $lastUsed, shortPinyin: $shortPinyin}';
  }
}
