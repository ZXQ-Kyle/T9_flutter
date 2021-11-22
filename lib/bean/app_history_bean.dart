import 'package:hive/hive.dart';

part 'app_history_bean.g.dart';

//flutter packages pub run build_runner build --delete-conflicting-outputs

@HiveType(typeId: 1)
class AppHistoryBean extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final DateTime time;

  AppHistoryBean(
    this.packageName,
    this.time,
  );

  @override
  String toString() {
    return 'AppHistoryBean{packageName: $packageName, time: $time}';
  }
}
