import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/product.dart';
import 'package:shappy/src/repository/product_category_repository.dart';
import 'package:toast/toast.dart';

class CategoryBasedProductsController extends ControllerMVC {
  List<Product> products;
  GlobalKey<ScaffoldState> scaffoldKey;
  CategoryBasedProductsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  Future<void> listenForCategoryBasedProducts(
      String shopID, String pcID) async {
    final List<Product> stream = await getProductsBasedOnCategory(shopID, pcID);
    if (stream != null){
      setState(() => products = stream);
      if(products.isEmpty)
        Toast.show("No Products Found", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      setState(() => products = <Product>[]);
      Toast.show("Error in Fetching Products", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void waitForSearchedProducts(
      String shopID, String keyWord, String pcID) async {
    if (keyWord == "" || keyWord == null)
      await listenForCategoryBasedProducts(shopID, pcID);
    else {
      final List<Product> stream = await getSearchedProducts(shopID, keyWord);
      if (stream != null && stream.length != 0)
        setState(() => products = stream);
      else {
        setState(() => products = <Product>[]);
        Toast.show("Searched Product Cannot Be Found", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      }
    }
  }
}
