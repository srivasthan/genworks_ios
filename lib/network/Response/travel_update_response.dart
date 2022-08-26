class TravelUpdateListItems {
  String? ticketId;
  String? modeOfTravel;
  String? noOfKmTravelled;
  String? estimatedTime;
  String? startDate;
  String? endDate;

  TravelUpdateListItems({
    this.ticketId,
    this.modeOfTravel,
    this.noOfKmTravelled,
    this.estimatedTime,
    this.startDate,
    this.endDate,
  });

  TravelUpdateListItems.fromJson(Map<String, dynamic> json) {
    ticketId = json["ticket_id"]?.toString();
    modeOfTravel = json["mode_of_travel"]?.toString();
    noOfKmTravelled = json["no_of_km_travelled"]?.toString();
    estimatedTime = json["estimated_time"]?.toString();
    startDate = json["start_date"]?.toString();
    endDate = json["end_date"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["ticket_id"] = ticketId;
    data["mode_of_travel"] = modeOfTravel;
    data["no_of_km_travelled"] = noOfKmTravelled;
    data["estimated_time"] = estimatedTime;
    data["start_date"] = startDate;
    data["end_date"] = endDate;
    return data;
  }
}

class TravelUpdateEntity {
  String? token;
  String? responseCode;
  List<TravelUpdateListItems?>? data;

  TravelUpdateEntity({
    this.token,
    this.responseCode,
    this.data,
  });

  TravelUpdateEntity.fromJson(Map<String, dynamic> json) {
    token = json["token"]?.toString();
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <TravelUpdateListItems>[];
      v.forEach((v) {
        arr0.add(TravelUpdateListItems.fromJson(v));
      });
      this.data = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["data"] = arr0;
    }
    return data;
  }
}

class TravelUpdateResponse {
  TravelUpdateEntity? travelUpdateEntity;

  TravelUpdateResponse({
    this.travelUpdateEntity,
  });

  TravelUpdateResponse.fromJson(Map<String, dynamic> json) {
    travelUpdateEntity = (json["response"] != null)
        ? TravelUpdateEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (travelUpdateEntity != null) {
      data["response"] = travelUpdateEntity!.toJson();
    }
    return data;
  }
}