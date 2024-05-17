import 'dart:io';
import 'dart:convert';
import 'package:shappy/src/models/product_category.dart';
import 'package:shappy/src/models/product_category_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shappy/src/helpers/custom_trace.dart';
import 'package:shappy/src/models/product.dart';
import 'package:shappy/src/models/store.dart';
import 'package:shappy/src/models/favoritestore.dart';
import 'package:http/http.dart' as http;
import 'package:shappy/src/models/store_category.dart';
import 'package:shappy/src/models/store_base.dart';
import 'package:shappy/src/models/user.dart';

Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
ValueNotifier<FavoriteStore> currentFavStore =
    new ValueNotifier(FavoriteStore());
Future<List<FavoriteStore>> getFavoriteStore(User user) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}FavStores';
  final client = new http.Client();
  try {
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer " +
            (user == null
                ? sharedPrefs.getString("apiToken")
                : (user.apiToken == null || user.apiToken == ""
                    ? sharedPrefs.getString("apiToken")
                    : user.apiToken))
      },
      body: {
        "user_ID": user != null
            ? user.id.toString()
            : sharedPrefs.getString("spUserID")
      },
    );
    return json.decode(response.body)['result'] != null
        ? List.from(json.decode(response.body)['result'])
            .map((element) => FavoriteStore.fromJSON(element))
            .toList()
        : [];
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return [];
  }
}

Future<Map<String, dynamic>> addFavoriteStore(String shopID, User user) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}addFavStore';
  final client = new http.Client();
  print(user);
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader: "Bearer " +
          (user == null
              ? sharedPrefs.getString("apiToken")
              : (user.apiToken == null || user.apiToken == ""
                  ? sharedPrefs.getString("apiToken")
                  : user.apiToken))
    }, body: {
      "user_ID": (user == null
          ? sharedPrefs.getString("spUserID")
          : (user.id == null || user.id.toString() == ""
              ? sharedPrefs.getString("spUserID")
              : user.id.toString())),
      "shop_ID": shopID
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonString =
          json.decode(response.body) as Map<String, dynamic>;
      return jsonString;
    } else {
      throw Exception('Unable to fetch user details from the REST API');
      return {};
    }
  } catch (e) {
    print(e);

    throw (e);
  }
}

Future<Map<String, dynamic>> removeFavoriteStore(String favID) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final client = new http.Client();
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}removeFavStore';
  try {
    final response = await client.put(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "fav_ID": favID
    });
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Unable to Delete Favourite Store");
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}

Future<List<StoreCategory>> getShopCategories(User user) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}allCategories';
  final client = new http.Client();
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader: "Bearer " +
          (user == null
              ? sharedPrefs.getString("apiToken")
              : (user.apiToken == null || user.apiToken == ""
                  ? sharedPrefs.getString("apiToken")
                  : user.apiToken))
    }, body: {
      "pages": "0"
    });
    return json.decode(response.body)['result'] != null
        ? List.from(json.decode(response.body)['result'])
            .map((element) => StoreCategory.fromJSON(element))
            .toList()
        : <StoreCategory>[];
  } catch (e) {
    print(e);
    print(CustomTrace(StackTrace.current, message: url));
    return [];
  }
}

Future<List<Store>> getShopsBasedOnCategories(int catID, {User user}) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}categoryShop';
  try {
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader:
            "Bearer " + sharedPrefs.getString("apiToken")
      },
      body: {"cat_ID": catID.toString()},
    );
    if (response.statusCode == 200) {
      return StoreBase.fromMap(json.decode(response.body)).stores;
    } else {
      throw Exception('Unable to fetch customers from the REST API');
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return [];
  }
}

Future<List<Store>> getSearchedStore(String pattern) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}allShopDetailsSearch';
  final client = new http.Client();
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "keyword": pattern,
      "paging": "0"
    });
    print(response.body);
    if (response.statusCode == 200) {
      return StoreBase.fromMap(json.decode(response.body)).stores;
    } else {
      throw Exception('Unable to Fetch Categories');
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}

Future<List<Product>> getBestSellingProducts(int shopID) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}bestsellingProducts';
  final client = new http.Client();
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "shop_ID": shopID.toString()
    });
    return json.decode(response.body)['result'] != null &&
            json.decode(response.body)['result'].isNotEmpty
        ? List.from(json.decode(response.body)['result'])
            .map((element) => Product.fromMap(element))
            .toList()
        : <Product>[];
  } catch (e) {
    print(e);
    print(CustomTrace(StackTrace.current, message: url));
    return [];
  }
}

Future<List<ProductCategory>> getProductCategories(int shopID) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}StoreProductCategoriesList';
  final client = new http.Client();
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "shop_ID": shopID.toString()
    });
    if (response.statusCode == 200) {
      return ProductCategoryBase.fromMap(json.decode(response.body))
          .productCategories;
    } else {
      throw Exception('Unable to Fetch Categories');
    }
  } catch (e) {
    print(e);

    throw (e);
  }
}

Future<List<Product>> getUnclassifiedProducts(int shopID) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}StoreProductCategoriesList';
  final client = new http.Client();
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "shop_ID": shopID.toString()
    });
    if (response.statusCode == 200) {
      return ProductCategoryBase.fromMap(json.decode(response.body)).products;
    } else {
      throw Exception('Unable to Fetch Categories');
    }
  } catch (e) {
    print(e);
    print(CustomTrace(StackTrace.current, message: url));
    return [];
  }
}

Future<List<Store>> getSearchedShopsBasedOnCategory(
    int catID, String pattern) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}CategoryShopSearch';
  try {
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader:
            "Bearer " + sharedPrefs.getString("apiToken")
      },
      body: {"keyword": pattern, "cat_ID": catID.toString(), "paging": "0"},
    );
    if (response.statusCode == 200) {
      return StoreBase.fromMap(json.decode(response.body)).stores;
    } else {
      throw Exception('Unable to fetch customers from the REST API');
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return <Store>[];
  }
}
