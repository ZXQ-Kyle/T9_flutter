import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_logic.dart';

class HomeRoute extends StatelessWidget {
  final logic = Get.put(HomeLogic());

  HomeRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '波妞帮你搜应用',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<HomeLogic>(builder: (ctx) {
              if (logic.list.isEmpty && logic.totalApps.isEmpty) {
                return const Text('刷新应用数据...');
              }
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.4,
                ),
                itemBuilder: (ctx, index) {
                  var bean = logic.list.elementAt(index);
                  return InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () async {
                      var app = await DeviceApps.getApp(bean.packageName);
                      logic.openApp(bean);
                      app?.openApp();
                    },
                    onLongPress: () async {
                      var app = await DeviceApps.getApp(bean.packageName);
                      app?.openSettingsScreen();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Image.memory(
                              bean.icon,
                              height: 40,
                              width: 40,
                            ),
                          ),
                          Text(
                            bean.name,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                cacheExtent: 56,
                itemCount: logic.list.length,
              );
            }),
          ),
          Container(
            color: Colors.black.withOpacity(0.1),
            height: 40,
            width: double.infinity,
            alignment: Alignment.center,
            child: Obx(() => Text(
                  logic.text.value,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                )),
          ),
          Container(
            color: Colors.black.withOpacity(0.1),
            height: 238,
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 8),
            child: GridView.builder(
              itemCount: 12,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: width / 3 / (230 / 4),
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

  Widget _generalPad(int index) {
    Widget wi(String str, {GestureTapCallback? onTap}) {
      return InkWell(
        borderRadius: BorderRadius.circular(50),
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Center(
          child: Text(str),
        ),
      );
    }

    switch (index) {
      case 0:
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
        return wi('${index + 1} ${wordMap['${index + 1}'] ?? ''}', onTap: () {
          logic.text.value = '${logic.text.value}${index + 1}';
          logic.filter(index: index);
        });
      case 9:
        return wi('x', onTap: () {
          logic.text.value = '';
          logic.reset();
        });
      case 10:
        return wi('0');
      case 11:
        return wi(
          '←',
          onTap: () {
            var text = logic.text.value;
            if (text.isEmpty) {
              return;
            } else {
              logic.text.value = text.substring(0, text.length - 1);
              logic.filter(reverse: true);
            }
          },
        );

      default:
        return wi('$index');
    }
  }
}
