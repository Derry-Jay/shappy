import 'order.dart';

class OrderBase {
  final bool success;
  final bool status;
  final String message;
  final List<Order> order;
  OrderBase(this.success, this.status, this.message, this.order);
  factory OrderBase.fromMap(Map<String, dynamic> json) {
    return OrderBase(
        json['success'],
        json['status'],
        json['message'],
        json['result'] != null
            ? List.from(json['result'])
                .map((element) => Order.fromJSON(element))
                .toList()
            : <Order>[]);
  }
}
