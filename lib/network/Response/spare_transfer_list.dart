class SpareTransfer {
  String? spareCode;
  int? quantity;

  SpareTransfer({
    this.spareCode,
    this.quantity,
  });

  SpareTransfer.fromJson(Map<String, dynamic> json) {
    spareCode = json["spare_code"]?.toString();
    quantity = json["quantity"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["spare_code"] = spareCode;
    data["quantity"] = quantity;
    return data;
  }
}

class SpareTransferListItems {
  String? spareTransferId;
  String? toTech;
  int? transferStatusCode;
  String? transferStatusName;
  List<SpareTransfer?>? transferData;

  SpareTransferListItems({
    this.spareTransferId,
    this.toTech,
    this.transferStatusCode,
    this.transferStatusName,
    this.transferData,
  });

  SpareTransferListItems.fromJson(Map<String, dynamic> json) {
    spareTransferId = json["spare_transfer_id"]?.toString();
    toTech = json["to_tech"]?.toString();
    transferStatusCode = json["transfer_status_code"]?.toInt();
    transferStatusName = json["transfer_status_name"]?.toString();
    if (json["transfer_data"] != null) {
      final v = json["transfer_data"];
      final arr0 = <SpareTransfer>[];
      v.forEach((v) {
        arr0.add(SpareTransfer.fromJson(v));
      });
      transferData = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["spare_transfer_id"] = spareTransferId;
    data["to_tech"] = toTech;
    data["transfer_status_code"] = transferStatusCode;
    data["transfer_status_name"] = transferStatusName;
    if (transferData != null) {
      final v = transferData;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["transfer_data"] = arr0;
    }
    return data;
  }
}

class SpareTransferEntity {
  String? responseCode;
  String? token;
  List<SpareTransferListItems?>? data;

  SpareTransferEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  SpareTransferEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <SpareTransferListItems>[];
      v.forEach((v) {
        arr0.add(SpareTransferListItems.fromJson(v));
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

class SpareTransferResponse {
  SpareTransferEntity? spareTransferEntity;

  SpareTransferResponse({
    this.spareTransferEntity,
  });

  SpareTransferResponse.fromJson(Map<String, dynamic> json) {
    spareTransferEntity = (json["response"] != null)
        ? SpareTransferEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (spareTransferEntity != null) {
      data["response"] = spareTransferEntity!.toJson();
    }
    return data;
  }
}
