import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/elements/GridWidget.dart';
import 'package:shappy/src/controller/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shappy/src/elements/FavoriteStoreWidget.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';
import 'package:qrscan/qrscan.dart' as imgScan;

import 'seller_success_page.dart';

class HomePage extends StatefulWidget {
  final RouteArgument routeArgument;
  HomePage({Key key, this.routeArgument}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends StateMVC<HomePage> with TickerProviderStateMixin {
  HomeController _con;
  int selectedIndex = 0;
  List<Widget> listViews = <Widget>[];
  AnimationController animationController;
  static DateTime selectedDate = DateTime.now();
  String date = '${myFormat.format(selectedDate)}';
  static var myFormat = new DateFormat('dd MMMM yyyy');
  TextEditingController tec = new TextEditingController();
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  String val;
  HomePageState() : super(HomeController()) {
    _con = controller;
  }

  void pickSessionData() async {
    final SharedPreferences sharedPrefs = await _sharePrefs;
    await _con.listenForHomeCategories();
    await _con.listenForFavoriteStore();
    if (widget.routeArgument.param) {
      _con.pushNotificationControl({
        "user_ID": widget.routeArgument.id,
        "device_token": sharedPrefs.getString("spDeviceToken"),
        "app_type": "0"
      });
      widget.routeArgument.param = false;
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    pickSessionData();
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
  }

  void navigateTo(String route, RouteArgument arguments) {
    Navigator.pushNamed(context, route, arguments: arguments).then(onGoBack);
  }

  FutureOr onGoBack(dynamic value) {
    setState(refresh);
  }

  String getInitials(String name) => name != null && name != ""
      ? name.trim().split(' ').map((l) => l[0]).take(2).join()
      : '';

  void refresh() async {
    await _con.listenForHomeCategories();
    await _con.listenForFavoriteStore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      backgroundColor: Color(0xffffffff),
      body: Stack(children: <Widget>[
        _con.category == null || _con.favoriteStore == null
            ? CircularLoadingWidget(
                height: 200,
              )
            : SingleChildScrollView(
                child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 30),
                child: Column(children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 20),
                        child: Text(
                          '#VocalforLocal',
                          style: TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffE62337)),
                        ),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  Column(children: [
                    Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 50),
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 20),
                        child: InkWell(
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 10,
                                  child: Container(
                                      child: Text(
                                        "Your Favorite stores",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 15),
                                      ),
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              100))),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                    icon: Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    onPressed: () => navigateTo("/favStores",
                                        RouteArgument(param: _con.user))),
                              )
                            ],
                          ),
                          onTap: () => navigateTo(
                              "/favStores", RouteArgument(param: _con.user)),
                        )),
                    Container(
                        height: MediaQuery.of(context).size.height / 6,
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 80),
                        child: _con.favoriteStore == null
                            ? CircularLoadingWidget(
                                height: 100,
                              )
                            : _con.favoriteStore.length != 0
                                ? FavoriteStoreWidget(
                                    favoriteStoreList: _con.favoriteStore,
                                    heroTag: 'home_store_carousel')
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                    ),
                                    margin: EdgeInsets.all(15),
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Add Your First Favourite Store',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff000000)),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                80),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              30,
                                          child: RaisedButton(
                                            color: Color(0xffE62337),
                                            onPressed: () async {
                                              var status = await Permission
                                                  .camera.status;
                                              if (status.isGranted) {
                                                val = await imgScan.scan();
                                                _con.waitUntilAddFavStore(
                                                    val, _con.user);
                                              } else {
                                                _con.getCamPerm();
                                                if (status.isGranted) {
                                                  val = await imgScan.scan();
                                                  _con.waitUntilAddFavStore(
                                                      val, _con.user);
                                                }
                                              }
                                            },
                                            child: Text('Scan',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white)),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                  ]),
                  InkWell(
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height / 16,
                            horizontal:
                                MediaQuery.of(context).size.width / 12.8),
                        width: MediaQuery.of(context).size.width / 1.048576,
                        height: MediaQuery.of(context).size.height / 6,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/img/Group 9751.png'),
                                fit: BoxFit.fill)),
                        child: Text("Become a seller",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 22))),
                    onTap: () => Navigator.of(context).pushNamed(
                        '/seller' +
                            (_con.user.shopRequestSentStatus
                                ? 'Success'
                                : 'Confirm'),
                        arguments: _con.user.shopRequestSentStatus
                            ? null
                            : RouteArgument(param: _con.user.toMap())),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: _con.category.length != 0
                        ? GridWidget(
                            categoryList: _con.category,
                            heroTag: 'home_category',
                          )
                        : CircularLoadingWidget(
                            height: 60,
                          ),
                  )
                ]),
              )),
        Container(
          width: double.infinity,
          height: 40.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(28.0),
              bottomLeft: Radius.circular(28.0),
            ),
            color: const Color(0xffe62136),
            boxShadow: [
              BoxShadow(
                color: const Color(0x29000000),
                offset: Offset(0, 2),
                blurRadius: 15,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 20,
              top: 10.0,
              right: MediaQuery.of(context).size.width / 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: const Color(0xffffffff)),
          child: TextField(
              onTap: () => navigateTo("/searchStore", null),
              onChanged: (pattern) => print(pattern),
              style: TextStyle(
                color: Colors.black,
              ),
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.all(12),
                hintText: 'Search your store',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.2)),
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.black.withOpacity(0.2))),
              ),
              controller: tec),
        ),
      ]),
    );
  }
}
