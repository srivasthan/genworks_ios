import 'package:fieldpro_genworks_healthcare/network/db/ticket_for_the_day.dart';
import 'package:floor/floor.dart';

@dao
abstract class TicketForTheDayDao {
  @Query('SELECT * FROM TicketForTheDayTable')
  Future<List<TicketForTheDayTable>> findAllTicketForTheDay();

  @Query(
      'SELECT * FROM TicketForTheDayTable WHERE ticketId = :ticketId AND id = :id')
  Stream<TicketForTheDayTable?> findTicketForTheDayById(
      String ticketId, String id);

  @Query('SELECT * FROM TicketForTheDayTable WHERE ticketId = :ticketId')
  Future<List<TicketForTheDayTable>> findTicketForTheDayByTicketId(String ticketId);

  @Query(
      "UPDATE TicketForTheDayTable SET travelPlanTransport = :travelPlanTransport WHERE ticketId =:ticketId")
  Future<void> updateTravelPlanTicketData(
      String travelPlanTransport, String ticketId);

  @Query(
      "UPDATE TicketForTheDayTable SET ticketStatus = :status WHERE ticketId =:ticketId")
  Future<void> updateTicketData(String status, String ticketId);

  @Query(
      "UPDATE TicketForTheDayTable SET ticketUpdate = :ticketUpdate WHERE ticketId =:ticketId")
  Future<void> updateTicketStatusData(String ticketUpdate, String ticketId);

  @insert
  Future<void> insertTicketForTheDay(TicketForTheDayTable newTicketTable);

  @Query('DELETE FROM TicketForTheDayTable WHERE id =:id')
  Future<void> deleteTicketForTheDayItem(int id);

  @Query('DELETE FROM TicketForTheDayTable')
  Future<void> deleteTicketForTheDayTable();

  @delete
  Future<void> deleteTicketForTheDay(TicketForTheDayTable newTicketTable);
}
