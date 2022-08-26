
class SelectTechnicianListItems {

  String? technicianCode;
  String? technicianName;

  SelectTechnicianListItems({
    this.technicianCode,
    this.technicianName,
  });
  SelectTechnicianListItems.fromJson(Map<String, dynamic> json) {
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

class SelectTechnicianEntity {
  String? responseCode;
  List<SelectTechnicianListItems?>? data;

  SelectTechnicianEntity({
    this.responseCode,
    this.data,
  });
  SelectTechnicianEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <SelectTechnicianListItems>[];
      v.forEach((v) {
        arr0.add(SelectTechnicianListItems.fromJson(v));
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

class SelectTechnicianResponse {
  SelectTechnicianEntity? selectTechnicianEntity;

  SelectTechnicianResponse({
    this.selectTechnicianEntity,
  });
  SelectTechnicianResponse.fromJson(Map<String, dynamic> json) {
    selectTechnicianEntity = (json["response"] != null) ? SelectTechnicianEntity.fromJson(json["response"]) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (selectTechnicianEntity != null) {
      data["response"] = selectTechnicianEntity!.toJson();
    }
    return data;
  }
}
