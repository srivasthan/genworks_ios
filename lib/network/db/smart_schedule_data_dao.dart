import 'package:fieldpro_genworks_healthcare/network/db/smart_schedule_data.dart';
import 'package:floor/floor.dart';

@dao
abstract class SmartScheduleDataDao {
  @Query('SELECT * FROM SmartScheduleDataTable')
  Future<List<SmartScheduleDataTable>> findAllSmartScheduleData();

  @Query(
      'SELECT * FROM SmartScheduleDataTable WHERE smartschedule_date = :smartschedule_date')
  Future<List<SmartScheduleDataTable>> findSmartScheduleDataByDate(
      String smartschedule_date);

  @Query(
      'SELECT * FROM SmartScheduleDataTable WHERE smartschedule_date = :smartschedule_date OR smartschedule_time = :smartschedule_time')
  Future<List<SmartScheduleDataTable>> findSmartScheduleDataByDateOrTime(
      String smartschedule_date, String smartschedule_time);

  @Query(
      'UPDATE SmartScheduleDataTable SET smartschedule_tittle = :smartschedule_tittle, smartschedule_time = :smartschedule_time, smartschedule_desc = :smartschedule_desc WHERE smartschedule_id =:smartschedule_id')
  Future<void> updateSmartScheduleData(
      String smartschedule_tittle,
      String smartschedule_time,
      String smartschedule_desc,
      int smartschedule_id);

  @insert
  Future<void> insertSmartScheduleData(
      SmartScheduleDataTable smartScheduleDataTable);

  @Query('DELETE FROM SmartScheduleDataTable')
  Future<void> deleteSmartScheduleDataTable();

  @Query(
      'DELETE FROM SmartScheduleDataTable WHERE smartschedule_id = :smartschedule_id')
  Future<void> deleteSmartScheduleData(int smartschedule_id);
}
