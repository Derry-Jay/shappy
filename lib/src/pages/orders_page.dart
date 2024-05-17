import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:shappy/src/helpers/helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/order.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/controller/order_controller.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';

class OrdersPage extends StatefulWidget {
  final RouteArgument routeArgument;
  OrdersPage({Key key, this.routeArgument}) : super(key: key);
  @override
  State<StatefulWidget> createState() => OrdersPageState();
}

class OrdersPageState extends StateMVC<OrdersPage> {
  int page;
  String orderDate = "";
  OrderController _con;
  ScrollController cont;
  static var myFormat = new DateFormat('dd MMMM yyyy');
  TextEditingController crc = new TextEditingController();
  OrdersPageState() : super(OrderController()) {
    _con = controller;
  }

  void navigateTo(String route, RouteArgument arguments) {
    Navigator.pushNamed(context, route, arguments: arguments).then(onGoBack);
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      page = 0;
      _con.listenForOrders(_con.user, page);
    });
  }

  void _scrollListener() {
    if (cont.position.pixels == cont.position.maxScrollExtent) {
      setState(() {
        page += 1;
        print(page);
        _con.listenForOrders(_con.user, page);
      });
    }
  }

  @override
  void dispose() {
    cont.dispose();
    super.dispose();
  }

  @override
  void initState() {
    page = 0;
    _con.user.id = int.parse(widget.routeArgument.id);
    if (widget.routeArgument.param == null) _con.setData();
    _con.listenForOrders(_con.user, page);
    super.initState();
    cont = new ScrollController()..addListener(_scrollListener);
  }

  Widget ordersBoxList(List<Order> items) => Expanded(
      child: items == null
          ? CircularLoadingWidget(height: MediaQuery.of(context).size.height)
          : (items.isEmpty
              ? Container(
                  child: Column(children: [
                    Image.asset("assets/img/empty_orders.png"),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    Text(
                      "You haven't placed any Orders",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    )
                  ], mainAxisAlignment: MainAxisAlignment.start),
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 4)
      )
              : ListView.builder(
          controller: cont,
          shrinkWrap: true,
          itemCount: items.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index < items.length)
              orderDate = items[index].date == null ||
                  items[index].date == "null"
                  ? ""
                  : myFormat
                  .format(DateTime.parse(items[index].date));
            return index == items.length
                ? (items.length < 10
                ? Container(height: 0, width: 0)
                : CircularLoadingWidget(height: 30))
                : Container(
              padding: EdgeInsets.symmetric(
                  horizontal:
                  MediaQuery.of(context).size.width / 30,
                  vertical:
                  MediaQuery.of(context).size.height /
                      100),
              child: Card(
                elevation: 0,
                color: Colors.white,
                child: InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context)
                              .size
                              .width /
                              30,
                          vertical: MediaQuery.of(context)
                              .size
                              .height /
                              100),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Text(
                                  '#' +
                                      items[index]
                                          .orderID
                                          .toString(),
                                  style: TextStyle(
                                      fontWeight:
                                      FontWeight.w500,
                                      fontSize: 17),
                                ),
                                Text(
                                    "₹" +
                                        items[index]
                                            .total
                                            .toString(),
                                    textAlign:
                                    TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 17))
                              ],
                              crossAxisAlignment:
                              CrossAxisAlignment.center),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Text(items[index].shopName,
                                  maxLines:
                                  Helper.getWordCount(
                                      items[index]
                                          .shopName),
                                  textAlign:
                                  TextAlign.justify,
                                  // softWrap: true,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.black,
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Container(
                                child: InkWell(
                                  onTap: () => navigateTo(
                                      '/orderDetails',
                                      RouteArgument(
                                          id: items[index]
                                              .orderID
                                              .toString(),
                                          param: {
                                            "User": _con.user,
                                            "Order":
                                            items[index]
                                          })),
                                  child: Text(
                                      'Details \u2192',
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Color(
                                              0xffe62136))),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                    MediaQuery.of(context)
                                        .size
                                        .height /
                                        100),
                              ),
                            ],
                          ),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Text(items[index].area,
                                    style: TextStyle(
                                      // fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontSize: 17)),
                                SizedBox(
                                    height:
                                    MediaQuery.of(context)
                                        .size
                                        .height /
                                        20)
                              ]),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Row(children: [
                                items[index].orderStatus !=
                                    6 &&
                                    items[index]
                                        .orderStatus !=
                                        0
                                    ? Icon(
                                    Icons
                                        .check_circle_rounded,
                                    color:
                                    Color(0xff399800))
                                    : (items[index]
                                    .orderStatus ==
                                    6
                                    ? Transform.rotate(
                                  angle: pi / 4,
                                  child: Icon(
                                      Icons
                                          .add_circle_outlined,
                                      color: Color(
                                          0xffe62136)),
                                )
                                    : Container(
                                    height: 0)),
                                Text(
                                    items[index].orderStatus ==
                                        0
                                        ? "Waiting for Shop Approval"
                                        : items[index].orderStatus ==
                                        1 ||
                                        items[index]
                                            .orderStatus ==
                                            2
                                        ? "Order Received"
                                        : (items[index].orderStatus ==
                                        3 ||
                                        items[index]
                                            .orderStatus ==
                                            4
                                        ? "On the Way"
                                        : (items[index]
                                        .orderStatus ==
                                        5
                                        ? "Order Delivered"
                                        : "Order Cancelled")),
                                    style: TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                        color: Colors.black))
                              ]),
                              Visibility(
                                  visible: false
                                  // items[index].orderStatus != 6 &&
                                  //     items[index].orderStatus != 5
                                  ,
                                  child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .end,
                                      children: [
                                        Icon(
                                            Icons
                                                .check_circle_rounded,
                                            color: Color(
                                                0xffb0afaf)),
                                        Text(
                                            items[index]
                                                .orderStatus ==
                                                0 ||
                                                items[index]
                                                    .orderStatus ==
                                                    1 ||
                                                items[index]
                                                    .orderStatus ==
                                                    2
                                                ? "On the Way"
                                                : (items[index].orderStatus ==
                                                3 ||
                                                items[index].orderStatus ==
                                                    4
                                                ? "Order Delivered/Cancelled"
                                                : ""),
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                color: Color(
                                                    0xffb0afaf)))
                                      ]))
                            ],
                          ),
                          Text(orderDate,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 14.5))
                        ],
                      ),
                    ),
                    onTap: () => navigateTo(
                        '/orderDetails',
                        RouteArgument(
                            id: items[index]
                                .orderID
                                .toString(),
                            param: {
                              "User": _con.user,
                              "Order": items[index]
                            }))),
              ),
            );
          })));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      backgroundColor: Color(0xfff3f2f2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffe62136),
        centerTitle: true,
        title: Text(
          'My Orders',
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // actions: <Widget>[
        //   IconButton(
        //       icon: Icon(Icons.search),
        //       onPressed: () {
        //         print('search icon');
        //       })
        // ],
      ),
      body: Column(children: [
        Container(
            decoration: BoxDecoration(
                color: Color(0xffe62136),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            padding: EdgeInsets.all(10)),
        ordersBoxList(_con.customerOrders)
      ]),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     print('MI<->DC');
      //   },
      //   tooltip: 'Filter',
      //   child: Icon(Icons.filter_alt_outlined),
      // ),
    );
  }
}
