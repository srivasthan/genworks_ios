//GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_services.dart';

// ************************************************************************
// RetrofitGenerator
// ************************************************************************

class _ApiService implements ApiService {
  _ApiService(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    this.baseUrl ??= 'https://genworks.kaspontech.com/djadmin/';
  }

  final Dio? _dio;
  String? baseUrl;

  @override
  technicianLogin(body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final Response _result = await _dio!.request(baseUrl! + 'technician_login/',
        queryParameters: queryParameters,
        options: Options(
          method: 'POST',
          headers: <String, dynamic>{},
          extra: _extra,
        ),
        data: _data);
    final value = LoginResponse.fromJson(_result.data);
    return value;
  }

  @override
  forgotPassword(body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'technician_forget_password',
        queryParameters: queryParameters,
        options: Options(
            method: 'POST', headers: <String, dynamic>{}, extra: _extra),
        data: _data);
    final value = ForgotPasswordResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  changePassword(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'change_password/',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = ChangePasswordResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  logout(body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'technician_logout/',
        queryParameters: queryParameters,
        options: Options(
            method: 'POST', headers: <String, dynamic>{}, extra: _extra),
        data: _data);
    final value = ForgotPasswordResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getProfileDetails(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'technician_profile' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = ProfileResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  uploadImage(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'edit_technician',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = ChangePasswordResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getToken(technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_token' + '?' + queryString,
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = TokenResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  technicianPunchIn(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'technician_punch',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = TechnicianPunchInResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  technicianPunchOut(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'technician_punch',
        queryParameters: queryParameters,
        options:
        Options(method: 'PUT', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = TechnicianPunchInResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  newTicket(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'technician_new_ticket' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = NewTicketResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  onGoingTicket(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'technician_ongoing_ticket' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = OngoingTicketResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  ticketForTheDay(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'technician_ticket_for_day' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = TicketForTheDayResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  acceptTicket(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'technician_ticket_accept',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = ChangePasswordResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  rejectTicket(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'technician_ticket_reject',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = ChangePasswordResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getProducts() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_product_details/',
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = ProductResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  spareStatusGetApi(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'spare_status' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = SpareStatusResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  pendingFrmGetApi(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'pending_frm' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = PendingFrmResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  onHandSpareGetApi(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'on_hand_spare' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = OnHandSpareResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  requestedSpareList(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'requested_spare_list' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = RequestedSpareListResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  spareTransferListGetApi(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'spare_transfer_list' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = SpareTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  spareReceiveListGetApi(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'spare_recive_list' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = SpareReceiveResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  acceptTransferSpare(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'accept_transfer_spare',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = TransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  receiveTransferSpare(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'recive_transfer_spare',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = TransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  selectTechnicianList(body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'technician_skill/',
        queryParameters: queryParameters,
        options: Options(
            method: 'POST', headers: <String, dynamic>{}, extra: _extra),
        data: _data);
    final value = SelectTechnicianResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getConsumedSpareList(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'onhand_spare/',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = OnHandPrimaryResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  postAddSpareTransfer(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'add_spare_transfer',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getSpareCart(
      token, technicianCode, warehouseId, ticketId, spare, frmSpare) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {
      'technician_code': technicianCode,
      'warehouse_id': warehouseId,
      'ticket_id': ticketId,
      'spare': spare,
      'frm_spare': frmSpare
    };
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_spare' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = SpareCartResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  postPersonalSpareRequest(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'personal_spare_request',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getupdateFieldReturnMatrial(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'update_frm',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  fieldProstarttravel(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'start_travel',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = TransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getDistance(currentLatitude, currentLongitude, destinationLatitude,
      destinationLongitude) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {
      'latitude1': currentLatitude,
      'longitude1': currentLongitude,
      'latitude2': destinationLatitude,
      'longitude2': destinationLongitude
    };
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_distance' + '?' + queryString,
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = GetDistanceResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  endTravel(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'end_travel',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  fieldProTransportBill(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'bill',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  startTicket(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'ticket_start',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  serviceCategory(token, technicianCode, serviceId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {
      'technician_code': technicianCode,
      'service_id': serviceId
    };
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_service_category' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = InstallationCompleteResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  serviceActivity(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'create_service_activite',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  consumedSpareRequest(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'imprest_spare_track',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = ImpresetResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  discountDetail(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'price_discount_range/',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = ForgotPasswordResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  submitComplete(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {
      'submit_complete_from': 'submit_complete_from'
    };
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'submit_complete_from' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  verifyOtp(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'verify_otp',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  pendingFrm(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'return_pending_frm',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getDropLocationApi() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_warehouse/',
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = DropLocationResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  discountConsumedSpareRequest(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'price_discount_range/',
        queryParameters: queryParameters,
        options:
        Options(method: 'PUT', headers: {'Token': token}, extra: _extra),
        data: _data);
    final value = DiscountResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  submitFromRequestSpare(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {
      'request_spare_form': 'request_spare_form'
    };
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'request_spare_form' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  submitFromWorkInProgressFrom(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {
      'work_in_progress_form': 'work_in_progress_form'
    };
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'work_in_progress_form' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getSuggestedTechnicians(body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body);
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'suggested_technicians/',
        queryParameters: queryParameters,
        options: Options(
            method: 'POST', headers: <String, dynamic>{}, extra: _extra),
        data: _data);
    final value = SuggestedTechnicianResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  submitEscalateTicket(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'submit_escalate': 'submit_escalate'};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'submit_escalate' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  ticketSchedule(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'ticket_schedule',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = TicketScheduleResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  technicianDashboard(body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'technician_dashboard/',
        queryParameters: queryParameters,
        options: Options(
            method: 'POST', headers: <String, dynamic>{}, extra: _extra),
        data: body);
    final value = DashBoardResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getKnowledgeBaseSubProductList(productId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'product_id': productId.toString()};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'tech_subproduct_details/' + '?' + queryString,
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = KBSubProductResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  enterSolution(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {
      'knowledge_base_solution': 'knowledge_base_solution'
    };
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'knowledge_base_solution' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  referKnowledgeBaseSolution(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'refer_knowledge_base_solution',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = ReferSolutionResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  training(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode!};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'training' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = TrainingResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  amcSearch(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'amc_search',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AMCResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  submittedClaim(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode!};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'submited_claims' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = SubmittedClaimResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  submitNewClaim(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'reimbursment_request',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getTravelUpdate(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'travel_list/',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = TravelUpdateResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  updateTravel(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'reimbursement_bill/',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getAMC() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_amc_details/',
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = AddAMCResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getWorkType() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_servicegroup/',
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = WorkTypeResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getCountry() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_country/',
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = CountryResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getAMCProduct() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_product_details/',
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = AMCProductResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getCallCategory() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_call_category/',
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = CallCategoryResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getState(countryId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    Map<String, String> queryParams = {'country_id': countryId!.toString()};
    String queryString = Uri(queryParameters: queryParams).query;
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_state/' + '?' + queryString,
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = StateResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getCity(stateId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    Map<String, String> queryParams = {'state_id': stateId!.toString()};
    String queryString = Uri(queryParameters: queryParams).query;
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_city/' + '?' + queryString,
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = CityResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getLocation(cityId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    Map<String, String> queryParams = {'city_id': cityId!.toString()};
    String queryString = Uri(queryParameters: queryParams).query;
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'get_location_details/' + '?' + queryString,
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = LocationResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  getAMCSubProduct(productId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    Map<String, String> queryParams = {'product_id': productId!.toString()};
    String queryString = Uri(queryParameters: queryParams).query;
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'tech_subproduct_details/' + '?' + queryString,
        queryParameters: queryParameters,
        options: Options(
            method: 'GET', headers: <String, dynamic>{}, extra: _extra));
    final value = AMCSubProductResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  validateSerialNo(body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'validate_cus_serial_no/',
        queryParameters: queryParameters,
        options: Options(
            method: 'POST', headers: <String, dynamic>{}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  addNewProductAmc(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'product_amc',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  technicianRenewAmc(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'technician_renew_amc',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  createNewAmcResult(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'amc',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  submitAMCTicket(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'submit_amc',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  assessmentList(token, technicianCode) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    Map<String, String> queryParams = {'technician_code': technicianCode!};
    String queryString = Uri(queryParameters: queryParams).query;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.get(
        baseUrl! + 'certificate' + '?' + queryString,
        queryParameters: queryParameters,
        options:
        Options(method: 'GET', headers: {'Token': token}, extra: _extra));
    final value = AssessmentResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  trainingReferenceDetails(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'training_reference_details/',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = TrainingReferenceResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  submitQuizDataAssessment(token, body) async {
    ArgumentError.checkNotNull(body, 'body');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
    final Response<Map<String, dynamic>> _result = await _dio!.request(
        baseUrl! + 'submit_quiz',
        queryParameters: queryParameters,
        options:
        Options(method: 'POST', headers: {'Token': token}, extra: _extra),
        data: body);
    final value = AddTransferResponse.fromJson(_result.data!);
    return Future.value(value);
  }

  @override
  technicianTracking({queryString}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio!.post(
        baseUrl! + 'add_technician_tracker/' + '?' + queryString!,
        queryParameters: queryParameters,
        options: Options(
            method: 'POST', headers: <String, dynamic>{}, extra: _extra));
    final value = TrackingResponse.fromJson(_result.data!);
    return Future.value(value);
  }
}
