class WarehouseDetails {
  int? warehouseId;
  String? warehouseName;

  WarehouseDetails({
    this.warehouseId,
    this.warehouseName,
  });

  WarehouseDetails.fromJson(Map<String, dynamic> json) {
    warehouseId = json["warehouse_id"]?.toInt();
    warehouseName = json["warehouse_name"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["warehouse_id"] = warehouseId;
    data["warehouse_name"] = warehouseName;
    return data;
  }
}

class Role {
  int? roleId;
  String? roleName;

  Role({
    this.roleId,
    this.roleName,
  });

  Role.fromJson(Map<String, dynamic> json) {
    roleId = json["role_id"]?.toInt();
    roleName = json["role_name"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["role_id"] = roleId;
    data["role_name"] = roleName;
    return data;
  }
}

class UserDetails {
  int? technicianId;
  String? technicianCode;
  String? profilePic;
  Role? role;
  int? punchStatus;
  String? punchStatusName;
  int? userStatus;
  int? loginStatus;
  int? organizationType;

  UserDetails({
    this.technicianId,
    this.technicianCode,
    this.profilePic,
    this.role,
    this.punchStatus,
    this.punchStatusName,
    this.userStatus,
    this.loginStatus,
    this.organizationType,
  });

  UserDetails.fromJson(Map<String, dynamic> json) {
    technicianId = json["technician_id"]?.toInt();
    technicianCode = json["technician_code"]?.toString();
    profilePic = json["profile_pic"]?.toString();
    role = (json["role"] != null) ? Role.fromJson(json["role"]) : null;
    punchStatus = json["punch_status"]?.toInt();
    punchStatusName = json["punch_status_name"]?.toString();
    userStatus = json["user_status"]?.toInt();
    loginStatus = json["login_status"]?.toInt();
    organizationType = json["organization_type"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["technician_id"] = technicianId;
    data["technician_code"] = technicianCode;
    data["profile_pic"] = profilePic;
    if (role != null) {
      data["role"] = role!.toJson();
    }
    data["punch_status"] = punchStatus;
    data["punch_status_name"] = punchStatusName;
    data["user_status"] = userStatus;
    data["login_status"] = loginStatus;
    data["organization_type"] = organizationType;
    return data;
  }
}

class LoginDetails {
  String? username;
  String? name;

  LoginDetails({
    this.username,
    this.name,
  });

  LoginDetails.fromJson(Map<String, dynamic> json) {
    username = json["username"]?.toString();
    name = json["name"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["username"] = username;
    data["name"] = name;
    return data;
  }
}

class LoginEntity {
  String? responseCode;
  String? token;
  LoginDetails? loginDetails;
  UserDetails? userDetails;
  int? technicianRating;
  List<WarehouseDetails?>? warehouseDetails;
  String? message;

  LoginEntity({
    this.responseCode,
    this.token,
    this.loginDetails,
    this.userDetails,
    this.technicianRating,
    this.warehouseDetails,
    this.message,
  });

  LoginEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json["response_code"]?.toString();
    token = json["token"]?.toString();
    loginDetails = (json["login_details"] != null)
        ? LoginDetails.fromJson(json["login_details"])
        : null;
    userDetails = (json["user_details"] != null)
        ? UserDetails.fromJson(json["user_details"])
        : null;
    technicianRating = json["technician_rating"]?.toInt();
    if (json["warehouse_details"] != null) {
      final v = json["warehouse_details"];
      final arr0 = <WarehouseDetails>[];
      v.forEach((v) {
        arr0.add(WarehouseDetails.fromJson(v));
      });
      warehouseDetails = arr0;
    }
    message = json["message"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["response_code"] = responseCode;
    data["token"] = token;
    if (loginDetails != null) {
      data["login_details"] = loginDetails!.toJson();
    }
    if (userDetails != null) {
      data["user_details"] = userDetails!.toJson();
    }
    data["technician_rating"] = technicianRating;
    if (warehouseDetails != null) {
      final v = warehouseDetails;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["warehouse_details"] = arr0;
    }
    data["message"] = message;
    return data;
  }
}

class LoginResponse {
  LoginEntity? loginEntity;

  LoginResponse({
    this.loginEntity,
  });

  LoginResponse.fromJson(Map<String, dynamic> json) {
    loginEntity = (json["response"] != null)
        ? LoginEntity.fromJson(json["response"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (loginEntity != null) {
      data["response"] = loginEntity!.toJson();
    }
    return data;
  }
}
