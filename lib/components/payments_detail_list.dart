import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_dashboard_ui/api/requests.dart';
import 'package:responsive_dashboard_ui/components/payment_list_tile.dart';
import 'package:responsive_dashboard_ui/config/size_config.dart';
import 'package:responsive_dashboard_ui/data.dart';
import 'package:responsive_dashboard_ui/provider.dart';
import 'package:responsive_dashboard_ui/style/colors.dart';
import 'package:responsive_dashboard_ui/style/style.dart';

class PaymentsDetailList extends StatelessWidget {
  const PaymentsDetailList({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(
        //   height: SizeConfig.blockSizeVertical! * 5,
        // ),
        MyApplyList(),
        // SizedBox(
        //   height: SizeConfig.blockSizeVertical! * 1,
        // ),
        OtherApplyList()
      ],
    );
  }
}

class MyApplyList extends ConsumerWidget {
  MyApplyList({Key? key}) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Apply>> results = ref.watch(myApplyListProvider);
    return results.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
        data: (applies) {
          if (_controller.value.text != "") {
            applies = [
              for (Apply apply in applies)
                if (apply.tenant.contains(_controller.value.text)) apply
            ];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PrimaryText(
                    text: '我的申请',
                    size: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  TextField(
                    onEditingComplete: () => ref.refresh(myApplyListProvider),
                    controller: _controller,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      hintText: '搜索申请',
                      hintStyle: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 2,
              ),
              SizedBox(
                height: SizeConfig.screenHeight! / 3,
                child: ListView.builder(
                    itemCount: applies.length,
                    itemExtent: 60.0,
                    itemBuilder: (BuildContext context, int index) {
                      return PaymentListTile(
                        title: applies[index].tenant,
                        subtitle: '管理员： ${applies[index].admins.join(",")}',
                        end: applies[index].create_at.substring(0, 10),
                      );
                    }),
              ),
            ],
          );
        });
  }
}

class OtherApplyList extends ConsumerWidget {
  OtherApplyList({Key? key}) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Apply>> results = ref.watch(otherApplyListProvider);
    return results.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
        data: (applies) {
          if (_controller.value.text != "") {
            applies = [
              for (Apply apply in applies)
                if (apply.tenant.contains(_controller.value.text)) apply
            ];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PrimaryText(
                    text: '待处理的权限申请',
                    size: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  TextField(
                    onEditingComplete: () => ref.refresh(otherApplyListProvider),
                    controller: _controller,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      hintText: '搜索申请',
                      hintStyle: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 2,
              ),
              SizedBox(
                height: SizeConfig.screenHeight! / 3,
                child: ListView.builder(
                    itemCount: applies.length,
                    itemExtent: 60.0,
                    itemBuilder: (BuildContext context, int index) {
                      return PaymentListTile(
                        title: applies[index].tenant,
                        subtitle: '管理员： ${applies[index].admins.join(",")}',
                        end: '申请人: ${applies[index].applier}',
                      );
                    }),
              ),
            ],
          );
        });
  }
}

