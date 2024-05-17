import 'package:shappy/src/models/store.dart';

class StoreBase {
  final bool success, status;
  final List<Store> stores;
  StoreBase(this.success, this.status, this.stores);
  factory StoreBase.fromMap(Map<String, dynamic> json) {
    return StoreBase(
        json['success'],
        json['status'],
        json['result'] != null
            ? List.from(json['result'])
                .map((element) => Store.fromMap(element))
                .toList()
            : <Store>[]);
  }
}
