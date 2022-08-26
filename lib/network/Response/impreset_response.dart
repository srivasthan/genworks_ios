class ImpresetResponseItemList {
  int? productGst;
  int? serviceGst;
  int? subTotal;
  String? priceLable;
  int? thresholdPercent;
  String? priceType;
  int? serviceCharge;
  int? spareCharge;
  String? customerEmailId;
  String? contactNumber;
  String? expiryDate;
  int? expirationStatus;

  ImpresetResponseItemList({
    this.productGst,
    this.serviceGst,
    this.subTotal,
    this.priceType,
    this.thresholdPercent,
    this.priceLable,
    this.serviceCharge,
    this.spareCharge,
    this.customerEmailId,
    this.contactNumber,
    this.expiryDate,
    this.expirationStatus,
  });

  ImpresetResponseItemList.fromJson(Map<String, dynamic> json) {
    productGst = json["product_gst"]?.toInt();
    serviceGst = json["service_gst"]?.toInt();
    subTotal = json["sub_total"]?.toInt();
    priceLable = json["price_lable"]?.toString();
    thresholdPercent = json["threshold_percent"]?.toInt();
    priceType = json["price_type"]?.toString();
    serviceCharge = json["service_charge"]?.toInt();
    spareCharge = json["spare_charge"]?.toInt();
    customerEmailId = json["customer_email_id"]?.toString();
    contactNumber = json["contact_number"]?.toString();
    expiryDate = json["expiry_date"]?.toString();
    expirationStatus = json["expiration_status"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["product_gst"] = productGst;
    data["service_gst"] = serviceGst;
    data["sub_total"] = subTotal;
    data["price_type"] = priceType;
    data["threshold_percent"] = thresholdPercent;
    data["price_lable"] = priceLable;
    data["service_charge"] = serviceCharge;
    data["spare_charge"] = spareCharge;
    data["customer_email_id"] = customerEmailId;
    data["contact_number"] = contactNumber;
    data["expiry_date"] = expiryDate;
    data["expiration_status"] = expirationStatus;
    return data;
  }
}

class ImpresetResponseEntity {
  String? responseCode;
  String? token;
  String? message;
  ImpresetResponseItemList? data;

  ImpresetResponseEntity({
    this.responseCode,
    this.token,
    this.message,
    this.data,
  });

  ImpresetResponseEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    message = json["message"]?.toString();
    data = (json["data"] != null)
        ? ImpresetResponseItemList.fromJson(json["data"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
    data["message"] = message;
    data["data"] = this.data!.toJson();
    return data;
  }
}

class ImpresetResponse {
  ImpresetResponseEntity? impresetResponseEntity;

  ImpresetResponse({
    this.impresetResponseEntity,
  });

  ImpresetResponse.fromJson(Map<String, dynamic> json) {
    impresetResponseEntity = (json["response"] != null)
        ? ImpresetResponseEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (impresetResponseEntity != null) {
      data["response"] = impresetResponseEntity!.toJson();
    }
    return data;
  }
}
