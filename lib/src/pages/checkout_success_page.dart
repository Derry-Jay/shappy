import 'package:flutter/material.dart';
import 'package:shappy/src/models/route_argument.dart';

class CheckoutSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/img/Group 9655.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          RaisedButton(
            color: Color(0xffE62337),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/app_page', (Route<dynamic> route) => false,
                arguments: RouteArgument(param: false, heroTag: "0")),
            child: Text('GO TO HOME PAGE',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
