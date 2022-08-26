class OnHandPrimaryListItems {
  int? spareId;
  String? spareCode;
  String? spareName;
  String? productId;
  int? quantity;
  String? productSubId;
  int? locationId;
  String? location;
  int? price;
  String? spareModel;
  int? leadTime;

  OnHandPrimaryListItems({
    this.spareId,
    this.spareCode,
    this.spareName,
    this.productId,
    this.quantity,
    this.productSubId,
    this.locationId,
    this.location,
    this.price,
    this.spareModel,
    this.leadTime,
  });

  OnHandPrimaryListItems.fromJson(Map<String, dynamic> json) {
    spareId = json["spare_id"]?.toInt();
    spareCode = json["spare_code"]?.toString();
    spareName = json["spare_name"]?.toString();
    productId = json["product_id"]?.toString();
    quantity = json["quantity"]?.toInt();
    productSubId = json["product_sub_id"]?.toString();
    locationId = json["location_id"]?.toInt();
    location = json["location"]?.toString();
    price = json["price"]?.toInt();
    spareModel = json["spare_model"]?.toString();
    leadTime = json["lead_time"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["spare_id"] = spareId;
    data["spare_code"] = spareCode;
    data["spare_name"] = spareName;
    data["product_id"] = productId;
    data["quantity"] = quantity;
    data["product_sub_id"] = productSubId;
    data["location_id"] = locationId;
    data["location"] = location;
    data["price"] = price;
    data["spare_model"] = spareModel;
    data["lead_time"] = leadTime;
    return data;
  }
}

class OnHandPrimaryEntity {
  String? responseCode;
  String? token;
  String? message;
  List<OnHandPrimaryListItems?>? data;

  OnHandPrimaryEntity({
    this.responseCode,
    this.token,
    this.message,
    this.data,
  });

  OnHandPrimaryEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    message = json["message"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <OnHandPrimaryListItems>[];
      v.forEach((v) {
        arr0.add(OnHandPrimaryListItems.fromJson(v));
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

class OnHandPrimaryResponse {
  OnHandPrimaryEntity? onHandPrimaryEntity;

  OnHandPrimaryResponse({
    this.onHandPrimaryEntity,
  });

  OnHandPrimaryResponse.fromJson(Map<String, dynamic> json) {
    onHandPrimaryEntity = (json["response"] != null)
        ? OnHandPrimaryEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (onHandPrimaryEntity != null) {
      data["response"] = onHandPrimaryEntity!.toJson();
    }
    return data;
  }
}
