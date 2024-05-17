import 'package:flutter/material.dart';
import 'package:shappy/src/models/favoritestore.dart';
import '../elements/FavoriteStoreLoaderWidget.dart';
import 'FavoriteStoreItemWidget.dart';

class FavoriteStoreWidget extends StatelessWidget {
  final List<FavoriteStore> favoriteStoreList;
  final String heroTag;

  FavoriteStoreWidget({Key key, this.favoriteStoreList, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return favoriteStoreList.isEmpty
        ? FavoriteStoreLoaderWidget()
        : Container(
            height: 150,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              itemCount: favoriteStoreList.length,
              itemBuilder: (context, index) {
                double _marginLeft = 0;
                (index == 0) ? _marginLeft = 0 : _marginLeft = 0;
                return FavoriteStoreItemWidget(
                  heroTag: heroTag,
                  marginLeft: _marginLeft,
                  favoriteStore: favoriteStoreList.elementAt(index),
                );
              },
              scrollDirection: Axis.horizontal,
            ));
  }
}
