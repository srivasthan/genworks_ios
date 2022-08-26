class WorkInProgressPojo {
  String spare_code;
  int spare_location_id;
  int spare_quantity;
  int is_it_chargable;

  WorkInProgressPojo(this.spare_code, this.spare_location_id,
      this.spare_quantity, this.is_it_chargable);

  Map toJson() {
    return {
      'spare_code': spare_code,
      'spare_location_id': spare_location_id,
      'spare_quantity': spare_quantity,
      'is_it_chargable': is_it_chargable
    };
  }
}
