import 'package:floor/floor.dart';

@entity
class InstallationReportDataTable {
  @primaryKey
  final int id;

  final int ser_check_list_id;
  final String service_group;
  final String description;
  final int quation_type;
  final String product_id;
  final String answer_value;
  final String remarks;
  final bool qsatype1;
  final bool qsatype2;

  InstallationReportDataTable(
      this.id,
      this.ser_check_list_id,
      this.service_group,
      this.description,
      this.quation_type,
      this.product_id,
      this.answer_value,
      this.remarks,
      this.qsatype1,
      this.qsatype2);
}
