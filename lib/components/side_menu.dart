import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_dashboard_ui/config/responsive.dart';
import 'package:responsive_dashboard_ui/config/size_config.dart';
import 'package:responsive_dashboard_ui/style/colors.dart';

import '../provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu(this.tabIndex, {
    Key? key,
  }) : super(key: key);

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 2,
      child: Container(
        height: SizeConfig.screenHeight,
        color: AppColors.secondaryBg,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 35,
                  width: 35,
                  child: SvgPicture.asset('assets/mac-action.svg'),
                ),
              ),
              iconBuilder(assetName: 'assets/home.svg', click: () => context.go("/home"), iconColor: tabIndex == 0 ? Colors.blue: Colors.black),
              iconBuilder(assetName: 'assets/clipboard.svg', click: () {}, iconColor: tabIndex == 1 ? Colors.blue: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}

iconBuilder({
  required String assetName,
  required VoidCallback click,
  required Color iconColor
}) =>
    IconButton(
      onPressed: click,
      icon: SvgPicture.asset(assetName, color: iconColor),
      iconSize: 20,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
    );
