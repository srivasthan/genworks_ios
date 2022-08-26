class CallCategoryListItems {
  int? callCategoryId;
  String? callCategoryName;

  CallCategoryListItems({
    this.callCategoryId,
    this.callCategoryName,
  });

  CallCategoryListItems.fromJson(Map<String, dynamic> json) {
    callCategoryId = json["call_category_id"]?.toInt();
    callCategoryName = json["call_category"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["call_category_id"] = callCategoryId;
    data["call_category"] = callCategoryName;
    return data;
  }
}

class CallCategoryEntity {
  String? responseCode;
  List<CallCategoryListItems?>? data;

  CallCategoryEntity({
    this.responseCode,
    this.data,
  });

  CallCategoryEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <CallCategoryListItems>[];
      v.forEach((v) {
        arr0.add(CallCategoryListItems.fromJson(v));
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

class CallCategoryResponse {
  CallCategoryEntity? callCategoryEntity;

  CallCategoryResponse({
    this.callCategoryEntity,
  });

  CallCategoryResponse.fromJson(Map<String, dynamic> json) {
    callCategoryEntity = (json["response"] != null)
        ? CallCategoryEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (callCategoryEntity != null) {
      data["response"] = callCategoryEntity!.toJson();
    }
    return data;
  }
}
