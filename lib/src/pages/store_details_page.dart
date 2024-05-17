import 'dart:async';
import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/helpers/helper.dart';
import 'package:shappy/src/models/product.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shappy/src/controller/store_controller.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';

class StorePage extends StatefulWidget {
  final RouteArgument routeArgument;
  StorePage({Key key, this.routeArgument}) : super(key: key);
  @override
  StorePageState createState() => StorePageState();
}

class StorePageState extends StateMVC<StorePage> {
  String price;
  int size, count;
  List<int> counts;
  List<bool> statuses = <bool>[];
  StoreController _con;
  Map<String, dynamic> cartData;
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  StorePageState() : super(StoreController()) {
    _con = controller;
  }

  void getData() async {
    _con.store = widget.routeArgument.param;
    final SharedPreferences sharedPrefs = await _sharePrefs;
    cartData = sharedPrefs.getString("cartData") != null &&
            sharedPrefs.getString("cartData") != ""
        ? json.decode(sharedPrefs.getString("cartData"))
        : {
            "shop_ID": sharedPrefs.getString("spShopID") != null &&
                    sharedPrefs.getString("spShopID") == widget.routeArgument.id
                ? sharedPrefs.getString("spShopID")
                : widget.routeArgument.id,
            "orderitems": []
          };
    cartData["shop_ID"] == null
        ? cartData["shop_ID"] = widget.routeArgument.id
        : print(cartData);
    await _con.getStorePageData(_con.store.shopID);
    await _con.waitForProductCategories(_con.store.shopID);
    await _con.waitForUnclassifiedProducts(_con.store.shopID);
    size =
        _con.bestSellingProducts != null ? _con.bestSellingProducts.length : 0;
    size += _con.unclassifiedProducts != null
        ? _con.unclassifiedProducts.length
        : 0;
    count = sharedPrefs.getInt("cartCount");
    counts = sharedPrefs.containsKey("Counts" +
            (sharedPrefs.getString("spShopID") != null ||
                    sharedPrefs.getString("spShopID") == widget.routeArgument.id
                ? sharedPrefs.getString("spShopID")
                : widget.routeArgument.id))
        ? sharedPrefs
            .getString("Counts" +
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
        : new List.filled(size, 0, growable: true);
    print(counts);
    if (_con.bestSellingProducts != null)
      for (Product p in _con.bestSellingProducts)
        statuses.add(p.productStatus == 1);
  }

  void navigateTo(String route, RouteArgument arguments) {
    Navigator.pushNamed(context, route, arguments: arguments).then(onGoBack);
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      getData();
    });
  }

  double getPrice(Map<String, dynamic> map) {
    double p = 0.0;
    if (map == null || map == {})
      return 0.0;
    else {
      for (Map<String, dynamic> m in map["orderitems"])
        p += m["cost"] == null || m["quantity"] == null
            ? 0.0
            : (m["quantity"] < 1 && m["cost"] < 1
                ? 0.0
                : m["cost"] * m["quantity"]);
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

  int getWordCount(String str) =>
      str == null ? 1 : (str.isEmpty ? 1 : str.trim().split(' ').length);

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  @protected
  @mustCallSuper
  void didChangeDependencies() {
    getData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    imageCache.clear();
    count = getCount(cartData);
    price = getPrice(cartData).toString();
    return WillPopScope(
        child: Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              elevation: 0,
              title: Text(_con.store.shopName),
              centerTitle: true,
              backgroundColor: Color(0xffe62136),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () async {
                    final SharedPreferences sharedPrefs = await _sharePrefs;
                    if (sharedPrefs.getString("spShopID") != null &&
                        sharedPrefs.getString("cartData") == null)
                      await sharedPrefs.remove("spShopID");
                    Navigator.of(context).pop();
                  }),
              // actions: [
              //   IconButton(
              //       icon: Icon(Icons.shopping_cart_outlined),
              //       onPressed: () => Navigator.of(context).pushNamed(
              //           '/app_page',
              //           arguments: RouteArgument(param: false, heroTag: "1")))
              // ]
            ),
            body: Stack(
              children: [
                _con.unclassifiedProducts == null &&
                        _con.bestSellingProducts == null &&
                        _con.categories == null
                    ? CircularLoadingWidget(
                        height: MediaQuery.of(context).size.height)
                    : ((_con.store.imageURL == null ||
                                _con.store.imageURL == "") &&
                            (_con.bestSellingProducts == null
                                ? true
                                : _con.bestSellingProducts.isEmpty) &&
                            (_con.categories == null
                                ? true
                                : _con.categories.isEmpty) &&
                            (_con.unclassifiedProducts == null
                                ? true
                                : _con.unclassifiedProducts.isEmpty)
                        ? Container(
                            child: Column(children: [
                              Image.asset("assets/img/empty_store_data.png"),
                              Text(
                                "Store Data Unavailable",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              )
                            ], mainAxisAlignment: MainAxisAlignment.start),
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width / 4,
                                top: MediaQuery.of(context).size.height / 3.2))
                        : SingleChildScrollView(
                            child: Column(children: [
                              Visibility(
                                  child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              4,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  _con.store.imageURL),
                                              fit: BoxFit.fill),
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              bottomRight:
                                                  Radius.circular(20)))),
                                  visible: _con.store.imageURL != null &&
                                      _con.store.imageURL != "" &&
                                      _con.store.imageURL != "null"),
                              _con.bestSellingProducts == null
                                  ? CircularLoadingWidget(
                                      height: 100,
                                    )
                                  : Column(
                                      children: [
                                        Visibility(
                                            child: Container(
                                                alignment: Alignment.topLeft,
                                                padding: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      20,
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      50,
                                                ),
                                                child: Text(
                                                  'Best Selling',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textAlign: TextAlign.left,
                                                )),
                                            visible: _con.bestSellingProducts !=
                                                    null &&
                                                _con.bestSellingProducts
                                                    .isNotEmpty),
                                        Visibility(
                                            child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    3.8,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: _con
                                                      .bestSellingProducts
                                                      .length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                              int index) =>
                                                          Card(
                                                    elevation: 0,
                                                    child: Container(
                                                        child: Column(
                                                          children: [
                                                            Image.network(
                                                              _con.bestSellingProducts[index].image !=
                                                                          null &&
                                                                      _con.bestSellingProducts[index].image !=
                                                                          ""
                                                                  ? _con
                                                                      .bestSellingProducts[
                                                                          index]
                                                                      .image
                                                                  : "https://shappyfiles.s3.ap-south-1.amazonaws.com/productImages/1606903542173-%5Bobject%20Object%5D",
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  4,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  8,
                                                            ),
                                                            Text(
                                                                _con
                                                                    .bestSellingProducts[
                                                                        index]
                                                                    .name,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color(
                                                                        0xffE62337),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                                maxLines: getWordCount(_con
                                                                    .bestSellingProducts[
                                                                        index]
                                                                    .name),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                            Text(
                                                                _con.bestSellingProducts[index].description !=
                                                                        null
                                                                    ? _con
                                                                        .bestSellingProducts[
                                                                            index]
                                                                        .description
                                                                    : "",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          MediaQuery.of(context).size.width /
                                                                              50),
                                                                  child: Text(
                                                                    "Rs " +
                                                                        _con.bestSellingProducts[index]
                                                                            .price,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        color: Color(
                                                                            0xffE62337),
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                counts == null ||
                                                                        counts[index] ==
                                                                            0
                                                                    ? ButtonTheme(
                                                                        minWidth:
                                                                            MediaQuery.of(context).size.width /
                                                                                3,
                                                                        child:
                                                                            RaisedButton(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(18.0),
                                                                            side:
                                                                                BorderSide(color: Color(0xffe62136)),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            final SharedPreferences
                                                                                sharedPrefs =
                                                                                await _sharePrefs;
                                                                            if (sharedPrefs.getString("spShopID") == null ||
                                                                                sharedPrefs.getString("spShopID") == widget.routeArgument.id) {
                                                                              setState(() => counts[index]++);
                                                                              if (sharedPrefs.getString("spShopID") == null)
                                                                                await sharedPrefs.setString("spShopID", widget.routeArgument.id);
                                                                              if (cartData["orderitems"] == null || cartData["orderitems"].length == 0)
                                                                                setState(() => cartData["orderitems"].add({
                                                                                      "product_ID": _con.bestSellingProducts[index].proID,
                                                                                      "product_name": _con.bestSellingProducts[index].name,
                                                                                      "desc": _con.bestSellingProducts[index].description,
                                                                                      "product_IMG": _con.bestSellingProducts[index].image,
                                                                                      "quantity": counts[index],
                                                                                      "cost": double.parse(_con.bestSellingProducts[index].price) * counts[index]
                                                                                    }));
                                                                              else {
                                                                                print("Hi");
                                                                                Map<String, dynamic> produ;
                                                                                for (Map<String, dynamic> cartProduct in cartData["orderitems"]) {
                                                                                  if (cartProduct["product_ID"] == _con.bestSellingProducts[index].proID) {
                                                                                    produ = cartProduct;
                                                                                    break;
                                                                                  }
                                                                                }
                                                                                if (produ == null)
                                                                                  cartData["orderitems"].add({
                                                                                    "product_ID": _con.bestSellingProducts[index].proID,
                                                                                    "product_name": _con.bestSellingProducts[index].name,
                                                                                    "desc": _con.bestSellingProducts[index].description,
                                                                                    "product_IMG": _con.bestSellingProducts[index].image,
                                                                                    "quantity": counts[index],
                                                                                    "cost": double.parse(_con.bestSellingProducts[index].price) * counts[index]
                                                                                  });
                                                                                else
                                                                                  produ["quantity"] += 1;
                                                                              }
                                                                              final s = await sharedPrefs.setString("cartData", json.encode(cartData));
                                                                              final c = await sharedPrefs.setInt("cartCount", count);
                                                                              final l = await sharedPrefs.setString("Counts" + (sharedPrefs.getString("spShopID") != null || sharedPrefs.getString("spShopID") == widget.routeArgument.id ? sharedPrefs.getString("spShopID") : widget.routeArgument.id), counts.toString());
                                                                              if (s && c && l)
                                                                                print(sharedPrefs.getString("cartData"));
                                                                            } else
                                                                              Toast.show("You Have unchecked-out-products from another shop", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                                                          },
                                                                          textColor:
                                                                              Colors.white,
                                                                          color:
                                                                              Color(0xffe62136),
                                                                          child:
                                                                              Text(
                                                                            'ADD',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 15,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(18.0),
                                                                          color:
                                                                              Color(0xFFf0f0f0),
                                                                        ),
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                20,
                                                                        margin:
                                                                            EdgeInsets.only(
                                                                          top: MediaQuery.of(context).size.height /
                                                                              100,
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            new IconButton(
                                                                              icon: new Icon(Icons.remove),
                                                                              onPressed: () async {
                                                                                final SharedPreferences sharedPrefs = await _sharePrefs;
                                                                                setState(() => counts[index]--);
                                                                                Map<String, dynamic> produ;
                                                                                if (cartData["orderitems"] != null || cartData["orderitems"].isNotEmpty) {
                                                                                  for (Map<String, dynamic> cartProduct in cartData["orderitems"]) {
                                                                                    if (cartProduct["product_ID"] == _con.bestSellingProducts[index].proID) {
                                                                                      produ = cartProduct;
                                                                                      break;
                                                                                    }
                                                                                  }
                                                                                  if (produ != null) {
                                                                                    if (produ["quantity"] != 1)
                                                                                      produ["quantity"]--;
                                                                                    else {
                                                                                      cartData["orderitems"].removeWhere((item) => item == produ);
                                                                                      if (cartData["orderitems"].isEmpty || cartData["orderitems"] == null){
                                                                                      final s = await sharedPrefs.remove("spShopID");
                                                                                      final r = await sharedPrefs.remove("cartCount");
                                                                                      if (r && s) print("Removed");}
                                                                                    }
                                                                                  }
                                                                                  if(sharedPrefs.containsKey("cartCount")){
                                                                                    final c = await sharedPrefs.setInt("cartCount", count);
                                                                                    if(c) print("Set");
                                                                                  }
                                                                                  final s = await sharedPrefs.setString("cartData", json.encode(cartData));
                                                                                  final l = await sharedPrefs.setString("Counts" + (sharedPrefs.getString("spShopID") != null || sharedPrefs.getString("spShopID") == widget.routeArgument.id ? sharedPrefs.getString("spShopID") : widget.routeArgument.id), counts.toString());
                                                                                  if (s && l) print(sharedPrefs.getString("cartData"));
                                                                                }
                                                                              },
                                                                            ),
                                                                            new Text(counts[index] != null ? counts[index].toString() : "0",
                                                                                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                                                                            new IconButton(
                                                                              icon: new Icon(Icons.add),
                                                                              onPressed: () async {
                                                                                final SharedPreferences sharedPrefs = await _sharePrefs;
                                                                                setState(() => counts[index]++);
                                                                                if (cartData["orderitems"] == null || cartData["orderitems"].length == 0)
                                                                                  cartData["orderitems"].add({
                                                                                    "product_ID": _con.bestSellingProducts[index].proID,
                                                                                    "product_name": _con.bestSellingProducts[index].name,
                                                                                    "desc": _con.bestSellingProducts[index].description,
                                                                                    "product_IMG": _con.bestSellingProducts[index].image,
                                                                                    "quantity": counts[index],
                                                                                    "cost": double.parse(_con.bestSellingProducts[index].price) * counts[index]
                                                                                  });
                                                                                else {
                                                                                  Map<String, dynamic> produ;
                                                                                  for (Map<String, dynamic> cartProduct in cartData["orderitems"]) {
                                                                                    if (cartProduct["product_ID"] == _con.bestSellingProducts[index].proID) {
                                                                                      produ = cartProduct;
                                                                                      break;
                                                                                    }
                                                                                  }
                                                                                  if (produ == null)
                                                                                    cartData["orderitems"].add({
                                                                                      "product_ID": _con.bestSellingProducts[index].proID,
                                                                                      "product_name": _con.bestSellingProducts[index].name,
                                                                                      "desc": _con.bestSellingProducts[index].description,
                                                                                      "product_IMG": _con.bestSellingProducts[index].image,
                                                                                      "quantity": counts[index],
                                                                                      "cost": double.parse(_con.bestSellingProducts[index].price) * counts[index]
                                                                                    });
                                                                                  else
                                                                                    produ["quantity"] += 1;
                                                                                }
                                                                                final s = await sharedPrefs.setString("cartData", json.encode(cartData));
                                                                                final c = await sharedPrefs.setInt("cartCount", count);
                                                                                final l = await sharedPrefs.setString("Counts" + (sharedPrefs.getString("spShopID") != null || sharedPrefs.getString("spShopID") == widget.routeArgument.id ? sharedPrefs.getString("spShopID") : widget.routeArgument.id), counts.toString());
                                                                                if (s && c && l) print(sharedPrefs.getString("cartData"));
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                              ],
                                                            ),
                                                          ],
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                        ),
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    100)),
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            30)),
                                            visible: _con.bestSellingProducts !=
                                                    null &&
                                                _con.bestSellingProducts
                                                    .isNotEmpty)
                                      ],
                                    ),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 50),
                              _con.categories == null
                                  ? CircularLoadingWidget(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              10)
                                  : Visibility(
                                      child: Container(
                                          child: GridView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                mainAxisSpacing:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        double.infinity,
                                                crossAxisSpacing:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        100.0,
                                                crossAxisCount:
                                                    MediaQuery.of(context)
                                                                .orientation ==
                                                            Orientation.portrait
                                                        ? 2
                                                        : 4,
                                                childAspectRatio:
                                                    ((MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            3.2768) /
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height),
                                              ),
                                              itemCount: _con.categories.length,
                                              itemBuilder: (context,
                                                      int index) =>
                                                  InkWell(
                                                    highlightColor:
                                                        Colors.transparent,
                                                    splashColor:
                                                        Theme.of(context)
                                                            .accentColor
                                                            .withOpacity(0.08),
                                                    onTap: () => navigateTo(
                                                        '/catbasedproducts',
                                                        RouteArgument(
                                                            id: _con
                                                                .store.shopID
                                                                .toString(),
                                                            heroTag: _con
                                                                .categories[
                                                                    index]
                                                                .id,
                                                            param:
                                                                _con.categories[
                                                                    index])),
                                                    child: Container(
                                                        margin: EdgeInsets.symmetric(
                                                            vertical:
                                                                MediaQuery.of(context)
                                                                        .size
                                                                        .height /
                                                                    50,
                                                            horizontal:
                                                                MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    50),
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                                MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    20,
                                                            vertical: MediaQuery.of(context)
                                                                    .size
                                                                    .height /
                                                                (_con
                                                                    .categories[index]
                                                                    .name
                                                                    .length *
                                                                    8)),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFf9eeff),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15)),
                                                          border: Border.all(
                                                            color: Color(
                                                                0xFFebc3ff),
                                                            style: BorderStyle
                                                                .solid,
                                                            width: 2.0,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          _con.categories[index]
                                                              .name,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Color(
                                                                  0xFFc657ff),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          softWrap: true,
                                                          maxLines: 3,
                                                          overflow:
                                                              TextOverflow.fade,
                                                        )),
                                                  )),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  30)),
                                      visible: _con.categories != null &&
                                          _con.categories.isNotEmpty),
                              _con.unclassifiedProducts == null
                                  ? CircularLoadingWidget(height: 100)
                                  : Visibility(
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  20,
                                              vertical: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  30),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Unclassified Products",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                textAlign: TextAlign.left,
                                              ),
                                              Expanded(
                                                  child: ListView.builder(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount: _con
                                                    .unclassifiedProducts
                                                    .length,
                                                itemBuilder: (context, index) {
                                                  int uo =
                                                      _con.bestSellingProducts !=
                                                              null
                                                          ? _con
                                                              .bestSellingProducts
                                                              .length
                                                          : 0;
                                                  return Expanded(
                                                    child: Card(
                                                      elevation: 0,
                                                      child: Container(
                                                          child: Row(
                                                              children: <
                                                                  Widget>[
                                                                _con.unclassifiedProducts[index].image !=
                                                                            null &&
                                                                        _con.unclassifiedProducts[index].image !=
                                                                            ""
                                                                    ? Image.network(
                                                                        _con
                                                                            .unclassifiedProducts[
                                                                                index]
                                                                            .image,
                                                                        width:
                                                                            MediaQuery.of(context).size.width /
                                                                                5,
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                8)
                                                                    : Image
                                                                        .asset(
                                                                        "assets/img/fvcustom.jpg",
                                                                        width:
                                                                            MediaQuery.of(context).size.width /
                                                                                4,
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                7,
                                                                      ),
                                                                Expanded(
                                                                    child: Container(
                                                                        padding: EdgeInsets.only(
                                                                            bottom: (MediaQuery.of(context).size.height * Helper.getWordCount(_con.unclassifiedProducts[index].name)).toDouble() /
                                                                                64),
                                                                        child: Text(
                                                                            _con.unclassifiedProducts[index].name,
                                                                            style: TextStyle(color: Color(0xffe62136), fontWeight: FontWeight.w500, fontSize: 16),
                                                                            textAlign: TextAlign.justify),
                                                                        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 40, vertical: MediaQuery.of(context).size.height / 150))),
                                                                Expanded(
                                                                  child: Container(
                                                                      padding: EdgeInsets.only(
                                                                        top: MediaQuery.of(context).size.height /
                                                                            50,
                                                                      ),
                                                                      child: Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Container(
                                                                            child:
                                                                                Text(
                                                                              'Rs. ${_con.unclassifiedProducts[index].price.toString()}',
                                                                              maxLines: 1,
                                                                              style: TextStyle(color: Color(0xffe62136), fontWeight: FontWeight.bold, fontSize: 16),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                              child: counts == null || counts[uo + index] == 0
                                                                                  ? ButtonTheme(
                                                                                      minWidth: 120,
                                                                                      child: RaisedButton(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(18.0),
                                                                                          side: BorderSide(color: Color(0xffe62136)),
                                                                                        ),
                                                                                        onPressed: () async {
                                                                                          final SharedPreferences sharedPrefs = await _sharePrefs;
                                                                                          if (sharedPrefs.getString("spShopID") == null || sharedPrefs.getString("spShopID") == widget.routeArgument.id) {
                                                                                            setState(() => counts[uo + index]++);
                                                                                            if (sharedPrefs.getString("spShopID") == null) await sharedPrefs.setString("spShopID", widget.routeArgument.id);
                                                                                            if (cartData["orderitems"] == null || cartData["orderitems"].length == 0)
                                                                                              setState(() => cartData["orderitems"].add({
                                                                                                    "product_ID": _con.unclassifiedProducts[index].proID,
                                                                                                    "product_name": _con.unclassifiedProducts[index].name,
                                                                                                    "desc": _con.unclassifiedProducts[index].description,
                                                                                                    "product_IMG": _con.unclassifiedProducts[index].image,
                                                                                                    "quantity": counts[uo + index],
                                                                                                    "cost": double.parse(_con.unclassifiedProducts[index].price) * counts[uo + index]
                                                                                                  }));
                                                                                            else {
                                                                                              Map<String, dynamic> produ;
                                                                                              for (Map<String, dynamic> cartProduct in cartData["orderitems"]) {
                                                                                                if (cartProduct["product_ID"] == _con.unclassifiedProducts[index].proID) {
                                                                                                  produ = cartProduct;
                                                                                                  break;
                                                                                                }
                                                                                              }
                                                                                              if (produ == null)
                                                                                                setState(() => cartData["orderitems"].add({
                                                                                                      "product_ID": _con.unclassifiedProducts[index].proID,
                                                                                                      "product_name": _con.unclassifiedProducts[index].name,
                                                                                                      "desc": _con.unclassifiedProducts[index].description,
                                                                                                      "product_IMG": _con.unclassifiedProducts[index].image,
                                                                                                      "quantity": counts[uo + index],
                                                                                                      "cost": double.parse(_con.unclassifiedProducts[index].price) * counts[uo + index]
                                                                                                    }));
                                                                                              else
                                                                                                produ["quantity"] += 1;
                                                                                            }
                                                                                            final s = await sharedPrefs.setString("cartData", json.encode(cartData));
                                                                                            final c = await sharedPrefs.setInt("cartCount", count);
                                                                                            final l = await sharedPrefs.setString("Counts" + (sharedPrefs.getString("spShopID") != null || sharedPrefs.getString("spShopID") == widget.routeArgument.id ? sharedPrefs.getString("spShopID") : widget.routeArgument.id), counts.toString());
                                                                                            if (s && c && l) print(sharedPrefs.getString("cartData"));
                                                                                          } else
                                                                                            Toast.show("You Have unchecked-out-products from another shop", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
                                                                                    )
                                                                                  : Container(
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(18.0),
                                                                                        color: Color(0xFFf0f0f0),
                                                                                      ),
                                                                                      height: MediaQuery.of(context).size.height / 20,
                                                                                      margin: EdgeInsets.only(
                                                                                        top: MediaQuery.of(context).size.height / 100,
                                                                                      ),
                                                                                      child: Row(
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: <Widget>[
                                                                                          new IconButton(
                                                                                            icon: new Icon(Icons.remove),
                                                                                            onPressed: () async {
                                                                                              final SharedPreferences sharedPrefs = await _sharePrefs;
                                                                                              setState(() => counts[uo + index]--);
                                                                                              Map<String, dynamic> produ;
                                                                                              if (cartData["orderitems"] != null || cartData["orderitems"].length != 0) {
                                                                                                for (Map<String, dynamic> cartProduct in cartData["orderitems"]) {
                                                                                                  if (cartProduct["product_ID"] == _con.unclassifiedProducts[index].proID) {
                                                                                                    produ = cartProduct;
                                                                                                    break;
                                                                                                  }
                                                                                                }
                                                                                                if (produ != null) {
                                                                                                  if (produ["quantity"] != 1)
                                                                                                    produ["quantity"]--;
                                                                                                  else {
                                                                                                    cartData["orderitems"].removeWhere((item) => item == produ);
                                                                                                    if (cartData["orderitems"].isEmpty || cartData["orderitems"] == null) {
                                                                                                      final s = await sharedPrefs.remove("spShopID");
                                                                                                      final r = await sharedPrefs.remove("cartCount");
                                                                                                      if (r && s) print("Removed");
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                                if(sharedPrefs.containsKey("cartCount")){
                                                                                                  final c = await sharedPrefs.setInt("cartCount", count);
                                                                                                  if(c) print("Set");
                                                                                                }
                                                                                                final s = await sharedPrefs.setString("cartData", json.encode(cartData));
                                                                                                final l = await sharedPrefs.setString("Counts" + (sharedPrefs.getString("spShopID") != null || sharedPrefs.getString("spShopID") == widget.routeArgument.id ? sharedPrefs.getString("spShopID") : widget.routeArgument.id), counts.toString());
                                                                                                if (s && l) print(sharedPrefs.getString("cartData"));
                                                                                              }
                                                                                            },
                                                                                          ),
                                                                                          new Text(counts == null ? "0" : (counts[uo + index] != null ? counts[uo + index].toString() : "0"), style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                                                                                          new IconButton(
                                                                                            icon: new Icon(Icons.add),
                                                                                            onPressed: () async {
                                                                                              final SharedPreferences sharedPrefs = await _sharePrefs;
                                                                                              setState(() => counts[uo + index]++);
                                                                                              if (cartData["orderitems"] == null || cartData["orderitems"].length == 0)
                                                                                                cartData["orderitems"].add({
                                                                                                  "product_ID": _con.unclassifiedProducts[index].proID,
                                                                                                  "product_name": _con.unclassifiedProducts[index].name,
                                                                                                  "desc": _con.unclassifiedProducts[index].description,
                                                                                                  "product_IMG": _con.unclassifiedProducts[index].image,
                                                                                                  "quantity": counts[uo + index],
                                                                                                  "cost": double.parse(_con.unclassifiedProducts[index].price) * counts[uo + index]
                                                                                                });
                                                                                              else {
                                                                                                Map<String, dynamic> produ;
                                                                                                for (Map<String, dynamic> cartProduct in cartData["orderitems"]) {
                                                                                                  if (cartProduct["product_ID"] == _con.unclassifiedProducts[index].proID) {
                                                                                                    produ = cartProduct;
                                                                                                    break;
                                                                                                  }
                                                                                                }
                                                                                                if (produ == null)
                                                                                                  cartData["orderitems"].add({
                                                                                                    "product_ID": _con.unclassifiedProducts[index].proID,
                                                                                                    "product_name": _con.unclassifiedProducts[index].name,
                                                                                                    "desc": _con.unclassifiedProducts[index].description,
                                                                                                    "product_IMG": _con.unclassifiedProducts[index].image,
                                                                                                    "quantity": counts[uo + index],
                                                                                                    "cost": double.parse(_con.unclassifiedProducts[index].price) * counts[uo + index]
                                                                                                  });
                                                                                                else
                                                                                                  produ["quantity"] += 1;
                                                                                              }
                                                                                              final s = await sharedPrefs.setString("cartData", json.encode(cartData));
                                                                                              final c = await sharedPrefs.setInt("cartCount", count);
                                                                                              final l = await sharedPrefs.setString("Counts" + (sharedPrefs.getString("spShopID") != null || sharedPrefs.getString("spShopID") == widget.routeArgument.id ? sharedPrefs.getString("spShopID") : widget.routeArgument.id), counts.toString());
                                                                                              if (s && c && l) print(sharedPrefs.getString("cartData"));
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    )),
                                                                        ],
                                                                      )),
                                                                )
                                                              ],
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween),
                                                          padding: EdgeInsets.symmetric(
                                                              vertical: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  500,
                                                              horizontal:
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      30)),
                                                    ),
                                                  );
                                                },
                                              )),
                                            ],
                                          ),
                                          height: (_con.unclassifiedProducts
                                                      .length *
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3)
                                              .toDouble()),
                                      visible: _con.unclassifiedProducts == null
                                          ? false
                                          : _con
                                              .unclassifiedProducts.isNotEmpty)
                            ]),
                          )),
                Container(
                    height: MediaQuery.of(context).size.height / 60,
                    decoration: BoxDecoration(
                        color: Color(0xffe62136),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20))),
                    padding: EdgeInsets.all(10))
              ],
            ),
            backgroundColor: Color(0xffffffff),
            floatingActionButton: Visibility(
                child: Container(
                    child: FloatingActionButton(
                        backgroundColor: Color(0xffe62136),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(
                                3500 /
                                    (MediaQuery.of(context).size.height -
                                        MediaQuery.of(context).size.width)))),
                        onPressed: () => Navigator.of(context).pushNamed(
                            '/app_page',
                            arguments:
                                RouteArgument(param: false, heroTag: "1")),
                        child: Container(
                            child: Row(
                                children: [
                                  Row(children: [
                                    Icon(Icons.shopping_basket_outlined),
                                    VerticalDivider(
                                        thickness: 2,
                                        color: Colors.white,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                25,
                                        indent:
                                            MediaQuery.of(context).size.height /
                                                500,
                                        endIndent:
                                            MediaQuery.of(context).size.height /
                                                500),
                                    Column(
                                        children: [
                                          Text((count != null
                                                  ? count.toString()
                                                  : "") +
                                              " Items"),
                                          Text(
                                            "₹ " + price,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween),
                                  ]),
                                  Icon(Icons.arrow_forward)
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width / 50,
                                vertical:
                                    MediaQuery.of(context).size.height / 80))),
                    width: MediaQuery.of(context).size.width / 1.05,
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 30),
                    height: MediaQuery.of(context).size.height / 12),
                visible: count != null && count != 0)),
        onWillPop: backButtonOverride);
  }

  Future<bool> backButtonOverride() async {
    bool flag = false;
    final SharedPreferences sharedPrefs = await _sharePrefs;
    if (sharedPrefs.getString("spShopID") != null &&
        sharedPrefs.getString("cartData") == null)
      flag = await sharedPrefs.remove("spShopID");
    Navigator.pop(context);
    return flag;
  }
}
