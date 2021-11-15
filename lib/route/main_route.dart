import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:t9_flutter/bean/app_bean.dart';
import 'package:t9_flutter/util/constant.dart';

class MainRoute extends StatefulWidget {
  const MainRoute({
    Key? key,
  }) : super(key: key);

  @override
  _MainRouteState createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {
  String _text = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('应用')),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<AppBean>(hiveBoxApp).listenable(),
              builder: (BuildContext context, Box<AppBean> box, Widget? child) {
                if (box.values.isEmpty) {
                  _init();
                  return const Text('刷新应用数据...');
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      onTap: () async {
                        var app = await DeviceApps.getApp(box.getAt(index)!.packageName);
                        app?.openApp();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Image.memory(
                              box.getAt(index)!.icon,
                              height: 22,
                              width: 48,
                            ),
                          ),
                          Text(box.getAt(index)!.name),
                          Text(box.getAt(index)!.shortPinyin),
                        ],
                      ),
                    );
                  },
                  cacheExtent: 56,
                  itemCount: box.values.length,
                );
              },
            ),
          ),
          Text(_text),
          Container(
            color: Colors.black.withOpacity(0.2),
            height: 300,
            child: GridView.builder(
              itemCount: 12,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: width / 3 / (300 / 4),
              ),
              itemBuilder: (ctx, index) {
                return _generalPad(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _init() async {
    List<Application>? res = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
      includeAppIcons: true,
    );
    List<ApplicationWithIcon>? apps =
        res.map<ApplicationWithIcon>((e) => e as ApplicationWithIcon).toList();
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
    Hive.box<AppBean>(hiveBoxApp).putAll(map);
  }

  String _generalPy(String name) {
    return PinyinHelper.getShortPinyin(name).replaceAll(RegExp(r'\.|_| '), '');
  }

  Widget _generalPad(int index) {
    Widget wi(String str, {GestureTapCallback? onTap}) {
      return InkWell(
        onTap: onTap,
        child: Center(
          child: Text(str),
        ),
      );
    }

    GestureTapCallback customTap = () {
      setState(() {
        _text = '$_text$index';
      });
    };
    switch (index) {
      case 0:
        return wi('1');
      case 1:
        return wi('2 ABC', onTap: customTap);
      case 2:
        return wi('3 DEF', onTap: customTap);
      case 3:
        return wi('4 GHI', onTap: customTap);
      case 4:
        return wi('5 JKL', onTap: customTap);
      case 5:
        return wi('6 MNO', onTap: customTap);
      case 6:
        return wi('7 PQRS', onTap: customTap);
      case 7:
        return wi('8 TUV', onTap: customTap);
      case 8:
        return wi('9 WXYZ', onTap: customTap);
      case 9:
        return wi('X', onTap: () {
          setState(() {
            _text = '';
          });
        });
      case 10:
        return wi('0');
      case 11:
        return wi(
          '←',
          onTap: () {
            setState(() {
              _text = _text.padRight(_text.length - 1);
            });
          },
        );

      default:
        return wi('$index');
    }
  }
}
