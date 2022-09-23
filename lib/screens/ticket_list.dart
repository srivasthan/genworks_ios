import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:fieldpro_genworks_healthcare/screens/show_image.dart';
import 'package:fieldpro_genworks_healthcare/screens/show_video.dart';
import 'package:fieldpro_genworks_healthcare/screens/start_ticket.dart';
import 'package:fieldpro_genworks_healthcare/screens/submit_complete.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:shimmer/shimmer.dart';

import '../network/api_services.dart';
import '../network/db/amc_ticket_details.dart';
import '../network/db/app_database.dart';
import '../network/db/new_ticket.dart';
import '../network/db/ongoing_ticket.dart';
import '../network/db/serial_no_data.dart';
import '../network/db/ticket_for_the_day.dart';
import '../network/model/new_ticket.dart';
import '../network/model/ongoing_ticket.dart';
import '../network/model/ticket_for_the_day.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/technician_punch.dart';
import '../utility/validator.dart';
import 'amc_ticket_details.dart';
import 'dashboard.dart';
import 'field_return_material.dart';
import 'map_screen.dart';

class TicketList extends StatefulWidget {
  final int selectedIndex;

  const TicketList(this.selectedIndex, {super.key});

  @override
  _TicketListState createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  bool _isLoading = true,
      _rejectFormFieldVisible = false,
      _isDateUpdated = false;
  int? val = -1;
  int _currentSelection = 0;
  final formKey = GlobalKey<FormState>();
  final TextEditingController _rejectReason = TextEditingController();
  bool _ongoingButtonClicked = false,
      _newTicketListEmpty = false,
      _ongoingTicketListEmpty = false,
      _ticketForTheDayListEmpty = false,
      _noDataAvailable = false,
      _newTicketButtonClicked = false,
      _ticketForTheDayButtonClicked = false;
  DateTime selectedDate = DateTime.now();
  var inputDate;
  File? image;
  String? _tfdContractType;
  String? _getToken,
      _getTechnicianCode,
      _newTicketId,
      _newTicketCustomerName,
      _newTicketMobile,
      _newTicketModel,
      _newTicketSerial,
      _newTicketCategory,
      _newTicketPriority,
      _rejectReasonString,
      _newTicketDescription;
  String? _ticketForTheDayId,
      _ticketForTheDayCustomerName,
      _ticketForTheDayMobile,
      _ticketForTheDayAddress,
      _ticketForTheDayModelNo,
      _ticketForTheDaySerial,
      _ticketForTheDayCategory,
      _ticketForTheDayPriority,
      _ticketForTheDayDescription;
  double? destinationLatitude, destinationLongitude;
  String? _ongoingTicketCustomerName,
      _ongoingTicketMobile,
      _ongoingTicketAddress,
      _ongoingTicketModelNo,
      _ongoingTicketSerial,
      _ongoingTicketPriority,
      _nextVisitDate,
      _ongoingTicketDescription;
  var newTicketList = <NewTicketModel>[];
  var _ongoingResult, _newResult, _ticketOfTheDayResult;
  List<OngoingTicketModel> ongoingTicketList = <OngoingTicketModel>[];
  List<TicketForTheDayModel> ticketForTheDayList = <TicketForTheDayModel>[];
  late PersistentBottomSheetController _controller;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _hideFloatingButton = false;

