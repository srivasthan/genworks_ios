class GetTravelDetailsResponse {
  int? status;
  String? result;

  GetTravelDetailsResponse({
    this.status,
    this.result,
  });

  GetTravelDetailsResponse.fromJson(Map<String, dynamic> json) {
    status = json["status"]?.toInt();
    result = json["result"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["status"] = status;
    data["result"] = result;
    return data;
  }
}
