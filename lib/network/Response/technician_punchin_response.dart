import 'dart:convert';

TechnicianPunchInResponse technicianPunchInResponseFromJson(String str) => TechnicianPunchInResponse.fromJson(json.decode(str));

String technicianPunchInResponseToJson(TechnicianPunchInResponse data) => json.encode(data.toJson());

class TechnicianPunchInResponse {
  TechnicianPunchInResponse({
    this.response,
  });

  TechnicianPunchInEntity? response;

  factory TechnicianPunchInResponse.fromJson(Map<String, dynamic> json) => TechnicianPunchInResponse(
    response: TechnicianPunchInEntity.fromJson(json["response"]),
  );

  Map<String, dynamic> toJson() => {
    "response": response!.toJson(),
  };
}

class TechnicianPunchInEntity {
  TechnicianPunchInEntity({
    this.responseCode,
    this.token,
    this.attendenceId,
    this.punchStatus,
    this.message,
  });

  String? responseCode;
  String? token;
  int? attendenceId;
  int? punchStatus;
  String? message;

  factory TechnicianPunchInEntity.fromJson(Map<String, dynamic> json) => TechnicianPunchInEntity(
    responseCode: json["response_code"],
    token: json["token"],
    attendenceId: json["attendence_id"],
    punchStatus: json["punch_status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "response_code": responseCode,
    "token": token,
    "attendence_id": attendenceId,
    "punch_status": punchStatus,
    "message": message,
  };
}
