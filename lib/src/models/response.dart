class Response {
  final bool success, status;
  final String message;
  Response(this.success, this.status, this.message);

  factory Response.fromMap(Map<String, dynamic> json) => Response(
      json['success'],
      json['status'],
      json['message'] ??
          (json['result'] is String
              ? json['result']
              : json['result'].toString()));
}
