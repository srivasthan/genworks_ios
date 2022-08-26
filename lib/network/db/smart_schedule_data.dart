import 'package:floor/floor.dart';

@entity
class SmartScheduleDataTable {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int? smartschedule_id;
  final String? smartschedule_date;
  final String? smartschedule_time;
  final String? smartschedule_tittle;
  final String? smartschedule_desc;
  final bool? smartschedule_update;

  SmartScheduleDataTable(
      {this.id,
      this.smartschedule_id,
      this.smartschedule_date,
      this.smartschedule_time,
      this.smartschedule_tittle,
      this.smartschedule_desc,
      this.smartschedule_update});
}
