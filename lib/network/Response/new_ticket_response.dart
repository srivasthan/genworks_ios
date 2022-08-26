import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class NewTicketResponse {
  @JsonKey(name: 'response')
  final NewTicketEntity? newTicketEntity;

  NewTicketResponse({this.newTicketEntity});

  factory NewTicketResponse.fromJson(Map<String, dynamic> json) {
    return NewTicketResponse(
      newTicketEntity:
          NewTicketEntity.fromJson(json['response'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': newTicketEntity,
    };
  }
}

@JsonSerializable()
class NewTicketEntity {
  @JsonKey(name: 'response_code')
  final String? responseCode;

  @JsonKey(name: 'token')
  final String? token;

  @JsonKey(name: 'data')
  final List<NewTicketListItems>? datum;

  NewTicketEntity({this.responseCode, this.token, this.datum});

  factory NewTicketEntity.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['data'] as List;
    List<NewTicketListItems> dataList =
        list.map((i) => NewTicketListItems.fromJson(i)).toList();

    return NewTicketEntity(
        responseCode: parsedJson['response_code'],
        token: parsedJson['token'],
        datum: dataList);
  }
}

class NewTicketListItems {
  @JsonKey(name: 'ticket_id')
  final String? ticketId;

  @JsonKey(name: 'priority')
  final String? priority;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'customer_name')
  final String? customerName;

  @JsonKey(name: 'customer_mobile')
  final String? customerMobile;

  @JsonKey(name: 'end_user_name')
  final String? endUserName;

  @JsonKey(name: 'end_user_number')
  final String? endUserMobile;

  @JsonKey(name: 'serial_no')
  final String? serialNo;

  @JsonKey(name: 'model_no')
  final String? modelNo;

  @JsonKey(name: 'customer_address')
  final String? customerAddress;

  @JsonKey(name: 'call_category')
  final String? callCategory;

  @JsonKey(name: 'contract_type')
  final String? contractType;

  @JsonKey(name: 'price_lable')
  final String? priceLabel;

  @JsonKey(name: 'price_type')
  final int? priceType;

  @JsonKey(name: 'problem_description')
  final String? problemDescription;

  @JsonKey(name: 'image')
  final String? ticketImage;

  @JsonKey(name: 'video')
  final String? video;

  @JsonKey(name: 'warranty_status')
  final String? warrantyStatus;

  @JsonKey(name: 'expiry_day')
  final String? contractExpiryDate;

  @JsonKey(name: 'part_number')
  final String? partNumber;

  NewTicketListItems(
      {this.ticketId,
      this.priority,
      this.location,
      this.customerName,
      this.customerMobile,
        this.endUserName,
        this.endUserMobile,
        this.priceLabel,
        this.priceType,
      this.serialNo,
      this.modelNo,
      this.customerAddress,
      this.callCategory,
      this.contractType,
      this.problemDescription,
      this.ticketImage,
      this.video,
        this.warrantyStatus,
        this.contractExpiryDate,
      this.partNumber});

  factory NewTicketListItems.fromJson(Map<String, dynamic> json) {
    return NewTicketListItems(
        ticketId: json["ticket_id"],
        priority: json["priority"],
        location: json["location"],
        customerName: json["customer_name"],
        customerMobile: json["customer_mobile"],
        endUserName: json["end_user_name"],
        endUserMobile: json["end_user_number"],
        priceLabel: json["price_lable"],
        priceType: json["price_type"],
        serialNo: json["serial_no"],
        modelNo: json["model_no"],
        customerAddress: json["customer_address"],
        callCategory: json["call_category"],
        contractType: json["contract_type"],
        problemDescription: json["problem_description"],
        ticketImage: json["image"],
        video: json["video"],
        warrantyStatus: json["warranty_status"],
        contractExpiryDate: json["expiry_day"],
        partNumber: json["part_number"]);
  }
}
