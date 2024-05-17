class Store {
  final bool codStatus, shopPickupStatus;
  final String shopName, shopCate, shopArea, imageURL;
  final int productCount, customerCount, deliveryRadius, shopID;
  Store(
      this.shopID,
      this.shopName,
      this.shopCate,
      this.imageURL,
      this.shopArea,
      this.customerCount,
      this.productCount,
      this.deliveryRadius,
      this.codStatus,
      this.shopPickupStatus);

  factory Store.fromMap(Map<String, dynamic> json) {
    return Store(
        json['shop_ID'],
        json['shop_name'],
        json['shop_categories'],
        json['shop_IMG'].toString(),
        json['area'],
        json['shappers'],
        json['product_count'],
        json['delivery_radius'],
        json['COD_status'] == 1,
        json['store_pickupStatus'] == 1);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['shop_ID'] = shopID;
    map['shop_name'] = shopName;
    map['shop_categories'] = shopCate;
    map['shop_IMG'] = imageURL;
    map['shappers'] = customerCount;
    return map;
  }

  static String getInitials(String name) => name == null
      ? ''
      : (name.isNotEmpty
          ? ''
          : name.trim().split(' ').map((l) => l[0]).take(2).join());
}
