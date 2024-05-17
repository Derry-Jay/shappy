import 'package:shappy/src/models/product.dart';
import 'package:shappy/src/models/product_category.dart';

class ProductCategoryBase {
  final bool success, status;
  final List<Product> products;
  final List<ProductCategory> productCategories;
  ProductCategoryBase(
      this.success, this.status, this.products, this.productCategories);
  factory ProductCategoryBase.fromMap(Map<String, dynamic> json) {
    return ProductCategoryBase(
        json['success'],
        json['status'],
        json['products'] != null && json['products'] != []
            ? List.from(json['products'])
                .map((element) => Product.fromMap(element))
                .toList()
            : <Product>[],
        json['product_category'] != null && json['product_category'] != []
            ? ProductCategory.fromJsonList(json['product_category'])
            : <ProductCategory>[]);
  }
}
