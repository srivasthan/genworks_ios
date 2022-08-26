import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class LoginEntity {
  @JsonKey(name: 'response_code')
  final String? responseCode;

  @JsonKey(name: 'token')
  final String? token;

  @JsonKey(name: 'login_details')
  final LoginDetails? loginDetails;

  @JsonKey(name: 'user_details')
  final UserDetails? userDetails;

  @JsonKey(name: 'technician_rating')
  final double? technicianRating;

  @JsonKey(name: 'punch_status')
  final int? punchStatus;

  @JsonKey(name: 'message')
  final String? message;

  // @JsonKey(name: 'warehouse_details')
  // final List<WareHouseDetail> wareHouseDetail;

  LoginEntity(
      {this.responseCode,
      this.token,
      this.loginDetails,
      this.userDetails,
      this.technicianRating,
      this.punchStatus,
      this.message});

  //  this.wareHouseDetail});

  factory LoginEntity.fromJson(Map<String, dynamic> json) {
    return LoginEntity(
        responseCode: json['response_code'],
        token: json['token'],
        loginDetails: LoginDetails.fromJson(
            json['login_details'] as Map<String, dynamic>),
        userDetails:
            UserDetails.fromJson(json['user_details'] as Map<String, dynamic>),
        technicianRating: json['technician_rating'],
        punchStatus: json['punch_status'],
        message: json['message']);
    // var wareHouseList = json['warehouse_details'] as List;
    // List<WareHouseDetail> dataList =
    //     wareHouseList.map((i) => WareHouseDetail.fromJson(i)).toList();

    // wareHouseDetail: dataList);
  }
}

class LoginDetails {
  @JsonKey(name: 'username')
  final String? userName;

  @JsonKey(name: 'name')
  final String? name;

  LoginDetails({this.userName, this.name});

  factory LoginDetails.fromJson(Map<String, dynamic> json) {
    return LoginDetails(userName: json['username'], name: json['name']);
  }
}

class UserDetails {
  @JsonKey(name: 'technician_id')
  final int? technicianId;

  @JsonKey(name: 'technician_code')
  final String? technicianCode;

  @JsonKey(name: 'role')
  final Role? role;

  @JsonKey(name: 'punch_status')
  final int? punchStatus;

  @JsonKey(name: 'profile_pic')
  final String? profilePic;

  UserDetails(
      {this.technicianId,
      this.technicianCode,
      this.role,
      this.punchStatus,
      this.profilePic});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
        technicianId: json['technician_id'],
        technicianCode: json['technician_code'],
        role: Role.fromJson(json['role'] as Map<String, dynamic>),
        punchStatus: json['punch_status'],
        profilePic: json['profile_pic']);
  }
}

class Role {
  @JsonKey(name: 'role_id')
  final int? roleId;

  @JsonKey(name: 'role_name')
  final String? roleName;

  Role({this.roleId, this.roleName});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(roleId: json['role_id'], roleName: json['role_name']);
  }
}

class WareHouseDetail {
  @JsonKey(name: 'warehouse_id')
  final int? wareHouseId;

  @JsonKey(name: 'warehouse_name')
  final String? wareHouseName;

  WareHouseDetail({this.wareHouseId, this.wareHouseName});

  factory WareHouseDetail.fromJson(Map<String, dynamic> json) {
    return WareHouseDetail(
        wareHouseId: json['warehouse_id'],
        wareHouseName: json['warehouse_name']);
  }
}
