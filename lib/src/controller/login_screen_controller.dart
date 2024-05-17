import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class LoginScreenController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  LoginScreenController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  @override
  void initState() {
    super.initState();
  }

}
