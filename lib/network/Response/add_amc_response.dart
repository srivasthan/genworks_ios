class AddAMCListItems {
  int? amcId;
  String? amcType;
  int? duration;
  int? priceType;
  int? cost;
  int? status;

  AddAMCListItems({
    this.amcId,
    this.amcType,
    this.duration,
    this.priceType,
    this.cost,
    this.status,
  });

  AddAMCListItems.fromJson(Map<String, dynamic> json) {
    amcId = json["amc_id"]?.toInt();
    amcType = json["amc_type"]?.toString();
    duration = json["duration"]?.toInt();
    priceType = json["price_type"]?.toInt();
    cost = json["cost"]?.toInt();
    status = json["status"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["amc_id"] = amcId;
    data["amc_type"] = amcType;
    data["duration"] = duration;
    data["price_type"] = priceType;
    data["cost"] = cost;
    data["status"] = status;
    return data;
  }
}

class AddAMCEntity {
  String? responseCode;
  List<AddAMCListItems?>? data;

  AddAMCEntity({
    this.responseCode,
    this.data,
  });

  AddAMCEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <AddAMCListItems>[];
      v.forEach((v) {
        arr0.add(AddAMCListItems.fromJson(v));
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

class AddAMCResponse {
  AddAMCEntity? addAMCEntity;

  AddAMCResponse({
    this.addAMCEntity,
  });

  AddAMCResponse.fromJson(Map<String, dynamic> json) {
    addAMCEntity = (json["response"] != null)
        ? AddAMCEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (addAMCEntity != null) {
      data["response"] = addAMCEntity!.toJson();
    }
    return data;
  }
}
