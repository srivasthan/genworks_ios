class PendingFrmList {
  String? ticketId;
  String? frmStatus;
  String? spareCode;
  String? spareLocation;
  int? spareQuantity;

  PendingFrmList({
    this.ticketId,
    this.frmStatus,
    this.spareCode,
    this.spareLocation,
    this.spareQuantity,
  });

  PendingFrmList.fromJson(Map<String, dynamic> json) {
    ticketId = json["ticket_id"]?.toString();
    frmStatus = json["frm_status_name"]?.toString();
    spareCode = json["spare_code"]?.toString();
    spareLocation = json["spare_location"]?.toString();
    spareQuantity = json["spare_quantity"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["ticket_id"] = ticketId;
    data["frm_status_name"] = frmStatus;
    data["spare_code"] = spareCode;
    data["spare_location"] = spareLocation;
    data["spare_quantity"] = spareQuantity;
    return data;
  }
}

class PendingFrmEntity {
  String? responseCode;
  String? token;
  List<PendingFrmList?>? data;

  PendingFrmEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  PendingFrmEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <PendingFrmList>[];
      v.forEach((v) {
        arr0.add(PendingFrmList.fromJson(v));
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

class PendingFrmResponse {
  PendingFrmEntity? pendingFrmEntity;

  PendingFrmResponse({
    this.pendingFrmEntity,
  });

  PendingFrmResponse.fromJson(Map<String, dynamic> json) {
    pendingFrmEntity = (json["response"] != null)
        ? PendingFrmEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (pendingFrmEntity != null) {
      data["response"] = pendingFrmEntity!.toJson();
    }
    return data;
  }
}
