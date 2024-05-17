import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shappy/src/models/store_category.dart';
import '../models/route_argument.dart';
import 'dart:math';

class GridItemWidget extends StatelessWidget {
  final StoreCategory category;
  final String heroTag;

  GridItemWidget({Key key, this.category, this.heroTag}) : super(key: key);

  String getInitials(String name) => name.isNotEmpty
      ? name.trim().split(' ').map((l) => l[0]).take(2).join()
      : '';

  String getColor(String color) =>
      color == null ? '' : (color.isEmpty ? '' : color.trim().split('#')[1]);

  int getWordCount(String str) =>
      str == null ? 1 : (str.isEmpty ? 1 : str.trim().split(' ').length);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      onTap: () => Navigator.of(context).pushNamed('/catbasedstore',
          arguments: RouteArgument(
              id: category.id, heroTag: heroTag, param: category)),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 20),
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 5,
        decoration: BoxDecoration(
          color: Color(int.parse("0x11" + getColor(category.bgColor))),
          borderRadius: BorderRadius.all(Radius.circular(sqrt(
              (pow(MediaQuery.of(context).size.height, 2) +
                      pow(MediaQuery.of(context).size.width, 2)) /
                  2500))),
          border: Border.all(
            color: Color(int.parse("0xFF" + getColor(category.bgColor))),
            style: BorderStyle.solid,
            width: 2.0,
          ),
        ),
        child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                child: Container(
                    child: Hero(
                      tag: heroTag + category.id,
                      child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: category.image,
                          placeholder: (context, url) => Image.asset(
                              'assets/img/loading.gif',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height / 250),
                          errorWidget: (context, url, error) => Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width / 35),
                              child: Text(getInitials(category.name),
                                  style: TextStyle(
                                      fontSize: 40,
                                      color: Color(
                                          int.parse("0xFF" + getColor(category.bgColor))),
                                      fontWeight: FontWeight.bold))),
                          height: MediaQuery.of(context).size.height / 12),
                    ),
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 50)),
              ),
              Text(
                category.name,
                style: TextStyle(
                    fontSize: 16,
                    color:
                        Color(int.parse("0xFF" + getColor(category.bgColor))),
                    fontWeight: FontWeight.bold),
                softWrap: false,
                maxLines: getWordCount(category.name),
                overflow: TextOverflow.ellipsis,
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start),
      ),
    );
  }
}
