import 'package:floor/floor.dart';

@entity
class NewAMCCreationDataTable {
  @primaryKey
  final int? id;

  String? contactNumber;
  String? customerName;
  String? customerEmail;
  String? flatNoStreet;
  String? street;
  int? postCode;
  int? countryId;
  int? stateId;
  int? cityId;
  int? locationId;
  String? priority;
  int? amcTypeId;
  int? amcPeriod;
  String? startDate;
  int? productId;
  int? subCategoryId;
  int? callCategoryId;
  String? modelNo;
  String? invoiceNo;
  int? totalAmount;
  String? modeOfPayment;
  bool? checkable;
  String? customerCode;

  NewAMCCreationDataTable(
      {this.id,
      this.contactNumber,
      this.customerName,
      this.customerEmail,
      this.flatNoStreet,
      this.street,
      this.postCode,
      this.countryId,
      this.stateId,
      this.cityId,
      this.locationId,
      this.priority,
      this.amcTypeId,
      this.amcPeriod,
      this.startDate,
      this.productId,
      this.subCategoryId,
        this.callCategoryId,
      this.modelNo,
      this.invoiceNo,
      this.totalAmount,
      this.modeOfPayment,
      this.checkable,
      this.customerCode});
}
