import '../helpers/custom_trace.dart';
import 'package:location/location.dart';

class Address {
  bool isDefault;
  double latitude, longitude;
  int id, doorNo, addressType;
  String pinCode, addressLine, landMark, area;
  Address();

  Address.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['address_ID'];
      pinCode = jsonMap['cus_pincode'] != null
          ? jsonMap['cus_pincode'].toString()
          : "";
      area = jsonMap['area'] != null ? jsonMap['area'] : "";
      doorNo =
          jsonMap['plot_house_no'] != null ? jsonMap['plot_house_no'] : null;
      landMark = jsonMap['landmark'] != null ? jsonMap['landmark'] : "";
      addressType =
          jsonMap['address_type'] != null ? jsonMap['address_type'] : null;
      latitude =
          jsonMap['cus_lat'] != null ? jsonMap['cus_lat'].toDouble() : null;
      longitude =
          jsonMap['cus_lon'] != null ? jsonMap['cus_lon'].toDouble() : null;
      isDefault = jsonMap['address_default'] != null
          ? (jsonMap['address_default'] == 1)
          : false;
      addressLine = jsonMap['cus_address'] != null
          ? jsonMap['cus_address']
          : getAddress(Address.fromJSON(jsonMap));
    } catch (e) {
      print(e);
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  bool isUnknown() => latitude == null || longitude == null;

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["address_ID"] = id;
    map["plot_house_no"] = doorNo;
    map["address_type"] = addressType;
    map["area"] = area;
    map["cus_lat"] = latitude;
    map["cus_lon"] = longitude;
    map["cus_pincode"] = pinCode;
    map["address_default"] = isDefault ? 1 : 0;
    map["cus_address"] = addressLine != null && addressLine != ""
        ? addressLine
        : getAddress(Address.fromJSON(map));
    return map;
  }

  LocationData toLocationData() {
    return LocationData.fromMap({
      "latitude": latitude,
      "longitude": longitude,
    });
  }

  String getAddress(Address address) {
    if (address == null)
      return "";
    else if (address.addressLine != null && address.addressLine != "")
      return address.addressLine;
    else {
      String oprs = address.doorNo != null && address.doorNo.toString() != ""
          ? address.doorNo.toString() + ", "
          : "";
      oprs +=
          address.area != null && address.area != "" ? address.area + ", " : "";
      oprs += address.pinCode != null && address.pinCode != ""
          ? address.pinCode + ". "
          : "";
      return oprs;
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}
