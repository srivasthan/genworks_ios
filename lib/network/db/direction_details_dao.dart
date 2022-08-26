import 'package:floor/floor.dart';
import 'direction_details.dart';

@dao
abstract class DirectionDetailsDao {
  @Query('SELECT * FROM DirectionDetailsTable')
  Future<List<DirectionDetailsTable>> findAllDirectionDetailsTable();

  @Query('SELECT * FROM DirectionDetailsTable WHERE ticketId = :ticketId')
  Future<List<DirectionDetailsTable>> findDirectionDetailsTableByTicketId(
      String ticketId);

  @insert
  Future<void> insertDirectionDetailsTable(DirectionDetailsTable directionDetailsTable);

  @Query('DELETE FROM DirectionDetailsTable')
  Future<void> deleteDirectionDetailsTable();
}
