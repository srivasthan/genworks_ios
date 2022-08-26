
class MonthlyTargetListItems {

  String? ticketId;
  String? priority;
  String? location;
  int? statusCode;
  String? statusName;
  String? customerName;
  String? customerMobile;
  String? serialNo;
  String? modelNo;
  String? nextVisit;
  String? customerAddress;
  String? callCategory;
  String? contractType;
  String? problemDescription;

  MonthlyTargetListItems({
    this.ticketId,
    this.priority,
    this.location,
    this.statusCode,
    this.statusName,
    this.customerName,
    this.customerMobile,
    this.serialNo,
    this.modelNo,
    this.nextVisit,
    this.customerAddress,
    this.callCategory,
    this.contractType,
    this.problemDescription,
  });
  MonthlyTargetListItems.fromJson(Map<String, dynamic> json) {
    ticketId = json["ticket_id"]?.toString();
    priority = json["priority"]?.toString();
    location = json["location"]?.toString();
    statusCode = json["status_code"]?.toInt();
    statusName = json["status_name"]?.toString();
    customerName = json["customer_name"]?.toString();
    customerMobile = json["customer_mobile"]?.toString();
    serialNo = json["serial_no"]?.toString();
    modelNo = json["model_no"]?.toString();
    nextVisit = json["next_visit"]?.toString();
    customerAddress = json["customer_address"]?.toString();
    callCategory = json["call_category"]?.toString();
    contractType = json["contract_type"]?.toString();
    problemDescription = json["problem_description"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["ticket_id"] = ticketId;
    data["priority"] = priority;
    data["location"] = location;
    data["status_code"] = statusCode;
    data["status_name"] = statusName;
    data["customer_name"] = customerName;
    data["customer_mobile"] = customerMobile;
    data["serial_no"] = serialNo;
    data["model_no"] = modelNo;
    data["next_visit"] = nextVisit;
    data["customer_address"] = customerAddress;
    data["call_category"] = callCategory;
    data["contract_type"] = contractType;
    data["problem_description"] = problemDescription;
    return data;
  }
}

class DashBoardListItems {

  int? status;
  String? techRewardPoint;
  String? nextRewardPoint;
  String? overallRank;
  List<MonthlyTargetListItems?>? monthlyTarget;
  int? taskCount;
  int? totalTaskCount;

  DashBoardListItems({
    this.status,
    this.techRewardPoint,
    this.nextRewardPoint,
    this.overallRank,
    this.monthlyTarget,
    this.taskCount,
    this.totalTaskCount,
  });
  DashBoardListItems.fromJson(Map<String, dynamic> json) {
    status = json["status"]?.toInt();
    techRewardPoint = json["tech_reward_point"]?.toString();
    nextRewardPoint = json["next_reward_point"]?.toString();
    overallRank = json["overall_rank"]?.toString();
    if (json["monthly_target"] != null) {
      final v = json["monthly_target"];
      final arr0 = <MonthlyTargetListItems>[];
      v.forEach((v) {
        arr0.add(MonthlyTargetListItems.fromJson(v));
      });
      monthlyTarget = arr0;
    }
    taskCount = json["task_count"]?.toInt();
    totalTaskCount = json["total_task_count"]?.toInt();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["status"] = status;
    data["tech_reward_point"] = techRewardPoint;
    data["next_reward_point"] = nextRewardPoint;
    data["overall_rank"] = overallRank;
    if (monthlyTarget != null) {
      final v = monthlyTarget;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["monthly_target"] = arr0;
    }
    data["task_count"] = taskCount;
    data["total_task_count"] = totalTaskCount;
    return data;
  }
}

class DashBoardEntity {

  String? responseCode;
  DashBoardListItems? data;

  DashBoardEntity({
    this.responseCode,
    this.data,
  });
  DashBoardEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    data = (json["data"] != null) ? DashBoardListItems.fromJson(json["data"]) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["data"] = this.data!.toJson();
    return data;
  }
}

class DashBoardResponse {
  DashBoardEntity? dashBoardEntity;

  DashBoardResponse({
    this.dashBoardEntity,
  });
  DashBoardResponse.fromJson(Map<String, dynamic> json) {
    dashBoardEntity = (json["response"] != null) ? DashBoardEntity.fromJson(json["response"]) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (dashBoardEntity != null) {
      data["response"] = dashBoardEntity!.toJson();
    }
    return data;
  }
}