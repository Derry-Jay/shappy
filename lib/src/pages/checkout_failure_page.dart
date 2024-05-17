import 'package:flutter/material.dart';
import 'package:shappy/src/models/route_argument.dart';

class CheckOutFailurePage extends StatelessWidget {
  final String message;
  BuildContext get context => this.context;
  CheckOutFailurePage(this.message);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                elevation: 0,
                title: Text('Problem with Checking Out'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/app_page', (Route<dynamic> route) => false,
                      arguments: RouteArgument(param: false, heroTag: "0")),
                )),
            body: Column(children: [
              Container(
                  decoration: BoxDecoration(
                      color: Color(0xffe62136),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  padding: EdgeInsets.all(10)),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/img/' +
                      (message.trim().contains("Cannot")
                          ? 'checkout_location_failure'
                          : 'checkout_product_unavailable_failure') +
                      '.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(
              height: 10,
              ),
              Container(
                  child: Text(
                      message.trim().contains("Cannot")
                          ? "Your Order Cannot be placed because your selected location is outside the delivery area of the store."
                          : "Your Order Cannot be placed because product is not available.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15))
            ])),
        onWillPop: backButtonOverride);
  }

  Future<bool> backButtonOverride() async {
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/app_page', (Route<dynamic> route) => false,
        arguments: RouteArgument(param: false, heroTag: "0"));
    return Future.value(true);
  }
}
