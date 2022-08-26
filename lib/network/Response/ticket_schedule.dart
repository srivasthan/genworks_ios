class TicketScheduleEntity {
  String? responseCode;
  String? token;
  String? data;

  TicketScheduleEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  TicketScheduleEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    data = json["data"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
    data["data"] = data;
    return data;
  }
}

class TicketScheduleResponse {
  TicketScheduleEntity? ticketScheduleEntity;

  TicketScheduleResponse({
    this.ticketScheduleEntity,
  });

  TicketScheduleResponse.fromJson(Map<String, dynamic> json) {
    ticketScheduleEntity = (json["response"] != null)
        ? TicketScheduleEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (ticketScheduleEntity != null) {
      data["response"] = ticketScheduleEntity!.toJson();
    }
    return data;
  }
}
