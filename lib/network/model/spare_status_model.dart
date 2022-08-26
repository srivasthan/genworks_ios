class SpareStatusModel {
  String? ticketId;
  String? frmStatus;
  String? spareCode;
  String? spareName;
  String? spareLocation;
  String? invoiceNumber;
  String? docketNumber;
  int? approvedQuantity;
  int? spareQuantity;

  SpareStatusModel({
    this.ticketId,
    this.frmStatus,
    this.spareCode,
    this.spareLocation,
    this.spareName,
    this.invoiceNumber,
    this.docketNumber,
    this.approvedQuantity,
    this.spareQuantity
  });
}
