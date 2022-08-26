import 'package:fieldpro_genworks_healthcare/network/db/travel_update_request_data.dart';
import 'package:floor/floor.dart';

@dao
abstract class TravelUpdateRequestDataDao {
  @Query('SELECT * FROM TravelUpdateRequestData')
  Future<List<TravelUpdateRequestData>> findAllSearchAMCContractData();

  @insert
  Future<void> insertSearchAMCContractData(
      TravelUpdateRequestData travelUpdateRequestData);

  @Query('DELETE FROM TravelUpdateRequestData')
  Future<void> deleteSearchAMCContractDataTable();

  @delete
  Future<void> deleteSearchAMCContractData(
      TravelUpdateRequestData travelUpdateRequestData);
}
