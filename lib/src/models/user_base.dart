import 'package:shappy/src/models/user.dart';

class UserBase {
  final bool success, status;
  final User user;
  UserBase(this.success, this.status, this.user);
  factory UserBase.fromMap(Map<String, dynamic> json) {
    return UserBase(json['success'], json['status'],
        json['result'] != null ? User.fromJSON(json['result']) : User());
  }
}
