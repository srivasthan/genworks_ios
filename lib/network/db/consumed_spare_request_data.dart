import 'package:floor/floor.dart';

@entity
class ConsumedSpareRequestDataTable {
  @primaryKey
  final int id;

  final String spareId;
  final String spareCode;
  final String spareName;
  final int quantity;
  late final bool upDateSpare;
  final int updateQuantity;
  final int price;
  final String location;
  final int spareLocationId;

  ConsumedSpareRequestDataTable(
      this.id,
      this.spareId,
      this.spareCode,
      this.spareName,
      this.quantity,
      this.upDateSpare,
      this.updateQuantity,
      this.price,
      this.location,
      this.spareLocationId);
}
