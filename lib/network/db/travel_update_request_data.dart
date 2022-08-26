import 'package:floor/floor.dart';

@entity
class TravelUpdateRequestData {
  @primaryKey
  final int? id;

  final String? ticketId;
  final String? modeOfTravel;
  final String? noOfKmTravelled;
  final String? estimatedTime;
  final String? startDate;
  final String? endDate;
  final String? imageSelected;
  final String? imagePath;
  final String? expenses;
  final int? adapterPosition;

  TravelUpdateRequestData(
      {this.id,
      this.ticketId,
      this.modeOfTravel,
      this.noOfKmTravelled,
      this.estimatedTime,
      this.startDate,
      this.endDate,
      this.imageSelected,
      this.imagePath,
      this.expenses,
      this.adapterPosition});
}
