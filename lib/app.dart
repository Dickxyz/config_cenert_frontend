// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_dashboard_ui/provider.dart';
import 'package:responsive_dashboard_ui/style/colors.dart';
import 'package:responsive_dashboard_ui/style/style.dart';
import 'package:tuple/tuple.dart';

import 'api/requests.dart';
import 'components/app_bar_actions_item.dart';
import 'components/bar_chart_component.dart';
import 'components/dashboard_header.dart';
import 'components/history_table.dart';
import 'components/info_card.dart';
import 'components/payments_detail_list.dart';
import 'components/side_menu.dart';
import 'config/size_config.dart';

void main() => runApp(ProviderScope(child: App()));

/// The main app.
class App extends StatelessWidget {
  /// Creates an [App].
  App({Key? key}) : super(key: key);

  /// The title of the app.
  static const String title = 'RateLimiter';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColors.primaryBg,
        ),
      );

  final GoRouter _router = GoRouter(
      routes: <GoRoute>[
        GoRoute(
            path: '/home',
            builder: (BuildContext context, GoRouterState state) =>
                const HomePage(index: 0)),
        GoRoute(
            path: '/detail',
            builder: (BuildContext context, GoRouterState state) {
              final tenant = state.queryParams['tenant'];
              final path = state.queryParams["path"];
              return HomePage(index: 1, tenant: tenant, path: path);
            })
      ],
      redirect: (state) {
        if (state.subloc == "/") {
          return "/home";
        }
        if (state.subloc.startsWith("/detail")) {
          final tenant = state.queryParams['tenant'];
          if (tenant == null) {
            return "/home";
          }
          final path = state.queryParams["path"];
          if (path == null) {
            return "/detail?tenant=$tenant&path=/";
          }
        }
      });
}

/// The screen of the first page.
class HomePage extends StatelessWidget {
  /// Creates a [Page1Screen].
  const HomePage({Key? key, required this.index, this.tenant, this.path})
      : super(key: key);

  final int index;
  final String? tenant, path;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Widget? tab;
    if (index == 0) {
      tab = HomeTab();
    } else if (index == 1) {
      tab = ConfigTab(path: path!, tenant: tenant!);
    }

    return Scaffold(
      appBar: const PreferredSize(
        child: SizedBox(),
        preferredSize: Size.zero,
      ),
      drawer: SizedBox(
        width: 100,
        child: SideMenu(index),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: SideMenu(index),
            ),
            Expanded(
              flex: 10,
              child: tab!,
            ),
            Expanded(
              flex: 4,
              child: Container(
                height: SizeConfig.screenHeight,
                color: AppColors.secondaryBg,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: const [
                      // AppBarActionItem(),
                      PaymentsDetailList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(tabStateProvider.notifier).state = 0;
    return SizedBox(
        height: SizeConfig.screenHeight,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                List<String>? res = await showTextInputDialog(
                  title: "创建租户",
                  okLabel: "创建",
                  cancelLabel: "取消",
                  context: context,
                  textFields: [
                    DialogTextField(hintText: "租户名"),
                    DialogTextField(hintText: "租户描述"),
                  ],
                );
                if (res != null) {
                  if (res[0] != null && res[1] != null) {
                    await createTenant(res[0], res[1]);
                    ref.refresh(myTenantProvider);
                  }
                }
              },
              child: const Icon(Icons.add, color: AppColors.iconGray),
              backgroundColor: AppColors.secondaryBg),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchTenant(),
                // SizedBox(height: SizeConfig.blockSizeVertical! * 5),
                MyTenant()
              ],
            ),
          ),
        ));
  }
}

class ConfigTab extends ConsumerWidget {
  const ConfigTab({Key? key, required this.tenant, required this.path})
      : super(key: key);

  final String path;
  final String tenant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(tabStateProvider.notifier).state = 1;
    AsyncValue<List<Config>> results =
        ref.watch(configResultProvider(Tuple2<String, String>(tenant, path)));
    final resources = path.split("/");

