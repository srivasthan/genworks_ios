import 'package:floor/floor.dart';

@entity
class SearchAMCContractDataTable {
  @primaryKey
  final int? id;

  String? customerCode;
  String? customerName;
  String? emailId;
  String? contactNumber;
  int? contractId;
  int? productId;
  String? productName;
  int? subCategoryId;
  String? subCategoryName;
  String? modelNo;
  String? serialNo;
  String? contractType;
  String? plotNumber;
  String? street;
  int? postCode;
  String? country;
  String? state;
  String? city;
  String? location;
  int? contractDuration;
  int? contractAmmount;
  String? startDate;
  String? expiryDay;
  String? invoiceId;
  int? flag;
  int? daysLeft;

  SearchAMCContractDataTable({
    this.id,
    this.customerCode,
    this.customerName,
    this.emailId,
    this.contactNumber,
    this.contractId,
    this.productId,
    this.productName,
    this.subCategoryId,
    this.subCategoryName,
    this.modelNo,
    this.serialNo,
    this.contractType,
    this.plotNumber,
    this.street,
    this.postCode,
    this.country,
    this.state,
    this.city,
    this.location,
    this.contractDuration,
    this.contractAmmount,
    this.startDate,
    this.expiryDay,
    this.invoiceId,
    this.flag,
    this.daysLeft,
  });
}