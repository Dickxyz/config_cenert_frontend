import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_dashboard_ui/style/colors.dart';
import 'package:responsive_dashboard_ui/style/style.dart';

class PaymentListTile extends StatelessWidget {
  final String title;
  final String end;
  final String subtitle;
  const PaymentListTile({
    Key? key,
    required this.title,
    required this.end,
    required this.subtitle, this.click,
  }) : super(key: key);
  final VoidCallback? click;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (click != null) {
          click!();
        }
      },
      contentPadding: const EdgeInsets.only(left: 0, right: 20),
      visualDensity: VisualDensity.standard,
      title: PrimaryText(
        text: title,
        size: 14.0,
        fontWeight: FontWeight.w500,
      ),
      subtitle: PrimaryText(
        text: subtitle,
        size: 12,
        color: AppColors.secondary,
      ),
      trailing: PrimaryText(
        text: end,
        size: 16,
        color: AppColors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
