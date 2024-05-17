import 'package:shappy/src/models/product.dart';

class ProductBase {
  final bool success, status;
  final List<Product> products;
  ProductBase(this.success, this.status, this.products);
  factory ProductBase.fromMap(Map<String, dynamic> json) {
    return ProductBase(
        json['success'],
        json['status'],
        json['result'] != null
            ? Product.fromJsonList(json['result'])
            : <Product>[]);
  }
}
