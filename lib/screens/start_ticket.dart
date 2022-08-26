import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:fieldpro_genworks_healthcare/screens/ticket_list.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:permission_handler/permission_handler.dart';

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/db/ticket_for_the_day.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'file_directory.dart';
import 'installation_report_complete.dart';

class StartTicket extends StatefulWidget {
  final String? ticketId;
  String? status;

  StartTicket({Key? key, required this.ticketId, required this.status})
      : super(key: key);

  @override
  _StartTicketState createState() => _StartTicketState();
}

class _StartTicketState extends State<StartTicket> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _modelNoController = TextEditingController();
  final TextEditingController _serialNoController = TextEditingController();
  final TextEditingController _warrantyController = TextEditingController();
  final TextEditingController _contractExpiryDateController = TextEditingController();
  final TextEditingController _priceTypeController = TextEditingController();
  final TextEditingController _ticketDateController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _partNumberController = TextEditingController();
  final TextEditingController _contractCategoryController =
      TextEditingController();
  final TextEditingController _workTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedMode;
  bool? _showStartTicket = false, _showUpdateTicket = false;

  Future<void> getDetailsFromDb() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final ticketForTheDayDao = database.ticketForTheDayDao;
    List<TicketForTheDayTable> result = await ticketForTheDayDao
        .findTicketForTheDayByTicketId(widget.ticketId!);

    _nameController.text = result[0].customerName;
    _mobileController.text = result[0].customerMobile;
    _addressController.text = result[0].customerAddress;
    _modelNoController.text = result[0].modelNo;
    _serialNoController.text = result[0].serialNo;
    _warrantyController.text = result[0].warrantyStatus;
    _contractExpiryDateController.text = result[0].contractExpiryDate;
    _priceTypeController.text = result[0].priceType;
    _ticketDateController.text = result[0].ticketDate;
    _priorityController.text = result[0].priority;
    _categoryController.text = result[0].callCategory;
    _contractCategoryController.text = result[0].contractType;
    _partNumberController.text = result[0].partNumber;
    _workTypeController.text = result[0].workType;
    _descriptionController.text = result[0].problemDescription;
    setState(() {
      if (widget.status == MyConstants.reached) {
        _showStartTicket = true;
        _showUpdateTicket = false;
      } else if (widget.status == MyConstants.ticketStarted ||
          widget.status == MyConstants.workInProgressAlert ||
          widget.status == MyConstants.escalate ||
          widget.status == MyConstants.ongoingTicket) {
        _showStartTicket = false;
        _showUpdateTicket = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    getDetailsFromDb();
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const TicketList(2)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // pushPage(context);
        return false;
      },
      child: MaterialApp(
        home: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TicketList(2))),
              ),
              title: _showStartTicket == true
                  ? const Text(MyConstants.startTicketButton)
                  : const Text(MyConstants.updateTicketButton),
              backgroundColor: Color(int.parse("0xfff" "507a7d")),
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Expanded(
                        child: SizedBox(
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(int.parse("0xfff" "507a7d")),
                                  Color(int.parse("0xfff" "507a7d"))
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8.0),
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0)),
                            ),
                            child: Center(
                              child: GestureDetector(
                                child: Text(
                                    "${MyConstants.ticketId}  :  ${widget.ticketId!}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      enabled: false,
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.cusName,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _mobileController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.cusMobile,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _addressController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.address,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _modelNoController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.modelNumber,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _serialNoController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.serialNumber,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _warrantyController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.warrantyHint,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _contractCategoryController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.contractHint,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _contractExpiryDateController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.contractExpiryDateHint,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _priceTypeController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.priceType,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _ticketDateController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.ticketRaisedDate,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _priorityController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.priority,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _categoryController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.category,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _workTypeController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.workType,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.description,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15.0),
                    Visibility(
                      visible: _showStartTicket!,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.status == MyConstants.reached) {
                              startTicketPostApi();
                            } else {
                              _updateTicketAlert(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              backgroundColor:
                                  Color(int.parse("0xfff" "5C7E7F"))),
                          child: const Text(MyConstants.startTicketButton,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white)),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _showUpdateTicket!,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.status == MyConstants.reached) {
                              startTicketPostApi();
                            } else {
                              _updateTicketAlert(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              backgroundColor:
                                  Color(int.parse("0xfff" "5C7E7F"))),
                          child: const Text(MyConstants.updateTicketButton,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> startTicketPostApi() async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final ticketForTheDayDao = database.ticketForTheDayDao;

      Map<String, dynamic> startTravelData = {
        'ticket_id': widget.ticketId,
        'technician_code':
            PreferenceUtils.getString(MyConstants.technicianCode),
        'start_date': _ticketDateController.text
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.startTicket(
          PreferenceUtils.getString(MyConstants.token), startTravelData);
      if (response.addTransferEntity!.responseCode == MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, response.addTransferEntity!.message!);
          ticketForTheDayDao.updateTicketData(
              MyConstants.ticketStarted, widget.ticketId!);
          _showStartTicket = false;
          _showUpdateTicket = true;
          widget.status = MyConstants.ticketStarted;
        });
      } else if (response.addTransferEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          _showStartTicket = true;
          _showUpdateTicket = false;
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, response.addTransferEntity!.message!);
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  _updateTicketAlert(BuildContext context) async {
    if (Platform.isAndroid) {
      final FileDirectory fileDirectory =
          FileDirectory(context, MyConstants.imageFolder);
      Directory? getDirectory;
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      await _requestPermission(Permission.storage);
      if (androidInfo.version.sdkInt >= int.parse(MyConstants.osVersion)) {
        showAlert(context);
      } else {
        await _requestPermission(Permission.storage);
        fileDirectory.createFolder().then((value) async {
          getDirectory = value;
          if (!await getDirectory!.exists()) {
            await getDirectory!.create(recursive: true);
            showAlert(context);
          } else {
            showAlert(context);
          }
          PreferenceUtils.setString(MyConstants.dirPath, getDirectory!.path);
        });
      }
    } else if (Platform.isIOS) showAlert(context);
  }

  showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMode = MyConstants.complete;
                            _updateTicket(MyConstants.complete, context);
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.complete,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.complete,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = value;
                                      _updateTicket(value!, context);
                                    });
                                  },
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMode = MyConstants.spareRequest;
                            _updateTicket(MyConstants.spareRequest, context);
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.spareRequest,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.spareRequest,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = value;
                                      _updateTicket(value!, context);
                                    });
                                  },
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMode = MyConstants.workInProgressAlert;
                            _updateTicket(
                                MyConstants.workInProgressAlert, context);
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.workInProgressAlert,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.workInProgressAlert,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = value;
                                      _updateTicket(value!, context);
                                    });
                                  },
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMode = MyConstants.escalate;
                            _updateTicket(MyConstants.escalate, context);
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.escalate,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.escalate,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = value;
                                      _updateTicket(value!, context);
                                    });
                                  },
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Text(
                                MyConstants.cancelButton,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Color(int.parse("0xfff" "507a7d"))),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ));
        });
      },
    );
  }

  Future<void> _updateTicket(String value, BuildContext context) async {
    Navigator.of(context).pop();

    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final ticketForTheDayDao = database.ticketForTheDayDao;

    ticketForTheDayDao.updateTicketStatusData(value, widget.ticketId!);
    PreferenceUtils.setString("ticket_id", widget.ticketId!);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                InstallationReportComplete(ticketStatusData: value)));
  }
}
