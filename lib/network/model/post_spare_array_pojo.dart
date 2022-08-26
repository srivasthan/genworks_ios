class PostSpareArrayPojo {
  String spare_code;
  int spare_location_id;
  int spare_quantity;
  int is_it_chargable;
  double spare_cost;

  PostSpareArrayPojo(this.spare_code, this.spare_location_id,
      this.spare_quantity, this.is_it_chargable, this.spare_cost);

  Map toJson() {
    return {
      'spare_code': spare_code,
      'spare_location_id': spare_location_id,
      'spare_quantity': spare_quantity,
      'is_it_chargable': is_it_chargable,
      'spare_cost': spare_cost
    };
  }
}
