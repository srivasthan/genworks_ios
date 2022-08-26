class LocationListItems {
  int? locationId;
  String? locationName;

  LocationListItems({
    this.locationId,
    this.locationName,
  });

  LocationListItems.fromJson(Map<String, dynamic> json) {
    locationId = json["location_id"]?.toInt();
    locationName = json["location_name"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["location_id"] = locationId;
    data["location_name"] = locationName;
    return data;
  }
}

class LocationEnity {
  String? responseCode;
  List<LocationListItems?>? data;

  LocationEnity({
    this.responseCode,
    this.data,
  });

  LocationEnity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <LocationListItems>[];
      v.forEach((v) {
        arr0.add(LocationListItems.fromJson(v));
      });
      this.data = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["data"] = arr0;
    }
    return data;
  }
}

class LocationResponse {
  LocationEnity? locationEnity;

  LocationResponse({
    this.locationEnity,
  });

  LocationResponse.fromJson(Map<String, dynamic> json) {
    locationEnity = (json["response"] != null)
        ? LocationEnity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (locationEnity != null) {
      data["response"] = locationEnity!.toJson();
    }
    return data;
  }
}
