import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/controller/user_controller.dart';

class SellerConfirmationPage extends StatefulWidget {
  final RouteArgument rar;
  SellerConfirmationPage(this.rar);
  SellerConfirmationPageState createState() => SellerConfirmationPageState();
}

class SellerConfirmationPageState extends StateMVC<SellerConfirmationPage> {
  UserController _con;
  SellerConfirmationPageState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(double.infinity);
    return Scaffold(
        body: Container(
            child: Column(
                children: <Widget>[
                  Column(
                    children: [
                      Image.asset(
                        'assets/img/Group 9740.png',
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 40),
                      Text('You want to become a Seller',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                  Container(
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sqrt((pow(
                                      MediaQuery.of(context).size.width, 2) +
                                  pow(MediaQuery.of(context).size.height, 2)) /
                              10000)),
                          side: BorderSide(color: Color(0xffe62136)),
                        ),
                        onPressed: () =>
                            _con.waitUntilSendShopRequest(widget.rar.param),
                        textColor: Colors.white,
                        color: Color(0xffe62136),
                        child: Text(
                          "Click here to confirm",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 16)
                ],
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly),
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 8)));
  }
}
