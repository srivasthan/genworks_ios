class TrainingReferenceListItems {
  int? trainingDetailsId;
  String? trainingId;
  String? trainingTitle;
  String? trainingThumbImage;
  String? trainingContentType;
  String? trainingContent;

  TrainingReferenceListItems({
    this.trainingDetailsId,
    this.trainingId,
    this.trainingTitle,
    this.trainingThumbImage,
    this.trainingContentType,
    this.trainingContent,
  });

  TrainingReferenceListItems.fromJson(Map<String, dynamic> json) {
    trainingDetailsId = json["training_details_id"]?.toInt();
    trainingId = json["training_id"]?.toString();
    trainingTitle = json["training_title"]?.toString();
    trainingThumbImage = json["training_thumb_image"]?.toString();
    trainingContentType = json["training_content_type"]?.toString();
    trainingContent = json["training_content"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["training_details_id"] = trainingDetailsId;
    data["training_id"] = trainingId;
    data["training_title"] = trainingTitle;
    data["training_thumb_image"] = trainingThumbImage;
    data["training_content_type"] = trainingContentType;
    data["training_content"] = trainingContent;
    return data;
  }
}

class TrainingReferenceEntity {
  String? responseCode;
  String? token;
  List<TrainingReferenceListItems?>? data;

  TrainingReferenceEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  TrainingReferenceEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <TrainingReferenceListItems>[];
      v.forEach((v) {
        arr0.add(TrainingReferenceListItems.fromJson(v));
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

class TrainingReferenceResponse {
  TrainingReferenceEntity? trainingReferenceEntity;

  TrainingReferenceResponse({
    this.trainingReferenceEntity,
  });

  TrainingReferenceResponse.fromJson(Map<String, dynamic> json) {
    trainingReferenceEntity = (json["response"] != null)
        ? TrainingReferenceEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (trainingReferenceEntity != null) {
      data["response"] = trainingReferenceEntity!.toJson();
    }
    return data;
  }
}
