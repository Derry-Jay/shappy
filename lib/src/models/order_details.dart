import 'ordered_product.dart';

class OrderDetails {
  final bool success, status;
  final String message;
  final List<OrderedProduct> products;
  OrderDetails(this.success, this.status, this.message, this.products);
  factory OrderDetails.fromMap(Map<String, dynamic> json) {
    return OrderDetails(
        json['success'],
        json['status'],
        json['message'],
        json['orderproducts'] != null
            ? List.from(json['orderproducts'])
                .map((element) => OrderedProduct.fromMap(element))
                .toList()
            : []);
  }
}
