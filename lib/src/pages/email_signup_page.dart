import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/controller/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';

class EmailSignUpPage extends StatefulWidget {
  final RouteArgument rar;
  EmailSignUpPage(this.rar);
  @override
  EmailSignUpPageState createState() => EmailSignUpPageState();
}

class EmailSignUpPageState extends StateMVC<EmailSignUpPage> {
  UserController _con;
  String pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  RegExp regExp;
  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  EmailSignUpPageState() : super(UserController()) {
    _con = controller;
  }

  void proceed() async {
    final SharedPreferences sharedPrefs = await _sharePrefs;
    _con.loginFormKey.currentState.save();
    await sharedPrefs.setString(
        "spAddID", widget.rar.param.addressID.toString());
    _con.navigateTo("/User_location", RouteArgument(id: _con.user.id.toString(), param: _con.user));
  }

  @override
  void initState() {
    regExp = new RegExp(pattern);
    _con.user.id = int.parse(widget.rar.id);
    _con.user.apiToken = widget.rar.heroTag;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(elevation: 0, backgroundColor: Colors.white),
        body: Padding(
            padding: EdgeInsets.all(15),
            child: ListView(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 20,
                ),
                Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 50,
                        vertical: MediaQuery.of(context).size.height / 60),
                    child: Text(
                      'Personal Details',
                      style: TextStyle(
                          color: Color(0xffe62136),
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                    )),
                Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 50,
                        vertical: MediaQuery.of(context).size.height / 60),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Sign up to get started and experience great shopping deals',
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 50,
                      vertical: MediaQuery.of(context).size.height / 60),
                  child: new Form(
                      key: _con.loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Enter Your Name',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 17)),
                          TextFormField(
                            onSaved: (input) => _con.user.name = input,
                            style: TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            controller: nameController,
                            validator: (input) =>
                                input.length < 5 ? "Name is too Small" : null,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 20,
                          ),
                          Text(
                            'Enter Your Email',
                            style:
                                TextStyle(color: Colors.black87, fontSize: 17),
                          ),
                          TextFormField(
                            onSaved: (input) => _con.user.email = input,
                            style: TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            validator: (input) =>
                                regExp.hasMatch(input) ? null : 'Invalid Email',
                            controller: emailController,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: MediaQuery.of(context).size.height / 6.5,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height / 30),
                              child: RaisedButton(
                                  textColor: Colors.white,
                                  color: Color(0xffe62136),
                                  child: Text(
                                    'CONTINUE',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  onPressed: () {
                                    _con
                                        .loginFormKey.currentState
                                        .validate()
                                    ? proceed()
                                        : Toast.show(
                                    'Please Enter Valid Details', context,
                                    duration: Toast.LENGTH_LONG
                                    );

                                  }

     )
    )
                        ],
                      )),
                ),
              ],
            )));
  }
}
