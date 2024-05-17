import '../helpers/custom_trace.dart';

class FavoriteStore {
  String id;
  String favId;
  String catId;
  String name;
  String ownerName;
  String shopNo;
  String phoneNo;
  String image;
  String email;
  String storeStatus;
  String codStatus;
  String pickupStatus;
  String startTime;
  String endTime;
  String landmark;
  String area;
  String address;
  String deliveryRadius;
  String lat;
  String lon;
  String productCount;
  String customerCount;
  String shopCat;
  FavoriteStore();
  FavoriteStore.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['shop_ID'].toString();
      favId = jsonMap['fav_ID'].toString();
      catId = jsonMap['cat_ID'].toString();
      shopCat = jsonMap['shop_categories'];
      name = jsonMap['shop_name'];
      ownerName = jsonMap['owner_name'];
      shopNo = jsonMap['shop_No'].toString();
      phoneNo = jsonMap['shop_Mobile'].toString();
      email = jsonMap['shop_Email'].toString();
      image = jsonMap['shop_IMG'].toString();
      storeStatus = jsonMap['shop_status'].toString();
      codStatus = jsonMap['COD_status'].toString();
      pickupStatus = jsonMap['store_pickupStatus'].toString();
      startTime = jsonMap['start_time'].toString();
      endTime = jsonMap['end_time'].toString();
      landmark = jsonMap['landmark'].toString();
      area = jsonMap['area'].toString();
      address = jsonMap['address'].toString();
      deliveryRadius = jsonMap['delivery_radius'].toString();
      lat = jsonMap['lat'].toString();
      lon = jsonMap['lon'].toString();
      customerCount = jsonMap['shappers'].toString();
      productCount = jsonMap['product_count'].toString();
    } catch (e) {
      id = '';
      name = '';
      image = '';
      print(CustomTrace(StackTrace.current, message: e));
    }
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['shop_ID'] = int.parse(id);
    map['shop_name'] = name;
    map['shop_categories'] = shopCat;
    map['shop_IMG'] = image;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }

  @override
  int get hashCode => this.id.hashCode;
}
