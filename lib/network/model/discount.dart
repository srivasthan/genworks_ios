class DiscountModel {
  String? ticketId;
  String? technicianCode;
  String? productGst;
  String? serviceGst;
  int? subTotal;
  String? priceType;
  int? priceLable;
  int? discount;
  int? discountAmount;
  int? discountType;
  int? total;
  int? thresholdPercent;
  String? serviceCharge;
  String? spareCharge;

  DiscountModel({
    this.ticketId,
    this.technicianCode,
    this.productGst,
    this.serviceGst,
    this.subTotal,
    this.priceType,
    this.priceLable,
    this.discount,
    this.discountAmount,
    this.discountType,
    this.total,
    this.thresholdPercent,
    this.serviceCharge,
    this.spareCharge,
  });
}