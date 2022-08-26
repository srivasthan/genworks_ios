import 'package:json_annotation/json_annotation.dart';

import '../entity/forgot_password.dart';

@JsonSerializable()
class ForgotPasswordResponse {
  @JsonKey(name: 'response')
  final ForgotPasswordEntity? forgotPasswordEntity;

  ForgotPasswordResponse({this.forgotPasswordEntity});

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
        forgotPasswordEntity: ForgotPasswordEntity.fromJson(
            json['response'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() {
    return {'response': forgotPasswordEntity};
  }
}
