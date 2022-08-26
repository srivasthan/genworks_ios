import 'package:floor/floor.dart';

@entity
class SerialNoDataTable {
  @primaryKey
  final int id;

  final String serialNo;
  final String ticketId;

  SerialNoDataTable(
      this.id,
      this.serialNo,
      this.ticketId);
}
