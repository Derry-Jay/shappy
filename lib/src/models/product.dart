class Product {
  final int weight, proID, shopID, productStatus;
  final String name, description, image, unit, proCat, price;
  Product(this.shopID, this.proID, this.name, this.description, this.proCat,
      this.price, this.image, this.productStatus, this.weight, this.unit);
  factory Product.fromMap(Map<String, dynamic> json) => (json != null
      ? Product(
          json['shop_ID'],
          json['product_ID'],
          json['product_name'],
          json['product_description'],
          json['product_category'],
          json['price'].toString(),
          json['product_IMG'],
          json['product_status'],
          json['weight'],
          json['units'])
      : null);
  Map toMap() {
    var map = new Map<String, dynamic>();
    map["product_ID"] = proID;
    map["shop_ID"] = shopID;
    map["product_description"] = description;
    map["product_name"] = name;
    map["product_IMG"] = image;
    map["product_status"] = productStatus;
    return map;
  }

  static List<Product> fromJsonList(List list) => (list == null || list == []
      ? <Product>[]
      : list.map((item) => Product.fromMap(item)).toList());
}
