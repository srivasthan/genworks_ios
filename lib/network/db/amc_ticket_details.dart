import 'package:floor/floor.dart';

@entity
class AmcDetailsTicketTable {
  @primaryKey
  final int id;

  final String technicianCode;
  final String ticketId;
  final String customerName;
  final String contactNumber;
  final String plotNumber;
  final String street;
  final String country;
  final String state;
  final String city;
  final String location;
  final String amcType;
  final String amcDuration;
  final String productName;
  final String subProductName;
  final String modelNo;
  final int amount;
  final String quantity;
  final String totalAmount;

  AmcDetailsTicketTable(
      this.id,
      this.technicianCode,
      this.ticketId,
      this.customerName,
      this.contactNumber,
      this.plotNumber,
      this.street,
      this.country,
      this.state,
      this.city,
      this.location,
      this.amcType,
      this.amcDuration,
      this.productName,
      this.subProductName,
      this.modelNo,
      this.amount,
      this.quantity,
      this.totalAmount);
}
