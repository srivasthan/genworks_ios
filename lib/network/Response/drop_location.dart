class DropLocationListItem {
  int? warehouseId;
  String? warehouseName;
  int? leadTime;

  DropLocationListItem({
    this.warehouseId,
    this.warehouseName,
    this.leadTime,
  });

  DropLocationListItem.fromJson(Map<String, dynamic> json) {
    warehouseId = json["warehouse_id"]?.toInt();
    warehouseName = json["warehouse_name"]?.toString();
    leadTime = json["lead_time"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["warehouse_id"] = warehouseId;
    data["warehouse_name"] = warehouseName;
    data["lead_time"] = leadTime;
    return data;
  }
}

class DropLocationEntity {
  String? responseCode;
  List<DropLocationListItem?>? data;

  DropLocationEntity({
    this.responseCode,
    this.data,
  });

  DropLocationEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <DropLocationListItem>[];
      v.forEach((v) {
        arr0.add(DropLocationListItem.fromJson(v));
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

class DropLocationResponse {
  DropLocationEntity? dropLocationEntity;

  DropLocationResponse({
    this.dropLocationEntity,
  });

  DropLocationResponse.fromJson(Map<String, dynamic> json) {
    dropLocationEntity = (json["response"] != null)
        ? DropLocationEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (dropLocationEntity != null) {
      data["response"] = dropLocationEntity!.toJson();
    }
    return data;
  }
}
