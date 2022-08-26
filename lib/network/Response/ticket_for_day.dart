class SerialNoListItems {
  String? serialNo;

  SerialNoListItems({
    this.serialNo,
  });

  SerialNoListItems.fromJson(
      Map<String, dynamic> json) {
    serialNo = json["serial_no"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["serial_no"] = serialNo;
    return data;
  }
}

class TicketForTheDayTicketListItems {
  String? ticketId;
  String? priority;
  String? plotNumber;
  String? street;
  String? country;
  String? state;
  String? city;
  String? location;
  int? statusCode;
  String? statusName;
  String? customerName;
  String? customerMobile;
  String? customerAddress;
  String? endUserName;
  String? endUserMobile;
  String? serialNo;
  String? modelNo;
  String? latitude;
  String? longitude;
  int? productId;
  int? ticketType;
  String? productName;
  List<SerialNoListItems?>? amcSerialNo;
  String? ammount;
  String? callCategory;
  String? contractType;
  int? duration;
  String? productSubName;
  String? problemDescription;
  String? modeOfTravel;
  String? ticketDate;
  int? serviceId;
  String? workType;
  String? nextVisit;
  String? responseTime;
  String? resolutionTime;
  String? partNumber;
  String? startDate;
  String? warrantyStatus;
  String? contractExpiryDate;
  String? priceType;

  TicketForTheDayTicketListItems({
    this.ticketId,
    this.priority,
    this.plotNumber,
    this.street,
    this.country,
    this.state,
    this.city,
    this.location,
    this.statusCode,
    this.statusName,
    this.customerName,
    this.customerMobile,
    this.customerAddress,
    this.endUserName,
    this.endUserMobile,
    this.serialNo,
    this.modelNo,
    this.latitude,
    this.longitude,
    this.productId,
    this.ticketType,
    this.productName,
    this.amcSerialNo,
    this.ammount,
    this.callCategory,
    this.contractType,
    this.duration,
    this.productSubName,
    this.problemDescription,
    this.modeOfTravel,
    this.ticketDate,
    this.serviceId,
    this.workType,
    this.nextVisit,
    this.responseTime,
    this.resolutionTime,
    this.partNumber,
    this.startDate,
    this.warrantyStatus,
    this.contractExpiryDate,
    this.priceType
  });

  TicketForTheDayTicketListItems.fromJson(Map<String, dynamic> json) {
    ticketId = json["ticket_id"]?.toString();
    priority = json["priority"]?.toString();
    plotNumber = json["plot_number"]?.toString();
    street = json["street"]?.toString();
    country = json["country"]?.toString();
    state = json["state"]?.toString();
    city = json["city"]?.toString();
    location = json["location"]?.toString();
    statusCode = json["status_code"]?.toInt();
    statusName = json["status_name"]?.toString();
    customerName = json["customer_name"]?.toString();
    customerMobile = json["customer_mobile"]?.toString();
    customerAddress = json["customer_address"]?.toString();
    endUserName = json["end_user_name"]?.toString();
    endUserMobile = json["end_user_number"]?.toString();
    serialNo = json["serial_no"]?.toString();
    modelNo = json["model_no"]?.toString();
    latitude = json["latitude"]?.toString();
    longitude = json["longitude"]?.toString();
    productId = json["product_id"]?.toInt();
    ticketType = json["ticket_type"]?.toInt();
    productName = json["product_name"]?.toString();
    if (json["amc_serial_no"] != null) {
      final v = json["amc_serial_no"];
      final arr0 = <SerialNoListItems>[];
      v.forEach((v) {
        arr0.add(SerialNoListItems.fromJson(v));
      });
      amcSerialNo = arr0;
    }
    ammount = json["ammount"]?.toString();
    callCategory = json["call_category"]?.toString();
    contractType = json["contract_type"]?.toString();
    duration = json["duration"]?.toInt();
    productSubName = json["product_sub_name"]?.toString();
    problemDescription = json["problem_description"]?.toString();
    modeOfTravel = json["mode_of_travel"]?.toString();
    startDate = json["start_date"]?.toString();
    serviceId = json["service_id"]?.toInt();
    workType = json["work_type"]?.toString();
    nextVisit = json["next_visit"]?.toString();
    responseTime = json["response_time"]?.toString();
    resolutionTime = json["resolution_time"]?.toString();
    partNumber = json["part_number"]?.toString();
    ticketDate = json["ticket_date"]?.toString();
    warrantyStatus = json["warranty_status"]?.toString();
    contractExpiryDate = json["expiry_day"]?.toString();
    priceType = json["price_lable"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["ticket_id"] = ticketId;
    data["priority"] = priority;
    data["plot_number"] = plotNumber;
    data["street"] = street;
    data["country"] = country;
    data["state"] = state;
    data["city"] = city;
    data["location"] = location;
    data["status_code"] = statusCode;
    data["status_name"] = statusName;
    data["customer_name"] = customerName;
    data["customer_mobile"] = customerMobile;
    data["customer_address"] = customerAddress;
    data["end_user_name"] = endUserName;
    data["end_user_number"] = endUserMobile;
    data["serial_no"] = serialNo;
    data["model_no"] = modelNo;
    data["latitude"] = latitude;
    data["longitude"] = longitude;
    data["product_id"] = productId;
    data["ticket_type"] = ticketType;
    data["product_name"] = productName;
    if (amcSerialNo != null) {
      final v = amcSerialNo;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["amc_serial_no"] = arr0;
    }
    data["ammount"] = ammount;
    data["call_category"] = callCategory;
    data["contract_type"] = contractType;
    data["duration"] = duration;
    data["product_sub_name"] = productSubName;
    data["problem_description"] = problemDescription;
    data["mode_of_travel"] = modeOfTravel;
    data["start_date"] = startDate;
    data["ticket_date"] = ticketDate;
    data["service_id"] = serviceId;
    data["work_type"] = workType;
    data["next_visit"] = nextVisit;
    data["response_time"] = responseTime;
    data["resolution_time"] = resolutionTime;
    data["part_number"] = partNumber;
    data["warranty_status"] = warrantyStatus;
    data["expiry_day"] = contractExpiryDate;
    data["price_lable"] = priceType;
    return data;
  }
}

class TicketForTheDayEntity {
  String? responseCode;
  String? token;
  List<TicketForTheDayTicketListItems?>? datum;

  TicketForTheDayEntity({
    this.responseCode,
    this.token,
    this.datum,
  });

  TicketForTheDayEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <TicketForTheDayTicketListItems>[];
      v.forEach((v) {
        arr0.add(TicketForTheDayTicketListItems.fromJson(v));
      });
      this.datum = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
    if (this.datum != null) {
      final v = this.datum;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["data"] = arr0;
    }
    return data;
  }
}

class TicketForTheDayResponse {
  TicketForTheDayEntity? ticketForTheDayEntity;

  TicketForTheDayResponse({
    this.ticketForTheDayEntity,
  });

  TicketForTheDayResponse.fromJson(Map<String, dynamic> json) {
    ticketForTheDayEntity = (json["response"] != null)
        ? TicketForTheDayEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (ticketForTheDayEntity != null) {
      data["response"] = ticketForTheDayEntity!.toJson();
    }
    return data;
  }
}
