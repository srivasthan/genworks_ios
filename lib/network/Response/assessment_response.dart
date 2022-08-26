class DataQuiz {
  int? quationId;
  String? quation;
  String? optionA;
  String? optionB;
  String? optionC;
  String? optionD;
  String? correctAnswer;

  DataQuiz({
    this.quationId,
    this.quation,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    this.correctAnswer,
  });

  DataQuiz.fromJson(Map<String, dynamic> json) {
    quationId = json["quation_id"]?.toInt();
    quation = json["quation"]?.toString();
    optionA = json["option_a"]?.toString();
    optionB = json["option_b"]?.toString();
    optionC = json["option_c"]?.toString();
    optionD = json["option_d"]?.toString();
    correctAnswer = json["correct_answer"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["quation_id"] = quationId;
    data["quation"] = quation;
    data["option_a"] = optionA;
    data["option_b"] = optionB;
    data["option_c"] = optionC;
    data["option_d"] = optionD;
    data["correct_answer"] = correctAnswer;
    return data;
  }
}

class AssessmentResponseListItems {
  int? assessmentId;
  String? assessmentName;
  int? assessmentStatus;
  int? totalQuations;
  int? quationToAssessment;
  int? threshold;
  int? score;
  int? status;
  String? statusName;
  String? trainingId;
  List<DataQuiz?>? quiz;

  AssessmentResponseListItems({
    this.assessmentId,
    this.assessmentName,
    this.assessmentStatus,
    this.totalQuations,
    this.quationToAssessment,
    this.threshold,
    this.score,
    this.status,
    this.statusName,
    this.trainingId,
    this.quiz,
  });

  AssessmentResponseListItems.fromJson(Map<String, dynamic> json) {
    assessmentId = json["assessment_id"]?.toInt();
    assessmentName = json["assessment_name"]?.toString();
    assessmentStatus = json["assessment_status"]?.toInt();
    totalQuations = json["total_quations"]?.toInt();
    quationToAssessment = json["quation_to_assessment"]?.toInt();
    threshold = json["threshold"]?.toInt();
    score = json["score"]?.toInt();
    status = json["status"]?.toInt();
    statusName = json["status_name"]?.toString();
    trainingId = json["training_id"]?.toString();
    if (json["quiz"] != null) {
      final v = json["quiz"];
      final arr0 = <DataQuiz>[];
      v.forEach((v) {
        arr0.add(DataQuiz.fromJson(v));
      });
      quiz = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["assessment_id"] = assessmentId;
    data["assessment_name"] = assessmentName;
    data["assessment_status"] = assessmentStatus;
    data["total_quations"] = totalQuations;
    data["quation_to_assessment"] = quationToAssessment;
    data["threshold"] = threshold;
    data["score"] = score;
    data["status"] = status;
    data["status_name"] = statusName;
    data["training_id"] = trainingId;
    if (quiz != null) {
      final v = quiz;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["quiz"] = arr0;
    }
    return data;
  }
}

class AssessmentEntity {
  String? responseCode;
  String? token;
  List<AssessmentResponseListItems?>? data;

  AssessmentEntity({
    this.responseCode,
    this.token,
    this.data,
  });

  AssessmentEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <AssessmentResponseListItems>[];
      v.forEach((v) {
        arr0.add(AssessmentResponseListItems.fromJson(v));
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

class AssessmentResponse {
  AssessmentEntity? assessmentEntity;

  AssessmentResponse({
    this.assessmentEntity,
  });

  AssessmentResponse.fromJson(Map<String, dynamic> json) {
    assessmentEntity = (json["response"] != null)
        ? AssessmentEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (assessmentEntity != null) {
      data["response"] = assessmentEntity!.toJson();
    }
    return data;
  }
}
