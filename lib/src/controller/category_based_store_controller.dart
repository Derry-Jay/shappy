import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/store_category.dart';
import 'package:shappy/src/models/store.dart';
import 'package:shappy/src/repository/store_repository.dart';

class CategoryBasedStoresController extends ControllerMVC {
  StoreCategory cat;
  List<Store> stores;
  GlobalKey<ScaffoldState> scaffoldKey;
  CategoryBasedStoresController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  Future<void> listenForCategoryBasedStores(StoreCategory cat) async {
    final List<Store> stream =
        await getShopsBasedOnCategories(int.parse(cat.id));
    if (stream != null && stream.isNotEmpty)
      setState(() => stores = stream);
    else
      setState(() => stores = <Store>[]);
  }
}
