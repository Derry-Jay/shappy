import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/controller/home_controller.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';
import 'package:shappy/src/models/favoritestore.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/models/store.dart';
import 'package:qrscan/qrscan.dart';
import 'package:permission_handler/permission_handler.dart';

class FavoriteStoresPage extends StatefulWidget {
  @override
  FavoriteStoresPageState createState() => FavoriteStoresPageState();
}

class FavoriteStoresPageState extends StateMVC<FavoriteStoresPage> {
  HomeController _con;
  String val = "";
  FavoriteStoresPageState() : super(HomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForFavoriteStore();
    super.initState();
  }

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
              "My Favourite Stores",
              style: TextStyle(fontSize: 25),
            ),
            leading: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Color(0xffe62136)),
        body: Column(children: [
          Container(
              decoration: BoxDecoration(
                  color: Color(0xffe62136),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              padding: EdgeInsets.all(10)),
          Expanded(
              child: Container(
            child: buildList(_con.favoriteStore),
          ))
        ]),
        backgroundColor: Color(0xffffffff));
  }

  Widget buildList(List<FavoriteStore> sl) => sl == null
      ? CircularLoadingWidget(
          height: MediaQuery.of(context).size.height,
        )
      : (sl.isEmpty
          ? InkWell(
              onTap: () async {
                var status = await Permission.camera.status;
                if (status.isGranted) {
                  val = await scan();
                  _con.waitUntilAddFavStore(val, _con.user);
                } else {
                  _con.getCamPerm();
                  if (status.isGranted) {
                    val = await scan();
                    _con.waitUntilAddFavStore(val, _con.user);
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/img/empty_fav_store.png"))),
              ),
            )
          : ListView.builder(
              itemCount: sl.length,
              itemBuilder: (BuildContext context, int index) {
                if (!sl.contains(null) && sl != null && sl.isNotEmpty) {
                  return InkWell(
                      child: Container(
                          color: Color(0xffffffff),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            MediaQuery.of(context).size.height /
                                                80,
                                        horizontal:
                                            MediaQuery.of(context).size.width /
                                                80),
                                    margin: EdgeInsets.only(
                                        left: MediaQuery.of(context).size.width /
                                            25,
                                        right:
                                            MediaQuery.of(context).size.width /
                                                25,
                                        top: MediaQuery.of(context).size.height /
                                            50),
                                    width:
                                        MediaQuery.of(context).size.width / 5,
                                    height:
                                        MediaQuery.of(context).size.height / 8,
                                    decoration: BoxDecoration(
                                      color: Color(0xfffceaea),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      border: Border.all(
                                        color: Color(0xfff8cdcd),
                                        style: BorderStyle.solid,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Text(getInitials(sl[index].name),
                                        style: TextStyle(
                                            fontSize: 45,
                                            color: Color(0xffe93b4d)))),
                                flex: 1,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 60),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                        children: [
                                          Container(
                                            child: Text(
                                                sl[index].name != null
                                                    ? sl[index].name
                                                    : "Shop Name Not Available",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14.078,
                                                    color: Colors.black),
                                                textAlign: TextAlign.left),
                                            // padding: EdgeInsets.all(10)
                                          ),
                                          IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Color(0xffd4d4d4),
                                                  size: 20),
                                              onPressed: () =>
                                                  _showDialog(sl[index].favId))
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween),
                                    Container(
                                      child: Text(
                                        sl[index].customerCount != null
                                            ? sl[index].customerCount +
                                                " Shapper" +
                                                (int.parse(sl[index]
                                                            .customerCount) !=
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
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              40,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 2,
                                          child: Container(
                                              // padding: EdgeInsets.all(10),
                                              child: Text(
                                                  sl[index].shopCat != null
                                                      ? sl[index].shopCat
                                                      : "",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12)),
                                              alignment: Alignment.centerLeft),
                                        ),
                                        Flexible(
                                          // padding: EdgeInsets.all(10),
                                          fit: FlexFit.tight,
                                          flex: 2,
                                          child: Container(
                                              child: Text(
                                                  sl[index].area != null
                                                      ? sl[index].area
                                                      : "",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12)),
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
                                            // padding: EdgeInsets.all(10),
                                              child: Text(
                                                  sl[index].productCount != null
                                                      ? sl[index]
                                                              .productCount
                                                              .toString() +
                                                          " Item" +
                                                          (int.parse(sl[index]
                                                                      .productCount) !=
                                                                  1
                                                              ? "s"
                                                              : "")
                                                      : "No Items to Show",
                                                  style: TextStyle(
                                                      color: Color(0xffe62136),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 10)),
                                              alignment: Alignment.centerLeft),
                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 2,
                                          child: Container(
                                            // padding: EdgeInsets.all(10),
                                              child: Text(
                                                  sl[index].deliveryRadius !=
                                                          null
                                                      ? sl[index]
                                                              .deliveryRadius
                                                              .toString() +
                                                          "KM"
                                                      : "Delivery Radius Data Unavailable",
                                                  style: TextStyle(
                                                      color: Color(0xffe62136),
                                                      fontWeight:
                                                          FontWeight.w500,
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
                              id: sl[index].id,
                              param: Store.fromMap(sl[index].toMap()))));
                } else {
                  return CircularLoadingWidget(height: 100);
                }
              }));

  void _showDialog(String id) async {
    await showDialog<String>(
      context: context,
      child: _SystemPadding(
        child: new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new Text("Confirm Favourite Store Removal"),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text(
                  'No',
                  style: TextStyle(color: Color(0xffe62136)),
                ),
                onPressed: () => Navigator.pop(context)),
            new FlatButton(
                onPressed: () => _con.waitUntilRemoveFavStore(id),
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Color(0xffe62136)),
                ))
          ],
        ),
      ),
    );
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AnimatedContainer(
        duration: const Duration(milliseconds: 300), child: child);
  }
}
