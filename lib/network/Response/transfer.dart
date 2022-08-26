class TransferResponseEntity {
  String? responseCode;
  String? token;
  String? message;

  TransferResponseEntity({
    this.responseCode,
    this.token,
    this.message,
  });

  TransferResponseEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    message = json["message"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
    data["message"] = message;
    return data;
  }
}

class TransferResponse {
  TransferResponseEntity? transferResponseEntity;

  TransferResponse({
    this.transferResponseEntity,
  });

  TransferResponse.fromJson(Map<String, dynamic> json) {
    transferResponseEntity = (json["response"] != null)
        ? TransferResponseEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (transferResponseEntity != null) {
      data["response"] = transferResponseEntity!.toJson();
    }
    return data;
  }
}
