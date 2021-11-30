import 'dart:async';
import 'dart:collection';

import 'package:device_apps/device_apps.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:t9_flutter/bean/app_bean.dart';
import 'package:t9_flutter/bean/app_history_bean.dart';
import 'package:t9_flutter/util/constant.dart';

const wordMap = {
  '2': 'ABC',
  '3': 'DEF',
  '4': 'GHI',
  '5': 'JKL',
  '6': 'MNO',
  '7': 'PQRS',
  '8': 'TUV',
  '9': 'WXYZ',
};

class HomeLogic extends GetxController {
  var text = ''.obs;
  List<AppBean> totalApps = [];
  List<AppBean> list = [];

  late StreamSubscription _listener;

  @override
  void onInit() async {
    Stream<ApplicationEvent> appListener = DeviceApps.listenToAppsChanges();
    _listener = appListener.listen((event) {
      switch (event.event) {
        case ApplicationEventType.updated:
          break;

        case ApplicationEventType.installed:
        case ApplicationEventType.uninstalled:
        case ApplicationEventType.enabled:
        case ApplicationEventType.disabled:
          updateDb(force: true);
          break;

        default:
          break;
      }
    });

    var box = Hive.box<AppBean>(hiveBoxApp);

    ///初始化应用数据
    if (box.isEmpty) {
      //首次创建
      _createDb();
    } else {
      //更新应用数据，保留打开次数及最后打开时间

      //数据库版本升级
      _initListData();
      updateDb();
    }
    super.onInit();
  }

  @override
  void onClose() {
    _listener.cancel();
    super.onClose();
  }

  _createDb() async {
    var box = Hive.box<AppBean>(hiveBoxApp);
    List<Application> res = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
      includeAppIcons: true,
    );
    List<ApplicationWithIcon> apps = res.cast<ApplicationWithIcon>();

    Map<String, AppBean> map = {};
    for (var e in apps) {
      if (!e.enabled) {
        continue;
      }
      map[e.packageName] = AppBean(
        e.packageName,
        e.appName,
        e.icon,
        0,
        DateTime.now(),
        _generalPy(e.appName),
        shield: false,
      );
    }
    box.putAll(map);
    _initListData();
  }

  void _initListData() {
    totalApps = Hive.box<AppBean>(hiveBoxApp).values.toList(growable: false);
    //默认排序，按最近打开顺序排序
    totalApps.sort((AppBean a, AppBean b) => b.lastUsed.compareTo(a.lastUsed));
    list = totalApps;
    update();
  }

  String _generalPy(String name) {
    return PinyinHelper.getShortPinyin(name)
        .replaceAll(RegExp(r'\.|_| '), '')
        .toUpperCase();
  }

  ///搜索核心逻辑
  ///[reverse] 删除输入
  ///[index] 点击的键盘位置
  void filter({int index = 0, bool reverse = false}) {
    if (text.value.isEmpty) {
      reset();
      return;
    }

    //模糊判断
    var vagueStr = text.value
        .split('')
        .map((e) => '[${index + 1}${wordMap[e] ?? ''}]')
        .join('.?');
    var vagueRegExp = RegExp(vagueStr);

    if (reverse) {
      list = totalApps;
    }
    var vagueList = list.where((element) {
      return (element.shortPinyin.length >= text.value.length) &&
          element.shortPinyin.contains(vagueRegExp);
    }).toList(growable: false);
    vagueList.sort((a, b) {
      var compareTo = b.openCount.compareTo(a.openCount);
      if (compareTo == 0) {
        return b.lastUsed.compareTo(a.lastUsed);
      }
      return compareTo;
    });

    //精确判断，按顺序强制匹配第一位至最后一位
    var startStr = text.value
        .split('')
        .map((e) => '[${index + 1}${wordMap[e] ?? ''}]')
        .join('');
    var startRegExp = RegExp(startStr);

    var startList = list.where((element) {
      return (element.shortPinyin.length >= text.value.length) &&
          element.shortPinyin.startsWith(startRegExp);
    }).toList();
    startList.sort((a, b) {
      var compareTo = b.openCount.compareTo(a.openCount);
      if (compareTo == 0) {
        return b.lastUsed.compareTo(a.lastUsed);
      }
      return compareTo;
    });
    startList.addAll(vagueList);
    list = LinkedHashSet<AppBean>.from(startList).toList();

    update();
  }

  void reset() {
    list = totalApps;
    update();
  }

  ///增加计数、修改最近打开时间
  void openApp(AppBean bean) {
    bean.lastUsed = DateTime.now();
    bean.openCount = bean.openCount + 1;
    bean.save();
    totalApps.sort((AppBean a, AppBean b) => b.lastUsed.compareTo(a.lastUsed));

    //添加到历史记录
    var lazyBox = Hive.lazyBox<AppHistoryBean>(hiveBoxHistory);
    lazyBox.add(AppHistoryBean(bean.packageName, bean.lastUsed));
  }

  ///更新应用数据
  void updateDb({bool force = false}) async {
    var box = Hive.box<AppBean>(hiveBoxApp);
    //判断数据库应用数据是否与实际相同，可选跳过比较
    if (!force) {
      List<Application> res = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,
        includeSystemApps: true,
      );
      //判断是否有应用变动
      List<String> keys = box.keys.map((e) => '$e').toList(growable: false);
      keys.sort((a, b) => a.compareTo(b));
      var list = res
          .where((element) => element.enabled)
          .map((e) => e.packageName)
          .toList(growable: false);
      list.sort((a, b) => a.compareTo(b));
      if (keys.join(',') == list.join(',')) {
        return;
      }
    }

    //更新数据
    List<Application> res = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
      includeAppIcons: true,
    );
    List<ApplicationWithIcon> apps =
        res.map<ApplicationWithIcon>((e) => e as ApplicationWithIcon).toList();
    Map<String, AppBean> map = {};
    for (var e in apps) {
      if (!e.enabled) {
        continue;
      }
      var bean = box.get(e.packageName);
      map[e.packageName] = bean ??
          AppBean(
            e.packageName,
            e.appName,
            e.icon,
            0,
            DateTime.now(),
            _generalPy(e.appName),
          );
    }
    //删除全部原数据，再添加新数据
    box.deleteAll(box.keys);
    box.putAll(map);
    _initListData();
  }
}
