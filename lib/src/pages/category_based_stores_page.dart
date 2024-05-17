import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/store.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';
import 'package:shappy/src/controller/category_based_store_controller.dart';

class CategoryBasedStoresPage extends StatefulWidget {
  final RouteArgument routeArgument;
  CategoryBasedStoresPage({Key key, this.routeArgument}) : super(key: key);
  @override
  CategoryBasedStoresPageState createState() => CategoryBasedStoresPageState();
}

class CategoryBasedStoresPageState extends StateMVC<CategoryBasedStoresPage> {
  CategoryBasedStoresController _con;

  CategoryBasedStoresPageState() : super(CategoryBasedStoresController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.cat = widget.routeArgument.param;
    _con.listenForCategoryBasedStores(_con.cat);
    super.initState();
  }

  int getWordCount(String str) =>
      str == null ? 1 : (str.isEmpty ? 1 : str.trim().split(' ').length);

  String getInitials(String name) => name.isNotEmpty
      ? name.trim().split(' ').map((l) => l[0]).take(2).join()
      : '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            title: Text(
              "Stores",
              style: TextStyle(fontSize: 25),
            ),
            leading: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Color(0xffe62136),
            actions: [
              IconButton(
                color: Colors.white,
                icon: Icon(
                  Icons.search,
                  size: 33,
                ),
                onPressed: () => Navigator.of(context).pushNamed(
                    '/categoryBasedStoreSearch',
                    arguments: RouteArgument(
                        param: _con.cat,
                        id: _con.cat.id,
                        heroTag: _con.cat.name)),
              )
            ]),
        body: Column(children: [
          Container(
              decoration: BoxDecoration(
                  color: Color(0xffe62136),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              padding: EdgeInsets.all(sqrt(
                  (pow(MediaQuery.of(context).size.height, 2) +
                          pow(MediaQuery.of(context).size.width, 2)) /
                      6400))),
          Expanded(
              child: Container(
                  child: buildList(_con.stores),
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 500)))
        ]),
        backgroundColor: Color(0xffffffff));
  }

  Widget buildList(List<Store> sl) => sl == null
      ? CircularLoadingWidget(height: MediaQuery.of(context).size.height / 2)
      : (sl.isEmpty
          ? Column(children: [
              Image.asset("assets/img/empty_stores.png"),
              SizedBox(
                height: MediaQuery.of(context).size.height / 64
              ),
              Text("No Stores Available in Your Area",
                  style: TextStyle(fontSize: 16, color: Colors.black))
            ], mainAxisAlignment: MainAxisAlignment.center)
          : ListView.builder(
              itemCount: sl.length,
              itemBuilder: (BuildContext context, int index) => InkWell(
                    child: Container(
                        color: Color(0xffffffff),
                        padding: EdgeInsets.all(sqrt(
                            (pow(MediaQuery.of(context).size.height, 2) +
                                    pow(MediaQuery.of(context).size.width, 2)) /
                                6400)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width /
                                                50),
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width /
                                                32,
                                        top:
                                            MediaQuery.of(context).size.height /
                                                70,
                                        right:
                                            MediaQuery.of(context).size.width /
                                                32),
                                    width:
                                        MediaQuery.of(context).size.width / 4.5,
                                    height: MediaQuery.of(context).size.height /
                                        9.1,
                                    decoration: BoxDecoration(
                                      color: Color(0xfffceaea),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      border: Border.all(
                                          color: Color(0xfff8cdcd),
                                          style: BorderStyle.solid,
                                          width: 2.0),
                                    ),
                                    child: Text(getInitials(sl[index].shopName),
                                        style: TextStyle(
                                            fontSize: 45,
                                            color: Color(0xffe93b4d)),
                                        maxLines:
                                            getWordCount(sl[index].shopName),
                                        textAlign: TextAlign.center)),
                                flex: 1),
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 50),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    child: Text(
                                        sl[index].shopName != null
                                            ? sl[index].shopName
                                            : "Shop Name Not Available",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Colors.black)),
                                  ),
                                  Container(
                                    child: Text(
                                      sl[index].customerCount != null &&
                                              sl[index].customerCount != 0
                                          ? sl[index].customerCount.toString() +
                                              " Shapper" +
                                              (sl[index].customerCount != 1
                                                  ? "s"
                                                  : "")
                                          : "No Shappers",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Color(0xffe62136)),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              (sl[index].shopCate.length * 9)),
                                  Row(
                                    children: <Widget>[
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 2,
                                        child: Container(
                                            child: Text(
                                                sl[index].shopCate != null
                                                    ? sl[index].shopCate
                                                    : "",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    // fontWeight: FontWeight.w500,
                                                    fontSize: 13)),
                                            alignment: Alignment.centerLeft),
                                      ),
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 2,
                                        child: Container(
                                            child: Text(
                                                sl[index].shopArea != null
                                                    ? sl[index].shopArea
                                                    : "",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13)),
                                            alignment: Alignment.centerLeft),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 2,
                                        child: Container(
                                            child: Text(
                                                sl[index].productCount != null
                                                    ? sl[index]
                                                            .productCount
                                                            .toString() +
                                                        " Item" +
                                                        (sl[index].productCount !=
                                                                1
                                                            ? "s"
                                                            : "")
                                                    : "No Items to Show",
                                                style: TextStyle(
                                                    color: Color(0xffe62136),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10)),
                                            alignment: Alignment.centerLeft),
                                      ),
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 2,
                                        child: Container(
                                            child: Text(
                                                sl[index].deliveryRadius != null
                                                    ? sl[index]
                                                            .deliveryRadius
                                                            .toString() +
                                                        "KM                        "
                                                    : "Delivery Radius Data Unavailable",
                                                style: TextStyle(
                                                    color: Color(0xffe62136),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10)),
                                            alignment: Alignment.centerLeft),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              flex: 2,
                            )
                          ],
                        )),
                    onTap: () => Navigator.of(context).pushNamed("/store",
                        arguments: RouteArgument(
                            param: sl[index], id: sl[index].shopID.toString())),
                  )));
}
