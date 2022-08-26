class AMCProductListItems {
  int? productId;
  String? productName;
  String? productModel;
  String? productDescription;
  String? productImage;

  AMCProductListItems({
    this.productId,
    this.productName,
    this.productModel,
    this.productDescription,
    this.productImage,
  });

  AMCProductListItems.fromJson(Map<String, dynamic> json) {
    productId = json["product_id"]?.toInt();
    productName = json["product_name"]?.toString();
    productModel = json["product_model"]?.toString();
    productDescription = json["product_description"]?.toString();
    productImage = json["product_image"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["product_id"] = productId;
    data["product_name"] = productName;
    data["product_model"] = productModel;
    data["product_description"] = productDescription;
    data["product_image"] = productImage;
    return data;
  }
}

class AMCProductEntity {
  String? responseCode;
  List<AMCProductListItems?>? data;

  AMCProductEntity({
    this.responseCode,
    this.data,
  });

  AMCProductEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <AMCProductListItems>[];
      v.forEach((v) {
        arr0.add(AMCProductListItems.fromJson(v));
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

class AMCProductResponse {
  AMCProductEntity? amcProductEntity;

  AMCProductResponse({
    this.amcProductEntity,
  });

  AMCProductResponse.fromJson(Map<String, dynamic> json) {
    amcProductEntity = (json["response"] != null)
        ? AMCProductEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (amcProductEntity != null) {
      data["response"] = amcProductEntity!.toJson();
    }
    return data;
  }
}
