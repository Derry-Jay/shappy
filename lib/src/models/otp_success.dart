class OTPSuccess {
  final bool success, status, registered;
  final String token, message;
  final int userID, addressID;
  OTPSuccess(this.success, this.status, this.registered, this.message,
      this.token, this.userID, this.addressID);
  factory OTPSuccess.fromMap(Map<String, dynamic> json) {
    return OTPSuccess(
        json['success'],
        json['status'],
        json['Registerd'],
        json['message'],
        json['jwt_token'],
        json['user_ID'],
        json['address_ID']);
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['success'] = success;
    map['status'] = status;
    map['message'] = message;
    map['Registerd'] = registered;
    map['jwt_token'] = token;
    map['user_ID'] = userID;
    map['address_ID'] = addressID;
    return map;
  }
}
