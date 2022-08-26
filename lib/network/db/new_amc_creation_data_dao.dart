import 'package:floor/floor.dart';

import 'new_amc_creation_data.dart';

@dao
abstract class NewAMCCreationDataDao {
  @Query('SELECT * FROM NewAMCCreationDataTable')
  Future<List<NewAMCCreationDataTable>> findAllNewAMCCreationData();

  @insert
  Future<void> insertNewAMCCreationData(
      NewAMCCreationDataTable newAMCCreationDataTable);

  @Query('SELECT * FROM NewAMCCreationDataTable WHERE checkable = :checkable')
  Future<List<NewAMCCreationDataTable>> findNewAMCCreationDataByCheckable(
      bool checkable);

  @Query('DELETE FROM NewAMCCreationDataTable')
  Future<void> deleteNewAMCCreationData();
}
