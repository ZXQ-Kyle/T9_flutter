import 'package:device_apps/device_apps.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:t9_flutter/bean/app_bean.dart';
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

  @override
  void onInit() async {
    var box = Hive.box<AppBean>(hiveBoxApp);

    ///初始化应用数据
    if (box.isEmpty) {
      List<Application> res = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,
        includeSystemApps: true,
        includeAppIcons: true,
      );
      List<ApplicationWithIcon> apps = res.cast<ApplicationWithIcon>();

      Map<String, AppBean> map = {};
      for (var e in apps) {
        map[e.packageName] = AppBean(
          e.packageName,
          e.appName,
          e.icon,
          0,
          DateTime.now(),
          _generalPy(e.appName),
        );
      }
      box.putAll(map);
    } else {
      ///更新应用数据
      updateDb(box);
    }
    _initListData();
    super.onInit();
  }

  void _initListData() {
    totalApps = Hive.box<AppBean>(hiveBoxApp).values.toList(growable: false);
    //默认排序，按最近打开顺序排序
    totalApps.sort((AppBean a, AppBean b) => b.lastUsed.compareTo(a.lastUsed));
    list = totalApps;
    update();
  }

  String _generalPy(String name) {
    return PinyinHelper.getShortPinyin(name).replaceAll(RegExp(r'\.|_| '), '').toUpperCase();
  }

  ///搜索核心逻辑
  void filter({bool reverse = false}) {
    if (text.value.isEmpty) {
      reset();
      return;
    }

    var join = text.value.split('').map((e) => '[${wordMap[e] ?? ''}]').join('.?');
    var regExp = RegExp(join);

    if (reverse) {
      list = totalApps;
    }
    list = list.where((element) {
      return (element.shortPinyin.length >= text.value.length) &&
          element.shortPinyin.contains(regExp);
    }).toList(growable: false);
    list.sort((a, b) {
      var compareTo = b.openCount.compareTo(a.openCount);
      if (compareTo == 0) {
        return b.lastUsed.compareTo(a.lastUsed);
      }
      return compareTo;
    });

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
  }

  ///更新应用数据
  void updateDb(Box<AppBean> box) async {
    List<Application> res = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
    );
    //判断是否有应用变动
    List<String> keys = box.keys.map((e) => '$e').toList(growable: false);
    keys.sort((a, b) => a.compareTo(b));
    var list = res.map((e) => e.packageName).toList(growable: false);
    list.sort((a, b) => a.compareTo(b));
    if (keys.join(',') == list.join(',')) {
      return;
    }
    //更新数据
    res = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
      includeAppIcons: true,
    );
    List<ApplicationWithIcon> apps =
        res.map<ApplicationWithIcon>((e) => e as ApplicationWithIcon).toList();
    Map<String, AppBean> map = {};
    for (var e in apps) {
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
    box.deleteAll(box.keys);
    box.putAll(map);
    _initListData();
  }
}
