import 'ordered_product.dart';

class OrderedProductBase {
  final bool success, status;
  final List<OrderedProduct> orderedProducts;
  OrderedProductBase(this.success, this.status, this.orderedProducts);
  factory OrderedProductBase.fromMap(Map<String, dynamic> json) {
    return OrderedProductBase(
        json['success'],
        json['status'],
        json['orderproducts'] != null
            ? List.from(json['orderproducts'])
                .map((element) => OrderedProduct.fromMap(element))
                .toList()
            : <OrderedProduct>[]);
  }
}
