class AssessmentModel {
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

  AssessmentModel({
    this.assessmentId,
    this.assessmentName,
    this.assessmentStatus,
    this.totalQuations,
    this.quationToAssessment,
    this.threshold,
    this.score,
    this.status,
    this.statusName,
    this.trainingId
  });
}

class DataQuizModel {
  int? quationId;
  String? quation;
  String? optionA;
  String? optionB;
  String? optionC;
  String? optionD;
  String? correctAnswer;

  DataQuizModel({
    this.quationId,
    this.quation,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    this.correctAnswer,
  });
}