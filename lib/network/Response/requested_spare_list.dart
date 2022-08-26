class RequestedSpareListItems {

  String? spareCode;
  int? quantity;
  String? spareName;
  String? status;

  RequestedSpareListItems({
    this.spareCode,
    this.quantity,
    this.spareName,
    this.status,
  });
  RequestedSpareListItems.fromJson(Map<String, dynamic> json) {
    spareCode = json["spare_code"]?.toString();
    quantity = json["quantity"]?.toInt();
    spareName = json["spare_name"]?.toString();
    status = json["status_name"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["spare_code"] = spareCode;
    data["quantity"] = quantity;
    data["spare_name"] = spareName;
    data["status_name"] = status;
    return data;
  }
}

class RequestedSpareListEntity {

  String? responseCode;
  String? token;
  String? message;
  List<RequestedSpareListItems?>? data;

  RequestedSpareListEntity({
    this.responseCode,
    this.token,
    this.message,
    this.data,
  });
  RequestedSpareListEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    message = json["message"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <RequestedSpareListItems>[];
      v.forEach((v) {
        arr0.add(RequestedSpareListItems.fromJson(v));
      });
      this.data = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
    data["message"] = message;
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

class RequestedSpareListResponse {

  RequestedSpareListEntity? requestedSpareListEntity;

  RequestedSpareListResponse({
    this.requestedSpareListEntity,
  });
  RequestedSpareListResponse.fromJson(Map<String, dynamic> json) {
    requestedSpareListEntity = (json["response"] != null) ? RequestedSpareListEntity.fromJson(json["response"]) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (requestedSpareListEntity != null) {
      data["response"] = requestedSpareListEntity!.toJson();
    }
    return data;
  }
}