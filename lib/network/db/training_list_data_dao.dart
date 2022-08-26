import 'package:fieldpro_genworks_healthcare/network/db/training_list_data.dart';
import 'package:floor/floor.dart';

@dao
abstract class TrainingListDataDao {
  @Query('SELECT * FROM TrainingListDataTable')
  Future<List<TrainingListDataTable>> findAllTrainingListData();

  @Query('SELECT * FROM TrainingListDataTable WHERE training_id = :training_id')
  Future<List<TrainingListDataTable>> findTrainingListDataByTrainingId(
      String training_id);

  @Query('SELECT * FROM TrainingListData WHERE training_id = :training_id AND training_content_type = :training_content_type')
  Future<List<TrainingListDataTable>> findTrainingListDataByTrainingIdAndTrainingContentType(
      String training_id,String training_content_type);

  @Query('SELECT * FROM TrainingListDataTable WHERE assessment_id = :assessment_id')
  Future<List<TrainingListDataTable>> findTrainingListDataByAssessmentId(
      int assessment_id);

  @insert
  Future<void> insertTrainingListData(
      TrainingListDataTable trainingListDataTable);

  @Query('DELETE FROM TrainingListDataTable')
  Future<void> deleteTrainingListDataTable();

  @delete
  Future<void> deleteTrainingListData(
      TrainingListDataTable trainingListDataTable);
}
