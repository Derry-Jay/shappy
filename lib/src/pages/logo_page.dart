import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';

class LogoPage extends StatefulWidget {
  @override
  _LogoPageState createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  String userID;
  DateTime currentBackPressTime;
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();

  void setData() async {
    final SharedPreferences sharedPrefs = await _sharePrefs;
    userID = sharedPrefs.getString("spUserID");
  }

  @override
  void initState() {
    setData();
    print(userID);
    super.initState();
    Timer(
        Duration(seconds: 5),
        () => userID == null
            ? Navigator.of(context).pushNamed('/Splash')
            : Navigator.of(context).pushNamedAndRemoveUntil(
                '/app_page', (Route<dynamic> route) => false,
                arguments: RouteArgument(
                    id: userID, param: userID == null, heroTag: "0")));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Container(
              child: Image.asset(
                'assets/img/Group 9443.png',
                width: MediaQuery.of(context).size.width / 1.25,
                fit: BoxFit.fill,
              ),
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 10,
                  top: MediaQuery.of(context).size.height / 2.5)),
        ),
        onWillPop: onWillPop);
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Toast.show("Press Again to Quit", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop()');
    return Future.value(true);
  }
}
