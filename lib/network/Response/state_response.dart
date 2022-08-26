class StateListItems {
  int? stateId;
  String? stateName;

  StateListItems({
    this.stateId,
    this.stateName,
  });

  StateListItems.fromJson(Map<String, dynamic> json) {
    stateId = json["state_id"]?.toInt();
    stateName = json["state_name"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["state_id"] = stateId;
    data["state_name"] = stateName;
    return data;
  }
}

class StateEntity {
  String? responseCode;
  List<StateListItems?>? data;

  StateEntity({
    this.responseCode,
    this.data,
  });

  StateEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <StateListItems>[];
      v.forEach((v) {
        arr0.add(StateListItems.fromJson(v));
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

class StateResponse {
  StateEntity? stateEntity;

  StateResponse({
    this.stateEntity,
  });

  StateResponse.fromJson(Map<String, dynamic> json) {
    stateEntity = (json["response"] != null)
        ? StateEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (stateEntity != null) {
      data["response"] = stateEntity!.toJson();
    }
    return data;
  }
}