    List<Widget> titleList = [
      PrimaryText(
        text: tenant,
        size: 30.0,
        fontWeight: FontWeight.w800,
      ),
      const SizedBox(width: 30),
      GestureDetector(
          onTap: () {
            context.go("/detail?tenant=$tenant&path=/");
          },
          child: const Text(
            "/",
            style: TextStyle(
                color: Colors.blue,
                height: 1.3,
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline),
          ))
    ];
    var paths = ["/"];
    for (int i = 0; i < resources.length; i++) {
      if (resources[i] == '') {
        paths.add(paths.last);
      }
      if (resources[i] != '') {
        paths.add(paths.last + resources[i] + "/");
        titleList.addAll([
          GestureDetector(
              onTap: () {
                context.go("/detail?tenant=$tenant&path=${paths[i + 1]}");
              },
              child: Text(
                resources[i],
                style: const TextStyle(
                    color: Colors.blue,
                    height: 1.3,
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline),
              )),
          const PrimaryText(text: "/")
        ]);
      }
    }

    return results.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
        data: (results) {
          Map<String, Config> configMap = {};
          for (Config config in results) {
            configMap[config.path.split("/").last] = config;
          }

          return SizedBox(
              height: SizeConfig.screenHeight,
              child: Scaffold(
                floatingActionButton: SpeedDial(
                  backgroundColor: AppColors.secondaryBg,
                  child: const Icon(Icons.menu, color: AppColors.iconGray),
                  children: [
                    SpeedDialChild(
                      child: const Icon(Icons.edit, color: Colors.blue),
                      // backgroundColor: Colors.blue,
                      label: '编辑',
                      labelStyle: TextStyle(fontSize: 18.0),
                      onTap: () async {
                        var configName = ref.read(chooseStateProvider.notifier).state;
                        List<String>? res = await showTextInputDialog(
                          title: "更新配置",
                          okLabel: "更新",
                          message: '正在编辑$configName配置',
                          cancelLabel: "取消",
                          context: context,
                          textFields: [
                            DialogTextField(initialText: configMap[configName]?.cap.toString(), suffixText: "桶容量"),
                            DialogTextField(initialText: configMap[configName]?.rate.toString(), suffixText: "令牌生产速率/秒"),
                            DialogTextField(initialText: configMap[configName]?.fail_upper_rate.toString(), suffixText: "失败率上限"),
                          ],
                        );
                        if (res != null) {
                          print('${res[0]}, ${res[1]}, ${res[2]}');
                          await updateConfig(tenant, path + configName, res[0], res[1], res[2]);
                          ref.refresh(configResultProvider(Tuple2<String, String>(tenant, path)));
                        }
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.add, color: Colors.blue),
                      // backgroundColor: Colors.orange,
                      label: '新建',
                      labelStyle: TextStyle(fontSize: 18.0),
                      onTap: () async {
                        List<String>? res = await showTextInputDialog(
                          title: "新建配置",
                          okLabel: "创建",
                          cancelLabel: "取消",
                          context: context,
                          textFields: [
                            DialogTextField(hintText: "配置名"),
                            DialogTextField(hintText: "桶容量"),
                            DialogTextField(hintText: "令牌生产速率/秒"),
                            DialogTextField(hintText: "失败率上限"),
                          ],
                        );
                        if (res != null) {
                          print("$tenant, ${path + res[0]}");
                            await createConfig(tenant, path + res[0], res[1], res[2], res[3]);
                            ref.refresh(configResultProvider(Tuple2<String, String>(tenant, path)));
                        }
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.delete, color: Colors.blue),
                      // backgroundColor: Colors.green,
                      label: '删除',
                      labelStyle: TextStyle(fontSize: 18.0),
                      onTap: () async {
                        var configName = ref.read(chooseStateProvider.notifier).state;
                        var res = await showOkCancelAlertDialog(
                          context: context,
                          title: "删除配置",
                          message: "删除$configName配置",
                          okLabel: "确认",
                          cancelLabel: "取消"
                        );
                        if (res.name == "ok") {
                          await delConfig(tenant, path + configName);
                          ref.refresh(configResultProvider(Tuple2<String, String>(tenant, path)));
                        }
                      },
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: titleList),
                        SizedBox(height: 20),
                        Wrap(
                            runSpacing: 20,
                            spacing: 20,
                            alignment: WrapAlignment.spaceBetween,
                            children: List.generate(results.length,
                                (index) => InfoCard(results[index])))
                      ],
                    )),
              ));
        });
  }
}
