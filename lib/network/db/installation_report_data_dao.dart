import 'package:floor/floor.dart';

import 'installation_report_data.dart';

@dao
abstract class InstallationReportDataDao {
  @Query('SELECT * FROM InstallationReportDataTable')
  Future<List<InstallationReportDataTable>> findAllInstallationReportData();

  @Query(
      'SELECT * FROM InstallationReportDataTable WHERE ticketId = :ticketId AND id = :id')
  Stream<InstallationReportDataTable?> findTInstallationReportDataById(
      String ticketId, String id);

  @Query(
      "UPDATE InstallationReportDataTable SET answer_value = :answerValue,remarks = :remarks WHERE ser_check_list_id =:ser_check_list_id")
  Future<void> updateData(
      String answerValue, String remarks, int ser_check_list_id);

  @Query(
      "UPDATE InstallationReportDataTable SET qsatype1 =:question1,qsatype2 = :question2 WHERE ser_check_list_id =:ser_check_list_id")
  Future<void> updateDataCheckBox(
      bool question1, bool question2, int ser_check_list_id);

  @insert
  Future<void> insertInstallationReportData(
      InstallationReportDataTable installationReportDataTable);

  @Query('DELETE FROM InstallationReportDataTable WHERE id =:id')
  Future<void> deleteTicketForTheDayItem(int id);

  @Query('DELETE FROM InstallationReportDataTable')
  Future<void> deleteTicketForTheDayTable();

  @delete
  Future<void> deleteTInstallationReportData(
      InstallationReportDataTable installationReportDataTable);
}
