import 'package:floor/floor.dart';

@entity
class AssessmentQuizDataTable {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int? quationId;
  final int? assessment_id;
  final String? quation;
  final String? optionA;
  final String? optionB;
  final String? optionC;
  final String? optionD;
  final String? correctAnswer;
  final bool? updateAnswer_a;
  final bool? updateAnswer_b;
  final bool? updateAnswer_c;
  final bool? updateAnswer_d;
  final String? your_answer;

  AssessmentQuizDataTable({
      this.id,
      this.quationId,
      this.assessment_id,
      this.quation,
      this.optionA,
      this.optionB,
      this.optionC,
      this.optionD,
      this.correctAnswer,
      this.updateAnswer_a,
      this.updateAnswer_b,
      this.updateAnswer_c,
      this.updateAnswer_d,
      this.your_answer});
}