class Data {
  int? productId;
  String? productName;
  String? productModel;
  String? productDescription;
  String? productImage;

  Data({
    this.productId,
    this.productName,
    this.productModel,
    this.productDescription,
    this.productImage,
  });

  Data.fromJson(Map<String, dynamic> json) {
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

class ProductEntity {
  String? responseCode;
  List<Data?>? data;

  ProductEntity({
    this.responseCode,
    this.data,
  });

  ProductEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <Data>[];
      v.forEach((v) {
        arr0.add(Data.fromJson(v));
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

class ProductResponse {
  ProductEntity? productEntity;

  ProductResponse({
    this.productEntity,
  });

  ProductResponse.fromJson(Map<String, dynamic> json) {
    productEntity = (json["response"] != null)
        ? ProductEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (productEntity != null) {
      data["response"] = productEntity!.toJson();
    }
    return data;
  }
}
