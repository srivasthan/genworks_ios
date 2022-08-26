class TokenEntity {
  String? responseCode;
  String? data;

  TokenEntity({
    this.responseCode,
    this.data,
  });

  TokenEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    data = json["data"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["data"] = this.data;
    return data;
  }
}

class TokenResponse {
  TokenEntity? tokenEntity;

  TokenResponse({
    this.tokenEntity,
  });

  TokenResponse.fromJson(Map<String, dynamic> json) {
    tokenEntity = (json["response"] != null)
        ? TokenEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (tokenEntity != null) {
      data["response"] = tokenEntity!.toJson();
    }
    return data;
  }
}
