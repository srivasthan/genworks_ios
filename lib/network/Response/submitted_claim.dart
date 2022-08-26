class SubmittedClaimList {
  String? startDate;
  String? endDate;
  String? comment;
  int? totalAmmount;
  int? status;
  String? statusName;

  SubmittedClaimList({
    this.startDate,
    this.endDate,
    this.comment,
    this.totalAmmount,
    this.status,
    this.statusName,
  });

  SubmittedClaimList.fromJson(Map<String, dynamic> json) {
    startDate = json["start_date"]?.toString();
    endDate = json["end_date"]?.toString();
    comment = json["comment"]?.toString();
    totalAmmount = json["total_ammount"]?.toInt();
    status = json["status"]?.toInt();
    statusName = json["status_name"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["start_date"] = startDate;
    data["end_date"] = endDate;
    data["comment"] = comment;
    data["total_ammount"] = totalAmmount;
    data["status"] = status;
    data["status_name"] = statusName;
    return data;
  }
}

class SubmittedClaimEntity {
  String? responseCode;
  String? token;
  List<SubmittedClaimList?>? data;

  SubmittedClaimEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  SubmittedClaimEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <SubmittedClaimList>[];
      v.forEach((v) {
        arr0.add(SubmittedClaimList.fromJson(v));
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

class SubmittedClaimResponse {
  SubmittedClaimEntity? submittedClaimEntity;

  SubmittedClaimResponse({
    this.submittedClaimEntity,
  });

  SubmittedClaimResponse.fromJson(Map<String, dynamic> json) {
    submittedClaimEntity = (json["response"] != null)
        ? SubmittedClaimEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (submittedClaimEntity != null) {
      data["response"] = submittedClaimEntity!.toJson();
    }
    return data;
  }
}
