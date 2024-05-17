import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/route_argument.dart';
import '../models/store.dart';
import '../controller/store_controller.dart';

class SearchCategoryStorePage extends StatefulWidget {
  final RouteArgument rar;
  SearchCategoryStorePage(this.rar);
  @override
  SearchCategoryStorePageState createState() => SearchCategoryStorePageState();
}

class SearchCategoryStorePageState extends StateMVC<SearchCategoryStorePage> {
  StoreController _con;
  TextEditingController kc = new TextEditingController();
  SearchCategoryStorePageState() : super(StoreController()) {
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
            onPressed: () => Navigator.pop(context),
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
                    onChanged: (str) =>
                        _con.waitForSearchedStoresBasedOnCategory(
                            str, int.parse(widget.rar.id)),
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
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                MediaQuery.of(context).size.height /
                                                    double.infinity,
                                            horizontal:
                                                MediaQuery.of(context).size.width /
                                                    double.infinity),
                                        height: MediaQuery.of(context).size.height /
                                            8,
                                        width: MediaQuery.of(context).size.width /
                                            4,
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
                                        child: Text(
                                            Store.getInitials(_con
                                                .searchedStores[index]
                                                .shopName),
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Color(0xffe62136)))),
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
                                                      ? _con
                                                          .searchedStores[index]
                                                          .shopName
                                                      : "Shop Name Not Available",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 18,
                                                      color: Colors.black)),
                                            ),
                                            // Container(
                                            //   child: Text(
                                            //     _con.searchedStores[index]
                                            //                 .shopCate !=
                                            //             null
                                            //         ? _con.searchedStores[index]
                                            //             .shopCate
                                            //         : "",
                                            //     style: TextStyle(
                                            //         fontWeight: FontWeight.w400,
                                            //         fontSize: 15,
                                            //         color: Color(0xffe62136)),
                                            //   ),
                                            // ),
                                            Container(
                                                child: Text(
                                                    _con.searchedStores[index]
                                                                .shopArea !=
                                                            null
                                                        ? _con
                                                            .searchedStores[
                                                                index]
                                                            .shopArea
                                                        : "",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xffe62136),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 10)),
                                                padding: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        35))
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround),
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
                  : _con.searchedStores.isNotEmpty)
        ],
      ),
    );
  }
}
