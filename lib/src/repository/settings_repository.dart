import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shappy/src/helpers/maps_util.dart';
import 'package:shappy/src/models/address.dart';
import 'package:shappy/src/models/setting.dart';

ValueNotifier<Setting> setting = new ValueNotifier(new Setting());
ValueNotifier<Address> deliveryAddress = new ValueNotifier(new Address());
final navigatorKey = GlobalKey<NavigatorState>();
//LocationData locationData;
Future<dynamic> setCurrentLocation() async {
  var location = new Location();
  MapsUtil mapsUtil = new MapsUtil();
  final whenDone = new Completer();
  Address _address = new Address();
  location.requestService().then((value) async {
    location.getLocation().then((_locationData) async {
      String _addressName = await mapsUtil.getAddressName(new LatLng(_locationData?.latitude, _locationData?.longitude), setting.value.googleMapsKey);
      _address = Address.fromJSON({'address': _addressName, 'latitude': _locationData?.latitude, 'longitude': _locationData?.longitude});
      //await changeCurrentLocation(_address);
      whenDone.complete(_address);
    }).timeout(Duration(seconds: 10), onTimeout: () async {
      //await changeCurrentLocation(_address);
      whenDone.complete(_address);
      return null;
    }).catchError((e) {
      whenDone.complete(_address);
    });
  });
  return whenDone.future;
}