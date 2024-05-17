import '../models/media.dart';
import '../helpers/custom_trace.dart';

class User {
  int id;
  Media image;
  bool auth, isRegistered, shopRequestSentStatus;
  String name, email, apiToken, deviceToken, phone, bio;
  User();
  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['user_ID'];
      name = jsonMap['username'] != null ? jsonMap['username'] : '';
      email = jsonMap['user_Email'] != null ? jsonMap['user_Email'] : '';
      apiToken = jsonMap['jwt_token'] != null ? jsonMap['jwt_token'] : "";
      deviceToken = jsonMap['device_token'] != null
          ? jsonMap['device_token']
          : (jsonMap['andriod_pushID'] != null
              ? jsonMap['andriod_pushID']
              : "");
      shopRequestSentStatus = jsonMap['shop_request_status'] == 1;
      try {
        phone = jsonMap['phone_No'];
      } catch (e) {
        phone = "";
      }
      try {
        bio = jsonMap['custom_fields']['bio']['view'];
      } catch (e) {
        bio = "";
      }
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
          ? Media.fromJSON(jsonMap['media'][0])
          : new Media();
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["user_ID"] = id.toString();
    map["user_Email"] = email;
    map["username"] = name;
    map["phone_No"] = phone;
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    map["api_token"] = apiToken;
    if (deviceToken != null && deviceToken != "") {
      map["device_token"] = deviceToken;
    }
    map["bio"] = bio;
    map["media"] = image?.toMap();
    return map.toString();
  }

  Map toProfileMap() {
    var map = new Map<String, dynamic>();
    map["user_ID"] = id.toString();
    map["username"] = name;
    map["user_Email"] = email;
    map["api_token"] = apiToken;
    return map;
  }
}
