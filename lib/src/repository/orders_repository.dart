import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shappy/src/models/user.dart';
import 'package:shappy/src/models/order.dart';
import 'package:shappy/src/models/order_base.dart';
import 'package:shappy/src/models/order_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:global_configuration/global_configuration.dart';

Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();

Future<List<Order>> getOrders(User user, int page) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}ordersHistory';
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader: "Bearer " +
          (user.apiToken != null
              ? user.apiToken
              : sharedPrefs.getString("apiToken"))
    }, body: {
      "user_ID": user.id.toString(),
      "pages": page.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonString =
          json.decode(response.body) as Map<String, dynamic>;
      return OrderBase.fromMap(jsonString).order;
    } else {
      throw Exception('Unable to fetch orders from the REST API');
    }
  } catch (e) {
    print(e);
    // throw (e);
    return <Order>[];
  }
}

Future<OrderDetails> fetchOrderDetails(String orderID, {User user}) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}OrdersProductListCustomer';
  final client = new http.Client();
  final response = await client.post(url, headers: {
    HttpHeaders.authorizationHeader:
        "Bearer " + sharedPrefs.getString("apiToken")
  }, body: {
    "order_ID": orderID
  });
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonString =
        json.decode(response.body) as Map<String, dynamic>;
    // print(jsonString);
    return OrderDetails.fromMap(jsonString);
  } else {
    throw Exception('Unable to fetch products from the REST API');
  }
}

Future<Map<String, dynamic>> cancelOrder(
    String cancelReason, int orderID) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orderUserCancel';
  try {
    final response = await client.put(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "order_ID": orderID.toString(),
      "order_status": "6",
      "cancel_reason": cancelReason
    });
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Unable to fetch products from the REST API');
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}

Future<Map<String, dynamic>> rateOrder(
    String orderReview, int orderID, int orderRating) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orderReview';
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "order_ID": orderID.toString(),
      "order_rating": orderRating.toString(),
      "order_review": orderReview
    });
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Unable to rate Order');
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}
