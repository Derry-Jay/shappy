import 'my_profile_page.dart';
import 'package:toast/toast.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import '../controller/home_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:qrscan/qrscan.dart' as imgScan;
import 'package:shappy/src/pages/cart_page.dart';
import 'package:shappy/src/pages/home_page.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainAppTabsPage extends StatefulWidget {
  final RouteArgument routeArgument;
  MainAppTabsPage(this.routeArgument);
  MainAppTabsPageState createState() => MainAppTabsPageState();
}

class MainAppTabsPageState extends StateMVC<MainAppTabsPage> {
  String title, val;
  HomeController _con;
  int specificPage, count = 0;
  DateTime currentBackPressTime;
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  MainAppTabsPageState() : super(HomeController()) {
    _con = controller;
  }

  void getData() async {
    final sharedPrefs = await _sharePrefs;
    count = sharedPrefs.containsKey("cartCount")
        ? sharedPrefs.getInt("cartCount")
        : 0;
    // print(count);
  }

  @override
  void initState() {
    specificPage = int.parse(widget.routeArgument.heroTag);
    _con.setData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    title =
        specificPage == 2 ? "My Profile" : (specificPage == 1 ? "Cart" : "");
    getData();
    _con.setData();
    return WillPopScope(
        child: Scaffold(
            resizeToAvoidBottomPadding: false,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
                centerTitle: true,
                title: specificPage != 0
                    ? Text(title)
                    : Container(height: 0, width: 0),
                leadingWidth: MediaQuery.of(context).size.width / 3,
                elevation: 0,
                backgroundColor: Color(0xffe62136),
                leading: specificPage == 0
                    ? GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed("/address",
                            arguments: RouteArgument(
                                param: _con.user,
                                id: _con.user.id.toString())),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 25,
                              top: MediaQuery.of(context).size.height / 100),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on, // add custom icons also
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 100,
                              ),
                              // Expanded(
                              //     child: Text(
                              //   title,
                              //   style: TextStyle(fontSize: 16),
                              // )),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 100,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 15, // add custom icons also
                              ),
                            ],
                          ),
                        ))
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                actions: <Widget>[
                  specificPage == 0
                      ? Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width / 20),
                          child: GestureDetector(
                            onTap: () async {
                              var status = await Permission.camera.status;
                              if (status.isGranted) {
                                val = await imgScan.scan();
                                _con.waitUntilAddFavStore(val, _con.user);
                              } else {
                                _con.getCamPerm();
                                if (status.isGranted) {
                                  val = await imgScan.scan();
                                  _con.waitUntilAddFavStore(val, _con.user);
                                }
                              }
                            }, //,
                            child: Icon(
                              Icons.crop_free,
                              size: 26.0,
                            ),
                          ))
                      : Container(
                          width: 0,
                          height: 0,
                        ),
                ]),
            body: specificPage == 2
                ? MyProfilePage()
                : (specificPage == 1
                    ? CartPage(false)
                    : HomePage(routeArgument: widget.routeArgument)),
            bottomNavigationBar: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Badge(
                        badgeContent: Text(count.toString(),
                            style: TextStyle(color: Colors.white)),
                        child: Icon(Icons.shopping_basket_outlined),
                        showBadge: count != 0),
                    label: 'Cart',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile',
                  ),
                ],
                currentIndex: specificPage,
                selectedItemColor: Color(0xffe62136),
                onTap: (index) => setState(() => specificPage = index),
                unselectedItemColor: Color(0xff707070))),
        onWillPop: backButtonOverride);
  }

  Future<bool> backButtonOverride() async {
    bool flag = true;
    if (specificPage != 0) {
      setState(() {
        specificPage = 0;
        flag = false;
      });
    } else {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        Toast.show("Press Again to Quit", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        setState(() => flag = false);
      } else
        setState(() => flag = true);
    }
    return Future.value(flag);
  }
}
