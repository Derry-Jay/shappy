import 'package:shappy/src/models/address.dart';

class AddressListBase {
  final bool success, status;
  final List<Address> addresses;
  AddressListBase(this.success, this.status, this.addresses);
  factory AddressListBase.fromMap(Map<String, dynamic> json) => AddressListBase(
      json['success'],
      json['status'],
      json['result'] != null
          ? List.from(json['result'])
              .map((element) => Address.fromJSON(element))
              .toList()
          : <Address>[]);
}
