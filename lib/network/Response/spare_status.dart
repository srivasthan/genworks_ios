class SpareStatusList {
  String? ticketId;
  String? frmStatus;
  String? spareCode;
  String? spareName;
  String? spareLocation;
  String? invoiceNumber;
  String? docketNumber;
  int? spareQuantity;
  int? approvedQuantity;

  SpareStatusList({
    this.ticketId,
    this.frmStatus,
    this.spareCode,
    this.spareName,
    this.spareLocation,
    this.approvedQuantity,
    this.spareQuantity,
  });

  SpareStatusList.fromJson(Map<String, dynamic> json) {
    ticketId = json["ticket_id"]?.toString();
    frmStatus = json["spare_status_name"]?.toString();
    spareCode = json["spare_code"]?.toString();
    spareName = json["spare_name"]?.toString();
    spareLocation = json["spare_location_name"]?.toString();
    invoiceNumber = json["invoice_number"]?.toString();
    docketNumber = json["docket_number"]?.toString();
    spareQuantity = json["spare_quantity"]?.toInt();
    approvedQuantity = json["approved_quantity"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["ticket_id"] = ticketId;
    data["spare_status_name"] = frmStatus;
    data["spare_code"] = spareCode;
    data["spare_name"] = spareName;
    data["spare_location_name"] = spareLocation;
    data["invoice_number"] = invoiceNumber;
    data["docket_number"] = docketNumber;
    data["spare_quantity"] = spareQuantity;
    data["approved_quantity"] = approvedQuantity;
    return data;
  }
}

class SpareStatusEntity {
  String? responseCode;
  String? token;
  String? message;
  List<SpareStatusList?>? data;

  SpareStatusEntity({
    this.responseCode,
    this.token,
    this.message,
    this.data,
  });

  SpareStatusEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    message = json["message"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <SpareStatusList>[];
      v.forEach((v) {
        arr0.add(SpareStatusList.fromJson(v));
      });
      this.data = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
    data["message"] = message;
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

class SpareStatusResponse {
  SpareStatusEntity? spareStatusEntity;

  SpareStatusResponse({
    this.spareStatusEntity,
  });

  SpareStatusResponse.fromJson(Map<String, dynamic> json) {
    spareStatusEntity = (json["response"] != null)
        ? SpareStatusEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (spareStatusEntity != null) {
      data["response"] = spareStatusEntity!.toJson();
    }
    return data;
  }
}
