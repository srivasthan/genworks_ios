import 'package:floor/floor.dart';
import 'ongoing_ticket.dart';

@dao
abstract class OngoingTicketDao {
  @Query('SELECT * FROM OngoingTicketTable')
  Future<List<OngoingTicketTable>> findAllOngoingTicket();

  @Query('SELECT * FROM OngoingTicketTable WHERE ticketId = :ticket_id')
  Future<List<OngoingTicketTable?>> findOngoingTicketById(String ticket_id);

  @insert
  Future<void> insertOngoingTicket(OngoingTicketTable newTicketTable);

  @Query('DELETE FROM OngoingTicketTable WHERE id =:id')
  Future<void> deleteOngoingTicketItem(int id);

  @Query('DELETE FROM OngoingTicketTable')
  Future<void> deleteOngoingTicketTable();

  @delete
  Future<void> deleteOngoingTicket(OngoingTicketTable newTicketTable);
}
