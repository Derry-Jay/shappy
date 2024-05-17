import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shappy/src/models/address_base.dart';
import 'package:shappy/src/models/address_list_base.dart';
import 'package:shappy/src/models/otp.dart';
import 'package:shappy/src/models/otp_success.dart';
import 'package:shappy/src/models/user_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../models/address.dart';
import '../models/user.dart';

ValueNotifier<User> currentUser = new ValueNotifier(User());
Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();

Future<OTP> login(User user) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}userLogin';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader:
          "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Ijk4NTYyMzQ3NTYiLCJpYXQiOjE2MDMxMDcxODV9.dg8wRM8BS04yyUtX1wzj9g0EYnu6tWbNUD0WOHsl5Wc"
    },
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    // setCurrentOTP(response.body);
    // setPhoneNo(user.phone);
    //
    // currentUser.value = User.fromJSON(json.decode(response.body));
    return OTP.fromMap(json.decode(response.body));
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
}

Future<OTPSuccess> otp(Map body) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}userOTPVerification';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader:
          "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Ijk4NTYyMzQ3NTYiLCJpYXQiOjE2MDMxMDcxODV9.dg8wRM8BS04yyUtX1wzj9g0EYnu6tWbNUD0WOHsl5Wc"
    },
    body: json.encode(body),
  );
  if (response.statusCode == 200) {
    print(response.body);
    return OTPSuccess.fromMap(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<Map<String, dynamic>> register(User user) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}userRegister';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + user.apiToken
    },
    body: json.encode(user.toProfileMap()),
  );
  if (response.statusCode == 200) {
    // currentUser.value = User.fromJSON(json.decode(response.body)['data']);
    return json.decode(response.body);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  // return currentUser.value;
}

Future<bool> resetPassword(User user) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}send_reset_link_email';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
}

Future<Map<String, dynamic>> updateUserData(Map<String, dynamic> body) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}userProfileEdit';
  try {
    final response = await client.put(
      url,
      headers: {
        HttpHeaders.authorizationHeader:
            "Bearer " + sharedPrefs.getString("apiToken")
      },
      body: body,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Unable to fetch products from the REST API');
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}

Future<List<Address>> getAddresses(User user) async {
  final client = http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}useraddresses';
  try {
    final response = await client.post(url, body: {
      "user_ID": user == null
          ? sharedPrefs.getString("spUserID")
          : (user.id == null
              ? sharedPrefs.getString("spUserID")
              : user.id.toString())
    }, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonString = json.decode(response.body);
      return AddressListBase.fromMap(jsonString).addresses;
    } else
      throw Exception('Unable to Fetch Addresses!!!');
  } catch (e) {
    print(e);
    throw (e);
  }
}

Future<Map<String, dynamic>> addAddress(Map<String, dynamic> body) async {
  final sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}addressRegister';
  final client = new http.Client();
  try {
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader:
            'Bearer ' + sharedPrefs.getString("apiToken")
      },
      body: body,
    );

    return json.decode(response.body);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return {};
  }
}

Future<Map<String, dynamic>> updateAddress(Map<String, dynamic> body) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}addressUpdate';
  try {
    final response = await client.put(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            "Bearer " + sharedPrefs.getString("apiToken")
      },
      body: json.encode(body),
    );
    return json.decode(response.statusCode == 200 ? response.body : "{}");
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return {};
  }
}

Future<Map<String, dynamic>> removeDeliveryAddress(
    int userID, int addID) async {
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}addressDelete';
  final client = new http.Client();
  try {
    final response = await client.put(url, headers: {
      HttpHeaders.authorizationHeader:
          'Bearer ' + sharedPrefs.getString("apiToken")
    }, body: {
      "user_ID": userID.toString(),
      "address_ID": addID.toString()
    });
    return response.statusCode == 200 ? json.decode(response.body) : {};
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return {};
  }
}

void setCurrentOTP(jsonString) async {
  print(json.decode(jsonString)['status']);
  try {
    if (json.decode(jsonString)['status']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('otp', jsonString);
      print(prefs.getString("otp"));
    }
  } catch (e) {
    print(e);
    print(CustomTrace(StackTrace.current, message: jsonString).toString());
    throw new Exception(e);
  }
}

Future<User> getCurrentOTP() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('otp')) {
    currentUser.value = User.fromJSON(json.decode(await prefs.get('otp')));
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<Map<String, dynamic>> sendShopRequest(Map<String, dynamic> body) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}userShopRegister';
  try {
    final response = await client.post(url,
        headers: {
          HttpHeaders.authorizationHeader:
              'Bearer ' + sharedPrefs.getString("apiToken")
        },
        body: body);
    return response.statusCode == 200 ? json.decode(response.body) : {};
  } catch (e) {
    print(e);
    print(CustomTrace(StackTrace.current, message: url));
    return {};
  }
}

Future<Map<String, dynamic>> userRegister(Map<String, dynamic> body) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}userRegister';
  final client = new http.Client();
  try {
    final response = await client.post(
      url,
      headers: {HttpHeaders.authorizationHeader: "Bearer " + body["api_token"]},
      body: body,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(CustomTrace(StackTrace.current, message: response.body).toString());
      throw new Exception(response.body);
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: e.toString()).toString());
    throw new Exception(e);
  }
}

Future<Map<String, dynamic>> setAddress(int userID, int addressID) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}addressDefault';
  try {
    final response = await client.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader:
            "Bearer " + sharedPrefs.getString("apiToken")
      },
      body: {"user_ID": userID.toString(), "address_ID": addressID.toString()},
    );
    return json.decode(response.statusCode == 200 ? response.body : "{}");
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: e.toString()).toString());
    throw new Exception(e);
  }
}

Future<Address> getAddressDetails(int addressID) async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}UserAddress';
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "address_ID": addressID.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonString =
          json.decode(response.body) as Map<String, dynamic>;
      if (jsonString['result'] == null) {
        if (sharedPrefs.getInt("defaultDeliveryAddressID") == addressID) {
          final r = await sharedPrefs.remove("defaultDeliveryAddressID");
          if (r) print("Removed");
        }
        return Address();
      } else
        return AddressBase.fromMap(jsonString).address;
    } else {
      throw Exception('Unable to fetch address details from the REST API');
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}

Future<User> getUserDetails() async {
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}userProfile';
  try {
    final response = await client.post(url, headers: {
      HttpHeaders.authorizationHeader:
          "Bearer " + sharedPrefs.getString("apiToken")
    }, body: {
      "user_ID": sharedPrefs.getString("spUserID")
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonString =
          json.decode(response.body) as Map<String, dynamic>;
      return UserBase.fromMap(jsonString).user;
    } else {
      throw Exception('Unable to fetch user details from the REST API');
    }
  } catch (e) {
    print(e);
    throw (e);
  }
}

Future<Map<String, dynamic>> pushToken(Map<String, dynamic> body) async {
  final String url =
      '${GlobalConfiguration().getString('base_url')}userPushNotification';
  final client = new http.Client();
  final SharedPreferences sharedPrefs = await _sharePrefs;
  print(sharedPrefs.getString("apiToken"));
  try {
    final response = await client.put(url,
        headers: {
          HttpHeaders.authorizationHeader:
              "Bearer " + sharedPrefs.getString("apiToken")
        },
        body: body);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonString =
          json.decode(response.body) as Map<String, dynamic>;
      return jsonString;
    } else {
      throw Exception('Unable to push notifications from the REST API');
    }
  } catch (e) {
    throw (e);
  }
}
