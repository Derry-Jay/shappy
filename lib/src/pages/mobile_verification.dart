import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shappy/src/models/otp.dart';
import 'package:shappy/src/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/controller/user_controller.dart';
import 'package:shappy/src/elements/BlockButtonWidget.dart';

class OTPScreen extends StatefulWidget {
  final RouteArgument rar;
  OTPScreen(this.rar);
  @override
  State<StatefulWidget> createState() {
    return OTPScreenState();
  }
}

class OTPScreenState extends StateMVC<OTPScreen> {
  UserController _con;
  User user;
  OTP oneTimePassCode;
  int field = 5;
  List numOfField = [];
  List<TextEditingController> controllers = <TextEditingController>[];
  String otp="";
  OTPScreenState() : super(UserController()) {
    _con = controller;
  }

  void _onTextChanged(int index,TextEditingController tc)
  {
    String value = tc.text;
    if (value.isEmpty)
    {
      FocusScope.of(context).previousFocus();
      return;
    }
    FocusScope.of(context).nextFocus();
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < field; i++) {
      numOfField.add("");
      controllers.add(TextEditingController());
    }
    oneTimePassCode = widget.rar.param;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _body(context, _con),
      ),
    );
  }

  Widget _body(BuildContext context, UserController _con) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _headerImage(),
        Text(oneTimePassCode.otp == null ? "" : oneTimePassCode.otp.toString()),
        Container(
          child: _boxWithLable(context, _con),
        ),
        SizedBox(height: 30),
        BlockButtonWidget(
          text: Text(
            "Continue",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).accentColor,
          onPressed: () {
            otp = numOfField.join("");
            if(oneTimePassCode.otp.toString() == otp){
              Map body = oneTimePassCode.toMap();
              _con.otp(body);
            }
          },
        ),
      ],
    );
  }

  Widget _boxWithLable(BuildContext context, UserController _con) {
    return Column(
      children: <Widget>[
        Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            alignment: Alignment.center,
            child: Text("verification",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).accentColor))),
        Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            alignment: Alignment.center,
            child: Text(
                "A 5-Digit PIN has been sent to your mobile no.Enter it below to continue",
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Colors.black))),
        _boxBuilder(context, _con),
      ],
    );
  }

  Widget _boxBuilder(BuildContext context, UserController _con) {
    return Form(
        key: _con.loginFormKey,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          for (int index = 0; index < numOfField.length; index++)
            _box(context, index),
        ]));
  }

  Widget _box(BuildContext context, int index) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height / 14,
      width: MediaQuery.of(context).size.width / 8,
      child: TextFormField(
        cursorColor: Color(0xffe62136),
        controller: controllers[index],
        validator: (input) => input.length != 1 ? "" : null,
        textInputAction: TextInputAction.next,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: Colors.black,
        ),
        maxLength: 1,
        onChanged: (v) {
          setState(() => numOfField[index] = v);
          _onTextChanged(index,controllers[index]);
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
          errorStyle: TextStyle(height: 0),
        ),
      ),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey, width: 2)),
    );
  }

  Widget _headerImage() {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      alignment: Alignment.topCenter,
      child: Image.asset(
        "assets/img/shappy_logo.JPG",
        fit: BoxFit.fill,
        height: 50,
      ),
    );
  }
}
