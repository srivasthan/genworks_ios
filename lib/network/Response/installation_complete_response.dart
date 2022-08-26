class InstallationCompleteListItems {
  int? serCheckListId;
  String? serviceGroup;
  String? description;
  int? quationType;

  InstallationCompleteListItems({
    this.serCheckListId,
    this.serviceGroup,
    this.description,
    this.quationType,
  });

  InstallationCompleteListItems.fromJson(Map<String, dynamic> json) {
    serCheckListId = json["ser_check_list_id"]?.toInt();
    serviceGroup = json["service_group"]?.toString();
    description = json["description"]?.toString();
    quationType = json["quation_type"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["ser_check_list_id"] = serCheckListId;
    data["service_group"] = serviceGroup;
    data["description"] = description;
    data["quation_type"] = quationType;
    return data;
  }
}

class InstallationCompleteEntity {
  String? responseCode;
  String? token;
  String? message;
  List<InstallationCompleteListItems?>? data;

  InstallationCompleteEntity({
    this.responseCode,
    this.token,
    this.message,
    this.data,
  });

  InstallationCompleteEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    message = json["message"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <InstallationCompleteListItems>[];
      v.forEach((v) {
        arr0.add(InstallationCompleteListItems.fromJson(v));
      });
      this.data = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["message"] = message;
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

class InstallationCompleteResponse {
  InstallationCompleteEntity? installationCompleteEntity;

  InstallationCompleteResponse({
    this.installationCompleteEntity,
  });

  InstallationCompleteResponse.fromJson(Map<String, dynamic> json) {
    installationCompleteEntity = (json["response"] != null)
        ? InstallationCompleteEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (installationCompleteEntity != null) {
      data["response"] = installationCompleteEntity!.toJson();
    }
    return data;
  }
}
