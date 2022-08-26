import 'package:fieldpro_genworks_healthcare/network/db/selected_onhand_spare.dart';
import 'package:floor/floor.dart';

@dao
abstract class SelectedOnHandSpareDao {
  @Query('SELECT * FROM SelectedOnHandSpareDataTable')
  Future<List<SelectedOnHandSpareDataTable>> findAll();

  @Query(
      'SELECT * FROM SelectedOnHandSpareDataTable WHERE isSelectedSpare =:isSelectedSpare AND ticketId =:ticketId')
  Future<List<SelectedOnHandSpareDataTable>> getSelectedSpareByTicketId(
      bool isSelectedSpare, String ticketId);

  @insert
  Future<void> insertSpare(
      SelectedOnHandSpareDataTable selectedOnHandSpareDataTable);

  @Query(
      'DELETE FROM SelectedOnHandSpareDataTable WHERE isSelectedSpare =:isSelectedSpare AND ticketId =:ticketId')
  Future<void> deleteSelectedSpareByTicketId(
      bool isSelectedSpare, String ticketId);
}
