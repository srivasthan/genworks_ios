class SpareCartListItems {
  int? spareId;
  String? spareCode;
  String? spareName;
  int? productId;
  int? quantity;
  int? productSubId;
  int? locationId;
  String? location;
  int? price;
  String? spareModel;
  int? leadTime;

  SpareCartListItems({
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

  SpareCartListItems.fromJson(Map<String, dynamic> json) {
    spareId = json["spare_id"]?.toInt();
    spareCode = json["spare_code"]?.toString();
    spareName = json["spare_name"]?.toString();
    productId = json["product_id"]?.toInt();
    quantity = json["quantity"]?.toInt();
    productSubId = json["product_sub_id"]?.toInt();
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

class SpareCartEntity {
  String? responseCode;
  String? token;
  List<SpareCartListItems?>? data;

  SpareCartEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  SpareCartEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <SpareCartListItems>[];
      v.forEach((v) {
        arr0.add(SpareCartListItems.fromJson(v));
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

class SpareCartResponse {
  SpareCartEntity? spareCartEntity;

  SpareCartResponse({
    this.spareCartEntity,
  });

  SpareCartResponse.fromJson(Map<String, dynamic> json) {
    spareCartEntity = (json["response"] != null)
        ? SpareCartEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (spareCartEntity != null) {
      data["response"] = spareCartEntity!.toJson();
    }
    return data;
  }
}
