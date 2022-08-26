import 'package:floor/floor.dart';

import 'assessment_quiz_data.dart';

@dao
abstract class AssessmentQuizDataDao {
  @Query('SELECT * FROM AssessmentQuizDataTable')
  Future<List<AssessmentQuizDataTable>> findAllAssessmentQuizData();

  @Query(
      'SELECT * FROM AssessmentQuizDataTable WHERE assessment_id = :assessment_id')
  Future<List<AssessmentQuizDataTable>> findAssessmentQuizDataByAssessmentId(
      int assessment_id);

  @Query('SELECT * FROM AssessmentQuizDataTable WHERE quationId = :quationId')
  Future<List<AssessmentQuizDataTable>> findAssessmentQuizDataByQuationId(
      int quationId);

  @Query(
      'UPDATE AssessmentQuizDataTable SET your_answer = :your_answer WHERE quationId =:quationId')
  Future<void> updateAssessmentQuizDataByYourAnswerANDQuationId(
      String your_answer, int quationId);

  @Query(
      'UPDATE AssessmentQuizDataTable SET updateAnswer_a = :updateAnswer_a, updateAnswer_b = :updateAnswer_b , updateAnswer_c = :updateAnswer_c , updateAnswer_d = :updateAnswer_d WHERE quationId =:quationId')
  Future<void> updatessessmentQuizData(bool updateAnswer_a, bool updateAnswer_b,
      bool updateAnswer_c, bool updateAnswer_d, int quationId);

  @insert
  Future<void> insertAssessmentQuizData(
      AssessmentQuizDataTable assessmentQuizDataTable);

  @Query('DELETE FROM AssessmentQuizDataTable')
  Future<void> deleteAssessmentQuizDataTable();

  @delete
  Future<void> deleteAssessmentQuizData(
      AssessmentQuizDataTable assessmentQuizDataTable);
}
