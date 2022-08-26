import 'package:floor/floor.dart';

import 'assessment_question_data.dart';

@dao
abstract class AssessmentQuestionDataDao {
  @Query('SELECT * FROM AssessmentQuestionDataTable')
  Future<List<AssessmentQuestionDataTable>> findAllAssessmentQuestionData();

  @Query(
      'SELECT * FROM AssessmentQuestionDataTable WHERE assessmentId = :assessmentId')
  Future<List<AssessmentQuestionDataTable>>
      findAssessmentQuestionDataByAssessmentId(int assessmentId);

  @Query(
      'SELECT * FROM AssessmentQuestionDataTable WHERE assessment_status = :assessment_status')
  Future<List<AssessmentQuestionDataTable>>
      findAssessmentQuestionDataByAssessmentStatus(bool assessment_status);

  @Query(
      'UPDATE AssessmentQuestionDataTable SET assessment_status = :assessment_status WHERE assessmentId =:assessmentId')
  Future<void> updateAssessmentQuestionDataByAssessmentStatusAndAssessmentId(
      bool assessment_status, int assessmentId);

  @insert
  Future<void> insertAssessmentQuestionData(
      AssessmentQuestionDataTable assessmentQuestionDataTable);

  @Query('DELETE FROM AssessmentQuestionDataTable')
  Future<void> deleteAssessmentQuestionDataTable();

  @delete
  Future<void> deleteAssessmentQuestionData(
      AssessmentQuestionDataTable assessmentQuestionDataTable);
}
