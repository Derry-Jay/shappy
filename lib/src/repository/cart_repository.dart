import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shappy/src/helpers/custom_trace.dart';
import 'package:shappy/src/models/store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:global_configuration/global_configuration.dart';

Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();

Future<Map<String, dynamic>> getCartData(Map<String, dynamic> body) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      "${GlobalConfiguration().getString('api_base_url')}cartDetails";
  HttpClient httpClient = new HttpClient();
  final HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  request.headers
      .set("Authorization", "Bearer " + sharedPrefs.getString("apiToken"));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(sharedPrefs.getString("cartData") != null
      ? sharedPrefs.getString("cartData")
      : json.encode(body)));
  try {
    HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      String reply = await response.transform(utf8.decoder).join();
      return json.decode(reply);
    } else {
      throw Exception('Unable to fetch Cart Data from the API');
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}

Future<Map<String, dynamic>> checkOut(Map<String, dynamic> body) async {
  HttpClient httpClient = new HttpClient();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      "${GlobalConfiguration().getString('api_base_url')}checkout";
  final HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  request.headers
      .set("Authorization", "Bearer " + sharedPrefs.getString("apiToken"));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode(body)));
  try {
    HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      String reply = await response.transform(utf8.decoder).join();
      await sharedPrefs.remove("cartData");
      return json.decode(reply);
    } else {
      throw Exception('Unable to Checkout');
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}

Future<Store> getShopStatus(int shopID) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}StoreProfile';
  final client = new http.Client();
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "shop_ID": shopID.toString()
    });
    return Store.fromMap(
        response.statusCode == 200 ? json.decode(response.body)['result'] : {});
  } catch (e) {
    print(e);
    print(CustomTrace(StackTrace.current, message: url));
    throw (e);
  }
}
