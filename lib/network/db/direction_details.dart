import 'package:floor/floor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@entity
class DirectionDetailsTable {
  @primaryKey
  final int? id;

  final String? distance;
  final String? duration;
  final String? startAddress;
  final String? endAddress;
  final String? ticketId;

  DirectionDetailsTable({
      this.id,
      this.ticketId,
      this.distance,
      this.duration,
      this.startAddress,
      this.endAddress});
}
