import 'package:floor/floor.dart';

import 'amc_ticket_details.dart';

@dao
abstract class AmcTicketDetailsDao {
  @Query('SELECT * FROM AmcDetailsTicketTable')
  Future<List<AmcDetailsTicketTable>> findAllAmcTicketDetails();

  @Query('SELECT * FROM AmcDetailsTicketTable WHERE ticketId = :ticketId')
  Future<List<AmcDetailsTicketTable>> findAmcTicketDetailsByTicketId(
      String ticketId);

  @insert
  Future<void> insertAmcTicketDetails(AmcDetailsTicketTable newTicketTable);

  @Query('DELETE FROM AmcDetailsTicketTable WHERE id =:id')
  Future<void> deleteAmcTicketDetailsItem(int id);

  @Query('DELETE FROM AmcDetailsTicketTable')
  Future<void> deleteAmcTicketDetailsTable();

  @delete
  Future<void> deleteAmcTicketDetails(AmcDetailsTicketTable newTicketTable);
}
