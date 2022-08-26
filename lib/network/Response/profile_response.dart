
class AssignedServiceDesk {

  String? assignedServiceDeskId;
  String? assignedServiceDeskName;

  AssignedServiceDesk({
    this.assignedServiceDeskId,
    this.assignedServiceDeskName,
  });
  AssignedServiceDesk.fromJson(Map<String, dynamic> json) {
    assignedServiceDeskId = json['assigned_service_desk_id']?.toString();
    assignedServiceDeskName = json['assigned_service_desk_name']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['assigned_service_desk_id'] = assignedServiceDeskId;
    data['assigned_service_desk_name'] = assignedServiceDeskName;
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
    roleId = json['role_id']?.toInt();
    roleName = json['role_name']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['role_id'] = roleId;
    data['role_name'] = roleName;
    return data;
  }
}

class ProfileResponseListItems {

  String? technicianCode;
  int? employeeId;
  String? fullName;
  String? emailId;
  String? contactNumber;
  String? alternateContactNumber;
  String? profilePic;
  String? address;
  String? plotNumber;
  String? street;
  String? landmark;
  int? postCode;
  Role? role;
  String? location;
  AssignedServiceDesk? assignedServiceDesk;
  String? assignedCountry;
  List<String?>? assignedState;
  List<String?>? assignedCity;
  String? assignedLocation;
  int? technicianRating;

  ProfileResponseListItems({
    this.technicianCode,
    this.employeeId,
    this.fullName,
    this.emailId,
    this.contactNumber,
    this.alternateContactNumber,
    this.profilePic,
    this.address,
    this.plotNumber,
    this.street,
    this.landmark,
    this.postCode,
    this.role,
    this.location,
    this.assignedServiceDesk,
    this.assignedCountry,
    this.assignedState,
    this.assignedCity,
    this.assignedLocation,
    this.technicianRating,
  });
  ProfileResponseListItems.fromJson(Map<String, dynamic> json) {
    technicianCode = json['technician_code']?.toString();
    employeeId = json['employee_id']?.toInt();
    fullName = json['full_name']?.toString();
    emailId = json['email_id']?.toString();
    contactNumber = json['contact_number']?.toString();
    alternateContactNumber = json['alternate_contact_number']?.toString();
    profilePic = json['profile_pic']?.toString();
    address = json['address']?.toString();
    plotNumber = json['plot_number']?.toString();
    street = json['street']?.toString();
    landmark = json['landmark']?.toString();
    postCode = json['post_code']?.toInt();
    role = (json['role'] != null) ? Role.fromJson(json['role']) : null;
    location = json['location']?.toString();
    assignedServiceDesk = (json['assigned_service_desk'] != null) ? AssignedServiceDesk.fromJson(json['assigned_service_desk']) : null;
    assignedCountry = json['assigned_country']?.toString();
    if (json['assigned_state'] != null) {
      final v = json['assigned_state'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      assignedState = arr0;
    }
    if (json['assigned_city'] != null) {
      final v = json['assigned_city'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      assignedCity = arr0;
    }
    assignedLocation = json['assigned_location']?.toString();
    technicianRating = json['technician_rating']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['technician_code'] = technicianCode;
    data['employee_id'] = employeeId;
    data['full_name'] = fullName;
    data['email_id'] = emailId;
    data['contact_number'] = contactNumber;
    data['alternate_contact_number'] = alternateContactNumber;
    data['profile_pic'] = profilePic;
    data['address'] = address;
    data['plot_number'] = plotNumber;
    data['street'] = street;
    data['landmark'] = landmark;
    data['post_code'] = postCode;
    if (role != null) {
      data['role'] = role!.toJson();
    }
    data['location'] = location;
    if (assignedServiceDesk != null) {
      data['assigned_service_desk'] = assignedServiceDesk!.toJson();
    }
    data['assigned_country'] = assignedCountry;
    if (assignedState != null) {
      final v = assignedState;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['assigned_state'] = arr0;
    }
    if (assignedCity != null) {
      final v = assignedCity;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['assigned_city'] = arr0;
    }
    data['assigned_location'] = assignedLocation;
    data['technician_rating'] = technicianRating;
    return data;
  }
}

class ProfileResponseEntity {

  String? responseCode;
  String? token;
  ProfileResponseListItems? data;

  ProfileResponseEntity({
    this.responseCode,
    this.token,
    this.data,
  });
  ProfileResponseEntity.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code']?.toString();
    token = json['token']?.toString();
    data = (json['data'] != null) ? ProfileResponseListItems.fromJson(json['data']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['token'] = token;
    if (data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProfileResponse {

  ProfileResponseEntity? response;

  ProfileResponse({
    this.response,
  });
  ProfileResponse.fromJson(Map<String, dynamic> json) {
    response = (json['response'] != null) ? ProfileResponseEntity.fromJson(json['response']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (response != null) {
      data['response'] = response!.toJson();
    }
    return data;
  }
}
