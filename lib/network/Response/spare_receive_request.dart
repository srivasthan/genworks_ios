class SpareReceiveDatum {
  String? spareCode;
  int? quantity;

  SpareReceiveDatum({
    this.spareCode,
    this.quantity,
  });

  SpareReceiveDatum.fromJson(
      Map<String, dynamic> json) {
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

class SpareReceiveItems {
  String? spareTransferId;
  String? fromTech;
  String? transferStatus;
  int? transferStatusCode;
  List<SpareReceiveDatum?>? transferData;

  SpareReceiveItems({
    this.spareTransferId,
    this.fromTech,
    this.transferStatus,
    this.transferData,
  });

  SpareReceiveItems.fromJson(Map<String, dynamic> json) {
    spareTransferId = json["spare_transfer_id"]?.toString();
    fromTech = json["from_tech"]?.toString();
    transferStatus = json["transfer_status_name"]?.toString();
    transferStatusCode = json["transfer_status_code"]?.toInt();
    if (json["transfer_data"] != null) {
      final v = json["transfer_data"];
      final arr0 = <SpareReceiveDatum>[];
      v.forEach((v) {
        arr0.add(SpareReceiveDatum.fromJson(v));
      });
      transferData = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["spare_transfer_id"] = spareTransferId;
    data["from_tech"] = fromTech;
    data["transfer_status_name"] = transferStatus;
    data["transfer_status_code"] = transferStatusCode;
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

class SpareReceiveEntity {
  String? responseCode;
  String? token;
  List<SpareReceiveItems?>? data;

  SpareReceiveEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  SpareReceiveEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <SpareReceiveItems>[];
      v.forEach((v) {
        arr0.add(SpareReceiveItems.fromJson(v));
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

class SpareReceiveResponse {
  SpareReceiveEntity? spareReceiveEntity;

  SpareReceiveResponse({
    this.spareReceiveEntity,
  });

  SpareReceiveResponse.fromJson(Map<String, dynamic> json) {
    spareReceiveEntity = (json["response"] != null)
        ? SpareReceiveEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (spareReceiveEntity != null) {
      data["response"] = spareReceiveEntity!.toJson();
    }
    return data;
  }
}
