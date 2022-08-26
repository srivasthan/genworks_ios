class OngoingTicketModel {
  String? ticketId;
  String? priority;
  String? location;
  String? statusName;
  String? customerName;
  String? customerMobile;
  String? endUserName;
  String? endUserMobile;
  String? serialNo;
  String? modelNo;
  String? latitude;
  String? longitude;
  String? customerAddress;
  String? callCategory;
  String? contractType;
  String? problemDescription;
  String? nextVisit;
  String? priceType;
  String? partNumber;
  String? warrantyStatus;
  String? warrantyExpiryDate;
  String? contractExpiryDate;
  int? ticketType;

  OngoingTicketModel({
    this.ticketId,
    this.priority,
    this.location,
    this.statusName,
    this.customerName,
    this.customerMobile,
    this.serialNo,
    this.modelNo,
    this.latitude,
    this.longitude,
    this.customerAddress,
    this.callCategory,
    this.contractType,
    this.problemDescription,
    this.nextVisit,
    this.endUserName,
    this.endUserMobile,
    this.priceType,
    this.partNumber,
    this.warrantyStatus,
    this.warrantyExpiryDate,
    this.contractExpiryDate,
    this.ticketType
  });
}
