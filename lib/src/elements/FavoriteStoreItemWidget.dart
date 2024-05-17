import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shappy/src/models/favoritestore.dart';
import 'package:shappy/src/models/store.dart';
import 'package:shappy/src/models/route_argument.dart';

class FavoriteStoreItemWidget extends StatelessWidget {
  final double marginLeft;
  final FavoriteStore favoriteStore;
  final String heroTag;

  FavoriteStoreItemWidget(
      {Key key, this.heroTag, this.marginLeft, this.favoriteStore})
      : super(key: key);

  String getInitials(String name) => name.isNotEmpty
      ? name.trim().split(' ').map((l) => l[0]).take(2).join()
      : '';
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      highlightColor: Colors.transparent,
      onTap: () => Navigator.of(context).pushNamed('/store',
          arguments: RouteArgument(
              param: Store.fromMap(favoriteStore.toMap()),
              id: favoriteStore.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.topEnd,
            children: <Widget>[
              Hero(
                tag: heroTag + favoriteStore.favId,
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 20),
                  width: MediaQuery.of(context).size.width / 5,
                  height: MediaQuery.of(context).size.height / 11.5,
                  decoration: BoxDecoration(
                    color: Color(0xfffceaea),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      color: Color(0xffe62337),
                      style: BorderStyle.solid,
                      width: 2.0,
                    ),
                  ),
                  child: Text(getInitials(favoriteStore.name),
                      style: TextStyle(
                          fontSize: 30,
                          color: Color(0xffe62337),
                          fontWeight: FontWeight.bold)),
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 40,
                      vertical: MediaQuery.of(context).size.height / 80),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Container(
              width: 100,
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              margin:
                  EdgeInsetsDirectional.only(start: this.marginLeft, end: 5),
              child: Column(
                children: <Widget>[
                  Text(this.favoriteStore.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(color: Colors.black, fontSize: 15),
                      textAlign: TextAlign.center),
                ],
              )),
        ],
      ),
    );
  }
}
