import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/store.dart';
import 'package:shappy/src/models/product.dart';
import 'package:shappy/src/models/product_category.dart';
import 'package:shappy/src/repository/store_repository.dart' as repos;

class StoreController extends ControllerMVC {
  Store store;
  List<ProductCategory> categories;
  GlobalKey<ScaffoldState> scaffoldKey;
  List<Store> searchedStores = <Store>[];
  List<Product> bestSellingProducts, unclassifiedProducts;
  StoreController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<void> getStorePageData(int shopID) async {
    final stream = await repos.getBestSellingProducts(shopID);
    if (stream != null) {
      setState(() => bestSellingProducts = stream);
      // if (bestSellingProducts.isEmpty)
      //   Toast.show("Best Selling Products Unavailable", context,
      //       duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      setState(() => bestSellingProducts = <Product>[]);
      Toast.show("Unable to Fetch Best Selling Products", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<void> waitForProductCategories(int shopID) async {
    final stream = await repos.getProductCategories(shopID);
    if (stream != null){
      setState(() => categories = stream);
      // if (categories.isEmpty)
      //   Toast.show("Best Selling Products Unavailable", context,
      //       duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      setState(() => categories = <ProductCategory>[]);
      Toast.show("Unable to Fetch Product Categories", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<void> waitForUnclassifiedProducts(int shopID) async {
    final stream = await repos.getUnclassifiedProducts(shopID);
    if (stream != null){
      setState(() => unclassifiedProducts = stream);
      // if (unclassifiedProducts.isEmpty)
      //   Toast.show("Best Selling Products Unavailable", context,
      //       duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      setState(() => unclassifiedProducts = <Product>[]);
      Toast.show("Unable to Fetch Products", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void waitForSearchedStores(String pattern) async {
    if (pattern == null || pattern == "") {
      setState(() => searchedStores = <Store>[]);
      Toast.show("No Stores Found", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    } else {
      final stream = await repos.getSearchedStore(pattern);
      if (stream != null) {
        setState(() => searchedStores = stream);
        if (searchedStores.isEmpty) {
          setState(() => searchedStores = <Store>[]);
          Toast.show("No Stores Found", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        }
      } else {
        setState(() => searchedStores = <Store>[]);
        Toast.show("No Stores Found", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      }
    }
  }

  void waitForSearchedStoresBasedOnCategory(String pattern, int catID) async {
    if (pattern == null || pattern == "") {
      setState(() => searchedStores = <Store>[]);
      Toast.show("No Stores Found", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    } else {
      final stream =
          await repos.getSearchedShopsBasedOnCategory(catID, pattern);
      if (stream != null) {
        setState(() => searchedStores = stream);
        if (searchedStores.isEmpty) {
          setState(() => searchedStores = <Store>[]);
          Toast.show("No Stores Found", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        }
      } else {
        setState(() => searchedStores = <Store>[]);
        Toast.show("No Stores Found", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      }
    }
  }
}
