import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_dashboard_ui/config/responsive.dart';
import 'package:responsive_dashboard_ui/config/size_config.dart';
import 'package:responsive_dashboard_ui/provider.dart';
import 'package:responsive_dashboard_ui/style/colors.dart';
import 'package:responsive_dashboard_ui/style/style.dart';

import '../api/requests.dart';

class InfoCard extends ConsumerWidget {
  final Config config;

  const InfoCard(this.config, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowSelect = ref.watch(chooseStateProvider);
    Border? border;
    final name = config.path.split("/").last;
    if (nowSelect == name) {
      border = Border.all(color: Colors.blue, width: 1);
    }
    return Container(
        constraints: BoxConstraints(
            minWidth: Responsive.isDesktop(context) ? 200.0 : 140),
        padding: EdgeInsets.fromLTRB(
            20.0, 20.0, Responsive.isDesktop(context) ? 40 : 10, 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: border,
        ),
        child: GestureDetector(
          onTap: () {
            ref.read(chooseStateProvider.notifier).state = name;
          },
          onDoubleTap: () {
            if (name == "__default__") {
              return;
            }
            ref.read(chooseStateProvider.notifier).state = '__default__';
            context.go("/detail?tenant=${config.tenant}&path=${config.path}/");
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                name == "__default__"
                    ? "assets/invoice.svg"
                    : "assets/credit-card.svg",
                width: Responsive.isDesktop(context) ? 35 : 28,
              ),
              SizedBox(
                height: SizeConfig.blockSizeHorizontal! * 2,
              ),
              PrimaryText(
                text: '桶容量: ${config.cap}',
                size: Responsive.isDesktop(context) ? 16 : 14,
                color: AppColors.secondary,
              ),
              PrimaryText(
                text: '令牌生成速率: ${config.rate}/秒',
                size: Responsive.isDesktop(context) ? 16 : 14,
                color: AppColors.secondary,
              ),
              PrimaryText(
                text: '失败率上限: ${config.fail_upper_rate}',
                size: Responsive.isDesktop(context) ? 16 : 14,
                color: AppColors.secondary,
              ),
              SizedBox(
                height: SizeConfig.blockSizeHorizontal! * 1,
              ),
              PrimaryText(
                text: name,
                size: Responsive.isDesktop(context) ? 18 : 16,
                fontWeight: FontWeight.w800,
              )
            ],
          ),
        ));
  }
}
