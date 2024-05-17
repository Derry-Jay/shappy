import 'dart:async';
import 'package:shappy/src/models/otp.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/helpers/maps_util.dart';
import 'package:shappy/src/models/address.dart';
import '../repository/user_repository.dart' as repository;
import '../models/route_argument.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends ControllerMVC {
  User user = new User();
  User userData;
  OTP oneTimePassCode;
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  OverlayEntry loader;
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  Set<Marker> allMarkers = <Marker>{};
  List<Address> addresses;
  Set<Polyline> polyLines = new Set();
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(13.06, 80.24),
    zoom: 11.0,
  );
  MapsUtil mapsUtil = new MapsUtil();
  Completer<GoogleMapController> mapController = Completer();
  UserController() {
    loader = Helper.overlayLoader(context);
    this.loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void navigateTo(String route, RouteArgument arguments) {
    Navigator.pushNamed(context, route, arguments: arguments).then(onGoBack);
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  void waitUntilUpdateProfile(Map<String, dynamic> body) async {
    final Map<String, dynamic> stream = await repository.updateUserData(body);
    if (stream != null && stream["success"] && stream["status"]) {
      print(stream["message"]);
      Navigator.of(context).pop();
    }
    Toast.show(stream["message"], context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }

  void waitUntilUpdateLocation(Map<String, dynamic> body) async {
    final Map<String, dynamic> stream = await repository.updateAddress(body);
    if (stream != null && stream["success"] && stream["status"]) {
      Toast.show(stream["result"], context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      Navigator.of(context).pop();
    } else
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void waitUntilAddAddress(Map<String, dynamic> body) async {
    final Map<String, dynamic> stream = await repository.addAddress(body);
    if (stream != null && stream["success"] && stream["status"]) {
      Toast.show("Address Added Successfully", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      await waitForUserData();
      await waitForAddresses(userData);
      if (addresses.length == 1) {
        final SharedPreferences sharedPrefs = await _sharePrefs;
        final a = await sharedPrefs.setInt(
            "defaultDeliveryAddressID", addresses.first.id);
        if (a) print("Added");
      }
      Navigator.of(context).pop();
    } else
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void login() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      await repository.login(user).then((value) {
        setState(() => value.phNo = user.phone);
        print(value.success);
        print(value.status);
        if (value != null && value.status && value.success) {
          setState(() {
            oneTimePassCode = value;
            oneTimePassCode.phNo = user.phone;
          });
          Helper.hideLoader(loader);
          if (oneTimePassCode != null)
            Navigator.of(context).pushNamed('/OTP',
                arguments: RouteArgument(
                    id: oneTimePassCode.oid.toString(),
                    heroTag: "restaurant_reviews",
                    param: oneTimePassCode));
        } else if (value != null && !value.status) {
          Toast.show("Invalid Phone Number", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        } else {
          Toast.show("Error", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      }).catchError((e) {
        loader.remove();
        Toast.show(e, context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void otp(Map body) async {
    bool flag;
    final SharedPreferences sharedPrefs = await _sharePrefs;
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      await repository.otp(body).then((value) async {
        if (value != null && value.status && value.registered) {
          onLocalStore(value.userID.toString(), value.token).then((val) async {
            setState(() => flag = val);
            await sharedPrefs.setInt(
                "defaultDeliveryAddressID", value.addressID);
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/app_page', (Route<dynamic> route) => false,
                arguments: RouteArgument(
                    id: value.userID.toString(), param: flag, heroTag: "0"));
          });
        } else if (value != null && value.status && !value.registered) {
          await sharedPrefs.setString("phone", body["phone_No"]);
          await sharedPrefs.setInt("defaultDeliveryAddressID", value.addressID);
          Navigator.of(scaffoldKey.currentContext).pushNamedAndRemoveUntil(
              '/registeration', (Route<dynamic> route) => false,
              arguments: RouteArgument(
                  param: value,
                  id: value.userID.toString(),
                  heroTag: value.token));
        } else {
          if (value != null)
            Toast.show("Error", context);
          else
            Toast.show("Invalid OTP", context);
        }
      }).catchError((e) {
        loader.remove();
        print(e);
        Toast.show(e.toString(), context, duration: Toast.LENGTH_LONG);
      }).whenComplete(() {
        Helper.hideLoader(loader);
        Toast.show("Done", context, duration: Toast.LENGTH_LONG);
      });
    } else {
      Toast.show("Please enter valid otp", context,
          duration: Toast.LENGTH_LONG);
    }
  }

  void waitForUserRegister(Map<String, dynamic> body) async {
    bool flag;
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      final stream = await repository.userRegister(body);
      print(stream);
      if (stream != null && stream["success"] && stream["status"]) {
        Helper.hideLoader(loader);
        flag = await onLocalStore(body["user_ID"], body["api_token"]);
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/app_page', (Route<dynamic> route) => false,
            arguments: RouteArgument(
                id: user.id.toString(), param: flag, heroTag: "0"));
      } else
        Toast.show("Error", context, duration: Toast.LENGTH_LONG);
    }
  }

  Future<bool> onLocalStore(String _userID, String token) async {
    final SharedPreferences sharedPrefs = await _sharePrefs;
    bool flag = sharedPrefs.getString("spUserID") == null &&
        sharedPrefs.getString("apiToken") == null &&
        sharedPrefs.getString("spDeviceToken") != null;
    if (flag) {
      await sharedPrefs.setString("spUserID", _userID);
      await sharedPrefs.setString("apiToken", token);
      return flag;
    }
    return false;
  }

  Future<void> waitUntilDeleteAddress(int userID, int addID) async {
    final stream = await repository.removeDeliveryAddress(userID, addID);
    if (stream != null) {
      if (stream["success"] && stream["status"]) {
        Toast.show(stream["result"], context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        final value = await repository.getUserDetails();
        if (value != null) {
          setState(() => userData = value);
          await waitForAddresses(userData);
          Navigator.pop(context);
        }
      } else
        Toast.show("Error", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else
      Toast.show("Error", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }

  Future<void> waitForAddresses(User user) async {
    final value = await repository.getAddresses(user);
    if (value != null) {
      setState(() => addresses = value);
      if (addresses.isEmpty)
        Toast.show("No Addresses Added", context, duration: Toast.LENGTH_LONG);
    } else
      Toast.show("Error Fetching Addresses", context,
          duration: Toast.LENGTH_LONG);
  }

  Future<void> waitForUserData() async {
    final value = await repository.getUserDetails();
    if (value != null)
      setState(() => userData = value);
    else
      setState(() => userData = User());
  }

  void waitUntilSetAddress(int userID, int addressID) async {
    final stream = await repository.setAddress(userID, addressID);
    final sharedPrefs = await _sharePrefs;
    if (stream != null && stream["success"] && stream["status"]) {
      Toast.show(stream["result"], context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      final r = await sharedPrefs.setInt("defaultDeliveryAddressID", addressID);
      if (r) Navigator.pop(context);
    } else
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void waitUntilSendShopRequest(Map<String, dynamic> body) async {
    final stream = await repository.sendShopRequest(body);
    if (stream != null && stream['success'] && stream['status']) {
      Toast.show(stream["message"], context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      Navigator.of(context).pushNamed("/sellerSuccess");
    } else
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}
