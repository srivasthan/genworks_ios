class TrainingList {
  String? trainingId;
  String? trainingTitle;
  String? certificateId;
  String? trainingThumbImage;
  String? trainingContentType;
  String? trainingContent;

  TrainingList({
    this.trainingId,
    this.trainingTitle,
    this.certificateId,
    this.trainingThumbImage,
    this.trainingContentType,
    this.trainingContent,
  });

  TrainingList.fromJson(Map<String, dynamic> json) {
    trainingId = json["training_id"]?.toString();
    trainingTitle = json["training_title"]?.toString();
    certificateId = json["certificate_id"]?.toString();
    trainingThumbImage = json["training_thumb_image"]?.toString();
    trainingContentType = json["training_content_type"]?.toString();
    trainingContent = json["training_content"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["training_id"] = trainingId;
    data["training_title"] = trainingTitle;
    data["certificate_id"] = certificateId;
    data["training_thumb_image"] = trainingThumbImage;
    data["training_content_type"] = trainingContentType;
    data["training_content"] = trainingContent;
    return data;
  }
}

class TrainingEntity {
  String? responseCode;
  String? token;
  List<TrainingList?>? data;

  TrainingEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  TrainingEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <TrainingList>[];
      v.forEach((v) {
        arr0.add(TrainingList.fromJson(v));
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

class TrainingResponse {
  TrainingEntity? trainingEntity;

  TrainingResponse({
    this.trainingEntity,
  });

  TrainingResponse.fromJson(Map<String, dynamic> json) {
    trainingEntity = (json["response"] != null)
        ? TrainingEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (trainingEntity != null) {
      data["response"] = trainingEntity!.toJson();
    }
    return data;
  }
}
