import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/product.dart';
import 'package:shappy/src/helpers/helper.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/models/product_category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';
import 'package:shappy/src/controller/category_based_product_controller.dart';
import 'package:toast/toast.dart';

class CategoryBasedProductsPage extends StatefulWidget {
  final RouteArgument routeArgument;
  CategoryBasedProductsPage({Key key, this.routeArgument}) : super(key: key);
  @override
  CategoryBasedProductsPageState createState() =>
      CategoryBasedProductsPageState();
}

class CategoryBasedProductsPageState
    extends StateMVC<CategoryBasedProductsPage> {
  String title, price, count;
  Product product;
  List<int> counts;
  ProductCategory cat;
  Map<String, dynamic> cartData;
  CategoryBasedProductsController _con;
  TextEditingController prc = new TextEditingController();
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  CategoryBasedProductsPageState() : super(CategoryBasedProductsController()) {
    _con = controller;
  }

  void getData() async {
    final SharedPreferences sharedPrefs = await _sharePrefs;
    cat = widget.routeArgument.param;
    await _con.listenForCategoryBasedProducts(
        widget.routeArgument.id, widget.routeArgument.heroTag);
    cartData = sharedPrefs.getString("cartData") != null
        ? json.decode(sharedPrefs.getString("cartData"))
        : {
            "shop_ID": sharedPrefs.getString("spShopID") != null ||
                    sharedPrefs.getString("spShopID") == widget.routeArgument.id
                ? sharedPrefs.getString("spShopID")
                : widget.routeArgument.id,
            "orderitems": []
          };
    count = sharedPrefs.getInt("cartCount").toString();
    counts = sharedPrefs.containsKey(widget.routeArgument.param.name +
            "Counts" +
            (sharedPrefs.getString("spShopID") != null ||
                    sharedPrefs.getString("spShopID") == widget.routeArgument.id
                ? sharedPrefs.getString("spShopID")
                : widget.routeArgument.id))
        ? sharedPrefs
            .getString(widget.routeArgument.param.name +
                "Counts" +
                (sharedPrefs.getString("spShopID") != null ||
                        sharedPrefs.getString("spShopID") ==
                            widget.routeArgument.id
                    ? sharedPrefs.getString("spShopID")
                    : widget.routeArgument.id))
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(",")
            .map((e) => int.parse(e.trim()))
            .toList()
        : new List.filled(
            _con.products == null || _con.products.isEmpty
                ? 0
                : _con.products.length,
            0,
            growable: true);
  }

  double getPrice(Map<String, dynamic> map) {
    double p = 0.0;
    if (map == null || map == {})
      return 0.0;
    else {
      for (Map<String, dynamic> m in map["orderitems"])
        p += m["cost"] == null || m["quantity"] == null
            ? 0.0
            : (m["quantity"] < 1 ? 0.0 : m["cost"] * m["quantity"]);
      return p;
    }
  }

  int getCount(Map<String, dynamic> map) {
    int c = 0;
    if (map == null || map == {})
      return 0;
    else {
      for (Map<String, dynamic> m in map["orderitems"])
        c +=
            m["quantity"] == null ? 0 : (m["quantity"] < 1 ? 0 : m["quantity"]);
      return c;
    }
  }

  @override
  @protected
  @mustCallSuper
  void didChangeDependencies() {
    getData();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    title = widget.routeArgument.param.name;
    price = getPrice(cartData).toString();
    count = getCount(cartData).toString();
    return Scaffold(
        backgroundColor: Color(0xffffffff),
        appBar: AppBar(
            // actions: [
            //   IconButton(
            //       icon: Icon(Icons.shopping_cart_outlined),
            //       onPressed: () => Navigator.of(context)
            //           .pushNamedAndRemoveUntil(
            //               '/app_page', (Route<dynamic> route) => false,
            //               arguments: RouteArgument(param: false, heroTag: "1")))
            // ],
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop()),
            elevation: 0,
            backgroundColor: Color(0xffe62136),
            title: Text(title),
            centerTitle: true),
        body: Column(children: [
          Container(
              decoration: BoxDecoration(
                  color: Color(0xffe62136),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              padding: EdgeInsets.all(10)),
          SizedBox(height: MediaQuery.of(context).size.height / 50),
          Container(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Search Products',
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.redAccent, style: BorderStyle.solid),
                  ),
                ),
                onChanged: (pattern) => _con.waitForSearchedProducts(
                    widget.routeArgument.id, pattern, cat.id),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 20,
                  vertical: MediaQuery.of(context).size.height / 500)),
          _con.products == null
              ? CircularLoadingWidget(
                  height: MediaQuery.of(context).size.height / 2)
              : (_con.products.isEmpty
                  ? Container(
                      child: Column(children: [
                        Image.asset("assets/img/empty_products.png"),
                        Text("Products Currently Unavailable",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                            textAlign: TextAlign.center)
                      ], mainAxisAlignment: MainAxisAlignment.start),
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 50,
                          top: MediaQuery.of(context).size.height / 4.5))
                  : Expanded(
                      child: Container(
                      child: ListView.builder(
                        itemCount: _con.products.length,
                        itemBuilder: (context, index) => Visibility(
                            child: Card(
                              elevation: 0,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _con.products[index].image != null &&
                                            _con.products[index].image != ""
                                        ? Image.network(
                                            _con.products[index].image != null
                                                ? _con.products[index].image
                                                : "",
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                5,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                10,
                                          )
                                        : Image.asset("assets/img/fvcustom.jpg",
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                5,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                10),
                                    Flexible(
                                        child: Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: MediaQuery.of(context).size.width /
                                                    40,
                                                vertical: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    150),
                                            child: Text(_con.products[index].name != null ? _con.products[index].name : "",
                                                style: TextStyle(
                                                    color: Color(0xffe62136),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                                textAlign: TextAlign.center),
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context).size.height /
                                                    (64 * Helper.getWordCount(_con.products[index].name))
                                                        .toDouble()))),
                                    Expanded(
                                        child: Column(
                                            children: <Widget>[
                                          Container(
                                            child: Text(
                                              _con.products[index].price != null
                                                  ? 'Rs. ${_con.products[index].price.toString()}'
                                                  : "",
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Color(0xffe62136),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          counts[index] == 0
                                              ? Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            25,
                                                  ),
                                                  child: ButtonTheme(
                                                    minWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            5,
                                                    child: RaisedButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18.0),
                                                        side: BorderSide(
                                                            color: Color(
                                                                0xffe62136)),
                                                      ),
                                                      onPressed: () async {
                                                        final SharedPreferences
                                                            sharedPrefs =
                                                            await _sharePrefs;
                                                        if (sharedPrefs.getString(
                                                                    "spShopID") ==
                                                                null ||
                                                            sharedPrefs.getString(
                                                                    "spShopID") ==
                                                                widget
                                                                    .routeArgument
                                                                    .id) {
                                                          setState(() =>
                                                              counts[index]++);
                                                          if (sharedPrefs.getString(
                                                                  "spShopID") ==
                                                              null) {
                                                            final d = await sharedPrefs
                                                                .setString(
                                                                    "spShopID",
                                                                    widget
                                                                        .routeArgument
                                                                        .id);
                                                            print(d
                                                                ? "Hi"
                                                                : "Hai");
                                                          }
                                                          if (cartData[
                                                                      "orderitems"] ==
                                                                  null ||
                                                              cartData["orderitems"]
                                                                      .length ==
                                                                  0)
                                                            setState(() =>
                                                                cartData[
                                                                        "orderitems"]
                                                                    .add({
                                                                  "product_ID": _con
                                                                      .products[
                                                                          index]
                                                                      .proID,
                                                                  "product_name": _con
                                                                      .products[
                                                                          index]
                                                                      .name,
                                                                  "desc": _con
                                                                      .products[
                                                                          index]
                                                                      .description,
                                                                  "product_IMG": _con
                                                                      .products[
                                                                          index]
                                                                      .image,
                                                                  "quantity":
                                                                      counts[
                                                                          index],
                                                                  "cost": double.parse(_con
                                                                          .products[
                                                                              index]
                                                                          .price) *
                                                                      counts[
                                                                          index]
                                                                }));
                                                          else {
                                                            Map<String, dynamic>
                                                                produ;
                                                            for (Map<String,
                                                                    dynamic> cartProduct
                                                                in cartData[
                                                                    "orderitems"]) {
                                                              if (cartProduct[
                                                                      "product_ID"] ==
                                                                  _con
                                                                      .products[
                                                                          index]
                                                                      .proID) {
                                                                produ =
                                                                    cartProduct;
                                                                break;
                                                              }
                                                            }
                                                            if (produ == null)
                                                              setState(() =>
                                                                  cartData[
                                                                          "orderitems"]
                                                                      .add({
                                                                    "product_ID": _con
                                                                        .products[
                                                                            index]
                                                                        .proID,
                                                                    "product_name": _con
                                                                        .products[
                                                                            index]
                                                                        .name,
                                                                    "desc": _con
                                                                        .products[
                                                                            index]
                                                                        .description,
                                                                    "product_IMG": _con
                                                                        .products[
                                                                            index]
                                                                        .image,
                                                                    "quantity":
                                                                        counts[
                                                                            index],
                                                                    "cost": double.parse(_con
                                                                            .products[
                                                                                index]
                                                                            .price) *
                                                                        counts[
                                                                            index]
                                                                  }));
                                                            else
                                                              produ["quantity"] +=
                                                                  1;
                                                          }
                                                          final s = await sharedPrefs
                                                              .setString(
                                                                  "cartData",
                                                                  json.encode(
                                                                      cartData));
                                                          final c =
                                                              await sharedPrefs
                                                                  .setInt(
                                                                      "cartCount",
                                                                      int.parse(
                                                                          count));
                                                          final l = await sharedPrefs.setString(
                                                              title +
                                                                  "Counts" +
                                                                  (sharedPrefs.getString("spShopID") !=
                                                                              null ||
                                                                          sharedPrefs.getString("spShopID") ==
                                                                              widget
                                                                                  .routeArgument.id
                                                                      ? sharedPrefs
                                                                          .getString(
                                                                              "spShopID")
                                                                      : widget
                                                                          .routeArgument
                                                                          .id),
                                                              counts
                                                                  .toString());
                                                          if (s && c && l)
                                                            print(sharedPrefs
                                                                .getString(
                                                                    "cartData"));
                                                        } else
                                                          Toast.show(
                                                              "You Have unchecked-out-products from another shop",
                                                              context,
                                                              duration: Toast
                                                                  .LENGTH_LONG,
                                                              gravity:
                                                                  Toast.BOTTOM);
                                                      },
                                                      textColor: Colors.white,
                                                      color: Color(0xffe62136),
                                                      child: Text(
                                                        'ADD',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                    color: Color(0xFFf0f0f0),
                                                  ),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      21.99023255552,
                                                  margin: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        100,
                                                  ),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3.75,
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        new IconButton(
                                                          icon: new Icon(
                                                              Icons.remove),
                                                          onPressed: () async {
                                                            final SharedPreferences
                                                                sharedPrefs =
                                                                await _sharePrefs;
                                                            setState(() =>
                                                                counts[
                                                                    index]--);
                                                            Map<String, dynamic>
                                                                produ;
                                                            if (cartData[
                                                                        "orderitems"] !=
                                                                    null ||
                                                                cartData["orderitems"]
                                                                        .length !=
                                                                    0) {
                                                              for (Map<String,
                                                                      dynamic> cartProduct
                                                                  in cartData[
                                                                      "orderitems"]) {
                                                                if (cartProduct[
                                                                        "product_ID"] ==
                                                                    _con
                                                                        .products[
                                                                            index]
                                                                        .proID) {
                                                                  produ =
                                                                      cartProduct;
                                                                  break;
                                                                }
                                                              }
                                                              if (produ !=
                                                                  null) {
                                                                if (produ[
                                                                        "quantity"] !=
                                                                    1)
                                                                  produ[
                                                                      "quantity"]--;
                                                                else {
                                                                  cartData[
                                                                          "orderitems"]
                                                                      .removeWhere((item) =>
                                                                          item ==
                                                                          produ);
                                                                  if (cartData[
                                                                              "orderitems"]
                                                                          .isEmpty ||
                                                                      cartData[
                                                                              "orderitems"] ==
                                                                          null) {
                                                                    final s = await sharedPrefs
                                                                        .remove(
                                                                            "spShopID");
                                                                    final r = await sharedPrefs
                                                                        .remove(
                                                                            "cartCount");
                                                                    if (r && s)
                                                                      print(
                                                                          "Removed");
                                                                  }
                                                                }
                                                              }
                                                              if (sharedPrefs
                                                                  .containsKey(
                                                                      "cartCount")) {
                                                                final c = await sharedPrefs.setInt(
                                                                    "cartCount",
                                                                    int.parse(
                                                                        count));
                                                                if (c)
                                                                  print("Set");
                                                              }
                                                              final s = await sharedPrefs
                                                                  .setString(
                                                                      "cartData",
                                                                      json.encode(
                                                                          cartData));
                                                              final l = await sharedPrefs.setString(
                                                                  title +
                                                                      "Counts" +
                                                                      (sharedPrefs.getString("spShopID") != null || sharedPrefs.getString("spShopID") == widget.routeArgument.id
                                                                          ? sharedPrefs.getString(
                                                                              "spShopID")
                                                                          : widget
                                                                              .routeArgument
                                                                              .id),
                                                                  counts
                                                                      .toString());
                                                              if (s && l)
                                                                print(sharedPrefs
                                                                    .getString(
                                                                        "cartData"));
                                                            }
                                                          },
                                                        ),
                                                        new Text(
                                                            counts[index] !=
                                                                    null
                                                                ? counts[index]
                                                                    .toString()
                                                                : "0",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black)),
                                                        new IconButton(
                                                          icon: new Icon(
                                                              Icons.add),
                                                          onPressed: () async {
                                                            final SharedPreferences
                                                                sharedPrefs =
                                                                await _sharePrefs;
                                                            setState(() =>
                                                                counts[
                                                                    index]++);
                                                            if (cartData[
                                                                        "orderitems"] ==
                                                                    null ||
                                                                cartData["orderitems"]
                                                                        .length ==
                                                                    0)
                                                              cartData[
                                                                      "orderitems"]
                                                                  .add({
                                                                "product_ID": _con
                                                                    .products[
                                                                        index]
                                                                    .proID,
                                                                "product_name": _con
                                                                    .products[
                                                                        index]
                                                                    .name,
                                                                "desc": _con
                                                                    .products[
                                                                        index]
                                                                    .description,
                                                                "product_IMG": _con
                                                                    .products[
                                                                        index]
                                                                    .image,
                                                                "quantity":
                                                                    counts[
                                                                        index],
                                                                "cost": double.parse(_con
                                                                        .products[
                                                                            index]
                                                                        .price) *
                                                                    counts[
                                                                        index]
                                                              });
                                                            else {
                                                              Map<String,
                                                                      dynamic>
                                                                  produ;
                                                              for (Map<String,
                                                                      dynamic> cartProduct
                                                                  in cartData[
                                                                      "orderitems"]) {
                                                                if (cartProduct[
                                                                        "product_ID"] ==
                                                                    _con
                                                                        .products[
                                                                            index]
                                                                        .proID) {
                                                                  produ =
                                                                      cartProduct;
                                                                  break;
                                                                }
                                                              }
                                                              if (produ == null)
                                                                cartData[
                                                                        "orderitems"]
                                                                    .add({
                                                                  "product_ID": _con
                                                                      .products[
                                                                          index]
                                                                      .proID,
                                                                  "product_name": _con
                                                                      .products[
                                                                          index]
                                                                      .name,
                                                                  "desc": _con
                                                                      .products[
                                                                          index]
                                                                      .description,
                                                                  "product_IMG": _con
                                                                      .products[
                                                                          index]
                                                                      .image,
                                                                  "quantity":
                                                                      counts[
                                                                          index],
                                                                  "cost": double.parse(_con
                                                                          .products[
                                                                              index]
                                                                          .price) *
                                                                      counts[
                                                                          index]
                                                                });
                                                              else
                                                                produ["quantity"] +=
                                                                    1;
                                                            }
                                                            final s = await sharedPrefs
                                                                .setString(
                                                                    "cartData",
                                                                    json.encode(
                                                                        cartData));
                                                            final c = await sharedPrefs
                                                                .setInt(
                                                                    "cartCount",
                                                                    int.parse(
                                                                        count));
                                                            final l = await sharedPrefs.setString(
                                                                title +
                                                                    "Counts" +
                                                                    (sharedPrefs.getString("spShopID") !=
                                                                                null ||
                                                                            sharedPrefs.getString("spShopID") ==
                                                                                widget
                                                                                    .routeArgument.id
                                                                        ? sharedPrefs.getString(
                                                                            "spShopID")
                                                                        : widget
                                                                            .routeArgument
                                                                            .id),
                                                                counts
                                                                    .toString());
                                                            if (s && c && l) {
                                                              print(sharedPrefs
                                                                  .getString(
                                                                      "cartData"));
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween),
                                                  // padding: EdgeInsets.only(bottom: 5.0)
                                                )
                                        ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.end))
                                  ]),
                            ),
                            visible: _con.products[index].productStatus == 1),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 25,
                          vertical: MediaQuery.of(context).size.height / 500),
                    )))
        ]),
        floatingActionButton: Visibility(
            child: Container(
                child: FloatingActionButton(
                    backgroundColor: Color(0xffe62136),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3500 /
                            (MediaQuery.of(context).size.height -
                                MediaQuery.of(context).size.width)))),
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                            '/app_page', (Route<dynamic> route) => false,
                            arguments:
                                RouteArgument(param: false, heroTag: "1")),
                    child: Container(
                        child: Row(children: [
                          Row(children: [
                            Icon(Icons.shopping_basket_outlined),
                            VerticalDivider(
                                thickness: 2,
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width / 25,
                                indent:
                                    MediaQuery.of(context).size.height / 500,
                                endIndent:
                                    MediaQuery.of(context).size.height / 500),
                            Column(
                                children: [
                                  Text((count != null ? count.toString() : "") +
                                      " Items"),
                                  Text(
                                    "₹ " + price,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween),
                          ]),
                          Icon(Icons.arrow_forward)
                        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 50,
                            vertical:
                                MediaQuery.of(context).size.height / 80))),
                width: MediaQuery.of(context).size.width / 1.05,
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 30),
                height: MediaQuery.of(context).size.height / 12),
            visible: cartData != null && cartData["orderitems"].isNotEmpty));
  }
}
