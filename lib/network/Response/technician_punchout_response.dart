import 'dart:convert';

TechnicianPunchOutResponse technicianPunchOutResponseFromJson(String str) => TechnicianPunchOutResponse.fromJson(json.decode(str));

String technicianPunchOutResponseToJson(TechnicianPunchOutResponse data) => json.encode(data.toJson());

class TechnicianPunchOutResponse {
  TechnicianPunchOutResponse({
    this.response,
  });

  TechnicianPunchOutEntity? response;

  factory TechnicianPunchOutResponse.fromJson(Map<String, dynamic> json) => TechnicianPunchOutResponse(
    response: TechnicianPunchOutEntity.fromJson(json["response"]),
  );

  Map<String, dynamic> toJson() => {
    "response": response!.toJson(),
  };
}

class TechnicianPunchOutEntity {
  TechnicianPunchOutEntity({
    this.responseCode,
    this.punchStatus,
    this.message,
  });

  String? responseCode;
  int? punchStatus;
  String? message;

  factory TechnicianPunchOutEntity.fromJson(Map<String, dynamic> json) => TechnicianPunchOutEntity(
    responseCode: json["response_code"],
    punchStatus: json["punch_status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "response_code": responseCode,
    "punch_status": punchStatus,
    "message": message,
  };
}