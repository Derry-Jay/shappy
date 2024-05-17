import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';

class StoreLocationController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  OverlayEntry loader;


  StoreLocationController() {
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void getList(){
    List<dynamic> list=new List<dynamic>();
    list.add({"id":1,"name":"Grocery"});
    list.add({"id":2,"name":"Cloth"});

  }

  void sign() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      Timer(Duration(seconds: 2), () {
        Helper.hideLoader(loader);
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/Home', (Route<dynamic> route) => false);
      });

      /*repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(conte0xt).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });*/
    }
  }

  void otp() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      Timer(Duration(seconds: 2), () {
        Helper.hideLoader(loader);
        Navigator.of(context).pushNamed('/Store_detail');
      });

      /*repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(conte0xt).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });*/
    }else{
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text("Please enter valid otp"),
      ));
    }
  }

  void storedeatil() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      Timer(Duration(seconds: 2), () {
        Helper.hideLoader(loader);
        Navigator.of(context).pushNamed('/Store_location');
      });

      /*repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(conte0xt).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });*/
    }
  }

  void register() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
//      repository.register(user).then((value) {
//        if (value != null && value.apiToken != null) {
//          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
//        } else {
//          scaffoldKey?.currentState?.showSnackBar(SnackBar(
//            content: Text(S.of(context).wrong_email_or_password),
//          ));
//        }
//      }).catchError((e) {
//        loader?.remove();
//        scaffoldKey?.currentState?.showSnackBar(SnackBar(
//          content: Text(S.of(context).this_email_account_exists),
//        ));
//      }).whenComplete(() {
//        Helper.hideLoader(loader);
//      });
    }
  }

  void resetPassword() {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
//      repository.resetPassword(user).then((value) {
//        if (value != null && value == true) {
//          scaffoldKey?.currentState?.showSnackBar(SnackBar(
//            content: Text(S.of(context).your_reset_link_has_been_sent_to_your_email),
//            action: SnackBarAction(
//              label: S.of(context).login,
//              onPressed: () {
//                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
//              },
//            ),
//            duration: Duration(seconds: 10),
//          ));
//        } else {
//          loader.remove();
//          scaffoldKey?.currentState?.showSnackBar(SnackBar(
//            content: Text(S.of(context).error_verify_email_settings),
//          ));
//        }
//      }).whenComplete(() {
//        Helper.hideLoader(loader);
//      });
    }
  }
}
