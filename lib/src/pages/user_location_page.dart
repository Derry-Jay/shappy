import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/controller/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/models/user.dart';
import 'package:location/location.dart';

class UserLocationPage extends StatefulWidget {
  final RouteArgument routeArgument;
  UserLocationPage({Key key, this.routeArgument}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return UserLocationPageState();
  }
}

class UserLocationPageState extends StateMVC<UserLocationPage> {
  LatLng currentPosition;
  bool isGpsEnabled = false, visible;
  String lat = "", long = "", pinCode = "";
  UserController _con;
  BitmapDescriptor destIcon;
  TextEditingController addCon = new TextEditingController();
  TextEditingController areaCon = new TextEditingController();
  TextEditingController lamaCon = new TextEditingController();
  TextEditingController doorNoCon = new TextEditingController();
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  UserLocationPageState() : super(UserController()) {
    _con = controller;
  }

  Future checkGpsAndGetUserLocation() async {
    final location = Location();
    if (!await location.serviceEnabled()) {
      location.requestService();
      var position = await Geolocator().getCurrentPosition();
      setState(() =>
          currentPosition = LatLng(position.latitude, position.longitude));
    } else if (await location.serviceEnabled()) {
      var position = await Geolocator().getCurrentPosition();
      setState(() =>
          currentPosition = LatLng(position.latitude, position.longitude));
    }
  }

  void setData() async {
    final SharedPreferences sharedPrefs = await _sharePrefs;
    destIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(50, 50)), 'assets/img/lmk.png');
    _con.user =
        widget.routeArgument.param is User && widget.routeArgument.param != null
            ? widget.routeArgument.param
            : User();
    _con.user.id = int.parse(widget.routeArgument.id);
    _con.user.phone = sharedPrefs.getString("phone");
  }

  @override
  void initState() {
    checkGpsAndGetUserLocation();
    setData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          currentPosition == null
              ? CircularLoadingWidget(
                  height: 100,
                )
              : Container(
                  child: GoogleMap(
                  gestureRecognizers: Set()
                    ..add(Factory<EagerGestureRecognizer>(
                        () => EagerGestureRecognizer())),
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: currentPosition,
                    zoom: 17.0,
                  ),
                  markers: _con.allMarkers,
                  onMapCreated: (GoogleMapController controller) {
                    _con.mapController.complete(controller);
                  },
                  onCameraMove: (CameraPosition cameraPosition) {
                    _con.cameraPosition = cameraPosition;
                    print(cameraPosition.target);
                  },
                  onTap: (ltLn) async {
                    setState(() => _con.allMarkers.add(Marker(
                        markerId: MarkerId("user_address"),
                        icon: destIcon,
                        position: ltLn,
                        draggable: true)));
                    print(ltLn);
                    var addresses = await Geocoder.local
                        .findAddressesFromCoordinates(
                            Coordinates(ltLn.latitude, ltLn.longitude));
                    print(addresses.first.toMap());
                    var first = addresses.first;
                    pinCode = first.postalCode;
                    addCon.text = first.addressLine;
                    // doorNoCon.text = first.featureName;
                    areaCon.text = first.subLocality;
                    // lamaCon.text = first.featureName;
                    lat = ltLn.latitude.toString();
                    long = ltLn.longitude.toString();
                  },
                  polylines: _con.polyLines,
                )),
          Column(
            children: [
              Flexible(
                  child: Container(
                      child: Form(
                        key: _con.loginFormKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Add Address",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2
                                    .merge(TextStyle(
                                        color: Theme.of(context).accentColor)),
                              ),
                              TextFormField(
                                controller: doorNoCon,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context).nextFocus();
                                },
                                validator: (input) => input.length == 0
                                    ? "Enter the door no, minimum 1 character"
                                    : null,
                                decoration: InputDecoration(
                                    labelText: "Door No",
                                    labelStyle: TextStyle(
                                        color: Theme.of(context).accentColor),
                                    contentPadding: EdgeInsets.all(12)),
                              ),
                              TextFormField(
                                controller: addCon,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context).nextFocus();
                                },
                                validator: (input) => input.length < 3
                                    ? "Enter the street name,minimum 3 character"
                                    : null,
                                decoration: InputDecoration(
                                    labelText: "Address",
                                    labelStyle: TextStyle(
                                        color: Theme.of(context).accentColor),
                                    contentPadding: EdgeInsets.all(12)),
                              ),
                              TextFormField(
                                controller: areaCon,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                onFieldSubmitted: (v) {},
                                validator: (input) => input.length < 3
                                    ? "Enter the area, minimum 3 character"
                                    : null,
                                decoration: InputDecoration(
                                    labelText: "Area",
                                    labelStyle: TextStyle(
                                        color: Theme.of(context).accentColor),
                                    contentPadding: EdgeInsets.all(12)),
                              ),
                              TextFormField(
                                controller: lamaCon,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context).nextFocus();
                                },
                                validator: (input) => input.length < 3
                                    ? "Enter the landmark,minimum 3 character"
                                    : null,
                                decoration: InputDecoration(
                                    labelText: "Landmark",
                                    labelStyle: TextStyle(
                                        color: Theme.of(context).accentColor),
                                    contentPadding: EdgeInsets.all(12)),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height /
                                        80),
                                child: RaisedButton(
                                    textColor: Colors.white,
                                    color: Color(0xffe62136),
                                    child: Text('SAVE'),
                                    onPressed: () async {
                                      final SharedPreferences sharedPrefs =
                                          await _sharePrefs;
                                      Map<String, dynamic> body = {
                                        "user_ID": _con.user.id.toString(),
                                        "address_ID":
                                            sharedPrefs.getString("spAddID"),
                                        "username": _con.user.name,
                                        "user_Email": _con.user.email,
                                        "api_token": _con.user.apiToken,
                                        "plot_house_no": doorNoCon.text,
                                        "cus_address": addCon.text,
                                        "area": areaCon.text,
                                        "landmark": lamaCon.text,
                                        "cus_lat": lat,
                                        "cus_lon": long
                                      };
                                      _con.waitForUserRegister(body);
                                    }),
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height / 15,
                              )
                            ],
                          ),
                        ),
                      ),
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height / 2.1,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 25,
                          vertical: MediaQuery.of(context).size.height / 37)))
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        ],
      ),
    );
  }
}
