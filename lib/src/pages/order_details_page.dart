import 'dart:math';
import 'package:intl/intl.dart';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/order.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/models/ordered_product.dart';
import 'package:shappy/src/controller/order_controller.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';

class OrderDetailsPage extends StatefulWidget {
  final RouteArgument routeArgument;
  OrderDetailsPage({Key key, this.routeArgument}) : super(key: key);
  @override
  State<StatefulWidget> createState() => OrderDetailsPageState();
}

class OrderDetailsPageState extends StateMVC<OrderDetailsPage> {
  String orderDate;
  OrderController _con;
  static var myFormat = new DateFormat('dd MMMM yyyy');
  TextEditingController crc = new TextEditingController();
  OrderDetailsPageState() : super(OrderController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.user = widget.routeArgument.param["User"];
    _con.order = widget.routeArgument.param["Order"];
    _con.waitForOrderDetails(_con.order);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3f2f2),
      appBar: AppBar(
        title: Text("Order Details"),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xffe62136),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: Column(children: [
        Container(
            decoration: BoxDecoration(
                color: Color(0xffe62136),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            padding: EdgeInsets.all(10)),
        _con.orderDetails == null
            ? CircularLoadingWidget(
                height: MediaQuery.of(context).size.height / 1.5)
            : Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
                      Column(children: [
                        Text(
                            "Order ID : " +
                                (_con.order.orderID != null
                                    ? "#" + _con.order.orderID.toString()
                                    : ""),
                            style:
                                TextStyle(color: Colors.black, fontSize: 14)),
                        Text(
                            (_con.order.shopName != null
                                    ? _con.order.shopName
                                    : "") +
                                " - " +
                                (_con.order.area != null
                                    ? _con.order.area
                                    : ""),
                            style:
                                TextStyle(color: Colors.black, fontSize: 14)),
                        Row(
                          children: [
                            Row(children: [
                              _con.order.orderStatus != 6 &&
                                      _con.order.orderStatus != 0
                                  ? Icon(Icons.check_circle_rounded,
                                      color: Color(0xff399800))
                                  : (_con.order.orderStatus == 6
                                      ? Transform.rotate(
                                          angle: pi / 4,
                                          child: Icon(Icons.add_circle_outlined,
                                              color: Color(0xffe62136)),
                                        )
                                      : Container(height: 0)),
                              Text(
                                  _con.order.orderStatus == 0
                                      ? "Waiting for Shop Approval"
                                      : _con.order.orderStatus == 1 ||
                                              _con.order.orderStatus == 2
                                          ? "Order Received"
                                          : (_con.order.orderStatus == 3 ||
                                                  _con.order.orderStatus == 4
                                              ? "On the Way"
                                              : (_con.order.orderStatus == 5
                                                  ? "Order Delivered"
                                                  : "Order Cancelled")),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black))
                            ]),
                            Visibility(
                                visible: false
                                // _con.order.orderStatus != 6 &&
                                //     _con.order.orderStatus != 5
                                ,
                                child: Row(children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Color(0xffb0afaf)),
                                  Text(
                                      _con.order.orderStatus == 0 ||
                                              _con.order.orderStatus == 1 ||
                                              _con.order.orderStatus == 2
                                          ? "On the Way"
                                          : (_con.order.orderStatus == 3 ||
                                                  _con.order.orderStatus == 4
                                              ? "Order Delivered/Cancelled"
                                              : ""),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xffb0afaf)))
                                ]))
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                        Text(
                            _con.order.date == null || _con.order.date == "null"
                                ? ""
                                : myFormat
                                    .format(DateTime.parse(_con.order.date)),
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                        Visibility(
                            child: Container(
                              child: Column(children: [
                                Divider(
                                  thickness: 1,
                                  color: Color(0xffe8e7e7),
                                ),
                                Text(
                                  "Cancelled Reason",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(_con.order.cancelReason,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center)
                              ], crossAxisAlignment: CrossAxisAlignment.start),
                            ),
                            visible: _con.order.orderStatus == 6),
                        Divider(
                          thickness: 1,
                          color: Color(0xffe8e7e7),
                        ),
                        Container(
                            child: buildList(_con.orderDetails.products),
                            height: ((_con.orderDetails.products.length *
                                        MediaQuery.of(context).size.height) /
                                    16)
                                .toDouble()),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                " Total - ₹",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                _con.order.total,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )
                            ],
                          ),
                        )
                      ], crossAxisAlignment: CrossAxisAlignment.start),
                      Visibility(
                          child: Container(
                            child: RaisedButton(
                              child: Text("Cancel Order"),
                              color: Color(0xffd4d4d4),
                              onPressed: () => _con.order.orderStatus != 5
                                  ? _showDialog(_con.order)
                                  : print("Hey"),
                            ),
                          ),
                          visible: _con.order.orderStatus != 5 &&
                              _con.order.orderStatus != 6)
                    ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height / 40,
                        horizontal: MediaQuery.of(context).size.width / 25)))
      ]),
    );
  }

  Widget buildList(List<OrderedProduct> op) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: op.length,
        itemBuilder: (BuildContext context, int index) {
          if (!op.contains(null) && op != null && op != []) {
            return Flexible(
                child: Row(children: <Widget>[
              Flexible(
                  child: Text(
                      op[index].productName != null
                          ? op[index].productName
                          : "NULL",
                      textAlign: TextAlign.justify,
                      maxLines: Helper.getWordCount(op[index].productName),
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Colors.black))),
              Flexible(
                  child: Text(
                      op[index].cartCount != null
                          ? op[index].cartCount.toString()
                          : "NULL",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Colors.black))),
              Text(
                  (op[index].cartCount != null
                      ? (double.parse(op[index].price) * op[index].cartCount)
                          .toString()
                      : ""),
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 17))
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween));
          } else {
            return CircularLoadingWidget(
              height: 100,
            );
          }
        });
  }

  void _showDialog(Order item) async {
    await showDialog<String>(
      context: context,
      child: _SystemPadding(
        child: new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  onSubmitted: (val) => setState(() => crc.text = val),
                  controller: crc,
                  decoration: new InputDecoration(
                      labelText: 'Cancel Reason',
                      hintText: 'eg. Duplicate Order'),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Color(0xffe62136)),
                ),
                onPressed: () {
                  _con.waitUntilOrderCancel(crc.text, item.orderID);
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
    );
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AnimatedContainer(
        duration: const Duration(milliseconds: 300), child: child);
  }
}
