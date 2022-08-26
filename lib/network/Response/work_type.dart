class WorkTypeListItems {
  int? workTypeId;
  String? workType;

  WorkTypeListItems({
    this.workTypeId,
    this.workType,
  });

  WorkTypeListItems.fromJson(Map<String, dynamic> json) {
    workTypeId = json['work_type_id']?.toInt();
    workType = json['work_type']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['work_type_id'] = workTypeId;
    data['work_type'] = workType;
    return data;
  }
}

class WorkTypeEntity {
  String? responseCode;
  List<WorkTypeListItems?>? data;

  WorkTypeEntity({
    this.responseCode,
    this.data,
  });

  WorkTypeEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code']?.toString();
    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <WorkTypeListItems>[];
      v.forEach((v) {
        arr0.add(WorkTypeListItems.fromJson(v));
      });
      this.data = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['response_code'] = responseCode;
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['data'] = arr0;
    }
    return data;
  }
}

class WorkTypeResponse {
  WorkTypeEntity? workTypeEntity;

  WorkTypeResponse({
    this.workTypeEntity,
  });

  WorkTypeResponse.fromJson(Map<String, dynamic> json) {
    workTypeEntity = (json['response'] != null)
        ? WorkTypeEntity.fromJson(json['response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (workTypeEntity != null) {
      data['response'] = workTypeEntity!.toJson();
    }
    return data;
  }
}
