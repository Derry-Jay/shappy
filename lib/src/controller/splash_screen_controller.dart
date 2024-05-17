import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/helpers/helper.dart';

class SplashScreenController extends ControllerMVC {
  OverlayEntry loader;
  bool loading = false;
  GlobalKey<ScaffoldState> scaffoldKey;
  ValueNotifier<Map<String, double>> progress = new ValueNotifier(new Map());

  SplashScreenController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    loader = Helper.overlayLoader(context);
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 20), () {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text("Check your Internet connection"),
      ));
    });
  }
}
