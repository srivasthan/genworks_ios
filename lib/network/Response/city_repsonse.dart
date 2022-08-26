class CityListItems {
  int? cityId;
  String? cityName;

  CityListItems({
    this.cityId,
    this.cityName,
  });

  CityListItems.fromJson(Map<String, dynamic> json) {
    cityId = json["city_id"]?.toInt();
    cityName = json["city_name"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["city_id"] = cityId;
    data["city_name"] = cityName;
    return data;
  }
}

class CityEntity {
  String? responseCode;
  List<CityListItems?>? data;

  CityEntity({
    this.responseCode,
    this.data,
  });

  CityEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <CityListItems>[];
      v.forEach((v) {
        arr0.add(CityListItems.fromJson(v));
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

class CityResponse {
  CityEntity? cityEntity;

  CityResponse({
    this.cityEntity,
  });

  CityResponse.fromJson(Map<String, dynamic> json) {
    cityEntity = (json["response"] != null)
        ? CityEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (cityEntity != null) {
      data["response"] = cityEntity!.toJson();
    }
    return data;
  }
}
