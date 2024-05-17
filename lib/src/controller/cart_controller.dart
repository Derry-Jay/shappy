import 'package:intl/intl.dart';
import 'package:shappy/src/helpers/helper.dart';
import 'package:shappy/src/models/address.dart';
import 'package:shappy/src/models/store.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:shappy/src/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/repository/cart_repository.dart';
import 'package:shappy/src/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartController extends ControllerMVC {
  User user;
  Store shop;
  Address address;
  Map<String, dynamic> cartPageData;
  GlobalKey<ScaffoldState> scaffoldKey;
  List<Widget> cartWidgets = <Widget>[];
  static var myFormat = new DateFormat('dd MMMM yyyy');
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<void> waitForCartData(Map<String, dynamic> body) async {
    final Map<String, dynamic> stream = await getCartData(body);
    final SharedPreferences sharedPrefs = await _sharePrefs;
    if (stream != null && stream["success"] && stream["status"]) {
      setState(() => cartPageData = stream["result"]);
      var cwg = <Widget>[];
      cartPageData.forEach((key, value) {
        if (value != null)
          cwg.add(Container(
              key: Key(key),
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 20),
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 50,
                  vertical: MediaQuery.of(context).size.height / 100),
              child: Row(children: [
                Text(
                  key,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                Text(
                    key == "estimated_delivery"
                        ? myFormat.format(DateTime.parse(value))
                        : (value is String ? value : value.toString()),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black))
              ], mainAxisAlignment: MainAxisAlignment.spaceBetween)));
      });
      final c = await sharedPrefs.setInt("cartCount", Helper.getCount(body));
      if (c)
        this.setState(() {
          print(body);
          print(sharedPrefs.getInt("cartCount"));
        });
      setState(() => cartWidgets = cwg);
      Toast.show("Added Successfully", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if ((stream != null || !(stream["success"] && stream["status"])) &&
        stream["message"] != " is not avaliable") {
      Toast.show(stream["message"], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      for (String key in sharedPrefs.getKeys())
        if (key != "spUserID" &&
            key != "apiToken" &&
            key != "spDeviceToken" &&
            key != "defaultDeliveryAddressID") {
          final r = await sharedPrefs.remove(key);
          if (r) print("Removed");
        }
    } else
      Toast.show("Empty Cart", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void waitUntilCheckOut(Map<String, dynamic> body) async {
    final Map<String, dynamic> stream = await checkOut(body);
    final SharedPreferences sharedPrefs = await _sharePrefs;
    print(stream);
    if (stream != null &&
        stream["success"] &&
        stream["status"] &&
        stream["orderplaced"])
      Navigator.of(context).pushNamed('/checkoutSuccess');
    else {
      print(stream);
      Navigator.of(context)
          .pushNamed('/checkoutFailure', arguments: stream["message"]);
    }
    for (String key in sharedPrefs.getKeys())
      if (key != "spUserID" &&
          key != "apiToken" &&
          key != "spDeviceToken" &&
          key != "defaultDeliveryAddressID") {
        final r = await sharedPrefs.remove(key);
        if (r) print("Removed");
      }
    Toast.show(stream["message"], context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void listenForUserData() async {
    final User stream = await getUserDetails();
    if (stream != null) setState(() => user = stream);
  }

  void waitForShopStatus(int shopID) async {
    final value = await getShopStatus(shopID);
    if (value != null) setState(() => shop = value);
  }

  void waitForAddressDetails(int addressID) async {
    final stream = await getAddressDetails(addressID);
    setState(() => address = stream != null ? stream : Address());
  }
}
