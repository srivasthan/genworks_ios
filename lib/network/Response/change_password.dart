import 'package:json_annotation/json_annotation.dart';

class ChangePasswordResponse {
  @JsonKey(name: 'response')
  final ChangePasswordEntity? changePasswordEntity;

  ChangePasswordResponse({this.changePasswordEntity});

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
        changePasswordEntity: ChangePasswordEntity.fromJson(
            json['response'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() {
    return {'response': changePasswordEntity};
  }
}

@JsonSerializable()
class ChangePasswordEntity {
  @JsonKey(name: 'response_code')
  final String? responseCode;

  @JsonKey(name: 'token')
  final String? token;

  @JsonKey(name: 'message')
  final String? message;

  ChangePasswordEntity({this.responseCode, this.token, this.message});

  factory ChangePasswordEntity.fromJson(Map<String, dynamic> json) {
    return ChangePasswordEntity(
        responseCode: json['response_code'],
        token: json['token'],
        message: json['message']);
  }
}
