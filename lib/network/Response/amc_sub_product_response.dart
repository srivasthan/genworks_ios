class AMCSubProductListItems {
  int? productSubId;
  String? productSubName;
  String? productSubModel;
  String? productSubDescription;
  String? productSubImage;
  int? productId;
  String? productName;

  AMCSubProductListItems({
    this.productSubId,
    this.productSubName,
    this.productSubModel,
    this.productSubDescription,
    this.productSubImage,
    this.productId,
    this.productName,
  });

  AMCSubProductListItems.fromJson(Map<String, dynamic> json) {
    productSubId = json["product_sub_id"]?.toInt();
    productSubName = json["product_sub_name"]?.toString();
    productSubModel = json["product_sub_model"]?.toString();
    productSubDescription = json["product_sub_description"]?.toString();
    productSubImage = json["product_sub_image"]?.toString();
    productId = json["product_id"]?.toInt();
    productName = json["product_name"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["product_sub_id"] = productSubId;
    data["product_sub_name"] = productSubName;
    data["product_sub_model"] = productSubModel;
    data["product_sub_description"] = productSubDescription;
    data["product_sub_image"] = productSubImage;
    data["product_id"] = productId;
    data["product_name"] = productName;
    return data;
  }
}

class AMCSubProductEntity {
  String? responseCode;
  List<AMCSubProductListItems?>? data;

  AMCSubProductEntity({
    this.responseCode,
    this.data,
  });

  AMCSubProductEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <AMCSubProductListItems>[];
      v.forEach((v) {
        arr0.add(AMCSubProductListItems.fromJson(v));
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

class AMCSubProductResponse {
  AMCSubProductEntity? amcSubProductEntity;

  AMCSubProductResponse({
    this.amcSubProductEntity,
  });

  AMCSubProductResponse.fromJson(Map<String, dynamic> json) {
    amcSubProductEntity = (json["response"] != null)
        ? AMCSubProductEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (amcSubProductEntity != null) {
      data["response"] = amcSubProductEntity!.toJson();
    }
    return data;
  }
}
