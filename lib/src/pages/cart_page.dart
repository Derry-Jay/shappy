import 'dart:async';
import 'dart:convert';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/cart_product.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/elements/dialog_button.dart';
import 'package:shappy/src/controller/cart_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  final bool flag;
  CartPage(this.flag);
  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends StateMVC<CartPage> {
  double size;
  String shopID, address;
  int _radioValue = 0;
  CartController _con;
  Map<String, dynamic> cartData;
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  CartPageState() : super(CartController()) {
    _con = controller;
  }

  void getData() async {
    final SharedPreferences sharedPrefs = await _sharePrefs;
    shopID = sharedPrefs.getString("spShopID");
    cartData = sharedPrefs.getString("cartData") != null &&
            sharedPrefs.getString("cartData") != ""
        ? json.decode(sharedPrefs.getString("cartData"))
        : {"shop_ID": shopID, "orderitems": []};
    if (!(sharedPrefs.getString("spShopID") == null ||
        sharedPrefs.getString("cartData") == null))
      _con.waitForShopStatus(int.parse(json
              .decode(sharedPrefs.getString("cartData"))["shop_ID"]
              .toString() ??
          "0"));
    await _con.waitForCartData(cartData);
    sharedPrefs.containsKey("defaultDeliveryAddressID")
        ? _con.waitForAddressDetails(
            sharedPrefs.getInt("defaultDeliveryAddressID"))
        : print(sharedPrefs.getString("spUserID"));
    _con.listenForUserData();
  }

  void dialog(BuildContext context) {
    var alertDialog = AlertDialog(
      content: CustomDialog(),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  void _handleRadioValueChange(int value) {
    setState(() => _radioValue = value);
    print(_radioValue);
    switch (_radioValue) {
      case 0:
        Toast.show("Cash On Delivery Selected", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        break;
      case 1:
        Toast.show("Store Pickup Selected", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        break;
    }
  }

  void navigateTo(String route, RouteArgument arguments) {
    Navigator.pushNamed(context, route, arguments: arguments).then(onGoBack);
  }

  FutureOr onGoBack(dynamic value) async {
    setState(() {
      getData();
    });
  }

  int getWordCount(String str) =>
      str == null ? 1 : (str.isEmpty ? 1 : str.trim().split(' ').length);

  @override
  void dispose() {
    _con.cartWidgets = <Widget>[];
    super.dispose();
  }

  @override
  void initState() {
    size = widget.flag ? 80 : 0;
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    address = _con.address == null ? "" : _con.address.getAddress(_con.address);
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(size),
            child: AppBar(
                leading: Container(height: 0, width: 0),
                title: Text("Cart"),
                backgroundColor: Color(0xffe62136),
                elevation: 0,
                centerTitle: true)),
        backgroundColor: Color(0xffffffff),
        body: Column(children: [
          Container(
              height: MediaQuery.of(context).size.height / 55,
              decoration: BoxDecoration(
                  color: Color(0xffe62136),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              padding: EdgeInsets.all(20)),
          _con.cartPageData == null && cartData == null
              ? CircularLoadingWidget(
                  height: MediaQuery.of(context).size.height / 2)
              : (_con.cartPageData == null ||
                      (cartData != null ? cartData["orderitems"].isEmpty : true)
                  ? Container(
                      child: Column(children: [
                        Image.asset("assets/img/empty_cart.png"),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 64),
                        Text("Your Cart is Empty",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height / 50,
                                color: Colors.black))
                      ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 3.2))
                  : Expanded(
                      child: SingleChildScrollView(
                          child: Column(children: [
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartData["orderitems"].length,
                              itemBuilder: (context, index) {
                                CartProduct product = CartProduct.fromMap(
                                    cartData["orderitems"][index]);
                                return Container(
                                    child: Card(
                                        elevation: 0,
                                        child: Row(
                                            children: <Widget>[
                                              Container(
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: product.image !=
                                                                      null &&
                                                                  product.image !=
                                                                      ""
                                                              ? NetworkImage(
                                                                  product.image)
                                                              : AssetImage(
                                                                  "assets/img/fvcustom.jpg"),
                                                          fit: BoxFit.fill)),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      15,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5),
                                              Flexible(
                                                  child: Text(product.name,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xffe62136),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16),
                                                      maxLines: getWordCount(
                                                          product.name),
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.clip)),
                                              Column(
                                                  children: <Widget>[
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          top: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              400),
                                                      child: Text(
                                                        '\₹ ' +
                                                            (product.price !=
                                                                    null
                                                                ? product.price
                                                                : ""),
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffe62136),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              25,
                                                      margin: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            200,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18.0),
                                                        color:
                                                            Color(0xFFf0f0f0),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          new IconButton(
                                                            icon: new Icon(
                                                                Icons.remove),
                                                            onPressed:
                                                                () async {
                                                              final SharedPreferences
                                                                  sharedPrefs =
                                                                  await _sharePrefs;
                                                              if (cartData["orderitems"]
                                                                          [
                                                                          index]
                                                                      [
                                                                      "quantity"] !=
                                                                  1)
                                                                setState(() =>
                                                                    cartData["orderitems"]
                                                                            [
                                                                            index]
                                                                        [
                                                                        "quantity"]--);
                                                              else {
                                                                setState(() => cartData[
                                                                        "orderitems"]
                                                                    .removeAt(
                                                                        index));
                                                                if (cartData[
                                                                            "orderitems"]
                                                                        .isEmpty ||
                                                                    cartData[
                                                                            "orderitems"] ==
                                                                        null) {
                                                                  for (String key
                                                                      in sharedPrefs
                                                                          .getKeys())
                                                                    if (key != "spUserID" &&
                                                                        key !=
                                                                            "apiToken" &&
                                                                        key !=
                                                                            "spDeviceToken") {
                                                                      final r =
                                                                          await sharedPrefs
                                                                              .remove(key);
                                                                      if (r)
                                                                        print(
                                                                            "Removed");
                                                                    }
                                                                  setState(() =>
                                                                      _con.cartPageData =
                                                                          null);
                                                                } else {
                                                                  final s = await sharedPrefs.setString(
                                                                      "cartData",
                                                                      json.encode(
                                                                          cartData));
                                                                  if (s)
                                                                    print(sharedPrefs
                                                                        .getString(
                                                                            "cartData"));
                                                                }
                                                              }
                                                              await _con
                                                                  .waitForCartData(
                                                                      cartData);
                                                            },
                                                          ),
                                                          Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  20,
                                                              child: new Text(
                                                                  cartData["orderitems"]
                                                                              [index][
                                                                          "quantity"]
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black))),
                                                          new IconButton(
                                                            icon: new Icon(
                                                                Icons.add),
                                                            onPressed:
                                                                () async {
                                                              final SharedPreferences
                                                                  sharedPrefs =
                                                                  await _sharePrefs;
                                                              setState(() =>
                                                                  cartData["orderitems"]
                                                                          [
                                                                          index]
                                                                      [
                                                                      "quantity"]++);
                                                              final s = await sharedPrefs
                                                                  .setString(
                                                                      "cartData",
                                                                      json.encode(
                                                                          cartData));
                                                              // final c = await sharedPrefs
                                                              //     .setInt(
                                                              //         "cartCount",
                                                              //         Helper.getCount(
                                                              //             cartData));
                                                              // if (s && c)
                                                              //   print(sharedPrefs
                                                              //       .getString(
                                                              //           "cartData"));
                                                              await _con
                                                                  .waitForCartData(
                                                                      cartData);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween)
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start)),
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            MediaQuery.of(context).size.height /
                                                200));
                              },
                            ),
                            for (Widget i in _con.cartWidgets) i,
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height / 60),
                              child: Row(
                                  children: [
                                    Visibility(
                                        child: Row(
                                            children: [
                                              Radio(
                                                value: 1,
                                                groupValue: _radioValue,
                                                onChanged:
                                                    _handleRadioValueChange,
                                                activeColor: Color(0xffe62136),
                                              ),
                                              Icon(
                                                Icons.storefront_sharp,
                                                color: Color(0xffe62136),
                                              ),
                                              Text(
                                                'Store pickup',
                                                style: new TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              )
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly),
                                        visible: _con.shop == null
                                            ? false
                                            : (_con.shop.shopPickupStatus ==
                                                    null
                                                ? false
                                                : _con.shop.shopPickupStatus)),
                                    Visibility(
                                        child: Row(
                                            children: [
                                              Radio(
                                                  value: 0,
                                                  groupValue: _radioValue,
                                                  onChanged:
                                                      _handleRadioValueChange,
                                                  activeColor:
                                                      Color(0xffe62136)),
                                              Icon(
                                                Icons.electric_car_outlined,
                                                color: Color(0xffe62136),
                                              ),
                                              Text(
                                                'Pay on Delivery',
                                                style: new TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              )
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween),
                                        visible: _con.shop == null
                                            ? false
                                            : (_con.shop.codStatus == null
                                                ? false
                                                : _con.shop.codStatus))
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width / 20,
                                  vertical:
                                      MediaQuery.of(context).size.height / 60),
                              child: GestureDetector(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Address',
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Color(0xffe62136))),
                                      Text(address,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.black)),
                                      Text('Change',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.left)
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween),
                                onTap: () {
                                  print(_con.user.toProfileMap());
                                  // print(cartData);
                                  navigateTo(
                                      '/address',
                                      RouteArgument(
                                          param: _con.user,
                                          id: _con.user.id.toString()));
                                },
                              ),
                            ),
                            // SizedBox(height: MediaQuery.of(context).size.height / 30),
                            Container(
                                child: RaisedButton(
                                  onPressed: () async {
                                    final SharedPreferences sharedPrefs =
                                        await _sharePrefs;
                                    cartData["user_ID"] =
                                        sharedPrefs.getString("spUserID");
                                    cartData["address_ID"] = sharedPrefs
                                        .getInt("defaultDeliveryAddressID")
                                        .toString();
                                    cartData["payment_type"] =
                                        _radioValue.toString();
                                    _con.waitUntilCheckOut(cartData);
                                    setState(() {
                                      cartData = null;
                                      _con.cartPageData = null;
                                    });
                                  },
                                  child: const Text(
                                    'Check out',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  color: Color(0xffe62136),
                                ),
                                width: double.infinity,
                                padding: EdgeInsets.only(
                                    right:
                                        MediaQuery.of(context).size.width / 20),
                                height: MediaQuery.of(context).size.height / 15,
                                margin: EdgeInsets.only(
                                    left:
                                        MediaQuery.of(context).size.width / 25))
                          ], mainAxisAlignment: MainAxisAlignment.spaceAround),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width / 100,
                              vertical:
                                  MediaQuery.of(context).size.height / 40)),
                    ))
        ]));
  }
}
