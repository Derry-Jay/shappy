import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shappy/src/controller/user_controller.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';

class MyProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyProfilePageState();
}

class MyProfilePageState extends StateMVC<MyProfilePage> {
  UserController _con;
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  MyProfilePageState() : super(UserController()) {
    _con = controller;
  }

  void navigateTo(String route, RouteArgument arguments) {
    Navigator.pushNamed(context, route, arguments: arguments).then(onGoBack);
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      _con.waitForUserData();
    });
  }

  @override
  void initState() {
    _con.waitForUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                  color: Color(0xffe62136),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              padding: EdgeInsets.all(sqrt(
                  (pow(MediaQuery.of(context).size.height, 2) +
                          pow(MediaQuery.of(context).size.width, 2)) /
                      10000))),
          _con.userData == null
              ? CircularLoadingWidget(
                  height: MediaQuery.of(context).size.height / 1.5)
              : Expanded(
                  child: SingleChildScrollView(
                  padding: EdgeInsets.all(sqrt(
                      (pow(MediaQuery.of(context).size.height, 2) +
                              pow(MediaQuery.of(context).size.width, 2)) /
                          1600)),
                  child: Column(
                    children: [
                      Card(
                          color: Color(0xffffffff),
                          elevation: 0,
                          child: Container(
                              child: Row(children: [
                                CircleAvatar(
                                  radius: sqrt((pow(
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              2) +
                                          pow(MediaQuery.of(context).size.width,
                                              2)) /
                                      400),
                                  backgroundImage: NetworkImage(
                                      "https://shappyfiles.s3.ap-south-1.amazonaws.com/productImages/1606815991699-%5Bobject%20Object%5D"),
                                ),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 25),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          _con.userData.name != null
                                              ? _con.userData.name
                                              : "",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Color(0xffe62136),
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                          _con.userData.phone != null
                                              ? _con.userData.phone
                                              : "",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w500
                                          )),
                                      Text(
                                          _con.userData.email != null
                                              ? _con.userData.email
                                              : "",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w500
                                          ),
                                          maxLines: 3),
                                      InkWell(
                                          onTap: () => navigateTo(
                                              '/personalInfoEdit',
                                              RouteArgument(
                                                  id: _con.userData.id
                                                      .toString(),
                                                  param: _con.userData)),
                                          child: Text("Edit")),
                                    ]),
                              ], mainAxisAlignment: MainAxisAlignment.start),
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height / 40,
                                  horizontal:
                                      MediaQuery.of(context).size.width / 20))),
                      Card(
                          elevation: 0,
                          child: InkWell(
                              child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.location_on_outlined,
                                            color: Color(0xffed606e)),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20),
                                        Text("Manage Address",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500))
                                      ]),
                                      Icon(Icons.arrow_forward_ios_outlined,
                                          size: 10)
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(sqrt(
                                              (pow(MediaQuery.of(context).size.height, 2) +
                                                      pow(
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                          2)) /
                                                  6400)))),
                                  padding: EdgeInsets.all(sqrt((pow(
                                              MediaQuery.of(context).size.height,
                                              2) +
                                          pow(MediaQuery.of(context).size.width, 2)) /
                                      10000))),
                              onTap: () async {
                                final SharedPreferences sharedPrefs =
                                    await _sharePrefs;
                                _con.userData.apiToken =
                                    sharedPrefs.getString("apiToken");
                                Navigator.of(context).pushNamed("/address",
                                    arguments: RouteArgument(
                                        id: _con.userData.id.toString(),
                                        param: _con.userData));
                              })),
                      Card(
                          elevation: 0,
                          child: InkWell(
                              child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.auto_awesome_motion,
                                            color: Color(0xffed606e)),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20),
                                        Text("My Orders",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500))
                                      ]),
                                      Icon(Icons.arrow_forward_ios_outlined,
                                          size: 10)
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(sqrt((pow(
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height,
                                                      2) +
                                                  pow(
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      2)) /
                                              6400)))),
                                  padding: EdgeInsets.all(sqrt((pow(
                                      MediaQuery.of(context).size.height,
                                      2) +
                                      pow(MediaQuery.of(context).size.width, 2)) /
                                      10000))),
                              onTap: () async {
                                final SharedPreferences sharedPrefs =
                                    await _sharePrefs;
                                setState(() => _con.userData.apiToken =
                                    sharedPrefs.getString("apiToken"));
                                Navigator.of(context).pushNamed("/orders",
                                    arguments: RouteArgument(
                                        id: _con.userData.id.toString(),
                                        param: _con.userData));
                              })),
                      Card(
                          elevation: 0,
                          child: InkWell(
                              child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.store,
                                              color: Color(0xffed606e)),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  20),
                                          Text("My Favourite Stores",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500))
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios_outlined,
                                          size: 10)
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(sqrt((pow(
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              2) +
                                              pow(
                                                  MediaQuery.of(
                                                      context)
                                                      .size
                                                      .width,
                                                  2)) /
                                              6400)))),
                                  padding: EdgeInsets.all(sqrt((pow(
                                      MediaQuery.of(context).size.height,
                                      2) +
                                      pow(MediaQuery.of(context).size.width, 2)) /
                                      10000))),
                              onTap: () => Navigator.of(context)
                                  .pushNamed("/favStores"))),
                      Card(
                          elevation: 0,
                          child: InkWell(
                              child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.help_outline_outlined,
                                            color: Color(0xffed606e)),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20),
                                        Text("Faq & Support",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500))
                                      ]),
                                      Icon(Icons.arrow_forward_ios_outlined,
                                          size: 10)
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(sqrt((pow(
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              2) +
                                              pow(
                                                  MediaQuery.of(
                                                      context)
                                                      .size
                                                      .width,
                                                  2)) /
                                              6400)))),
                                  padding: EdgeInsets.all(sqrt((pow(
                                      MediaQuery.of(context).size.height,
                                      2) +
                                      pow(MediaQuery.of(context).size.width, 2)) /
                                      10000))),
                              onTap: () =>
                                  Navigator.of(context).pushNamed("/Faq"))),
                      Card(
                          elevation: 0,
                          child: InkWell(
                              child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Icon(Icons.exit_to_app_outlined,
                                            color: Color(0xffed606e)),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20),
                                        Text("Logout",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500))
                                      ]),
                                      Icon(Icons.arrow_forward_ios_outlined,
                                          size: 10)
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(sqrt((pow(
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              2) +
                                              pow(
                                                  MediaQuery.of(
                                                      context)
                                                      .size
                                                      .width,
                                                  2)) /
                                              6400)))),
                                  padding: EdgeInsets.all(sqrt((pow(
                                      MediaQuery.of(context).size.height,
                                      2) +
                                      pow(MediaQuery.of(context).size.width, 2)) /
                                      10000))),
                              onTap: _showDialog))
                    ],
                  ),
                ))
        ],
      ),
    );
  }

  void _showDialog() async {
    await showDialog<String>(
      context: context,
      child: _SystemPadding(
        child: new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new Text("Are You sure to Logout?"),
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
                onPressed: () async {
                  final SharedPreferences sharedPrefs = await _sharePrefs;
                  for (String key in sharedPrefs.getKeys())
                    if (key != "spDeviceToken" &&
                        key != "defaultDeliveryAddressID") {
                      final r = await sharedPrefs.remove(key);
                      if (r) print("Removed");
                    }
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      "/Login", (Route<dynamic> route) => false);
                },
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
