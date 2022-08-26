import 'package:floor/floor.dart';

import 'new_ticket.dart';

@dao
abstract class NewTicketDao {
  @Query('SELECT * FROM NewTicketTable')
  Future<List<NewTicketTable>> findAllNewTicket();

  @Query('SELECT * FROM NewTicketTable WHERE ticketId = :ticketId AND id = :id')
  Stream<NewTicketTable?> findNewTicketById(String ticketId, String id);

  @Query('SELECT * FROM NewTicketTable WHERE ticketId = :ticketId')
  Stream<NewTicketTable?> findNewTicketByTicketId(String ticketId);

  @insert
  Future<void> insertNewTicket(NewTicketTable newTicketTable);

  @Query('DELETE FROM NewTicketTable WHERE id =:id')
  Future<void> deleteNewTicketItem(int id);

  @Query('DELETE FROM NewTicketTable')
  Future<void> deleteNewTicketTable();

  @delete
  Future<void> deleteNewTicket(NewTicketTable newTicketTable);
}
