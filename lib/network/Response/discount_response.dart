class DiscountResponseListItems {
  String? ticketId;
  String? technicianCode;
  String? productGst;
  String? serviceGst;
  int? subTotal;
  String? priceLable;
  String? priceType;
  int? discount;
  int? discountAmount;
  int? discountType;
  int? total;
  int? thresholdPercent;
  String? serviceCharge;
  String? spareCharge;

  DiscountResponseListItems({
    this.ticketId,
    this.technicianCode,
    this.productGst,
    this.serviceGst,
    this.subTotal,
    this.priceType,
    this.priceLable,
    this.discount,
    this.discountAmount,
    this.discountType,
    this.total,
    this.thresholdPercent,
    this.serviceCharge,
    this.spareCharge,
  });

  DiscountResponseListItems.fromJson(Map<String, dynamic> json) {
    ticketId = json["ticket_id"]?.toString();
    technicianCode = json["technician_code"]?.toString();
    productGst = json["product_gst"]?.toString();
    serviceGst = json["service_gst"]?.toString();
    subTotal = json["sub_total"]?.toInt();
    priceLable = json["price_lable"]?.toString();
    priceType = json["price_type"]?.toInt();
    discount = json["discount"]?.toInt();
    discountAmount = json["discount_amount"]?.toInt();
    discountType = json["discount_type"]?.toInt();
    total = json["total"]?.toInt();
    thresholdPercent = json["threshold_percent"]?.toInt();
    serviceCharge = json["service_charge"]?.toString();
    spareCharge = json["spare_charge"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["ticket_id"] = ticketId;
    data["technician_code"] = technicianCode;
    data["product_gst"] = productGst;
    data["service_gst"] = serviceGst;
    data["sub_total"] = subTotal;
    data["price_type"] = priceLable;
    data["price_lable"] = priceType;
    data["discount"] = discount;
    data["discount_amount"] = discountAmount;
    data["discount_type"] = discountType;
    data["total"] = total;
    data["threshold_percent"] = thresholdPercent;
    data["service_charge"] = serviceCharge;
    data["spare_charge"] = spareCharge;
    return data;
  }
}

class DiscountResponseEntity {
  String? responseCode;
  String? token;
  DiscountResponseListItems? data;

  DiscountResponseEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  DiscountResponseEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    data = (json["data"] != null)
        ? DiscountResponseListItems.fromJson(json["data"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
    data["data"] = this.data!.toJson();
    return data;
  }
}

class DiscountResponse {
  DiscountResponseEntity? discountResponseEntity;

  DiscountResponse({
    this.discountResponseEntity,
  });

  DiscountResponse.fromJson(Map<String, dynamic> json) {
    discountResponseEntity = (json["response"] != null)
        ? DiscountResponseEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (discountResponseEntity != null) {
      data["response"] = discountResponseEntity!.toJson();
    }
    return data;
  }
}
