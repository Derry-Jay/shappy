import 'package:shappy/src/helpers/custom_trace.dart';

class StoreCategory {
  String id;
  String name;
  String image;
  String bgColor;
  StoreCategory({String id, String name});

  StoreCategory.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['cat_ID'].toString();
      name = jsonMap['shop_categories'];
      bgColor = jsonMap['cat_fgClr'];
      image = jsonMap['category_IMG'].toString();
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  static List<StoreCategory> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => StoreCategory.fromJSON(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.id} ${this.name}';
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(StoreCategory model) {
    return this?.id == model?.id;
  }

  @override
  String toString() => name;
}
