class AMCListItems {
  String? customerCode;
  String? customerName;
  String? emailId;
  String? contactNumber;
  int? contractId;
  int? productId;
  String? productName;
  int? subCategoryId;
  String? subCategoryName;
  String? modelNo;
  String? serialNo;
  String? contractType;
  String? plotNumber;
  String? street;
  int? postCode;
  String? country;
  String? state;
  String? city;
  String? location;
  int? contractDuration;
  int? contractAmmount;
  String? startDate;
  String? expiryDay;
  String? invoiceId;
  int? flag;
  int? daysLeft;

  AMCListItems({
    this.customerCode,
    this.customerName,
    this.emailId,
    this.contactNumber,
    this.contractId,
    this.productId,
    this.productName,
    this.subCategoryId,
    this.subCategoryName,
    this.modelNo,
    this.serialNo,
    this.contractType,
    this.plotNumber,
    this.street,
    this.postCode,
    this.country,
    this.state,
    this.city,
    this.location,
    this.contractDuration,
    this.contractAmmount,
    this.startDate,
    this.expiryDay,
    this.invoiceId,
    this.flag,
    this.daysLeft,
  });

  AMCListItems.fromJson(Map<String, dynamic> json) {
    customerCode = json["customer_code"]?.toString();
    customerName = json["customer_name"]?.toString();
    emailId = json["email_id"]?.toString();
    contactNumber = json["contact_number"]?.toString();
    contractId = json["contract_id"]?.toInt();
    productId = json["product_id"]?.toInt();
    productName = json["product_name"]?.toString();
    subCategoryId = json["sub_category_id"]?.toInt();
    subCategoryName = json["sub_category_name"]?.toString();
    modelNo = json["model_no"]?.toString();
    serialNo = json["serial_no"]?.toString();
    contractType = json["contract_type"]?.toString();
    plotNumber = json["plot_number"]?.toString();
    street = json["street"]?.toString();
    postCode = json["post_code"]?.toInt();
    country = json["country"]?.toString();
    state = json["state"]?.toString();
    city = json["city"]?.toString();
    location = json["location"]?.toString();
    contractDuration = json["contract_duration"]?.toInt();
    contractAmmount = json["contract_ammount"]?.toInt();
    startDate = json["start_date"]?.toString();
    expiryDay = json["expiry_day"]?.toString();
    invoiceId = json["invoice_id"]?.toString();
    flag = json["flag"]?.toInt();
    daysLeft = json["days_left"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["customer_code"] = customerCode;
    data["customer_name"] = customerName;
    data["email_id"] = emailId;
    data["contact_number"] = contactNumber;
    data["contract_id"] = contractId;
    data["product_id"] = productId;
    data["product_name"] = productName;
    data["sub_category_id"] = subCategoryId;
    data["sub_category_name"] = subCategoryName;
    data["model_no"] = modelNo;
    data["serial_no"] = serialNo;
    data["contract_type"] = contractType;
    data["plot_number"] = plotNumber;
    data["street"] = street;
    data["post_code"] = postCode;
    data["country"] = country;
    data["state"] = state;
    data["city"] = city;
    data["location"] = location;
    data["contract_duration"] = contractDuration;
    data["contract_ammount"] = contractAmmount;
    data["start_date"] = startDate;
    data["expiry_day"] = expiryDay;
    data["invoice_id"] = invoiceId;
    data["flag"] = flag;
    data["days_left"] = daysLeft;
    return data;
  }
}

class AMCEntity {
  String? responseCode;
  String? token;
  String? message;
  List<AMCListItems?>? data;

  AMCEntity({
    this.responseCode,
    this.token,
    this.message,
    this.data,
  });

  AMCEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    message = json["message"]?.toString();
    if (json["data"] != null) {
      final v = json["data"];
      final arr0 = <AMCListItems>[];
      v.forEach((v) {
        arr0.add(AMCListItems.fromJson(v));
      });
      this.data = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
    data["message"] = message;
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

class AMCResponse {
  AMCEntity? response;

  AMCResponse({
    this.response,
  });

  AMCResponse.fromJson(Map<String, dynamic> json) {
    response = (json["response"] != null)
        ? AMCEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (response != null) {
      data["response"] = response!.toJson();
    }
    return data;
  }
}
