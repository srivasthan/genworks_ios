import 'package:floor/floor.dart';

@entity
class TicketForTheDayTable {
  @primaryKey
  final int id;

  final String technicianCode;
  final String ticketId;
  final String priority;
  final String location;
  final String customerName;
  final String customerMobile;
  final String endUserName;
  final String endUserMobile;
  final String serialNo;
  final String modelNo;
  final String customerAddress;
  final String callCategory;
  final String contractType;
  final String problemDescription;
  final String ticketStatus;
  final String nextVisit;
  final String latitude;
  final String longitude;
  final int statusCode;
  final int serviceId;
  final String resolutionTime;
  final String workType;
  final String ticketDate;
  final String ticketState;
  final String ticketUpdate;
  final String travelPlanTransport;
  final int ticketType;
  final String partNumber;
  final String warrantyStatus;
  final String contractExpiryDate;
  final String priceType;

  TicketForTheDayTable(
      this.id,
      this.technicianCode,
      this.ticketId,
      this.priority,
      this.location,
      this.customerName,
      this.customerMobile,
      this.endUserName,
      this.endUserMobile,
      this.serialNo,
      this.modelNo,
      this.customerAddress,
      this.callCategory,
      this.contractType,
      this.problemDescription,
      this.ticketStatus,
      this.nextVisit,
      this.latitude,
      this.longitude,
      this.statusCode,
      this.serviceId,
      this.resolutionTime,
      this.workType,
      this.ticketDate,
      this.ticketState,
      this.ticketUpdate,
      this.travelPlanTransport,
      this.ticketType,
      this.partNumber,
      this.warrantyStatus,
      this.contractExpiryDate,
      this.priceType);
}
