class GetDistanceEntity {
  String? responseCode;
  String? metter;
  String? message;

  GetDistanceEntity({
    this.responseCode,
    this.metter,
    this.message,
  });

  GetDistanceEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    metter = json["metter"]?.toString();
    message = json["message"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["metter"] = metter;
    data["message"] = message;
    return data;
  }
}

class GetDistanceResponse {
  GetDistanceEntity? getDistanceEntity;

  GetDistanceResponse({
    this.getDistanceEntity,
  });

  GetDistanceResponse.fromJson(Map<String, dynamic> json) {
    getDistanceEntity = (json["response"] != null)
        ? GetDistanceEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (getDistanceEntity != null) {
      data["response"] = getDistanceEntity!.toJson();
    }
    return data;
  }
}
