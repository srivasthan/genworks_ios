class ReferSolutionListItems {
  String? problemDesc;
  String? productCategory;
  String? category;
  String? solution;
  String? uploadImage;
  String? uploadVideo;

  ReferSolutionListItems({
    this.problemDesc,
    this.productCategory,
    this.category,
    this.solution,
    this.uploadImage,
    this.uploadVideo,
  });

  ReferSolutionListItems.fromJson(Map<String, dynamic> json) {
    problemDesc = json["problem_desc"]?.toString();
    productCategory = json["product_category"]?.toString();
    category = json["category"]?.toString();
    solution = json["solution"]?.toString();
    uploadImage = json["upload_image"]?.toString();
    uploadVideo = json["upload_video"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["problem_desc"] = problemDesc;
    data["product_category"] = productCategory;
    data["category"] = category;
    data["solution"] = solution;
    data["upload_image"] = uploadImage;
    data["upload_video"] = uploadVideo;
    return data;
  }
}

class ReferSolutionEntity {
  String? responseCode;
  String? token;
  List<ReferSolutionListItems?>? data;

  ReferSolutionEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  ReferSolutionEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <ReferSolutionListItems>[];
      v.forEach((v) {
        arr0.add(ReferSolutionListItems.fromJson(v));
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

class ReferSolutionResponse {
  ReferSolutionEntity? referSolutionEntity;

  ReferSolutionResponse({
    this.referSolutionEntity,
  });

  ReferSolutionResponse.fromJson(Map<String, dynamic> json) {
    referSolutionEntity = (json["response"] != null)
        ? ReferSolutionEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (referSolutionEntity != null) {
      data["response"] = referSolutionEntity!.toJson();
    }
    return data;
  }
}
