class CartProduct {
  final String name, image, description, price;
  final int cartCount, proID;
  CartProduct(this.proID, this.name, this.description, this.image,
      this.cartCount, this.price);
  factory CartProduct.fromMap(Map<String, dynamic> json) {
    return CartProduct(
        json['product_ID'],
        json['product_name'],
        json['desc'],
        json['product_IMG'],
        json['cartquantity'] ?? json['quantity'],
        json['cost'].toString() ?? json['price'].toString());
  }
  Map toMap() {
    var map = new Map<String, dynamic>();
    map["product_ID"] = proID;
    map["product_description"] = description;
    map["product_name"] = name;
    map["product_IMG"] = image;
    map["cartquantity"] = cartCount;
    map["quantity"] = cartCount;
    return map;
  }

  List<CartProduct> fromMapList(List list) => list != null
      ? list.map((item) => CartProduct.fromMap(item)).toList()
      : <CartProduct>[];
}
