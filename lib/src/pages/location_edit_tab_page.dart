import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/controller/user_controller.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/models/address.dart' as Add;
import 'package:shared_preferences/shared_preferences.dart';

class LocationEditTabPage extends StatefulWidget {
  final RouteArgument rar;
  LocationEditTabPage(this.rar);
  @override
  LocationEditTabPageState createState() => LocationEditTabPageState();
}

class LocationEditTabPageState extends StateMVC<LocationEditTabPage> {
  Add.Address address;
  String lat, long;
  UserController _con;
  BitmapDescriptor destIcon;
  final _formKey = GlobalKey<FormState>();
  TextEditingController areaController = new TextEditingController();
  TextEditingController doorNoController = new TextEditingController();
  TextEditingController pinCodeController = new TextEditingController();
  TextEditingController landmarkController = new TextEditingController();
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  LocationEditTabPageState() : super(UserController()) {
    _con = controller;
  }

  void setIcon() async {
    destIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(50, 50)), 'assets/img/lmk.png');
  }

  @override
  void initState() {
    address = widget.rar.param is Add.Address && widget.rar.param != null
        ? widget.rar.param
        : Add.Address();
    pinCodeController.text = address.pinCode != null ? address.pinCode : "";
    doorNoController.text =
        address.doorNo != null ? address.doorNo.toString() : "";
    areaController.text = address.area != null ? address.area : "";
    landmarkController.text = address.landMark != null ? address.landMark : "";
    setIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: _con.cameraPosition,
              markers: _con.allMarkers,
              onMapCreated: (GoogleMapController controller) {
                _con.mapController.complete(controller);
                // _con.getCurrentLocation();
              },
              gestureRecognizers: Set()
                ..add(Factory<EagerGestureRecognizer>(
                    () => EagerGestureRecognizer())),
              onCameraMove: (CameraPosition cameraPosition) {
                _con.cameraPosition = cameraPosition;
              },
              onTap: (atOn) async {
                setState(() => _con.allMarkers.add(Marker(
                    markerId: MarkerId("user_address"),
                    icon: destIcon,
                    position: atOn,
                    draggable: true)));
                print(_con.allMarkers);
                print('${atOn.latitude}, ${atOn.longitude}');
                var addresses = await Geocoder.local
                    .findAddressesFromCoordinates(
                        Coordinates(atOn.latitude, atOn.longitude));
                print(addresses.first.toMap());
                var first = addresses.first;
                print("Locality:" + first.locality);
                print("Admin Area:" + first.adminArea);
                print("Sub Locality:" + first.subLocality);
                print("Sub Admin Area:" + first.subAdminArea);
                print("Address Line:" + first.addressLine);
                print("Feature name:" + first.featureName);
                print("SubThroughFare name:" +
                    (first.subThoroughfare == null
                        ? ""
                        : first.subThoroughfare));
                print("ThroughFare name:" +
                    (first.thoroughfare == null ? "" : first.thoroughfare));
                lat = atOn.latitude.toString();
                long = atOn.longitude.toString();
                pinCodeController.text = first.postalCode;
                doorNoController.text = first.featureName;
                areaController.text = first.subLocality;
              },
              polylines: _con.polyLines,
            ),
            height: 250,
          ),
          Container(
              margin: EdgeInsets.all(MediaQuery.of(context).size.height / 50),
              child: Form(
                  key: _formKey,
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
                        child: RaisedButton(
                            textColor: Colors.white,
                            color: Color(0xffe62136),
                            child: Text('SAVE'),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                final SharedPreferences sharedPrefs =
                                    await _sharePrefs;
                                Map<String, dynamic> body = {
                                  "address_ID": address.id.toString(),
                                  "address_type": address.addressType != null
                                      ? address.addressType.toString()
                                      : (widget.rar.heroTag != null
                                          ? widget.rar.heroTag
                                          : "0"),
                                  "user_ID": sharedPrefs.getString("spUserID"),
                                  "plot_house_no": doorNoController.text,
                                  "area": areaController.text,
                                  "landmark": landmarkController.text,
                                  "cus_pincode": pinCodeController.text
                                };
                                _con.waitUntilUpdateLocation(body);
                              } else {
                                print('Error');
                              }
                            }),
                        width: double.infinity,
                        height: 50,
                      ),
                    ],
                  )),
              height: MediaQuery.of(context).size.height / 2)
        ],
      ),
    );
  }
}