  final Map<int, Widget> _children = {
    0: const Padding(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      child: Text(
        "New Ticket",
        style: TextStyle(fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    ),
    1: const Padding(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      child: Text(
        "Ongoing Ticket",
        style: TextStyle(fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    ),
    2: const Padding(
      padding: EdgeInsets.only(left: 5.0, right: 10.0),
      child: Text(
        "Ticket Details",
        style: TextStyle(fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    ),
  };

  Future<void> getNewTicketList(BuildContext context) async {
    setState(() {
      _currentSelection = 0;
      _isLoading = true;
      newTicketList.clear();
      _ongoingButtonClicked = false;
      _ticketForTheDayButtonClicked = false;
      _newTicketButtonClicked = true;
      _hideFloatingButton = false;
      val = -1;
      _rejectReason.text = MyConstants.empty;
      _noDataAvailable = false;
      if (_ongoingTicketListEmpty == true) {
        _ongoingTicketListEmpty = !_ongoingTicketListEmpty;
      }
      if (_ticketForTheDayListEmpty == true) {
        _ticketForTheDayListEmpty = !_ticketForTheDayListEmpty;
      }
      PreferenceUtils.setString(MyConstants.technicianStatus,
          MyConstants.busy);
    });

    if (await checkInternetConnection() == true) {
      _getToken = PreferenceUtils.getString(MyConstants.token);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      ApiService apiService = ApiService(dio.Dio());
      final response =
      await apiService.newTicket(_getToken!, _getTechnicianCode!);
      if (response.newTicketEntity!.responseCode == "200") {
        final database = await $FloorAppDatabase
            .databaseBuilder('floor_database.db')
            .build();
        final newTicketDao = database.newTicketDao;
        await newTicketDao.deleteNewTicketTable();
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.newTicketEntity!.token!);
          for (int i = 0; i < response.newTicketEntity!.datum!.length; i++) {
            newTicketList.add(NewTicketModel(
                ticketId: response.newTicketEntity!.datum![i].ticketId ??
                    MyConstants.na,
                priority: response.newTicketEntity!.datum![i].priority ??
                    MyConstants.na,
                location: response.newTicketEntity!.datum![i].location ??
                    MyConstants.na,
                customerName: response.newTicketEntity!.datum![i]
                    .customerName ?? MyConstants.na,
                customerMobile:
                response.newTicketEntity!.datum![i].customerMobile ??
                    MyConstants.na,
                serialNo: response.newTicketEntity!.datum![i].serialNo ??
                    MyConstants.na,
                modelNo: response.newTicketEntity!.datum![i].modelNo ??
                    MyConstants.na,
                customerAddress:
                response.newTicketEntity!.datum![i].customerAddress ??
                    MyConstants.na,
                endUserName: response.newTicketEntity!.datum![i].endUserName ??
                    MyConstants.na,
                endUserMobile:
                response.newTicketEntity!.datum![i].endUserMobile ??
                    MyConstants.na,
                callCategory: response.newTicketEntity!.datum![i]
                    .callCategory ?? MyConstants.na,
                contractType: response.newTicketEntity!.datum![i]
                    .contractType ?? MyConstants.na,
                ticketImage: response.newTicketEntity!.datum![i].ticketImage ??
                    MyConstants.na,
                problemDescription:
                response.newTicketEntity!.datum![i].problemDescription ??
                    MyConstants.na,
                priceType:
                response.newTicketEntity!.datum![i].priceLabel ?? MyConstants.na,
                warrantyStatus:
                response.newTicketEntity!.datum![i].warrantyStatus ?? MyConstants.na,
                contractExpiryDate:
                response.newTicketEntity!.datum![i].contractExpiryDate ?? MyConstants.na,
                video:
                response.newTicketEntity!.datum![i].video ?? MyConstants.na,
                partNumber:
                response.newTicketEntity!.datum![i].partNumber ??
                    MyConstants.na));
            NewTicketTable newTicketData = NewTicketTable(
                i + 1,
                response.newTicketEntity!.datum![i].ticketId ?? MyConstants.na,
                response.newTicketEntity!.datum![i].priority ?? MyConstants.na,
                response.newTicketEntity!.datum![i].location ?? MyConstants.na,
                response.newTicketEntity!.datum![i].customerName ??
                    MyConstants.na,
                response.newTicketEntity!.datum![i].customerMobile ??
                    MyConstants.na,
                response.newTicketEntity!.datum![i].serialNo ?? MyConstants.na,
                response.newTicketEntity!.datum![i].modelNo ?? MyConstants.na,
                response.newTicketEntity!.datum![i].customerAddress ??
                    MyConstants.na,
                response.newTicketEntity!.datum![i].callCategory ??
                    MyConstants.na,
                response.newTicketEntity!.datum![i].contractType ??
                    MyConstants.na,
                response.newTicketEntity!.datum![i].problemDescription ??
                    MyConstants.na,
                response.newTicketEntity!.datum![i].endUserName ??
                    MyConstants.na,
                response.newTicketEntity!.datum![i].endUserMobile ??
                    MyConstants.na);
            newTicketDao.insertNewTicket(newTicketData);
          }
          _isLoading = !_isLoading;
          _newTicketListEmpty = true;
        });
      }
      if (response.newTicketEntity!.responseCode == "400") {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.newTicketEntity!.token!);
          _noDataAvailable = true;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void getUserList() async {
    final database =
    await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final newTicketDao = database.newTicketDao;
    _newResult = await newTicketDao.findAllNewTicket();
  }

  getNewTicketListDetails(int index) {
    _newTicketId = _newResult[index].ticketId;
    _newTicketCustomerName = _newResult[index].customerName;
    _newTicketMobile = _newResult[index].customerMobile;
    _newTicketSerial = _newResult[index].serialNo;
    _newTicketCategory = _newResult[index].callCategory;
    _newTicketModel = _newResult[index].serialNo;
    _newTicketPriority = _newResult[index].priority;
    _newTicketDescription = _newResult[index].problemDescription;
  }

  Future<void> getOngoingTicketList(BuildContext context) async {
    setState(() {
      _currentSelection = 1;
      _isLoading = true;
      ongoingTicketList.clear();
      _newTicketButtonClicked = false;
      _ticketForTheDayButtonClicked = false;
      _hideFloatingButton = false;
      _ongoingButtonClicked = true;
      _noDataAvailable = false;
      if (_newTicketListEmpty == true) {
        _newTicketListEmpty = !_newTicketListEmpty;
      }
      if (_ticketForTheDayListEmpty == true) {
        _ticketForTheDayListEmpty = !_ticketForTheDayListEmpty;
      }
    });
    if (await checkInternetConnection() == true) {
      _getToken = PreferenceUtils.getString(MyConstants.token);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      ApiService apiService = ApiService(dio.Dio());
      final response =
      await apiService.onGoingTicket(_getToken!, _getTechnicianCode!);
      if (response.ongoingTicketEntity!.responseCode == "200") {
        final database = await $FloorAppDatabase
            .databaseBuilder('floor_database.db')
            .build();
        final ongoingTicketDao = database.ongoingTicketDao;
        final ticketForTheDayDao = database.ticketForTheDayDao;
        await ongoingTicketDao.deleteOngoingTicketTable();
        await ticketForTheDayDao.deleteTicketForTheDayTable();
        setState(() {
          PreferenceUtils.setString(MyConstants.token,
              response.ongoingTicketEntity!.token!);
          for (int i = 0;
          i < response.ongoingTicketEntity!.datum!.length;
          i++) {
            ongoingTicketList.add(OngoingTicketModel(
                ticketId: response.ongoingTicketEntity!.datum![i]!.ticketId ??
                    MyConstants.na,
                priority: response.ongoingTicketEntity!.datum![i]!.priority ??
                    MyConstants.na,
                location: response.ongoingTicketEntity!.datum![i]!.location ??
                    MyConstants.na,
                statusName: response.ongoingTicketEntity!.datum![i]!
                    .statusName ?? MyConstants.na,
                customerName:
                response.ongoingTicketEntity!.datum![i]!.customerName ??
                    MyConstants.na,
                latitude: response.ongoingTicketEntity!.datum![i]!.latitude ??
                    MyConstants.na,
                longitude: response.ongoingTicketEntity!.datum![i]!.longitude ??
                    MyConstants.na,
                ticketType: response.ongoingTicketEntity!.datum![i]!
                    .ticketType ?? 0,
                customerMobile:
                response.ongoingTicketEntity!.datum![i]!.customerMobile ??
                    MyConstants.na,
                serialNo: response.ongoingTicketEntity!.datum![i]!.serialNo ??
                    MyConstants.na,
                modelNo: response.ongoingTicketEntity!.datum![i]!.modelNo ??
                    MyConstants.na,
                customerAddress:
                response.ongoingTicketEntity!.datum![i]!.customerAddress ??
                    MyConstants.na,
                callCategory:
                response.ongoingTicketEntity!.datum![i]!.callCategory ??
                    MyConstants.na,
                endUserName:
                response.ongoingTicketEntity!.datum![i]!.endUsername ??
                    MyConstants.na,
                endUserMobile:
                response.ongoingTicketEntity!.datum![i]!.endUserMobile ??
                    MyConstants.na,
                contractType:
                response.ongoingTicketEntity!.datum![i]!.contractType ??
                    MyConstants.na,
                nextVisit: response.ongoingTicketEntity!.datum![i]!.nextVisit ??
                    MyConstants.na,
                priceType: response.ongoingTicketEntity!.datum![i]!.priceType ??
                    MyConstants.na,
                partNumber: response.ongoingTicketEntity!.datum![i]!
                    .partNumber ??
                    MyConstants.na,
                warrantyStatus: response.ongoingTicketEntity!.datum![i]!
                    .warrantyStatus ??
                    MyConstants.na,
                warrantyExpiryDate: response.ongoingTicketEntity!.datum![i]!
                    .warrantyExpiryDate ??
                    MyConstants.na,
                contractExpiryDate: response.ongoingTicketEntity!.datum![i]!
                    .contractExpiryDate ??
                    MyConstants.na,
                problemDescription: response
                    .ongoingTicketEntity!.datum![i]!.problemDescription ??
                    MyConstants.na));

            //insert values to ongoingTicketTable
            OngoingTicketTable ongoingTicketTable = OngoingTicketTable(
                i + 1,
                PreferenceUtils.getString(
                    MyConstants.technicianCode),
                response.ongoingTicketEntity!.datum![i]?.ticketId ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.priority ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.location ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.customerName ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.customerMobile ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.serialNo ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.modelNo ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.customerAddress ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.callCategory ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.contractType ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.problemDescription ??
                    MyConstants.na,
                "Work_In_Progress",
                response.ongoingTicketEntity!.datum![i]?.nextVisit ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.endUsername ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.endUserMobile ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.siteId ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.segmentId ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.segmentName ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.applicationId ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.batteryBankId ??
                    MyConstants.na,
                response.ongoingTicketEntity!.datum![i]?.flag ?? 0);
            ongoingTicketDao.insertOngoingTicket(ongoingTicketTable);

            if (response.ongoingTicketEntity!.datum![i]?.statusName ==
                MyConstants.accepted ||
                response.ongoingTicketEntity!.datum![i]?.statusName ==
                    MyConstants.travelStarted ||
                response.ongoingTicketEntity!.datum![i]?.statusName ==
                    MyConstants.reached ||
                response.ongoingTicketEntity!.datum![i]?.statusName ==
                    MyConstants.ticketStarted ||
                response.ongoingTicketEntity!.datum![i]?.statusName ==
                    MyConstants.otpVerified) {
              TicketForTheDayTable ticketForTheDayTable = TicketForTheDayTable(
                  i + 1,
                  PreferenceUtils.getString(
                      MyConstants.technicianCode),
                  response.ongoingTicketEntity!.datum![i]?.ticketId ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.priority ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.location ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.customerName ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.customerMobile ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.endUsername ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.endUserMobile ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.serialNo ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.modelNo ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.customerAddress ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.callCategory ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.contractType ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.problemDescription ??
                      "",
                  response.ongoingTicketEntity!.datum![i]?.statusName ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.nextVisit ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.latitude ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.longitude ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.statusCode ?? 0,
                  response.ongoingTicketEntity!.datum![i]?.serviceId ?? 0,
                  MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.workType ??
                      MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.ticketDate ??
                      MyConstants.na,
                  MyConstants.today,
                  MyConstants.empty,
                  MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.ticketType ?? 0,
                  response.ongoingTicketEntity!.datum![i]?.partNumber ?? MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.warrantyStatus ?? MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.contractExpiryDate ?? MyConstants.na,
                  response.ongoingTicketEntity!.datum![i]?.priceType ??
                      MyConstants.na);
              ticketForTheDayDao.insertTicketForTheDay(ticketForTheDayTable);
            }
          }

          _ongoingTicketListEmpty = !_ongoingTicketListEmpty;
          _isLoading = !_isLoading;
        });
      }
      if (response.ongoingTicketEntity!.responseCode == "400") {
        setState(() {
          PreferenceUtils.setString(MyConstants.token,
              response.ongoingTicketEntity!.token!);
          _noDataAvailable = true;
          _isLoading = !_isLoading;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> getOngoingTicketDetails() async {
    final database =
    await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final ongoingTicketDao = database.ongoingTicketDao;
    _ongoingResult = await ongoingTicketDao.findAllOngoingTicket();
  }

  getOngoingDetails(int index) {
    _ongoingTicketCustomerName = _ongoingResult[index].customerName;
    _ongoingTicketMobile = _ongoingResult[index].customerMobile;
    _ongoingTicketAddress = _ongoingResult[index].customerAddress;
    _ongoingTicketSerial = _ongoingResult[index].serialNo;
    _ongoingTicketModelNo = _ongoingResult[index].modelNo;
    _ongoingTicketPriority = _ongoingResult[index].priority;
    _ongoingTicketDescription = _ongoingResult[index].problemDescription;
    if (_ongoingResult[index].nextVisit.toString() != MyConstants.na) {
      _nextVisitDate = DateFormat('dd-MM-yyyy').format(
          DateFormat('yyyy-MM-dd').parse(_ongoingResult[index].nextVisit));
    }
  }

  Future<void> getTicketForTheDayList(BuildContext context) async {
    setState(() {
      _currentSelection = 2;
      _isLoading = true;
      ticketForTheDayList.clear();
      _newTicketButtonClicked = false;
      _ongoingButtonClicked = false;
      _ticketForTheDayButtonClicked = true;
      _hideFloatingButton = false;
      _noDataAvailable = false;
      if (_newTicketListEmpty == true) {
        _newTicketListEmpty = !_newTicketListEmpty;
      }
      if (_ongoingTicketListEmpty == true) {
        _ongoingTicketListEmpty = !_ongoingTicketListEmpty;
      }
    });
    if (await checkInternetConnection() == true) {
      _getToken = PreferenceUtils.getString(MyConstants.token);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      ApiService apiService = ApiService(dio.Dio());
      final response =
      await apiService.ticketForTheDay(_getToken!, _getTechnicianCode!);
      if (response.ticketForTheDayEntity!.responseCode == "200") {
        final database = await $FloorAppDatabase
            .databaseBuilder('floor_database.db')
            .build();
        final ticketForTheDayDao = database.ticketForTheDayDao;
        final amcTicketDetailsDao = database.amcTicketDetailsDao;
        final serialNoDataDao = database.serialNoDataDao;
        await amcTicketDetailsDao.deleteAmcTicketDetailsTable();
        await ticketForTheDayDao.deleteTicketForTheDayTable();
        await serialNoDataDao.deleteSerialNoData();
        setState(() {
          PreferenceUtils.setString(MyConstants.token,
              response.ticketForTheDayEntity!.token!);
          for (int i = 0;
          i < response.ticketForTheDayEntity!.datum!.length;
          i++) {
            ticketForTheDayList.add(TicketForTheDayModel(
                ticketId: response.ticketForTheDayEntity!.datum![i]!.ticketId ??
                    MyConstants.na,
                priority: response.ticketForTheDayEntity!.datum![i]!.priority ??
                    MyConstants.na,
                location: response.ticketForTheDayEntity!.datum![i]!.location ??
                    MyConstants.na,
                status: response.ticketForTheDayEntity!.datum![i]!.statusName ??
                    MyConstants.na,
                customerName:
                response.ticketForTheDayEntity!.datum![i]!.customerName ??
                    MyConstants.na,
                customerMobile:
                response.ticketForTheDayEntity!.datum![i]!.customerMobile ??
                    MyConstants.na,
                serialNo: response.ticketForTheDayEntity!.datum![i]!.serialNo ??
                    MyConstants.na,
                modelNo: response.ticketForTheDayEntity!.datum![i]!.modelNo ??
                    MyConstants.na,
                customerAddress:
                response.ticketForTheDayEntity!.datum![i]!.customerAddress ??
                    MyConstants.na,
                callCategory:
                response.ticketForTheDayEntity!.datum![i]!.callCategory ??
                    MyConstants.na,
                endUserName:
                response.ticketForTheDayEntity!.datum![i]!.endUserName ??
                    MyConstants.na,
                endUserMobile:
                response.ticketForTheDayEntity!.datum![i]!.endUserMobile ??
                    MyConstants.na,
                contractType:
                response.ticketForTheDayEntity!.datum![i]!.contractType ??
                    MyConstants.na,
                ticketType:
                response.ticketForTheDayEntity!.datum![i]!.ticketType ?? 0,
                modeOfTravel:
                response.ticketForTheDayEntity!.datum![i]?.modeOfTravel ??
                    MyConstants.na,
                priceType:
                response.ticketForTheDayEntity!.datum![i]?.priceType ??
                    MyConstants.na,
                partNumber: response.ticketForTheDayEntity!.datum![i]
                    ?.partNumber ??
                    MyConstants.na,
                warrantyStatus: response.ticketForTheDayEntity!.datum![i]
                    ?.warrantyStatus ??
                    MyConstants.na,
                contractExpiryDate: response.ticketForTheDayEntity!.datum![i]
                    ?.contractExpiryDate ??
                    MyConstants.na,
                problemDescription: response
                    .ticketForTheDayEntity!.datum![i]!.problemDescription ??
                    MyConstants.na));

            if (response.ticketForTheDayEntity!.datum![i]!.ticketType ==
                MyConstants.amcTicketType) {
              int totalAmount = response
                  .ticketForTheDayEntity!.datum![i]!.amcSerialNo!.length *
                  int.parse(
                      response.ticketForTheDayEntity!.datum![i]?.ammount ??
                          "0");

              if (response
                  .ticketForTheDayEntity!.datum![i]!.amcSerialNo!.isNotEmpty) {
                for (int j = 0;
                j <
                    response.ticketForTheDayEntity!.datum![i]!.amcSerialNo!
                        .length;
                j++) {
                  SerialNoDataTable serialNoDataTable = SerialNoDataTable(
                      i + 1,
                      response.ticketForTheDayEntity!.datum![i]!
                          .amcSerialNo![j]!.serialNo ??
                          "",
                      response.ticketForTheDayEntity!.datum![i]?.ticketId ??
                          "");

                  serialNoDataDao.insertSerialNoData(serialNoDataTable);
                }
              }

              int amount = int.parse(
                  response.ticketForTheDayEntity!.datum![i]?.ammount ?? "0");

              AmcDetailsTicketTable amcDetailsTicketTable =
              AmcDetailsTicketTable(
                i + 1,
                PreferenceUtils.getString(
                    MyConstants.technicianCode),
                response.ticketForTheDayEntity!.datum![i]?.ticketId ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.customerName ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.customerMobile ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.plotNumber ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.street ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.country ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.state ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.city ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.location ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.contractType ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.duration
                    .toString() ??
                    "0",
                response.ticketForTheDayEntity!.datum![i]?.productName ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.productSubName ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.modelNo ??
                    MyConstants.na,
                amount,
                response.ticketForTheDayEntity!.datum![i]!.amcSerialNo!.length
                    .toString(),
                totalAmount.toString(),
              );

              amcTicketDetailsDao.insertAmcTicketDetails(amcDetailsTicketTable);
            }

            TicketForTheDayTable ticketForTheDayTable = TicketForTheDayTable(
                i + 1,
                PreferenceUtils.getString(
                    MyConstants.technicianCode),
                response.ticketForTheDayEntity!.datum![i]?.ticketId ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.priority ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.location ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.customerName ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.customerMobile ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.endUserName ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.endUserMobile ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.serialNo ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.modelNo ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.customerAddress ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.callCategory ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.contractType ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.problemDescription ??
                    "",
                response.ticketForTheDayEntity!.datum![i]?.statusName ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.nextVisit ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.latitude ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.longitude ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.statusCode ?? 0,
                response.ticketForTheDayEntity!.datum![i]?.serviceId ?? 0,
                response.ticketForTheDayEntity!.datum![i]?.resolutionTime ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.workType ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.ticketDate ??
                    MyConstants.na,
                MyConstants.today,
                MyConstants.empty,
                response.ticketForTheDayEntity!.datum![i]?.modeOfTravel ??
                    MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.ticketType ?? 0,
                response.ticketForTheDayEntity!.datum![i]?.partNumber ?? MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.warrantyStatus ?? MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.contractExpiryDate ?? MyConstants.na,
                response.ticketForTheDayEntity!.datum![i]?.priceType ??
                    MyConstants.na);
            ticketForTheDayDao.insertTicketForTheDay(ticketForTheDayTable);
          }
          _ticketForTheDayListEmpty = !_ticketForTheDayListEmpty;
          _isLoading = !_isLoading;
        });
      }
      if (response.ticketForTheDayEntity!.responseCode == "400") {
        setState(() {
          PreferenceUtils.setString(MyConstants.token,
              response.ticketForTheDayEntity!.token!);
          _noDataAvailable = true;
          _isLoading = !_isLoading;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void getTicketForDayDetails() async {
    final database =
    await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final ticketForTheDayDao = database.ticketForTheDayDao;
    _ticketOfTheDayResult = await ticketForTheDayDao.findAllTicketForTheDay();
  }

  getTicketForTheDay(int index) {
    _ticketForTheDayId = _ticketOfTheDayResult[index].ticketId;
    _ticketForTheDayCustomerName = _ticketOfTheDayResult[index].customerName;
    _ticketForTheDayMobile = _ticketOfTheDayResult[index].customerMobile;
    _ticketForTheDayAddress = _ticketOfTheDayResult[index].customerAddress;
    _ticketForTheDaySerial = _ticketOfTheDayResult[index].serialNo;
    _ticketForTheDayCategory = _ticketOfTheDayResult[index].callCategory;
    _ticketForTheDayModelNo = _ticketOfTheDayResult[index].modelNo;
    _tfdContractType = _ticketOfTheDayResult[index].contractType;
    _ticketForTheDayPriority = _ticketOfTheDayResult[index].priority;
    _ticketForTheDayDescription =
        _ticketOfTheDayResult[index].problemDescription;
    destinationLatitude = double.parse(_ticketOfTheDayResult[index].latitude);
    destinationLongitude = double.parse(_ticketOfTheDayResult[index].longitude);
  }

  Future<void> refreshNewTicket() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      _newTicketListEmpty = !_newTicketListEmpty;
      getNewTicketList(context);
    });

    return;
  }

  Future<void> refreshOngoingTicket() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      _ongoingTicketListEmpty = !_ongoingTicketListEmpty;
      getOngoingTicketList(context);
    });

    return;
  }

  Future<void> refreshTicketForTheDay() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      _ticketForTheDayListEmpty = !_ticketForTheDayListEmpty;
      getTicketForTheDayList(context);
    });

    return;
  }

  showImage(int index, BuildContext context) async {
    if (newTicketList[index].ticketImage == MyConstants.na) {
      setToastMessage(context, MyConstants.noImage);
    } else {
      if (newTicketList[index].ticketImage != MyConstants.na &&
          newTicketList[index].ticketImage!.isNotEmpty &&
          newTicketList[index].ticketImage != null) {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ShowImage(
                          capturedImage: null,
                          image: MyConstants.baseurl +
                              newTicketList[index].ticketImage!)));
        });
      } else {
        setToastMessage(context, MyConstants.noImage);
      }
    }
  }

  videoPicker(int index, BuildContext context) async {
    if (newTicketList[index].video == MyConstants.na) {
      setToastMessage(context, MyConstants.noVideo);
    } else {
      if (newTicketList[index].video != MyConstants.na &&
          newTicketList[index].video!.isNotEmpty &&
          newTicketList[index].video != null) {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ShowVideo(
                          video: null,
                          videoPath: MyConstants.baseurl +
                              newTicketList[index].video!)));
        });
      } else {
        setToastMessage(context, MyConstants.noVideo);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    Future.delayed(Duration.zero, () {
      if (widget.selectedIndex == 0) {
        getNewTicketList(context);
      } else if (widget.selectedIndex == 1) {
        getOngoingTicketList(context);
      } else if (widget.selectedIndex == 2) {
        getTicketForTheDayList(context);
      }
    });
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashBoard()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //  pushPage(context);
        return false;
      },
      child: MaterialApp(
        home: SafeArea(
          child: Scaffold(
            key: _key,
            appBar: AppBar(
              title: const Text(
                  "Ticket List", style: TextStyle(color: Colors.white)),
              backgroundColor: Color(int.parse("0xfff" "507a7d")),
              leading: IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashBoard()));
                  },
                  icon: const Icon(Icons.arrow_back_ios_outlined)),
            ),
            body: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                MaterialSegmentedControl(
                  children: _children,
                  selectionIndex: _currentSelection,
                  borderColor: Colors.grey,
                  selectedColor: Color(int.parse("0xfff" "507a7d")),
                  unselectedColor: Colors.white,
                  borderRadius: 32.0,
                  horizontalPadding: const EdgeInsets.only(top: 10.0),
                  disabledChildren: const [
                    3,
                  ],
                  onSegmentChosen: (int index) {
                    setState(() {
                      if (_isLoading == true) {
                        setToastMessage(
                            context, MyConstants.requestAlready);
                      } else {
                        _currentSelection = index;
                        if (index == 0) {
                          getNewTicketList(context);
                        } else if (index == 1) {
                          getOngoingTicketList(context);
                        } else if (index == 2) {
                          getTicketForTheDayList(context);
                        }
                      }
                    });
                  },
                ),
              ]),
              Visibility(
                  visible: _newTicketButtonClicked, child: newTicketScreen()),
              Visibility(
                  visible: _ongoingButtonClicked, child: onGoingTicketScreen()),
              Visibility(
                  visible: _ticketForTheDayButtonClicked,
                  child: ticketForTheDayScreen()),
              Visibility(
                visible: _isLoading,
                child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[400]!,
                    child: ListView.builder(
                        itemCount: 4,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16.0),
                        itemBuilder: (context, index) {
                          return Container(
                              padding: const EdgeInsets.only(top: 5),
                              child: Card(
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Row(
                                          children: [
                                            const Padding(
                                                padding: EdgeInsets.all(
                                                    5.0)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: const <Widget>[
                                                  Text("",
                                                      style:
                                                      TextStyle(fontSize: 15)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: const <Widget>[
                                                  Text("",
                                                      style:
                                                      TextStyle(fontSize: 15)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: const <Widget>[
                                                  Text("",
                                                      style:
                                                      TextStyle(fontSize: 15)),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                      ])));
                        })),
              ),
              Visibility(
                  visible: _noDataAvailable,
                  child: const Center(
                    child: Padding(
                        padding: EdgeInsets.only(top: 250),
                        child: Text(MyConstants.noDataAvailable)),
                  )),
              Visibility(
                  visible: _newTicketListEmpty, child: newTicketListView()),
              Visibility(
                  visible: _ongoingTicketListEmpty,
                  child: ongoingTicketListView()),
              Visibility(
                  visible: _ticketForTheDayListEmpty,
                  child: ticketForTheDayListView())
            ]),
            floatingActionButton: _isLoading == true
                ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[400]!,
                child: FloatingActionButton(
                  backgroundColor: Color(int.parse("0xfff" "2b6c72")),
                  elevation: 0.0,
                  onPressed: () {},
                  child: const Icon(Icons.calendar_view_day_sharp),
                ))
                : _hideFloatingButton == false
                ? FloatingActionButton(
              backgroundColor: Color(int.parse("0xfff" "2b6c72")),
              elevation: 0.0,
              child: const Icon(Icons.calendar_view_day_sharp),
              onPressed: () {
                if (PreferenceUtils.getInteger(
                    MyConstants.punchStatus) ==
                    1) {
                  dashBoardBottomSheet(context, true);
                } else {
                  dashBoardBottomSheet(context, false);
                }
              },
            )
                : null,
          ),
        ),
      ),
    );
  }

  Widget newTicketScreen() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0)),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Ticket ID',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 1,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Priority',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 1,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0)),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Location',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget onGoingTicketScreen() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0)),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Ticket ID',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 1,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Priority',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 1,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Location',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 1,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0)),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Status',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget ticketForTheDayScreen() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0)),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Ticket ID',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 1,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Priority',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 1,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Location',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 1,
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse("0xfff" "507a7d")),
                    Color(int.parse("0xfff" "507a7d"))
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0)),
              ),
              child: Center(
                child: GestureDetector(
                  child: const Text('Status',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget newTicketListView() {
    getUserList();
    return Expanded(
      child: RefreshIndicator(
        onRefresh: refreshNewTicket,
        child: ListView.builder(
            itemCount: newTicketList.length,
            padding: const EdgeInsets.only(left: 16, right: 16),
            itemBuilder: (context, index) {
              return Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: GestureDetector(
                    onTap: () {
                      getNewTicketListDetails(index);
                      setState(() => _hideFloatingButton = true);
                      _controller = _key.currentState!.showBottomSheet(
                              (_) =>
                              SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        flex: 0,
                                        child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Color(int.parse(
                                                    "0xfff" "5C7E7F")),
                                                borderRadius: const BorderRadius
                                                    .only(
                                                    bottomLeft:
                                                    Radius.circular(10.0),
                                                    bottomRight:
                                                    Radius.circular(10.0))),
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.only(left: 15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: <Widget>[
                                                    const Text(
                                                      "New Ticket",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    IconButton(
                                                        onPressed: () {
                                                          _controller.close();
                                                          setState(() =>
                                                          _hideFloatingButton =
                                                          false);
                                                        },
                                                        icon: const Icon(
                                                          Icons.clear,
                                                          color: Colors.white,
                                                        ))
                                                  ],
                                                ))),
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: Container(
                                            padding: const EdgeInsets.only(
                                                top: 5),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Name",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    capitalize(
                                                                        _newTicketCustomerName!),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Mobile Number",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    _newTicketMobile!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Address:",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    newTicketList[index].customerAddress!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Model Number",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    newTicketList[index].modelNo!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Serial Number",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    _newTicketSerial!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Warranty Status",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    newTicketList[
                                                                    index]
                                                                        .warrantyStatus!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Contract Type",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    _newResult[
                                                                    index]
                                                                        .contractType !=
                                                                        null
                                                                        ? capitalize(
                                                                        _newResult[
                                                                        index]
                                                                            .contractType)
                                                                        : MyConstants
                                                                        .na,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Contract Expiry Date",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    newTicketList[index].contractExpiryDate!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Price Type",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    newTicketList[index].priceType!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Category",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    newTicketList[index].callCategory!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Priority",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    newTicketList[index].priority!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: const <Widget>[
                                                              Text(
                                                                  "Description",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      15,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                            ],
                                                          ),
                                                        ),
                                                        const Expanded(
                                                            flex: 0,
                                                            child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child: Text(
                                                                    _newTicketDescription!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                        15)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 20.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                child: const Text(
                                                                    "View Image File",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        15,
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                                onTap: () {
                                                                  showImage(
                                                                      index,
                                                                      context);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                child: const Text(
                                                                    "View Video File",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        15,
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                                onTap: () {
                                                                  videoPicker(
                                                                      index,
                                                                      context);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(5.0)),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                            children: <Widget>[
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  acceptTechnicianTicket(
                                                                      context,
                                                                      _newTicketId!);
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                            30.0)), backgroundColor: Color(
                                                                        int
                                                                            .parse(
                                                                            "0xfff" "3eccbb")),
                                                                    minimumSize:
                                                                    const Size(
                                                                        140,
                                                                        35)),
                                                                child: const Text(
                                                                    'Accept',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        15,
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  _controller
                                                                      .close();
                                                                  _controller =
                                                                      _key
                                                                          .currentState!
                                                                          .showBottomSheet((
                                                                          context) =>
                                                                          showRejectBottomSheet(
                                                                              _newTicketId!));
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                            30.0)), backgroundColor: Color(
                                                                        int
                                                                            .parse(
                                                                            "0xfff" "E63946")),
                                                                    minimumSize:
                                                                    const Size(
                                                                        140,
                                                                        35)),
                                                                child: const Text(
                                                                    'Reject',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        15,
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 20.0,
                                                  ),
                                                ])),
                                      )
                                    ]),
                              )
                      );
                    },
                    child: Card(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 7.5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                              newTicketList[index].ticketId ==
                                                  null
                                                  ? "NA"
                                                  : newTicketList[index]
                                                  .ticketId!,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                              newTicketList[index].priority ==
                                                  null
                                                  ? "NA"
                                                  : newTicketList[index]
                                                  .priority!,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                              newTicketList[index].location ==
                                                  null
                                                  ? "NA"
                                                  : newTicketList[index]
                                                  .location!,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                            ])),
                  ));
            }),
      ),
    );
  }

  Widget ongoingTicketListView() {
    getOngoingTicketDetails();

    return Expanded(
      child: RefreshIndicator(
        onRefresh: refreshOngoingTicket,
        child: ListView.builder(
            itemCount: ongoingTicketList.length,
            padding: const EdgeInsets.only(left: 10, right: 10),
            itemBuilder: (context, index) {
              return Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: GestureDetector(
                    onTap: () {
                      if (ongoingTicketList[index].statusName ==
                          MyConstants.otpVerified) {
                        ArtSweetAlert.show(
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                                title: MyConstants.appTittle,
                                text: MyConstants.optAlert,
                                showCancelBtn: true,
                                confirmButtonText: MyConstants.yesButton,
                                cancelButtonText: MyConstants.noButton,
                                onConfirm: () async {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  final database = await $FloorAppDatabase
                                      .databaseBuilder('floor_database.db')
                                      .build();
                                  final spareRequestDataDao = database
                                      .spareRequestDataDao;
                                  spareRequestDataDao
                                      .deleteSpareRequestDataTable();

                                  PreferenceUtils.setString(
                                      MyConstants.ticketIdStore,
                                      ongoingTicketList[index].ticketId!);


                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FieldReturnMaterial(
                                                ticketUpdate: MyConstants
                                                    .ongoingTicket,
                                              )));
                                },
                                onCancel: () async {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  if (await checkInternetConnection() == true) {
                                    showAlertDialog(context);
                                    Map<String, dynamic> pendingFrmData = {
                                      'technician_code': PreferenceUtils
                                          .getString(
                                          MyConstants.technicianCode),
                                      'ticket_id': ongoingTicketList[index]
                                          .ticketId!,
                                      'frm_status': 2,
                                      'frm': 0,
                                    };

                                    ApiService apiService = ApiService(
                                        dio.Dio());
                                    final response = await apiService
                                        .pendingFrm(
                                        PreferenceUtils.getString(
                                            MyConstants.token),
                                        pendingFrmData);
                                    if (response.addTransferEntity!
                                        .responseCode ==
                                        MyConstants.response200) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      setState(() {
                                        PreferenceUtils.setString(
                                            MyConstants.token,
                                            response.addTransferEntity!.token!);
                                        setToastMessage(
                                            context, response.addTransferEntity!
                                            .message!);
                                        Future.delayed(
                                            const Duration(seconds: 2), () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DashBoard()));
                                        });
                                      });
                                    } else if (response.addTransferEntity!
                                        .responseCode ==
                                        MyConstants.response400) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      setState(() {
                                        PreferenceUtils.setString(
                                            MyConstants.token,
                                            response.addTransferEntity!.token!);
                                      });
                                    } else if (response.addTransferEntity!
                                        .responseCode ==
                                        MyConstants.response500) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      setState(() {
                                        setToastMessage(
                                            context, response.addTransferEntity!
                                            .message!);
                                      });
                                    }
                                  } else {
                                    setToastMessage(
                                        context,
                                        MyConstants.internetConnection);
                                  }
                                },
                                cancelButtonColor: Color(int.parse(
                                    "0xfff" "C5C5C5")),
                                confirmButtonColor: Color(int.parse(
                                    "0xfff" "507a7d"))));
                      }
                      else {
                        getOngoingDetails(index);
                        setState(() => _hideFloatingButton = true);
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Color(
                                                  int.parse(
                                                      "0xfff" "5C7E7F")),
                                              borderRadius: const BorderRadius
                                                  .only(
                                                  bottomLeft:
                                                  Radius.circular(10.0),
                                                  bottomRight:
                                                  Radius.circular(10.0))),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: <Widget>[
                                                  const Text(
                                                    "Ongoing Ticket",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  IconButton(
                                                      onPressed: () {
                                                        setState(() =>
                                                        _hideFloatingButton =
                                                        false);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      icon: const Icon(
                                                        Icons.clear,
                                                        color: Colors.white,
                                                      ))
                                                ],
                                              ))),
                                      Container(
                                          padding: const EdgeInsets.only(
                                              top: 5),
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Name",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                capitalize(
                                                                    _ongoingTicketCustomerName!),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Mobile Number",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                _ongoingTicketMobile!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Address",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                _ongoingTicketAddress!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Model Number",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                _ongoingTicketModelNo!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Serial Number",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                _ongoingTicketSerial!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Warranty Status",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                ongoingTicketList[index].warrantyStatus!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Warranty Expiry Date",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                ongoingTicketList[index].warrantyExpiryDate!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Contract Type",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                capitalize(
                                                                    _ongoingResult[
                                                                    index]
                                                                        .contractType),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Contract Expiry Date",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                ongoingTicketList[index].contractExpiryDate!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Price Type",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                ongoingTicketList[
                                                                index]
                                                                    .priceType!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                // SizedBox(
                                                //   height: 10.0,
                                                // ),
                                                // Row(
                                                //   children: [
                                                //     new Padding(
                                                //         padding:
                                                //         new EdgeInsets.all(
                                                //             5.0)),
                                                //     new Expanded(
                                                //       flex: 0,
                                                //       child: new Column(
                                                //         crossAxisAlignment:
                                                //         CrossAxisAlignment
                                                //             .start,
                                                //         children: <Widget>[
                                                //           Text(
                                                //               "Expiry Date             :",
                                                //               style: TextStyle(
                                                //                   fontSize: 15,
                                                //                   fontWeight:
                                                //                   FontWeight
                                                //                       .w600)),
                                                //         ],
                                                //       ),
                                                //     ),
                                                //     new Expanded(
                                                //       child: new Column(
                                                //         crossAxisAlignment:
                                                //         CrossAxisAlignment
                                                //             .start,
                                                //         children: <Widget>[
                                                //           Padding(
                                                //             padding:
                                                //             EdgeInsets.only(
                                                //                 left: 10.0),
                                                //             child: Text(
                                                //                 _ongoingResult[
                                                //                 index]
                                                //                     .endUserMobileNumber,
                                                //                 style: TextStyle(
                                                //                     fontSize:
                                                //                     15)),
                                                //           ),
                                                //         ],
                                                //       ),
                                                //     )
                                                //   ],
                                                // ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets
                                                            .all(5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Category",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                  15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                left:
                                                                10.0),
                                                            child: Text(
                                                                ongoingTicketList[index]
                                                                    .callCategory!
                                                                    .isEmpty
                                                                    ? MyConstants
                                                                    .na
                                                                    : ongoingTicketList[index]
                                                                    .callCategory!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Priority",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                _ongoingTicketPriority!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  children: [
                                                    const Padding(
                                                        padding:
                                                        EdgeInsets.all(
                                                            5.0)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: const <Widget>[
                                                          Text(
                                                              "Description",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                        flex: 0,
                                                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0),
                                                            child: Text(
                                                                _ongoingTicketDescription!,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                    15)),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 15.0,
                                                ),
                                                Container(
                                                  child: ongoingTicketList[index]
                                                      .statusName ==
                                                      MyConstants
                                                          .spareDelivered ||
                                                      ongoingTicketList[index]
                                                          .statusName ==
                                                          MyConstants
                                                              .workInProgress
                                                      ? Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets
                                                              .all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <
                                                              Widget>[
                                                            Text(
                                                                "Visit Date",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                    15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <
                                                              Widget>[
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  left:
                                                                  10.0),
                                                              child: Text(
                                                                  _nextVisitDate!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 0,
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                              .only(
                                                              right:
                                                              15.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                            children: <
                                                                Widget>[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                    left:
                                                                    10.0),
                                                                child:
                                                                IconButton(
                                                                  onPressed:
                                                                      () =>
                                                                      _selectDate(
                                                                          context),
                                                                  icon:
                                                                  const Icon(
                                                                    Icons
                                                                        .calendar_today_sharp,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                      : null,
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Center(
                                                  child: ongoingTicketList[index]
                                                      .statusName ==
                                                      MyConstants
                                                          .spareDelivered ||
                                                      ongoingTicketList[index]
                                                          .statusName ==
                                                          MyConstants
                                                              .workInProgress
                                                      ? Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 10.0,
                                                        right: 10.0),
                                                    child: SizedBox(
                                                      width: MediaQuery
                                                          .of(
                                                          context)
                                                          .size
                                                          .width,
                                                      child: ElevatedButton(
                                                        onPressed: () =>
                                                            updateTicket(
                                                                context,
                                                                ongoingTicketList[
                                                                index]
                                                                    .ticketId,
                                                                ongoingTicketList[
                                                                index]
                                                                    .statusName),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10.0)), backgroundColor: Color(
                                                                int.parse(
                                                                    "0xfff" "5C7E7F"))),
                                                        child: const Text(
                                                            MyConstants
                                                                .updateButton,
                                                            style: TextStyle(
                                                                fontSize:
                                                                15,
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                  )
                                                      : null,
                                                ),
                                                Center(
                                                  child: ongoingTicketList[index]
                                                      .statusName ==
                                                      MyConstants.accepted ||
                                                      ongoingTicketList[index]
                                                          .statusName ==
                                                          MyConstants.reached ||
                                                      ongoingTicketList[index]
                                                          .statusName ==
                                                          MyConstants
                                                              .ticketStarted ||
                                                      ongoingTicketList[index]
                                                          .statusName ==
                                                          MyConstants
                                                              .otpVerified ||
                                                      ongoingTicketList[index]
                                                          .statusName ==
                                                          MyConstants
                                                              .travelStarted ||
                                                      ongoingTicketList[index]
                                                          .statusName ==
                                                          MyConstants
                                                              .priceApproved ||
                                                      ongoingTicketList[index]
                                                          .statusName ==
                                                          MyConstants
                                                              .priceRejected
                                                      ? Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 10.0,
                                                        right: 10.0),
                                                    child: SizedBox(
                                                      width: MediaQuery
                                                          .of(
                                                          context)
                                                          .size
                                                          .width,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          if (ongoingTicketList[index]
                                                              .statusName ==
                                                              MyConstants
                                                                  .accepted ||
                                                              ongoingTicketList[index]
                                                                  .statusName ==
                                                                  MyConstants
                                                                      .travelStarted ||
                                                              ongoingTicketList[index]
                                                                  .statusName ==
                                                                  MyConstants
                                                                      .reached) {
                                                            Navigator
                                                                .pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        MapView(
                                                                            double
                                                                                .parse(
                                                                                ongoingTicketList[index]
                                                                                    .latitude!),
                                                                            double
                                                                                .parse(
                                                                                ongoingTicketList[index]
                                                                                    .longitude!),
                                                                            ongoingTicketList[index]
                                                                                .ticketId,
                                                                            ongoingTicketList[index]
                                                                                .priority,
                                                                            ongoingTicketList[index]
                                                                                .location,
                                                                            ongoingTicketList[index]
                                                                                .statusName,
                                                                            ongoingTicketList[index]
                                                                                .ticketType,
                                                                            MyConstants
                                                                                .startTicketType)));
                                                          } else
                                                          if (ongoingTicketList[index]
                                                              .statusName ==
                                                              MyConstants
                                                                  .ticketStarted) {
                                                            Navigator
                                                                .pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        StartTicket(
                                                                            status: MyConstants
                                                                                .ongoingTicket,
                                                                            ticketId:
                                                                            ongoingTicketList[index]
                                                                                .ticketId)));
                                                          } else {
                                                            PreferenceUtils
                                                                .setString(
                                                                MyConstants
                                                                    .ticketIdStore,
                                                                ongoingTicketList[
                                                                index]
                                                                    .ticketId!);
                                                            Navigator
                                                                .pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        SubmitComplete(
                                                                            status: MyConstants
                                                                                .ongoingTicket,
                                                                            ticketId:
                                                                            ongoingTicketList[index]
                                                                                .ticketId)));
                                                          }
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    10.0)), backgroundColor: Color(
                                                                int.parse(
                                                                    "0xfff" "5C7E7F"))),
                                                        child: const Text(
                                                            MyConstants
                                                                .continueButton,
                                                            style: TextStyle(
                                                                fontSize:
                                                                15,
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                                  )
                                                      : null,
                                                ),
                                                const SizedBox(
                                                  height: 15.0,
                                                )
                                              ]))
                                    ]),
                              );
                            });
                      }
                    },
                    child: Card(
                        child:
                        Column(mainAxisSize: MainAxisSize.min, children: <
                            Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 7.5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: <Widget>[
                                      Text(ongoingTicketList[index].ticketId!,
                                          style: const TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center,
                                      children: <Widget>[
                                        Text(
                                            ongoingTicketList[index].priority ??
                                                "",
                                            style: const TextStyle(
                                                fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: <Widget>[
                                      Text(ongoingTicketList[index].location!,
                                          style: const TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: <Widget>[
                                      Text(ongoingTicketList[index].statusName!,
                                          style: const TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                        ])),
                  ));
            }),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)));
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          _isDateUpdated = true;
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          inputDate = formatter.format(selectedDate);
          _nextVisitDate = DateFormat('dd-MM-yyyy')
              .format(DateFormat('yyyy-MM-dd').parse(inputDate.toString()));
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void updateTicket(BuildContext context, String? ticketId,
      String? statusName) async {
    if (await checkInternetConnection() == true) {
      if (!_isDateUpdated) {
        setToastMessage(context, MyConstants.selectDateError);
      } else {
        showAlertDialog(context);

        Map<String, dynamic> ticketScheduleData = {
          'technician_code':
          PreferenceUtils.getString(MyConstants.technicianCode),
          'ticket_id': ticketId,
          'next_visit': DateFormat('yyyy-MM-dd')
              .format(DateFormat('dd-MM-yyyy').parse(_nextVisitDate!)),
          'ticket_status': statusName
        };

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.ticketSchedule(
            PreferenceUtils.getString(MyConstants.token),
            ticketScheduleData);

        if (response.ticketScheduleEntity != null) {
          if (response.ticketScheduleEntity!.responseCode ==
              MyConstants.response200) {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              PreferenceUtils.setString(MyConstants.token,
                  response.ticketScheduleEntity!.token!);
              setToastMessage(context, response.ticketScheduleEntity!.data!);

              if (_nextVisitDate ==
                  DateFormat('dd-MM-yyyy').format(DateTime.now())) {
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TicketList(2)));
                });
              } else {
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TicketList(1)));
                });
              }
            });
          } else if (response.ticketScheduleEntity!.responseCode ==
              MyConstants.response400) {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              PreferenceUtils.setString(MyConstants.token,
                  response.ticketScheduleEntity!.token!);
              setToastMessage(context, response.ticketScheduleEntity!.data!);
            });
          } else if (response.ticketScheduleEntity!.responseCode ==
              MyConstants.response500) {
            Navigator.of(context, rootNavigator: true).pop();
            setToastMessage(context, response.ticketScheduleEntity!.data!);
          }
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, MyConstants.internalServerError);
        }
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Widget ticketForTheDayListView() {
    getTicketForDayDetails();
    return Expanded(
      child: RefreshIndicator(
        onRefresh: refreshTicketForTheDay,
        child: ListView.builder(
            itemCount: ticketForTheDayList.length,
            padding: const EdgeInsets.only(left: 10, right: 10),
            itemBuilder: (context, index) {
              return Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: GestureDetector(
                    onTap: () async {
                      if (ticketForTheDayList[index].status ==
                          MyConstants.reached ||
                          ticketForTheDayList[index].status ==
                              MyConstants.ticketStarted) {
                        if (ticketForTheDayList[index].ticketType ==
                            MyConstants.amcTicketType) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AMCTicketDetails(
                                          ticketId: ticketForTheDayList[index]
                                              .ticketId)));
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      StartTicket(
                                          status: ticketForTheDayList[index]
                                              .status,
                                          ticketId: ticketForTheDayList[index]
                                              .ticketId)));
                        }
                      } else if (ticketForTheDayList[index].status ==
                          MyConstants.otpVerified) {
                        ArtSweetAlert.show(
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                                title: MyConstants.appTittle,
                                text: MyConstants.optAlert,
                                showCancelBtn: true,
                                confirmButtonText:
                                MyConstants.yesButton,
                                cancelButtonText:
                                MyConstants.noButton,
                                onConfirm: () async {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  final database = await $FloorAppDatabase
                                      .databaseBuilder('floor_database.db')
                                      .build();
                                  final spareRequestDataDao =
                                      database.spareRequestDataDao;
                                  spareRequestDataDao
                                      .deleteSpareRequestDataTable();

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FieldReturnMaterial(
                                                ticketUpdate:
                                                MyConstants
                                                    .ticketForTheDay,
                                              )));
                                },
                                onCancel: () async {
                                  if (await checkInternetConnection() == true) {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();

                                    showAlertDialog(context);
                                    Map<String, dynamic> pendingFrmData = {
                                      'technician_code':
                                      PreferenceUtils.getString(
                                          MyConstants
                                              .technicianCode),
                                      'ticket_id':
                                      ticketForTheDayList[index].ticketId,
                                      'frm_status': 2,
                                      'frm': 0,
                                    };

                                    ApiService apiService =
                                    ApiService(dio.Dio());
                                    final response =
                                    await apiService.pendingFrm(
                                        PreferenceUtils.getString(
                                            MyConstants.token),
                                        pendingFrmData);
                                    if (response
                                        .addTransferEntity!.responseCode ==
                                        MyConstants.response200) {
                                      setState(() {
                                        Navigator.of(context,
                                            rootNavigator: true)
                                            .pop();
                                        PreferenceUtils.setString(
                                            MyConstants.token,
                                            response.addTransferEntity!.token!);
                                        setToastMessage(
                                            context,
                                            response
                                                .addTransferEntity!.message!);
                                        Future.delayed(
                                            const Duration(seconds: 2),
                                                () {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DashBoard()));
                                            });
                                      });
                                    } else if (response
                                        .addTransferEntity!.responseCode ==
                                        MyConstants.response400) {
                                      setState(() {
                                        Navigator.of(context,
                                            rootNavigator: true)
                                            .pop();
                                        PreferenceUtils.setString(
                                            MyConstants.token,
                                            response.addTransferEntity!.token!);
                                      });
                                    } else if (response
                                        .addTransferEntity!.responseCode ==
                                        MyConstants.response500) {
                                      setState(() {
                                        Navigator.of(context,
                                            rootNavigator: true)
                                            .pop();
                                        setToastMessage(
                                            context,
                                            response
                                                .addTransferEntity!.message!);
                                      });
                                    }
                                  } else {
                                    setToastMessage(
                                        context,
                                        MyConstants
                                            .internetConnection);
                                  }
                                },
                                cancelButtonColor:
                                Color(int.parse("0xfff" "C5C5C5")),
                                confirmButtonColor:
                                Color(int.parse("0xfff" "507a7d"))));
                      } else {
                        getTicketForTheDay(index);
                        setState(() => _hideFloatingButton = true);
                        _controller =
                            _key.currentState!.showBottomSheet((context) =>
                                SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Color(int.parse(
                                                    "0xfff" "5C7E7F")),
                                                borderRadius: const BorderRadius
                                                    .only(
                                                    bottomLeft:
                                                    Radius.circular(10.0),
                                                    bottomRight:
                                                    Radius.circular(10.0))),
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.only(left: 15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: <Widget>[
                                                    const Text(
                                                      "Ticket Details",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    IconButton(
                                                        onPressed: () {
                                                          _controller.close();
                                                          setState(() =>
                                                          _hideFloatingButton =
                                                          false);
                                                        },
                                                        icon: const Icon(
                                                          Icons.clear,
                                                          color: Colors.white,
                                                        ))
                                                  ],
                                                ))),
                                        Container(
                                            padding: const EdgeInsets.only(
                                                top: 5),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Name",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  capitalize(
                                                                      _ticketForTheDayCustomerName!),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Mobile",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  _ticketForTheDayMobile!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Address",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  _ticketForTheDayAddress!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Model Number",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  _ticketForTheDayModelNo!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Serial Number",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  _ticketForTheDaySerial!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Warranty Status",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  ticketForTheDayList[index].warrantyStatus!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Contract Type",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  _tfdContractType!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Contract Expiry Date",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  ticketForTheDayList[index].contractExpiryDate!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Price Type",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  ticketForTheDayList[index]
                                                                      .priceType!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Category",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  ticketForTheDayList[index]
                                                                      .callCategory!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Priority",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  _ticketForTheDayPriority!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Padding(
                                                          padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: const <Widget>[
                                                            Text(
                                                                "Description",
                                                                style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                          ],
                                                        ),
                                                      ),
                                                      const Expanded(
                                                          flex: 0,
                                                          child: Text(":", style: TextStyle(fontWeight: FontWeight.bold))
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0),
                                                              child: Text(
                                                                  _ticketForTheDayDescription!,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      15)),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 20.0,
                                                  ),
                                                  Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: 10.0,
                                                          right: 10.0,
                                                          bottom: 10.0),
                                                      child: SizedBox(
                                                        width:
                                                        MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator
                                                                .pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        MapView(
                                                                            destinationLatitude,
                                                                            destinationLongitude,
                                                                            _ticketForTheDayId,
                                                                            _ticketForTheDayPriority,
                                                                            ticketForTheDayList[
                                                                            index]
                                                                                .location,
                                                                            ticketForTheDayList[
                                                                            index]
                                                                                .status,
                                                                            ticketForTheDayList[
                                                                            index]
                                                                                .ticketType,
                                                                            MyConstants
                                                                                .startTicketType)));
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      10.0)), backgroundColor: Color(int
                                                                  .parse(
                                                                  "0xfff" "5C7E7F"))),
                                                          child: const Text(
                                                              MyConstants
                                                                  .travelPlan,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ]))
                                      ]),
                                )
                            );
                      }
                    },
                    child: Card(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 7.5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(ticketForTheDayList[index]
                                              .ticketId!,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                                ticketForTheDayList[index]
                                                    .priority ??
                                                    "",
                                                style: const TextStyle(
                                                    fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(ticketForTheDayList[index]
                                              .location!,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(ticketForTheDayList[index]
                                              .status!,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                            ])),
                  ));
            }),
      ),
    );
  }

  void acceptTechnicianTicket(BuildContext context, String ticketId) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);
      _getToken = PreferenceUtils.getString(MyConstants.token);
      Map<String, dynamic> acceptTechnicianData = {'ticket_id': ticketId};
      ApiService apiService = ApiService(dio.Dio());
      final response =
      await apiService.acceptTicket(_getToken, acceptTechnicianData);
      if (response.changePasswordEntity!.responseCode == '200') {
        setState(() {
          PreferenceUtils.setString(MyConstants.token,
              response.changePasswordEntity!.token!);

          _controller.close();
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, response.changePasswordEntity!.message!);
          Future.delayed(const Duration(seconds: 1), () {
            getNewTicketList(context);
          });
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Widget showRejectBottomSheet(String ticketId) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter myState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color(int.parse("0xfff" "5C7E7F")),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0))),
                  child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            "Reject Ticket",
                            style: TextStyle(color: Colors.white),
                          ),
                          IconButton(
                              onPressed: () {
                                _controller.close();
                                setState(() => _hideFloatingButton = false);
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ))
                        ],
                      ))),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    title: Row(children: [
                      Radio(
                        value: 1,
                        groupValue: val,
                        onChanged: (value) {
                          myState(() {
                            val = value;
                            _rejectFormFieldVisible = false;
                            _rejectReasonString = "Busy with Assigned Call";
                          });
                        },
                        activeColor: Color(int.parse("0xfff" "3eccbb")),
                      ),
                      const Text("Busy with Assigned Call")
                    ]),
                  ),
                  ListTile(
                      title: Row(
                        children: [
                          Radio(
                            value: 2,
                            groupValue: val,
                            onChanged: (value) {
                              myState(() {
                                val = value;
                                _rejectFormFieldVisible = false;
                                _rejectReasonString = "End of Business day";
                              });
                            },
                            activeColor: Color(int.parse("0xfff" "3eccbb")),
                          ),
                          const Text("End of Business day")
                        ],
                      )),
                  ListTile(
                      title: Row(
                        children: [
                          Radio(
                            value: 3,
                            groupValue: val,
                            onChanged: (value) {
                              myState(() {
                                val = value;
                                _rejectFormFieldVisible = false;
                                _rejectReasonString = "Long Distance";
                              });
                            },
                            activeColor: Color(int.parse("0xfff" "3eccbb")),
                          ),
                          const Text("Long Distance")
                        ],
                      )),
                  ListTile(
                    title: Row(children: [
                      Radio(
                        value: 4,
                        groupValue: val,
                        onChanged: (value) {
                          myState(() {
                            val = value;
                            _rejectReason.value = TextEditingValue.empty;
                            _rejectFormFieldVisible = true;
                            _rejectReasonString = "Others";
                          });
                        },
                        activeColor: Color(int.parse("0xfff" "3eccbb")),
                      ),
                      const Text("Others")
                    ]),
                  )
                ],
              ),
              Visibility(
                visible: _rejectFormFieldVisible,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0, right: 20.0, left: 20.0),
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _rejectReason,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          labelText: 'Enter Reason',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter reason";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 10.0, right: 10.0),
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: ElevatedButton(
                        onPressed: () {
                          rejectTechnicianTicket(context, ticketId);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0)), backgroundColor: Color(int.parse("0xfff" "E63946"))),
                        child: const Text('Reject',
                            style: TextStyle(fontSize: 15, color: Colors
                                .white)),
                      ),
                    ),
                  )),
              const SizedBox(
                height: 20.0,
              )
            ],
          );
        }
    );
  }

  void rejectTechnicianTicket(BuildContext context, String ticketId) async {
    if (await checkInternetConnection() == true) {
      final form = formKey.currentState;
      if (_rejectReasonString == "Busy with Assigned Call" ||
          _rejectReasonString == "End of Business day" ||
          _rejectReasonString == "Long Distance") {
        showAlertDialog(context);
        _getToken = PreferenceUtils.getString(MyConstants.token);
        Map<String, dynamic> acceptTechnicianData = {
          'ticket_id': ticketId,
          'ticket_reject_reason': _rejectReasonString
        };
        ApiService apiService = ApiService(dio.Dio());
        final response =
        await apiService.rejectTicket(_getToken, acceptTechnicianData);
        if (response.changePasswordEntity!.responseCode == '200') {
          setState(() {
            PreferenceUtils.setString(MyConstants.token,
                response.changePasswordEntity!.token!);

            _controller.close();
            Navigator.of(context, rootNavigator: true).pop();
            setToastMessage(context, response.changePasswordEntity!.message!);
            Future.delayed(const Duration(seconds: 1), () {
              getNewTicketList(context);
            });
          });
        }
      }
      else if (_rejectReasonString == "Others") {
        if (form!.validate()) {
          form.save();
          showAlertDialog(context);
          _getToken = PreferenceUtils.getString(MyConstants.token);
          Map<String, dynamic> acceptTechnicianData = {
            'ticket_id': ticketId,
            'ticket_reject_reason': _rejectReason.text.trim()
          };
          ApiService apiService = ApiService(dio.Dio());
          final response =
          await apiService.rejectTicket(_getToken, acceptTechnicianData);
          if (response.changePasswordEntity!.responseCode == '200') {
            setState(() {
              PreferenceUtils.setString(MyConstants.token,
                  response.changePasswordEntity!.token!);

              _controller.close();
              Navigator.of(context, rootNavigator: true).pop();
              setToastMessage(context, response.changePasswordEntity!.message!);
              Future.delayed(const Duration(seconds: 1), () {
                getNewTicketList(context);
              });
            });
          }
        } else {
          setToastMessage(context, MyConstants.emptyForm);
        }
      } else {
        setToastMessage(context, MyConstants.selectReason);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }
}
