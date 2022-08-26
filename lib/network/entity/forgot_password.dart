import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ForgotPasswordEntity {
  @JsonKey(name: 'response_code')
  final String? responseCode;

  @JsonKey(name: 'message')
  final String? message;

  ForgotPasswordEntity({this.responseCode, this.message});

  factory ForgotPasswordEntity.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordEntity(
        responseCode: json['response_code'], message: json['message']);
  }
}
