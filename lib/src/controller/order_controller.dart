import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:shappy/src/models/user.dart';
import 'package:shappy/src/models/order.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/order_details.dart';
import 'package:shappy/src/repository/user_repository.dart';
import 'package:shappy/src/repository/orders_repository.dart' as repository;

class OrderController extends ControllerMVC {
  User user = new User();
  Order order;
  OrderDetails orderDetails;
  List<Order> customerOrders;
  GlobalKey<ScaffoldState> scaffoldKey;
  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void setData() async {
    final stream = await getUserDetails();
    if (stream != null)
      setState(() => user = stream);
    else
      setState(() => user = User());
  }

  void listenForOrders(User user, int page) async {
    final value = await repository.getOrders(user, page);
    if (value != null && value.isNotEmpty) {
      if (customerOrders == null)
        setState(() => customerOrders = value);
      else
        for (Order od in value)
          if (!od.isIn(customerOrders)) setState(() => customerOrders.add(od));
    } else {
      if (customerOrders == null) {
        setState(() => customerOrders = <Order>[]);
        // Toast.show("Unable to Fetch Orders", context,
        //     duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else
        Toast.show("No More Orders", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void waitForOrderDetails(Order order) async {
    final stream = await repository.fetchOrderDetails(order.orderID.toString(),
        user: user);
    if (stream != null)
      setState(() => orderDetails = stream);
    else
      Toast.show("Unable to Fetch Order Details", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void waitUntilOrderCancel(String cancelReason, int orderID) async {
    await repository.cancelOrder(cancelReason, orderID).then((value) async {
      if (value != null && value["success"] && value["status"]) {
        print(value["message"]);
        listenForOrders(user, 0);
        Navigator.of(context).pop();
      }
    });
  }

  void waitUntilOrderRate(
      String orderReview, int orderID, int orderRating) async {
    await repository.rateOrder(orderReview, orderID, orderRating).then((value) {
      if (value != null && value["success"] && value["status"])
        print(value["message"]);
    });
  }
}
