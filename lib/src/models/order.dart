class Order {
  final int orderID, paymentType, shopID, orderStatus;
  final String shopName, date, area, total, orderTime, phNo, cancelReason;
  Order(
      this.orderID,
      this.shopID,
      this.shopName,
      this.phNo,
      this.area,
      this.orderStatus,
      this.date,
      this.orderTime,
      this.paymentType,
      this.total,
      this.cancelReason);
  factory Order.fromJSON(Map<String, dynamic> json) {
    return Order(
        json['order_ID'],
        json['shop_ID'],
        json['shop_name'],
        json['shop_Mobile'],
        json['area'],
        json['order_status'],
        json['order_date'].toString(),
        json['order_time'],
        json['payment_type'],
        json['Total'].toString(),
        json['cancel_reason'] == null ? "" : json['cancel_reason']);
  }

  @override
  bool operator ==(other) =>
      other is Order && other.orderID == orderID && other.shopID == shopID;

  @override
  // TODO: implement hashCode
  int get hashCode => orderID.hashCode;

  bool isIn(List<Order> list) {
    for (Order e in list) {
      if (e == this) return true;
    }
    return false;
  }
}
