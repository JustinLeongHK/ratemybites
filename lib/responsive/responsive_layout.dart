import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/providers/user_provider.dart';
import 'package:flutter_ratemybites/utilis/global_variables.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget mobileScreenLayout;
  final Widget webScreenLayout;
  final Widget welcomeScreen;
  final bool newUser;

  const ResponsiveLayout(
      {required this.mobileScreenLayout,
      required this.webScreenLayout,
      required this.welcomeScreen,
      required this.newUser,
      super.key});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > webScreenSize) {
        if (widget.newUser) {
          return widget.welcomeScreen;
        }
        return widget.webScreenLayout;
      }
      if (widget.newUser) {
        return widget.welcomeScreen;
      }
      return widget.mobileScreenLayout;
    });
  }
}
