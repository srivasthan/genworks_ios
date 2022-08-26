class SuggestedTechnicianListItems {
  String? technicianName;
  String? technicianCode;

  SuggestedTechnicianListItems({
    this.technicianName,
    this.technicianCode,
  });
  SuggestedTechnicianListItems.fromJson(Map<String, dynamic> json) {
    technicianCode = json["technician_code"]?.toString();
    technicianName = json["technician_name"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["technician_code"] = technicianCode;
    data["technician_name"] = technicianName;
    return data;
  }
}

class SuggestedTechnicianEntity {

  String? responseCode;
  List<SuggestedTechnicianListItems?>? data;

  SuggestedTechnicianEntity({
    this.responseCode,
    this.data,
  });
  SuggestedTechnicianEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <SuggestedTechnicianListItems>[];
      v.forEach((v) {
        arr0.add(SuggestedTechnicianListItems.fromJson(v));
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

class SuggestedTechnicianResponse {
  SuggestedTechnicianEntity? suggestedTechnicianEntity;

  SuggestedTechnicianResponse({
    this.suggestedTechnicianEntity,
  });
  SuggestedTechnicianResponse.fromJson(Map<String, dynamic> json) {
    suggestedTechnicianEntity = (json["response"] != null) ? SuggestedTechnicianEntity.fromJson(json["response"]) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (suggestedTechnicianEntity != null) {
      data["response"] = suggestedTechnicianEntity!.toJson();
    }
    return data;
  }
}