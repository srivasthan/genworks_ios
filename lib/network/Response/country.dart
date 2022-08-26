class CountryListItems {
  int? countryId;
  String? countryName;

  CountryListItems({
    this.countryId,
    this.countryName,
  });

  CountryListItems.fromJson(Map<String, dynamic> json) {
    countryId = json["country_id"]?.toInt();
    countryName = json["country_name"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["country_id"] = countryId;
    data["country_name"] = countryName;
    return data;
  }
}

class CountryEntity {
  String? responseCode;
  List<CountryListItems?>? data;

  CountryEntity({
    this.responseCode,
    this.data,
  });

  CountryEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <CountryListItems>[];
      v.forEach((v) {
        arr0.add(CountryListItems.fromJson(v));
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

class CountryResponse {
  CountryEntity? countryEntity;

  CountryResponse({
    this.countryEntity,
  });

  CountryResponse.fromJson(Map<String, dynamic> json) {
    countryEntity = (json["response"] != null)
        ? CountryEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (countryEntity != null) {
      data["response"] = countryEntity!.toJson();
    }
    return data;
  }
}
