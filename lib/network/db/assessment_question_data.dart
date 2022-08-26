import 'package:floor/floor.dart';

@entity
class AssessmentQuestionDataTable {
  @primaryKey
  final int? id;

  final int? assessmentId;
  final String? assessmentName;
  final int? totalQuations;
  final int? quationToAssessment;
  final int? score;
  final String? status;
  final String? trainingId;
  final int? threshold;
  final bool? assessment_status;

  AssessmentQuestionDataTable({
      this.id,
      this.assessmentId,
      this.assessmentName,
      this.totalQuations,
      this.quationToAssessment,
      this.score,
      this.status,
      this.trainingId,
      this.threshold,
      this.assessment_status});
}
