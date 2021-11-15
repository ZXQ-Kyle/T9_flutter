import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:t9_flutter/bean/app_bean.dart';
import 'package:t9_flutter/route/home_route/home_route.dart';
import 'package:t9_flutter/util/constant.dart';

void main() async {
  /// 状态栏透明
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  await Hive.initFlutter('hive_db');
  Hive.registerAdapter(AppBeanAdapter());
  await Hive.openBox<AppBean>(hiveBoxApp);
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
      ),
      home: HomeRoute(),
    );
  }
}
