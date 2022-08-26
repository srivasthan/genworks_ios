import 'package:floor/floor.dart';

import 'consumed_spare_request_data.dart';

@dao
abstract class ConsumedSpareRequestDataDao {
  @Query('SELECT * FROM ConsumedSpareRequestDataTable')
  Future<List<ConsumedSpareRequestDataTable>> findAllConsumedSpareRequestData();

  @Query('SELECT * FROM ConsumedSpareRequestDataTable WHERE spareId = :id')
  Future<ConsumedSpareRequestDataTable?> findConsumedSpareRequestDataById(
      String id);

  @Query(
      'SELECT * FROM ConsumedSpareRequestDataTable WHERE upDateSpare = :updateSpare')
  Future<List<ConsumedSpareRequestDataTable?>> updateSpareCart(
      bool updateSpare);

  @Query(
      "UPDATE ConsumedSpareRequestDataTable SET upDateSpare = :upDateSpare WHERE spareId =:spareId")
  Future<void> updateConsumedSpare(bool upDateSpare, String spareId);

  @Query(
      "UPDATE ConsumedSpareRequestDataTable SET updateQuantity = :quantity WHERE spareId =:spareId")
  Future<void> updateQuantity(int quantity, String spareId);

  @insert
  Future<void> insertConsumedSpareRequestData(
      ConsumedSpareRequestDataTable consumedSpareRequestDataTable);

  @Query('DELETE FROM ConsumedSpareRequestDataTable WHERE id =:id')
  Future<void> deleteConsumedSpareRequestDataItem(int id);

  @Query('DELETE FROM ConsumedSpareRequestDataTable')
  Future<void> deleteConsumedSpareRequestDataTable();

  @delete
  Future<void> deleteConsumedSpareRequestData(
      ConsumedSpareRequestDataTable consumedSpareRequestDataTable);
}
