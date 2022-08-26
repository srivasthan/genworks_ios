import 'package:floor/floor.dart';

@entity
class OngoingTicketTable {
  @primaryKey
  final int id;

  final String technicianCode;
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
  final String ticketStatus;
  final String nextVisit;
  final String endUserName;
  final String endUserMobileNumber;
  final String siteID;
  final String segment;
  final String segmentID;
  final String application;
  final String batteryBankID;
  final int flag;

  OngoingTicketTable(
      this.id,
      this.technicianCode,
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
      this.ticketStatus,
      this.nextVisit,
      this.endUserName,
      this.endUserMobileNumber,
      this.siteID,
      this.segment,
      this.segmentID,
      this.application,
      this.batteryBankID,
      this.flag);
}
