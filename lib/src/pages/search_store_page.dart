import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/route_argument.dart';
import '../models/store.dart';
import '../controller/store_controller.dart';

class SearchStorePage extends StatefulWidget {
  @override
  SearchStorePageState createState() => SearchStorePageState();
}

class SearchStorePageState extends StateMVC<SearchStorePage> {
  StoreController _con;
  final now = new DateTime.now();
  static var myFormat = new DateFormat('dd MMMM yyyy');
  TextEditingController kc = new TextEditingController();
  SearchStorePageState() : super(StoreController()) {
    _con = controller;
  }
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
          elevation: 0,
          leading: Container(
              child: IconButton(
            icon: Icon(Icons.arrow_back_ios_sharp),
            color: Colors.white,
            iconSize: 20,
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/app_page', (Route<dynamic> route) => false,
                arguments: RouteArgument(param: false, heroTag: "0")),
          )),
          backgroundColor: Color(0xffe62136),
          actions: <Widget>[]),
      body: Column(
        children: [
          Stack(children: [
            Container(
              height: 70,
              width: double.infinity,
              padding: EdgeInsets.only(left: 20, top: 15),
              decoration: BoxDecoration(
                  color: Color(0xffe62136),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
            ),
            Container(
                child: TextField(
                    autofocus: true,
                    cursorColor: Colors.black,
                    controller: kc,
                    onChanged: _con.waitForSearchedStores,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'Search your store',
                      hintStyle:
                          TextStyle(color: Colors.black.withOpacity(0.2)),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.2))),
                    )),
                color: Colors.white,
                margin: EdgeInsets.all(10))
          ]),
          Visibility(
              child: Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Visibility(
                          child: InkWell(
                            child: Container(
                                color: Color(0xffffffff),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              7.0368744177664,
                                          decoration: BoxDecoration(
                                            color: Color(0xfffceaea),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            border: Border.all(
                                              color: Color(0xfff8cdcd),
                                              style: BorderStyle.solid,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: _con
                                                  .searchedStores[index]
                                                  .imageURL,
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                'assets/img/loading.gif',
                                                fit: BoxFit.cover,
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                                  width: MediaQuery.of(context).size.width /
                                                      8,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      4,
                                                  child: Text(
                                                      Store.getInitials(_con
                                                          .searchedStores[index]
                                                          .shopName),
                                                      style: TextStyle(
                                                          fontSize: 45,
                                                          color: Color(0xffe93b4d)))),
                                            ),
                                          )),
                                      flex: 1,
                                    ),
                                    SizedBox(width: 10),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                            child: Text(
                                                _con.searchedStores[index]
                                                            .shopName !=
                                                        null
                                                    ? _con.searchedStores[index]
                                                        .shopName
                                                    : "Shop Name Not Available",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                    color: Colors.black)),
                                          ),
                                          Container(
                                            // padding: EdgeInsets.all(10),
                                            // fit: FlexFit.tight,
                                            // flex: 2,
                                            child: Text(
                                              _con.searchedStores[index]
                                                          .customerCount !=
                                                      null
                                                  ? _con.searchedStores[index]
                                                          .customerCount
                                                          .toString() +
                                                      " Shapper" +
                                                      (_con.searchedStores[index]
                                                                  .customerCount !=
                                                              1
                                                          ? "s"
                                                          : "")
                                                  : "No Shappers",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15,
                                                  color: Color(0xffe62136)),
                                            ),
                                          ),
                                          // SizedBox(
                                          //   height: MediaQuery.of(context).size.height /
                                          //       (_con.searchedStores[index].shopCate.length * 3.2),
                                          // ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Flexible(
                                                fit: FlexFit.tight,
                                                flex: 2,
                                                child: Container(
                                                    // padding: EdgeInsets.all(10),
                                                    child: Text(
                                                        _con
                                                                    .searchedStores[
                                                                        index]
                                                                    .shopCate !=
                                                                null
                                                            ? _con
                                                                    .searchedStores[
                                                                        index]
                                                                    .shopCate +
                                                                "            "
                                                            : "",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 12)),
                                                    alignment:
                                                        Alignment.centerLeft),
                                              ),
                                              Flexible(
                                                // padding: EdgeInsets.all(10),
                                                fit: FlexFit.tight,
                                                flex: 2,
                                                child: Container(
                                                    child: Text(
                                                        _con
                                                                    .searchedStores[
                                                                        index]
                                                                    .shopArea !=
                                                                null
                                                            ? _con
                                                                    .searchedStores[
                                                                        index]
                                                                    .shopArea +
                                                                "            "
                                                            : "",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 12)),
                                                    alignment:
                                                        Alignment.centerLeft),
                                              )
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Flexible(
                                                // padding: EdgeInsets.all(10),
                                                fit: FlexFit.tight,
                                                flex: 2,
                                                child: Container(
                                                    child: Text(
                                                        _con
                                                                    .searchedStores[
                                                                        index]
                                                                    .productCount !=
                                                                null
                                                            ? _con
                                                                    .searchedStores[
                                                                        index]
                                                                    .productCount
                                                                    .toString() +
                                                                " Items               "
                                                            : "No Items to Show",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffe62136),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 10)),
                                                    alignment:
                                                        Alignment.centerLeft),
                                              ),
                                              Flexible(
                                                // padding: EdgeInsets.all(10),
                                                fit: FlexFit.tight,
                                                flex: 2,
                                                child: Container(
                                                    child: Text(
                                                        _con
                                                                    .searchedStores[
                                                                        index]
                                                                    .deliveryRadius !=
                                                                null
                                                            ? _con
                                                                    .searchedStores[
                                                                        index]
                                                                    .deliveryRadius
                                                                    .toString() +
                                                                "KM                        "
                                                            : "Delivery Radius Data Unavailable",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffe62136),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 10)),
                                                    alignment:
                                                        Alignment.centerLeft),
                                              )
                                            ],
                                          )
                                        ],mainAxisAlignment: MainAxisAlignment.spaceBetween
                                      ),
                                      flex: 2,
                                    )
                                  ],
                                )),
                            onTap: () => Navigator.of(context).pushNamed(
                                "/store",
                                arguments: RouteArgument(
                                    param: _con.searchedStores[index],
                                    id: _con.searchedStores[index].shopID
                                        .toString())),
                          ),
                          visible: _con.searchedStores[index].shopID != null),
                      itemCount: _con.searchedStores.length)),
              visible: _con.searchedStores == null
                  ? false
                  : (_con.searchedStores.length == 0 ? false : true))
        ],
      ),
    );
  }
}
