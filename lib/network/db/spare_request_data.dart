import 'package:floor/floor.dart';

@entity
class SpareRequestDataTable {
  @primaryKey
  final int id;

  final String spareId;
  final String spareCode;
  final String spareName;
  final int productId;
  final int productSubId;
  final String location;
  final int quantity;
  final double price;
  final String spareModel;
  late final bool upDateSpare;
  final int updateQuantity;
  final int isChargeable;
  final int leadTime;
  final double totalCost;
  final int locationId;

  SpareRequestDataTable(
      this.id,
      this.spareId,
      this.spareCode,
      this.spareName,
      this.productId,
      this.productSubId,
      this.location,
      this.quantity,
      this.price,
      this.spareModel,
      this.upDateSpare,
      this.updateQuantity,
      this.isChargeable,
      this.leadTime,
      this.totalCost,
      this.locationId);
}
