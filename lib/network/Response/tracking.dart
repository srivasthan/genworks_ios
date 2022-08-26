class TrackerEntity {
  String? responseCode;
  String? message;

  TrackerEntity({
    this.responseCode,
    this.message,
  });

  TrackerEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    message = json["message"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["message"] = message;
    return data;
  }
}

class TrackingResponse {
  TrackerEntity? trackerEntity;

  TrackingResponse({
    this.trackerEntity,
  });

  TrackingResponse.fromJson(Map<String, dynamic> json) {
    trackerEntity = (json["response"] != null)
        ? TrackerEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (trackerEntity != null) {
      data["response"] = trackerEntity!.toJson();
    }
    return data;
  }
}
