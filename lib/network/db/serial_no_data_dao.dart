import 'package:fieldpro_genworks_healthcare/network/db/serial_no_data.dart';
import 'package:floor/floor.dart';

@dao
abstract class SerialNoDataDao {
  @Query('SELECT * FROM SerialNoDataTable')
  Future<List<SerialNoDataTable>> findAllSerialNoData();

  @insert
  Future<void> insertSerialNoData(
      SerialNoDataTable installationReportDataTable);

  @Query('SELECT * FROM SerialNoDataTable WHERE ticketId = :ticketId')
  Future<List<SerialNoDataTable>> findSerialNoDataByTicketId(String ticketId);

  @Query('DELETE FROM SerialNoDataTable')
  Future<void> deleteSerialNoData();
}
