class AddTransferEntity {
  String? responseCode;
  String? token;
  String? message;
  String? mesage;

  AddTransferEntity({
    this.responseCode,
    this.token,
    this.message,
    this.mesage
  });

  AddTransferEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    message = json["message"]?.toString();
    mesage = json["mesage"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
    data["message"] = message;
    data["mesage"] = mesage;
    return data;
  }
}

class AddTransferResponse {
  AddTransferEntity? addTransferEntity;

  AddTransferResponse({
    this.addTransferEntity,
  });

  AddTransferResponse.fromJson(Map<String, dynamic> json) {
    addTransferEntity = (json["response"] != null)
        ? AddTransferEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (addTransferEntity != null) {
      data["response"] = addTransferEntity!.toJson();
    }
    return data;
  }
}
