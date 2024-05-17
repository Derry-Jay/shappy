import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shappy/src/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/models/address.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/controller/user_controller.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';

class AddressesPage extends StatefulWidget {
  final RouteArgument routeArgument;
  AddressesPage({Key key, this.routeArgument}) : super(key: key);
  @override
  State<StatefulWidget> createState() => AddressesPageState();
}

class AddressesPageState extends StateMVC<AddressesPage> {
  User user;
  UserController _con;
  AddressesPageState() : super(UserController()) {
    _con = controller;
  }

  void pickData() async {
    user = widget.routeArgument.param;
    await _con.waitForAddresses(user);
  }

  void navigateTo(String route, RouteArgument arguments) {
    Navigator.pushNamed(context, route, arguments: arguments).then(onGoBack);
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      pickData();
    });
  }

  @override
  void initState() {
    pickData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => navigateTo('/addAndEditAddress', null),
          child: Icon(
            Icons.add,
            color: Colors.white,
            semanticLabel: "Add",
          ),
          backgroundColor: Color(0xffe62136),
        ),
        backgroundColor: Color(0xffffffff),
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xffe62136),
            centerTitle: true,
            title: Text("Addresses"),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Container(
              decoration: BoxDecoration(
                  color: Color(0xffe62136),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 80)),
          _con.addresses == null
              ? CircularLoadingWidget(
                  height: MediaQuery.of(context).size.height / 2,
                )
              : Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (Address add in _con.addresses)
                            InkWell(
                                child: Card(
                                    elevation: 0,
                                    child: Container(
                                        padding: EdgeInsets.all(sqrt(
                                            (pow(MediaQuery.of(context).size.height, 2) +
                                                pow(MediaQuery.of(context).size.width, 2)) /
                                                4096)),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                  children: [
                                                    Text(
                                                        "Address #" +
                                                            (_con.addresses
                                                                        .indexOf(
                                                                            add) +
                                                                    1)
                                                                .toString(),
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffe62136),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Container(
                                                        child: PopupMenuButton<
                                                            String>(
                                                          onSelected: (str) => str ==
                                                                  'Delete'
                                                              ? _showDialog(
                                                                  add.id)
                                                              : navigateTo(
                                                                  '/addAndEditAddress',
                                                                  RouteArgument(
                                                                      param:
                                                                          add,
                                                                      heroTag: add
                                                                          .addressType
                                                                          .toString(),
                                                                      id: add.id
                                                                          .toString())),
                                                          itemBuilder:
                                                              (BuildContext
                                                                  context) {
                                                            return {
                                                              'Edit',
                                                              'Delete'
                                                            }.map((String
                                                                choice) {
                                                              return PopupMenuItem<
                                                                  String>(
                                                                value: choice,
                                                                child: Text(
                                                                    choice),
                                                              );
                                                            }).toList();
                                                          },
                                                        ),
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            30,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            10)
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween),
                                              // SizedBox(
                                              //     height: MediaQuery.of(context)
                                              //             .size
                                              //             .height /
                                              //         100),
                                              Text(add.getAddress(add),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500))
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween),
                                        width: double.infinity,
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
                                                        6400)))))),
                                onTap: () => _con.waitUntilSetAddress(
                                    int.parse(widget.routeArgument.id), add.id))
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 50,
                          vertical: MediaQuery.of(context).size.height / 50)))
        ]));
  }

  void _showDialog(int id) async {
    await showDialog<String>(
      context: context,
      child: _SystemPadding(
        child: new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new Text("Confirm Address Removal"),
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
                onPressed: () async =>
                    await _con.waitUntilDeleteAddress(user.id, id),
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
