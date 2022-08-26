class OngoingTicketListItem {
  String? ticketId;
  String? priority;
  String? location;
  int? statusCode;
  int? serviceId;
  String? statusName;
  String? customerName;
  String? customerMobile;
  String? serialNo;
  String? modelNo;
  String? nextVisit;
  String? customerAddress;
  String? latitude;
  String? longitude;
  String? startDate;
  String? ticketDate;
  String? callCategory;
  String? contractType;
  String? batteryBankId;
  String? siteId;
  String? endUsername;
  String? endUserMobile;
  String? segmentId;
  String? segmentName;
  String? applicationId;
  String? applicationName;
  String? problemDescription;
  String? warrantyCheck;
  String? arblApprove;
  int? flag;
  int? ticketType;
  String? setrStatus;
  String? plotNumber;
  String? street;
  String? landmark;
  String? postCode;
  String? country;
  String? state;
  String? city;
  String? partNumber;
  String? workType;
  String? warrantyStatus;
  String? warrantyExpiryDate;
  String? contractExpiryDate;
  String? priceType;

  OngoingTicketListItem({
    this.ticketId,
    this.priority,
    this.location,
    this.statusCode,
    this.serviceId,
    this.statusName,
    this.customerName,
    this.customerMobile,
    this.serialNo,
    this.modelNo,
    this.nextVisit,
    this.customerAddress,
    this.latitude,
    this.longitude,
    this.startDate,
    this.ticketDate,
    this.callCategory,
    this.contractType,
    this.batteryBankId,
    this.siteId,
    this.endUsername,
    this.endUserMobile,
    this.segmentId,
    this.segmentName,
    this.applicationId,
    this.applicationName,
    this.problemDescription,
    this.warrantyCheck,
    this.arblApprove,
    this.flag,
    this.ticketType,
    this.setrStatus,
    this.plotNumber,
    this.street,
    this.landmark,
    this.postCode,
    this.country,
    this.state,
    this.city,
    this.partNumber,
    this.workType,
    this.warrantyStatus,
    this.warrantyExpiryDate,
    this.contractExpiryDate,
    this.priceType
  });

  OngoingTicketListItem.fromJson(Map<String, dynamic> json) {
    ticketId = json["ticket_id"]?.toString();
    priority = json["priority"]?.toString();
    location = json["location"]?.toString();
    serviceId = json["service_id"]?.toInt();
    statusCode = json["status_code"]?.toInt();
    statusName = json["status_name"]?.toString();
    customerName = json["customer_name"]?.toString();
    customerMobile = json["customer_mobile"]?.toString();
    serialNo = json["serial_no"]?.toString();
    modelNo = json["model_no"]?.toString();
    nextVisit = json["next_visit"]?.toString();
    customerAddress = json["customer_address"]?.toString();
    latitude = json["latitude"]?.toString();
    longitude = json["longitude"]?.toString();
    startDate = json["start_date"]?.toString();
    ticketDate = json["ticket_date"]?.toString();
    callCategory = json["call_category"]?.toString();
    contractType = json["contract_type"]?.toString();
    batteryBankId = json["battery_bank_id"]?.toString();
    siteId = json["site_id"]?.toString();
    endUsername = json["end_user_name"]?.toString();
    endUserMobile = json["end_user_number"]?.toString();
    segmentId = json["segment_id"]?.toString();
    segmentName = json["segment_name"]?.toString();
    applicationId = json["application_id"]?.toString();
    applicationName = json["application_name"]?.toString();
    problemDescription = json["problem_description"]?.toString();
    warrantyCheck = json["warranty_check"]?.toString();
    arblApprove = json["arbl_approve"]?.toString();
    flag = json["flag"]?.toInt();
    ticketType = json["ticket_type"]?.toInt();
    setrStatus = json["setr_status"]?.toString();
    plotNumber = json["plot_number"]?.toString();
    street = json["street"]?.toString();
    landmark = json["landmark"]?.toString();
    postCode = json["post_code"]?.toString();
    country = json["country"]?.toString();
    state = json["state"]?.toString();
    city = json["city"]?.toString();
    partNumber = json["part_number"]?.toString();
    workType = json["work_type"]?.toString();
    warrantyStatus = json["warranty_status"]?.toString();
    warrantyExpiryDate = json["warranty_expiry_date"]?.toString();
    contractExpiryDate = json["expiry_day"]?.toString();
    priceType = json["price_lable"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["ticket_id"] = ticketId;
    data["priority"] = priority;
    data["location"] = location;
    data["service_id"] = serviceId;
    data["status_code"] = statusCode;
    data["status_name"] = statusName;
    data["customer_name"] = customerName;
    data["customer_mobile"] = customerMobile;
    data["serial_no"] = serialNo;
    data["model_no"] = modelNo;
    data["start_date"] = startDate;
    data["ticket_date"] = ticketDate;
    data["next_visit"] = nextVisit;
    data["customer_address"] = customerAddress;
    data["call_category"] = callCategory;
    data["contract_type"] = contractType;
    data["battery_bank_id"] = batteryBankId;
    data["site_id"] = siteId;
    data["end_user_name"] = endUsername;
    data["end_user_number"] = endUserMobile;
    data["segment_id"] = segmentId;
    data["segment_name"] = segmentName;
    data["application_id"] = applicationId;
    data["application_name"] = applicationName;
    data["problem_description"] = problemDescription;
    data["warranty_check"] = warrantyCheck;
    data["arbl_approve"] = arblApprove;
    data["flag"] = flag;
    data["setr_status"] = setrStatus;
    data["plot_number"] = plotNumber;
    data["street"] = street;
    data["landmark"] = landmark;
    data["post_code"] = postCode;
    data["country"] = country;
    data["state"] = state;
    data["city"] = city;
    data["part_number"] = partNumber;
    data["work_type"] = workType;
    data["warranty_status"] = warrantyStatus;
    data["warranty_expiry_date"] = warrantyExpiryDate;
    data["expiry_day"] = contractExpiryDate;
    data["price_lable"] = priceType;
    return data;
  }
}

class OngoingTicketEntity {
  String? responseCode;
  String? token;
  List<OngoingTicketListItem?>? datum;

  OngoingTicketEntity({
    this.responseCode,
    this.token,
    this.datum,
  });

  OngoingTicketEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <OngoingTicketListItem>[];
      v.forEach((v) {
        arr0.add(OngoingTicketListItem.fromJson(v));
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

class OngoingTicketResponse {
  OngoingTicketEntity? ongoingTicketEntity;

  OngoingTicketResponse({
    this.ongoingTicketEntity,
  });

  OngoingTicketResponse.fromJson(Map<String, dynamic> json) {
    ongoingTicketEntity = (json["response"] != null)
        ? OngoingTicketEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (ongoingTicketEntity != null) {
      data["response"] = ongoingTicketEntity!.toJson();
    }
    return data;
  }
}
