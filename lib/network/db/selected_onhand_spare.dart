import 'package:floor/floor.dart';

@entity
class SelectedOnHandSpareDataTable {
  @primaryKey
  final int? id;

  final String? spareId;
  final String? spareCode;
  final String? spareName;
  final int? quantity;
  final String? location;
  late final bool? isSelectedSpare;
  final int? locationId;
  final String? ticketId;
  final double? price;

  SelectedOnHandSpareDataTable(
      {this.id,
      this.spareId,
      this.spareCode,
      this.spareName,
      this.quantity,
      this.location,
      this.isSelectedSpare,
      this.locationId,
      this.ticketId,
      this.price});
}
