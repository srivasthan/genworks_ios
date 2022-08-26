import 'package:floor/floor.dart';

@entity
class NewTicketTable {
  @primaryKey
  final int id;

  final String ticketId;
  final String priority;
  final String location;
  final String customerName;
  final String customerMobile;
  final String serialNo;
  final String modelNo;
  final String customerAddress;
  final String callCategory;
  final String contractType;
  final String problemDescription;
  final String endUserName;
  final String endUserMobile;

  NewTicketTable(
      this.id,
      this.ticketId,
      this.priority,
      this.location,
      this.customerName,
      this.customerMobile,
      this.serialNo,
      this.modelNo,
      this.customerAddress,
      this.callCategory,
      this.contractType,
      this.problemDescription,
      this.endUserName,
      this.endUserMobile);
}
