import 'package:shappy/src/models/address.dart';

class AddressBase {
  final bool success, status;
  final Address address;
  AddressBase(this.success, this.status, this.address);

  factory AddressBase.fromMap(Map<String, dynamic> json) {
    return AddressBase(json["success"], json["status"],
        Address.fromJSON(json['result'] != null ? json['result'] : {}));
  }
}
