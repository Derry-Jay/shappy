import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/controller/user_controller.dart';
import 'package:shappy/src/elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends StateMVC<LoginScreen> {
  UserController _con;

  LoginScreenState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        key: _con.scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Column(children: <Widget>[
          Container(
              padding: EdgeInsets.only(top: 140),
              width: double.infinity,
              child: Card(
                  elevation: 0,
                  child: Column(children: <Widget>[
                    SizedBox(height: 30),
                    Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              "Welcome",
                              style: TextStyle(
                                  color: Colors.redAccent[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                            ),
                            Text(
                              "sign up to get started and experience great shopping deals",
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20)),
                    SizedBox(height: 30),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      width: config.App(context).appWidth(88),
                      child: Form(
                        key: _con.loginFormKey,
                        child: TextFormField(
                            keyboardType: TextInputType.phone,
                            onSaved: (input) => _con.user.phone = input,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            validator: (input) => input.length != 10
                                ? "Enter the valid mobile number"
                                : null,
                            decoration: InputDecoration(
                                labelText: "Mobile No",
                                labelStyle: TextStyle(color: Colors.black),
                                hintText: '978.....',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.3))),
                            maxLength: 10,
                            maxLengthEnforced: true),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                        child: BlockButtonWidget(
                            text: Text(
                              "NEXT",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () => _con.login()),
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20)),
                    SizedBox(height: 30)
                  ], crossAxisAlignment: CrossAxisAlignment.start)))
        ]));
  }
}
