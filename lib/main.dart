import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:t9_flutter/bean/app_bean.dart';
import 'package:t9_flutter/bean/app_history_bean.dart';
import 'package:t9_flutter/route/home_route/home_route.dart';
import 'package:t9_flutter/util/constant.dart';

final logger = Logger(
  printer: PrettyPrinter(
      methodCount: 2,
      // number of method calls to be displayed
      errorMethodCount: 8,
      // number of method calls if stacktrace is provided
      lineLength: 120,
      // width of the output
      colors: true,
      // Colorful log messages
      printEmojis: true,
      // Print an emoji for each log message
      printTime: false // Should each log print contain a timestamp
      ),
);

void main() async {
  /// 状态栏透明
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  await Hive.initFlutter('hive_db');
  Hive.registerAdapter(AppBeanAdapter());
  Hive.registerAdapter(AppHistoryBeanAdapter());
  await Hive.openBox<AppBean>(hiveBoxApp);
  await Hive.openLazyBox<AppHistoryBean>(hiveBoxHistory);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '波妞帮你搜应用',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashColor: Colors.blue,
      ),
      home: HomeRoute(),
    );
  }
}
