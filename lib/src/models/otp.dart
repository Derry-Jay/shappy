class OTP {
  final bool success, status;
  final int oid, otp;
  String phNo;
  OTP(this.success, this.status, this.oid, this.otp);
  factory OTP.fromMap(Map<String, dynamic> json) {
    return OTP(json['success'], json['status'], json['otp_ID'], json['OTP']);
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map["phone_No"] = phNo;
    map["otp_ID"] = oid;
    map["otp"] = otp;
    return map;
  }
}
