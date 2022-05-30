import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_dashboard_ui/api/requests.dart';
import 'package:responsive_dashboard_ui/components/payment_list_tile.dart';
import 'package:responsive_dashboard_ui/config/responsive.dart';
import 'package:responsive_dashboard_ui/provider.dart';
import 'package:responsive_dashboard_ui/style/colors.dart';
import 'package:responsive_dashboard_ui/style/style.dart';

import '../config/size_config.dart';

class SearchTenant extends ConsumerWidget {
  SearchTenant({
    Key? key,
  }) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            const PrimaryText(
              text: '限流系统',
              size: 30.0,
              fontWeight: FontWeight.w800,
            ),
            const Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 1,
              child: TextField(
                onEditingComplete: () async {
                  if (_controller.value.text == "") {
                    return;
                  }
                  await ref
                      .read(searchResultProvider.notifier)
                      .search(_controller.value.text);
                },
                controller: _controller,
                decoration: InputDecoration(
                  fillColor: AppColors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.only(left: 40, right: 50),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.white),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  hintText: '搜索租户',
                  hintStyle: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SearchResultList()
      ],
    );
  }
}

class SearchResultList extends ConsumerWidget {
  const SearchResultList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Tenant> results = ref.watch(searchResultProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 2,
        ),
        SizedBox(
          height: SizeConfig.screenHeight! / 3,
          child: ListView.builder(
              itemCount: results.length,
              itemExtent: 60.0,
              itemBuilder: (BuildContext context, int index) {
                return PaymentListTile(
                  title: results[index].name,
                  subtitle: '管理员： ${results[index].admins.join(",")}',
                  end: results[index].desc,
                  click: () async {
                    await createApply(results[index].name);
                    ref.refresh(myApplyListProvider);
                  },
                );
              }),
        ),
      ],
    );
  }
}

class MyTenant extends ConsumerWidget {
  MyTenant({
    Key? key,
  }) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            const PrimaryText(
              text: '租户列表',
              size: 30.0,
              fontWeight: FontWeight.w800,
            ),
            const Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 1,
              child: TextField(
                controller: _controller,
                onEditingComplete: () async {
                  await ref.refresh(myTenantProvider);
                },
                decoration: InputDecoration(
                  fillColor: AppColors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.only(left: 40, right: 50),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.white),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  hintText: '搜索租户',
                  hintStyle: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        TenantList(_controller)
      ],
    );
  }
}

class TenantList extends ConsumerWidget {
  const TenantList(this._controller, {Key? key}) : super(key: key);
  final TextEditingController _controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Tenant>> results = ref.watch(myTenantProvider);
    return results.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
        data: (tenants) {
          if (_controller.value.text != '') {
            tenants = [
              for (Tenant tenant in tenants)
                if (tenant.name.contains(_controller.value.text)) tenant
            ];
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 2,
              ),
              SizedBox(
                height: SizeConfig.screenHeight! / 3,
                child: ListView.builder(
                    itemCount: tenants.length,
                    itemExtent: 60.0,
                    itemBuilder: (BuildContext context, int index) {
                      return PaymentListTile(
                        title: tenants[index].name,
                        subtitle: '管理员： ${tenants[index].admins.join(",")}',
                        end: tenants[index].desc,
                        click: () => context.go("/detail?tenant=${tenants[index].name}"),
                      );
                    }),
              ),
            ],
          );
        });
  }
}
