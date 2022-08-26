class OnHandSpareListItems {

  String? spareCode;
  int? spareLocationId;
  String? spareLocation;
  int? quantity;
  int? statusCode;
  String? spareName;
  String? statusName;

  OnHandSpareListItems({
    this.spareCode,
    this.spareLocationId,
    this.spareLocation,
    this.quantity,
    this.statusCode,
    this.spareName,
    this.statusName,
  });
  OnHandSpareListItems.fromJson(Map<String, dynamic> json) {
    spareCode = json["spare_code"]?.toString();
    spareLocationId = json["spare_location_id"]?.toInt();
    spareLocation = json["spare_location"]?.toString();
    quantity = json["quantity"]?.toInt();
    statusCode = json["status_code"]?.toInt();
    statusName = json["status_name"]?.toString();
    spareName = json["spare_name"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["spare_code"] = spareCode;
    data["spare_location_id"] = spareLocationId;
    data["spare_location"] = spareLocation;
    data["quantity"] = quantity;
    data["status_code"] = statusCode;
    data["status_name"] = statusName;
    data["spare_name"] = spareName;
    return data;
  }
}

class OnHandSpareEntity {

  String? responseCode;
  String? token;
  List<OnHandSpareListItems?>? data;

  OnHandSpareEntity({
    this.responseCode,
    this.token,
    this.data,
  });
  OnHandSpareEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <OnHandSpareListItems>[];
      v.forEach((v) {
        arr0.add(OnHandSpareListItems.fromJson(v));
      });
      this.data = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
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

class OnHandSpareResponse {
  OnHandSpareEntity? onHandSpareEntity;

  OnHandSpareResponse({
    this.onHandSpareEntity,
  });
  OnHandSpareResponse.fromJson(Map<String, dynamic> json) {
    onHandSpareEntity = (json["response"] != null) ? OnHandSpareEntity.fromJson(json["response"]) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (onHandSpareEntity != null) {
      data["response"] = onHandSpareEntity!.toJson();
    }
    return data;
  }
}