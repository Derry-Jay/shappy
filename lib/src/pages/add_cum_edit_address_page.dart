import 'dart:async';

import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shappy/src/controller/user_controller.dart';
import 'package:shappy/src/elements/CircularLoadingWidget.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class AddAndEditAddressPage extends StatefulWidget {
  final RouteArgument rar;
  AddAndEditAddressPage(this.rar);
  @override
  AddAndEditAddressPageState createState() => AddAndEditAddressPageState();
}

class AddAndEditAddressPageState extends StateMVC<AddAndEditAddressPage> {
  Location location = Location();
  LatLng currentPosition;
  GoogleMapController mapController;
  String lat, long;
  UserController _con;
  BitmapDescriptor destIcon;
  final _formKey = GlobalKey<FormState>();
  TextEditingController addCon = new TextEditingController();
  TextEditingController areaController = new TextEditingController();
  TextEditingController doorNoController = new TextEditingController();
  TextEditingController pinCodeController = new TextEditingController();
  TextEditingController landmarkController = new TextEditingController();
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  AddAndEditAddressPageState() : super(UserController()) {
    _con = controller;
  }

  Future getUserLocation() async {
    if (!await location.serviceEnabled()) {
      location.requestService();
      var position = await Geolocator().getCurrentPosition();
      lat = position.latitude.toString();
      long = position.longitude.toString();
      setState(() =>
          currentPosition = LatLng(position.latitude, position.longitude));
    } else if (await location.serviceEnabled()) {
      var position = await Geolocator().getCurrentPosition();
      lat = position.latitude.toString();
      long = position.longitude.toString();
      setState(() =>
          currentPosition = LatLng(position.latitude, position.longitude));
    }
  }

  void setData() async {
    final geoLocator = Geolocator();
    final flag = await geoLocator.checkGeolocationPermissionStatus();
    print(flag);
    destIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(50, 50)), 'assets/img/lmk.png');
    if (widget.rar != null) {
      final position = await geoLocator.getCurrentPosition();
      lat = widget.rar.param.latitude != null
          ? widget.rar.param.latitude.toString()
          : position.latitude.toString();
      long = widget.rar.param.longitude != null
          ? widget.rar.param.longitude.toString()
          : position.longitude.toString();
      pinCodeController.text = widget.rar.param.pinCode;
      addCon.text = widget.rar.param.addressLine;
      doorNoController.text = widget.rar.param.doorNo.toString();
      areaController.text = widget.rar.param.area;
      setState(() =>
          currentPosition = LatLng(double.parse(lat), double.parse(long)));
    } else {
      final position = await geoLocator.getCurrentPosition();
      setState(() =>
          currentPosition = LatLng(position.latitude, position.longitude));
      lat = position.latitude.toString();
      long = position.longitude.toString();
      final addresses = await Geocoder.local.findAddressesFromCoordinates(
          Coordinates(double.parse(lat), double.parse(long)));
      final first = addresses.first;
      pinCodeController.text = first.postalCode;
      addCon.text = first.addressLine;
      areaController.text = first.subLocality;
    }
    setState(() => _con.allMarkers.add(Marker(
        markerId: MarkerId("destPin"),
        position: currentPosition,
        icon: destIcon,
        draggable: true)));
  }

  void _onMapCreated(GoogleMapController controller) {
    _con.mapController.complete(controller);
    print("Hi");
  }

  void setDestPin(LatLng ao) async {
    destIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(50, 50)), 'assets/img/lmk.png');
    var addresses = await Geocoder.local
        .findAddressesFromCoordinates(Coordinates(ao.latitude, ao.longitude));
    var first = addresses.first;
    pinCodeController.text = first.postalCode;
    addCon.text = first.addressLine;
    // doorNoController.text = first.featureName;
    areaController.text = first.subLocality;
    lat = ao.latitude.toString();
    long = ao.longitude.toString();
    setState(() {
      currentPosition = ao;
      _con.allMarkers.add(Marker(
          // onDragEnd: setDestPin,
          markerId: MarkerId("destPin"),
          position: ao,
          icon: destIcon,
          draggable: true));
    });
  }

  @override
  void initState() {
    getUserLocation();
    setData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text("Add Location"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context))),
      body: Stack(
        children: [
          currentPosition == null
              ? CircularLoadingWidget(
                  height: MediaQuery.of(context).size.height,
                )
              : GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: true,
                  mapType: MapType.normal,
                  markers: _con.allMarkers,
                  compassEnabled: true,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition:
                      CameraPosition(target: currentPosition, zoom: 13.0),
                  onTap: setDestPin),
          Column(children: [
            Container(
                decoration: BoxDecoration(
                    color: Color(0xffe62136),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                padding: EdgeInsets.all(15)),
            Flexible(
                child: Container(
              color: Colors.white,
              child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: doorNoController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onSaved: (str) => doorNoController.text = str,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your Door No';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Door No',
                            ),
                          ),
                          TextFormField(
                            controller: addCon,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onSaved: (str) => doorNoController.text = str,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your Address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Address Line',
                            ),
                          ),
                          TextFormField(
                            controller: areaController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onSaved: (str) => areaController.text = str,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your area';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Area',
                            ),
                          ),
                          TextFormField(
                            controller: pinCodeController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onSaved: (str) => pinCodeController.text = str,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your Pin Code';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Pin Code',
                            ),
                          ),
                          TextFormField(
                            controller: landmarkController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            onSaved: (str) => landmarkController.text = str,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your landmark';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Landmark',
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 80),
                            child: RaisedButton(
                                textColor: Colors.white,
                                color: Color(0xffe62136),
                                child: Text('SAVE'),
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    final sharedPrefs = await _sharePrefs;
                                    Map<String, dynamic> body = {
                                      "user_ID":
                                          sharedPrefs.getString("spUserID"),
                                      "plot_house_no": doorNoController.text,
                                      "area": areaController.text,
                                      "landmark": landmarkController.text,
                                      "cus_pincode": pinCodeController.text,
                                      "cus_address": addCon.text,
                                      "cus_lat": lat != null ? lat : "",
                                      "cus_lon": long != null ? long : ""
                                    };
                                    if (widget.rar == null)
                                      _con.waitUntilAddAddress(body);
                                    else {
                                      body["address_ID"] = widget.rar.id;
                                      _con.waitUntilUpdateLocation(body);
                                    }
                                  } else {
                                    print('Error');
                                  }
                                }),
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 15,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 25,
                          vertical: MediaQuery.of(context).size.height / 37))),
              height: MediaQuery.of(context).size.height / 2.1,
            ))
          ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
        ],
        alignment: Alignment.topRight,
      ),
    );
  }
}
