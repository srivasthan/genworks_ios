import 'package:fieldpro_genworks_healthcare/network/db/spare_request_data.dart';
import 'package:floor/floor.dart';

@dao
abstract class SpareRequestDataDao {
  @Query('SELECT * FROM SpareRequestDataTable')
  Future<List<SpareRequestDataTable>> findAllSpareRequestData();

  @Query('SELECT * FROM SpareRequestDataTable WHERE spareId = :id')
  Future<SpareRequestDataTable?> findSpareRequestDataById(String id);

  @Query('SELECT * FROM SpareRequestDataTable WHERE upDateSpare = :updateSpare')
  Future<List<SpareRequestDataTable?>> updateSpareRequestData(bool updateSpare);

  @Query(
      "UPDATE SpareRequestDataTable SET upDateSpare = :upDateSpare WHERE spareId =:spareId")
  Future<void> updateConsumedSpare(bool upDateSpare, String spareId);

  @Query(
      "UPDATE SpareRequestDataTable SET updateQuantity = :quantity WHERE spareId =:spareId")
  Future<void> updateQuantity(int quantity, String spareId);

  @Query(
      "UPDATE SpareRequestDataTable SET isChargeable = :ischargeable,totalCost = :totalCost WHERE spareId =:spareId")
  Future<void> updatespareischargeable(int ischargeable,double totalCost, int spareId);

  @insert
  Future<void> insertSpareRequestData(
      SpareRequestDataTable spareRequestDataTable);

  @Query('DELETE FROM SpareRequestDataTable WHERE id =:id')
  Future<void> deleteSpareRequestDataItem(int id);

  @Query('DELETE FROM SpareRequestDataTable')
  Future<void> deleteSpareRequestDataTable();

  @delete
  Future<void> deleteSpareRequestData(
      SpareRequestDataTable spareRequestDataTable);
}
