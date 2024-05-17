import 'package:flutter/material.dart';
import 'package:shappy/src/models/route_argument.dart';

class SellerSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).size.height / 3, left: 7),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Image.asset(
                'assets/img/Group 9481.png',
              ),
              Text('Our representative will contact you shortly',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontFamily: "Montserrat"))
            ],
          ),
          Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height / 15),
            height: MediaQuery.of(context).size.height / 16,
            width: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: RaisedButton(
              color: Color(0xffE62337),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/app_page', (Route<dynamic> route) => false,
                  arguments: RouteArgument(param: false, heroTag: "0")),
              child: Text('GO TO HOME PAGE',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          )
        ],
      ),
    );
  }
}
