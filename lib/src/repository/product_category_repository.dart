import 'dart:core';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shappy/src/models/product.dart';
import 'package:shappy/src/models/product_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:global_configuration/global_configuration.dart';

Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();

Future<List<Product>> getProductsBasedOnCategory(
    String shopID, String pcID) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      "${GlobalConfiguration().getString('api_base_url')}shopProductCategories";
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "shop_ID": shopID,
      "productCat_ID": pcID
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonString =
          json.decode(response.body) as Map<String, dynamic>;
      return ProductBase.fromMap(jsonString).products;
    } else {
      throw Exception("Unable to fetch Products from the REST API");
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}

Future<List<Product>> getSearchedProducts(String shopID, String keyWord) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      "${GlobalConfiguration().getString('api_base_url')}ShopProductDetails";
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "shop_ID": shopID,
      "keyword": keyWord,
      "paging": "0"
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonString =
          json.decode(response.body) as Map<String, dynamic>;
      return ProductBase.fromMap(jsonString).products;
    } else {
      throw Exception("Unable to fetch Products from the REST API");
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}
