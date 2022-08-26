import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:fieldpro_genworks_healthcare/screens/show_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/db/travel_update_request_data.dart';
import '../network/model/submitted_claim.dart';
import '../network/model/travel_update_model.dart';
import '../open_file/src/plaform/open_file.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/technician_punch.dart';
import '../utility/validator.dart';
import 'dashboard.dart';
import 'file_directory.dart';

class Reimbursement extends StatefulWidget {
  final int? selectedIndex;
  final String? backButton;

  const Reimbursement(
      {Key? key, @required this.selectedIndex, @required this.backButton})
      : super(key: key);

  @override
  _ReimbursementState createState() => _ReimbursementState();
}

class _ReimbursementState extends State<Reimbursement> {
  final Map<int, Widget> _children = {
    0: const Padding(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      child: Text(
        "Travel Update",
        style: TextStyle(fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    ),
    1: const Padding(
      padding: EdgeInsets.only(left: 5.0, right: 10.0),
      child: Text(
        "Travel Claim",
        style: TextStyle(fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    ),
  };
  int _currentSelection = 0;
  bool? _isLoading = true,
      _noDataAvailable = false,
      _travelUpdateFragment = false,
      _travelClaimFragment = false,
      _showTravelClaim = false,
      _showNewClaim = false;
  var image = <File?>[];
  var capturedImage = <File?>[];
  var encImageBase64 = <String?>[];
  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();
  final _claimList = <SubmittedClaimModel>[];
  final _updateList = <TravelUpdateModel>[];
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final _travelCostController = <TextEditingController>[];
  var showTickList = <bool>[];
  var pdfFile;
  var check;

  Future<void> getClaimList() async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
      _showTravelClaim = true;
      _showNewClaim = false;
      PreferenceUtils.setString(MyConstants.technicianStatus, MyConstants.free);
    });

    if (widget.selectedIndex == 1) {
      _currentSelection = 1;
    }
    //clear the list
    _claimList.clear();

    ApiService apiService = ApiService(dio.Dio());
    final response = await apiService.submittedClaim(
        PreferenceUtils.getString(MyConstants.token),
        PreferenceUtils.getString(MyConstants.technicianCode));
    if (response.submittedClaimEntity!.responseCode ==
        MyConstants.response200) {
      setState(() {
        PreferenceUtils.setString(
            MyConstants.token, response.submittedClaimEntity!.token!);
        for (int i = 0; i < response.submittedClaimEntity!.data!.length; i++) {
          _claimList.add(SubmittedClaimModel(
              statusName: response.submittedClaimEntity!.data![i]!.statusName,
              status: response.submittedClaimEntity!.data![i]!.status,
              comment: response.submittedClaimEntity!.data![i]!.comment,
              endDate: response.submittedClaimEntity!.data![i]!.endDate,
              startDate: response.submittedClaimEntity!.data![i]!.startDate,
              totalAmmount:
                  response.submittedClaimEntity!.data![i]!.totalAmmount));
        }
        _isLoading = !_isLoading!;
        _travelClaimFragment = true;
      });
    } else if (response.submittedClaimEntity!.responseCode ==
        MyConstants.response400) {
      setState(() {
        _isLoading = !_isLoading!;
        PreferenceUtils.setString(
            MyConstants.token, response.submittedClaimEntity!.token!);
        _noDataAvailable = true;
      });
    } else if (response.submittedClaimEntity!.responseCode ==
        MyConstants.response500) {
      setState(() {
        _isLoading = !_isLoading!;
      });
    } else {
      setToastMessage(context, MyConstants.internalServerError);
    }
  }

  Future<void> getTravelUpdateList() async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
    });

    if (widget.selectedIndex == 0) {
      _currentSelection = 0;
    }

    //clear the list
    _updateList.clear();
    _travelCostController.clear();
    showTickList.clear();
    image.clear();
    capturedImage.clear();
    encImageBase64.clear();

    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final travelUpdateRequestDataDao = database.travelUpdateRequestDataDao;
    await travelUpdateRequestDataDao.deleteSearchAMCContractDataTable();

    Map<String, dynamic> travelUpdateData = {
      'technician_code': PreferenceUtils.getString(MyConstants.technicianCode)
    };

    ApiService apiService = ApiService(dio.Dio());
    final response = await apiService.getTravelUpdate(
        PreferenceUtils.getString(MyConstants.token), travelUpdateData);
    if (response.travelUpdateEntity!.responseCode == MyConstants.response200) {
      setState(() {
        PreferenceUtils.setString(
            MyConstants.token, response.travelUpdateEntity!.token!);
        for (int i = 0; i < response.travelUpdateEntity!.data!.length; i++) {
          _updateList.add(TravelUpdateModel(
              ticketId: response.travelUpdateEntity!.data![i]!.ticketId,
              modeOfTravel: response.travelUpdateEntity!.data![i]!.modeOfTravel,
              estimatedTime:
                  response.travelUpdateEntity!.data![i]!.estimatedTime,
              endDate: response.travelUpdateEntity!.data![i]!.endDate,
              startDate: response.travelUpdateEntity!.data![i]!.startDate,
              noOfKmTravelled:
                  response.travelUpdateEntity!.data![i]!.noOfKmTravelled));

          _travelCostController
              .add(TextEditingController(text: MyConstants.empty));
          showTickList.add(false);
          image.add(null);
          capturedImage.add(null);
          encImageBase64.add(MyConstants.empty);

          TravelUpdateRequestData travelUpdateRequestData =
              TravelUpdateRequestData(
                  id: i + 1,
                  ticketId:
                      response.travelUpdateEntity!.data![i]!.ticketId ?? "",
                  modeOfTravel:
                      response.travelUpdateEntity!.data![i]!.modeOfTravel ?? "",
                  noOfKmTravelled:
                      response.travelUpdateEntity!.data![i]!.noOfKmTravelled ??
                          "",
                  estimatedTime:
                      response.travelUpdateEntity!.data![i]!.estimatedTime ??
                          "",
                  startDate:
                      response.travelUpdateEntity!.data![i]!.startDate ?? "",
                  endDate: response.travelUpdateEntity!.data![i]!.endDate ?? "",
                  adapterPosition: MyConstants.chargeable,
                  expenses: MyConstants.empty,
                  imagePath: MyConstants.empty,
                  imageSelected: MyConstants.empty);

          travelUpdateRequestDataDao
              .insertSearchAMCContractData(travelUpdateRequestData);
        }
        _isLoading = !_isLoading!;
        _travelUpdateFragment = true;
      });
    } else if (response.travelUpdateEntity!.responseCode ==
        MyConstants.response400) {
      setState(() {
        _isLoading = !_isLoading!;
        PreferenceUtils.setString(
            MyConstants.token, response.travelUpdateEntity!.token!);
        _noDataAvailable = true;
      });
    } else if (response.travelUpdateEntity!.responseCode ==
        MyConstants.response500) {
      setState(() {
        _isLoading = !_isLoading!;
      });
    } else {
      setToastMessage(context, MyConstants.internalServerError);
    }
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    if (widget.selectedIndex == 0) {
      _travelUpdateFragment = true;
      _travelClaimFragment = false;
      Future.delayed(Duration.zero, () {
        getTravelUpdateList();
      });
    } else if (widget.selectedIndex == 1) {
      _travelClaimFragment = true;
      _travelUpdateFragment = false;
      Future.delayed(Duration.zero, () {
        getClaimList();
      });
    }
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashBoard()));
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;

    return WillPopScope(
      onWillPop: () async {
        pushPage(context);
        return true;
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashBoard())),
            ),
            title: const Text(MyConstants.appName),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Expanded(
                  flex: 0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: MaterialSegmentedControl(
                              children: _children,
                              selectionIndex: _currentSelection,
                              borderColor: Colors.grey,
                              selectedColor:
                                  Color(int.parse("0xfff" "507a7d")),
                              unselectedColor: Colors.white,
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
                                      _travelUpdateFragment = true;
                                      _travelClaimFragment = false;
                                      _showNewClaim = false;
                                      getTravelUpdateList();
                                    } else if (index == 1) {
                                      _travelClaimFragment = true;
                                      _travelUpdateFragment = false;
                                      getClaimList();
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ]),
                ),
                Expanded(
                  flex: 0,
                  child: Visibility(
                    visible: _travelUpdateFragment!,
                    child: travelUpdateList(),
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Visibility(
                    visible: _travelClaimFragment!,
                    child: travelClaimScreen(),
                  ),
                ),
                Expanded(flex: 0, child: newClaimScreen())
              ],
            ),
          ),
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
              : showFab
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
    );
  }

  Widget travelUpdateList() {
    return RefreshIndicator(
      onRefresh: refreshUpdateList,
      child: _isLoading == true
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[400]!,
              child: ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  itemBuilder: (context, index) {
                    return Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Card(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 7.5),
                                child: Row(
                                  children: [
                                    const Padding(
                                        padding: EdgeInsets.all(5.0)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const <Widget>[
                                          Text(MyConstants.na,
                                              style: TextStyle(fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                            ])));
                  }),
            )
          : _noDataAvailable == false
              ? ListView.builder(
                  itemCount: _updateList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  itemBuilder: (context, index) {
                    return Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Card(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                              const SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                children: [
                                  const Padding(padding: EdgeInsets.all(5.0)),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const <Widget>[
                                        Text(
                                            MyConstants.ticketId +
                                                "              :",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: Text(
                                              _updateList[index].ticketId!,
                                              style: const TextStyle(fontSize: 15)),
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
                                  const Padding(padding: EdgeInsets.all(5.0)),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const <Widget>[
                                        Text(MyConstants.travelDistance,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: Text(
                                              _updateList[index]
                                                  .noOfKmTravelled!,
                                              style: const TextStyle(fontSize: 15)),
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
                                  const Padding(padding: EdgeInsets.all(5.0)),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const <Widget>[
                                        Text(MyConstants.travelTime,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: Text(
                                              _updateList[index].estimatedTime!,
                                              style: const TextStyle(fontSize: 15)),
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
                                  const Padding(padding: EdgeInsets.all(5.0)),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const <Widget>[
                                        Text(MyConstants.travelCharge,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 20.0),
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller:
                                                _travelCostController[index],
                                            decoration: const InputDecoration(
                                                labelText: MyConstants
                                                    .enterTravelAmount,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        10, 10, 10, 0),
                                                border: OutlineInputBorder()),
                                          ),
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
                                  const Padding(padding: EdgeInsets.all(5.0)),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const <Widget>[
                                        Text(MyConstants.attachment,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0),
                                          child: GestureDetector(
                                            onTap: () => captureImage(index),
                                            child: const Text(
                                                MyConstants.attachmentString,
                                                style: TextStyle(
                                                    color: Colors.lightBlue,
                                                    fontSize: 15)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Visibility(
                                      visible: showTickList[index],
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShowImage(
                                                          image: "",
                                                          capturedImage:
                                                              capturedImage[
                                                                  index])));
                                        },
                                        icon: Image.asset(
                                          'assets/images/check.png',
                                          width: 25,
                                          height: 25,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 15.0, right: 15.0),
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_travelCostController[index]
                                        .text
                                        .isEmpty) {
                                      setToastMessage(
                                          context, MyConstants.travelCostError);
                                    } else {
                                      updateTravel(
                                          index, _updateList[index].ticketId);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "2b6c72"))),
                                  child: const Text(MyConstants.updateButton,
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                            ])));
                  })
              : Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: const Center(
                      child: Text(MyConstants.noDataAvailable),
                    ),
                  ),
                ),
    );
  }

  Future<void> captureImage(int? index) async {
    var photo = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    if (photo != null) {
      attachmentDialog(context);
      setState(() {
        image[index!] = File(photo.path);
        List<int> imageBytes = image[index]!.readAsBytesSync();
        encImageBase64[index] = base64Encode(imageBytes);
      });

      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        final FileDirectory fileDirectory =
            FileDirectory(context, MyConstants.imageFolder);
        Directory? getDirectory;

        await _requestPermission(Permission.storage);

        if (androidInfo.version.sdkInt >= int.parse(MyConstants.osVersion)) {
          capturedImage[index!] = File(photo.path);
        } else {
          fileDirectory.createFolder().then((value) async {
            getDirectory = value;
            capturedImage[index!] = await image[index]!
                .copy('${getDirectory!.path}/${timestamp()}.png');

            if (!await getDirectory!.exists()) {
              await getDirectory!.create(recursive: true);
            }
          });
        }
      } else if (Platform.isIOS) {
        var status = await Permission.camera.request();
        Directory? directory = await getApplicationSupportDirectory();

        if (status == PermissionStatus.granted) {
          if (await _requestPermission(Permission.photos)) {
            capturedImage[index!] = await image[index]!
                .copy('${directory.path}/${timestamp()}.png');
          }
        } else if (status == PermissionStatus.denied) {
          captureImage(index);
        } else if (status == PermissionStatus.permanentlyDenied) {
          openAppSettings();
        }
      }

      setState(() {
        Navigator.of(context, rootNavigator: true).pop();
        showTickList[index!] = true;
      });
    } else {
      setToastMessage(context, MyConstants.captureImageError);
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

  void updateTravel(int? index, String? ticketId) async {
    if (await checkInternetConnection() == true) {
      if (_travelCostController[index!].text.trim().isEmpty) {
        setToastMessage(context, MyConstants.toDateError);
      } else {
        showAlertDialog(context);

        /* post travel update details to server*/
        Map<String, String> getTravelDetailsData = {
          'technician_code':
              PreferenceUtils.getString(MyConstants.technicianCode),
          'ticket_id': ticketId!,
          'travelling_charges': _travelCostController[index].text.trim(),
          'attachment': showTickList[index] == true
              ? MyConstants.base64 + encImageBase64[index]!
              : MyConstants.empty
        };

        final database = await $FloorAppDatabase
            .databaseBuilder('floor_database.db')
            .build();
        final travelUpdateRequestDataDao = database.travelUpdateRequestDataDao;

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.updateTravel(
            PreferenceUtils.getString(MyConstants.token), getTravelDetailsData);

        if (response.addTransferEntity != null) {
          if (response.addTransferEntity!.responseCode ==
              MyConstants.response200) {
            try {
              if (capturedImage[index] != null) {
                if (await capturedImage[index]!.exists()) {
                  await capturedImage[index]!.delete();
                }
              }
            } catch (e) {
            }
            await travelUpdateRequestDataDao.deleteSearchAMCContractDataTable();
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              FocusScope.of(context).requestFocus(FocusNode());
              PreferenceUtils.setString(
                  MyConstants.token, response.addTransferEntity!.token!);
              setToastMessage(context, response.addTransferEntity!.message!);

              Future.delayed(const Duration(seconds: 2), () {
                getTravelUpdateList();
              });
            });
          } else if (response.addTransferEntity!.responseCode ==
              MyConstants.response400) {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              PreferenceUtils.setString(
                  MyConstants.token, response.addTransferEntity!.token!);
              setToastMessage(context, response.addTransferEntity!.message!);
            });
          } else if (response.addTransferEntity!.responseCode ==
              MyConstants.response500) {
            Navigator.of(context, rootNavigator: true).pop();
            setToastMessage(context, response.addTransferEntity!.message!);
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

  Widget travelClaimScreen() {
    return Visibility(
      visible: _showTravelClaim!,
      child: Column(children: [
        Expanded(
          flex: 0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: GestureDetector(
                              child: const Text(MyConstants.submittedClaim,
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _showTravelClaim = false;
                                _showNewClaim = true;
                                _selectedFromDate = DateTime.now();
                                _selectedToDate = DateTime.now();
                                pdfFile = null;
                                _fromDateController.text = MyConstants.empty;
                                _toDateController.text = MyConstants.empty;
                              });
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      ]),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 0,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        child: const Text(MyConstants.fromDate,
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
                        child: const Text(MyConstants.toDate,
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
                        child: const Text(MyConstants.amount,
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
                        child: const Text(MyConstants.status,
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        travelClaimList()
      ]),
    );
  }

  Widget travelClaimList() {
    return Expanded(
      flex: 0,
      child: RefreshIndicator(
        onRefresh: refreshClaimList,
        child: _isLoading == true
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[400]!,
                child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    itemBuilder: (context, index) {
                      return Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: Card(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 7.5),
                                  child: Row(
                                    children: [
                                      const Padding(
                                          padding: EdgeInsets.all(5.0)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const <Widget>[
                                            Text(MyConstants.na,
                                                style: TextStyle(fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ])));
                    }),
              )
            : _noDataAvailable == false
                ? ListView.builder(
                    itemCount: _claimList.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    itemBuilder: (context, index) {
                      return Container(
                          padding: const EdgeInsets.only(top: 10),
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
                                                _claimList[index].startDate ==
                                                        null
                                                    ? MyConstants.na
                                                    : _claimList[index]
                                                        .startDate!,
                                                style: const TextStyle(fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                                _claimList[index].endDate ==
                                                        null
                                                    ? MyConstants.na
                                                    : _claimList[index]
                                                        .endDate!,
                                                style: const TextStyle(fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                                _claimList[index]
                                                            .totalAmmount ==
                                                        null
                                                    ? MyConstants.na
                                                    : _claimList[index]
                                                        .totalAmmount!
                                                        .toString(),
                                                style: const TextStyle(fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                                _claimList[index].statusName ==
                                                        null
                                                    ? MyConstants.na
                                                    : _claimList[index]
                                                        .statusName!
                                                        .toString(),
                                                style: const TextStyle(fontSize: 11)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ])));
                    })
                : const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Center(
                      child: Text(MyConstants.noDataAvailable),
                    ),
                  ),
      ),
    );
  }

  Widget newClaimScreen() {
    return Visibility(
      visible: _showNewClaim!,
      child: Column(children: [
        Expanded(
          flex: 0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: GestureDetector(
                              child: const Text(MyConstants.newClaim,
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _showNewClaim = false;
                                _showTravelClaim = true;
                              });
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      ]),
                ),
              ),
            ),
          ),
        ),
        Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: GestureDetector(
                        onTap: () => selectFromDate(context),
                        child: TextFormField(
                          showCursor: false,
                          enabled: false,
                          controller: _fromDateController,
                          decoration: const InputDecoration(
                              labelText: MyConstants.fromDate,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder()),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: GestureDetector(
                        onTap: () => selectToDate(context),
                        child: TextFormField(
                          showCursor: false,
                          enabled: false,
                          controller: _toDateController,
                          decoration: const InputDecoration(
                              labelText: MyConstants.toDate,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder()),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
        Expanded(
            flex: 0,
            child: SingleChildScrollView(
              child: _isLoading == true
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[400]!,
                      child: ListView.builder(
                          itemCount: 5,
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          itemBuilder: (context, index) {
                            return Container(
                                height: 50,
                                padding: const EdgeInsets.only(top: 10),
                                child: const Card(child: null));
                          }),
                    )
                  : pdfFile != null
                      ? Container(
                          color: Colors.white,
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Html(
                              shrinkWrap: true,
                              data: pdfFile,
                              style: {
                                "table": Style(
                                  backgroundColor:
                                      const Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                                ),
                                "tr": Style(
                                  border: const Border(
                                      bottom: BorderSide(color: Colors.grey)),
                                ),
                                "th": Style(
                                  padding: const EdgeInsets.all(6),
                                  backgroundColor: Colors.grey,
                                ),
                                "td": Style(
                                  padding: const EdgeInsets.all(6),
                                  alignment: Alignment.topLeft,
                                ),
                                'h5': Style(
                                    maxLines: 2,
                                    textOverflow: TextOverflow.ellipsis),
                              },
                              customRender: {
                                "table": (context, child) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: (context.tree as TableLayoutElement)
                                        .toWidget(context),
                                  );
                                },
                                "bird": (RenderContext context, Widget child) {
                                  return const TextSpan(text: "🐦");
                                },
                                "flutter":
                                    (RenderContext context, Widget child) {
                                  return FlutterLogo(
                                    style: (context.tree.element!
                                                .attributes['horizontal'] !=
                                            null)
                                        ? FlutterLogoStyle.horizontal
                                        : FlutterLogoStyle.markOnly,
                                    textColor: context.style.color!,
                                    size: context.style.fontSize!.size! * 5,
                                  );
                                },
                              },
                              onLinkTap: (url, _, __, ___) {
                              },
                              onImageTap: (src, _, __, ___) {
                              },
                              onImageError: (exception, stackTrace) {
                              },
                              onCssParseError: (css, messages) {
                                messages.forEach((element) {
                                });
                              },
                            ),
                          ),
                        )
                      : null,
            )),
        Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 140.0,
                    child: ElevatedButton(
                      onPressed: () => saveAsPDF(),
                      style: ElevatedButton.styleFrom(
                          shape:
                          RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                  10.0)), backgroundColor: Color(int.parse(
                              "0xfff" "5C7E7F"))),
                      child: const Text(
                          MyConstants.downloadButton,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white)),
                    ),
                  ),
                  SizedBox(
                    width: 140.0,
                    child: ElevatedButton(
                      onPressed: () => getTravelDetails(),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "507a7d"))),
                      child: const Text(MyConstants.viewButton,
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                  )
                ],
              ),
            )),
        Expanded(
            flex: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
                child: ElevatedButton(
                  onPressed: () => submitNewClaimRequest(),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "507a7d"))),
                  child: const Text(MyConstants.submitButton,
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ),
            ))
      ]),
    );
  }

  Future<void> refreshClaimList() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getClaimList();
    });

    return;
  }

  Future<void> refreshUpdateList() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getTravelUpdateList();
    });

    return;
  }

  Future<void> selectFromDate(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedFromDate,
          firstDate: DateTime.now().subtract(const Duration(days: 730)),
          lastDate: DateTime.now());
      if (picked != null && picked != _selectedFromDate) {
        setState(() {
          _selectedFromDate = picked;
          _fromDateController.value = TextEditingValue(
              text: DateFormat('dd-MM-yyyy').format(_selectedFromDate));
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      if(_fromDateController.text.trim().isNotEmpty){
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedToDate,
            firstDate: DateTime.now().subtract(const Duration(days: 730)),
            lastDate: DateTime.now());
        if (picked != null && picked != _selectedToDate) {
          setState(() {
            if(_selectedFromDate.compareTo(picked) <= 0){
              _selectedToDate = picked;
              _toDateController.value = TextEditingValue(
                  text: DateFormat('dd-MM-yyyy').format(_selectedToDate));
            } else {
              setToastMessage(context, MyConstants.selectedDateError);
            }
          });
        }
      } else {
        setToastMessage(context, MyConstants.fromDateError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void getTravelDetails() async {
    if (await checkInternetConnection() == true) {
      if (_fromDateController.text.trim().isNotEmpty) {
        if (_toDateController.text.trim().isEmpty) {
          setToastMessage(context, MyConstants.toDateError);
        } else {
          setState(() => _isLoading = true);

          /* post travel claim details to server*/
          Map<String, String> getTravelDetailsData = {
            'technician_code':
                PreferenceUtils.getString(MyConstants.technicianCode),
            'from_date': DateFormat('yyyy-MM-dd').format(_selectedFromDate),
            'to_date': DateFormat('yyyy-MM-dd').format(_selectedToDate)
          };

          final Response<String> result = await Dio().request(
              'https://genworks.kaspontech.com/djadmin/reimbursement_web_view/',
              options: Options(
                  method: 'POST',
                  headers: {'Content-Type': 'application/json'},
                  extra: <String, dynamic>{}),
              data: getTravelDetailsData);

          final value = result.data;

          int idx = value!.indexOf(",");
          var cut = value.substring(1, idx).trim();
          int status = int.parse(cut.split(":")[1].trim());

          switch (status) {
            case 1:
              {
                var idx = value.split(",");
                var cut = idx.sublist(1).join(",");
                var idx1 = cut.split(":");
                var cut1 = idx1.sublist(1).join(":");
                String convertedData =
                    cut1.replaceAll('"', '').replaceAll('}', '');

                setState(() {
                  pdfFile = convertedData;
                });

                _isLoading = !_isLoading!;

                break;
              }
            case 0:
              {
                setState(() {
                  pdfFile = null;
                  _isLoading = !_isLoading!;
                  setToastMessage(context, MyConstants.noClaimsFoundError);
                });
              }
          }
        }
      } else {
        setToastMessage(context, MyConstants.fromDateError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void submitNewClaimRequest() async {
    if (await checkInternetConnection() == true) {
      if (_fromDateController.text.trim().isNotEmpty) {
        if (_toDateController.text.trim().isEmpty) {
          setToastMessage(context, MyConstants.toDateError);
        } else {
          showAlertDialog(context);

          /* post travel claim details to server*/
          Map<String, String> getTravelDetailsData = {
            'technician_code':
                PreferenceUtils.getString(MyConstants.technicianCode),
            'from_date': DateFormat('yyyy-MM-dd').format(_selectedFromDate),
            'to_date': DateFormat('yyyy-MM-dd').format(_selectedToDate)
          };

          ApiService apiService = ApiService(dio.Dio());
          final response = await apiService.submitNewClaim(
              PreferenceUtils.getString(MyConstants.token),
              getTravelDetailsData);

          if (response.addTransferEntity != null) {
            if (response.addTransferEntity!.responseCode ==
                MyConstants.response200) {
              setState(() {
                Navigator.of(context, rootNavigator: true).pop();
                PreferenceUtils.setString(
                    MyConstants.token, response.addTransferEntity!.token!);
                setToastMessage(context, response.addTransferEntity!.message!);

                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashBoard()));
                });
              });
            } else if (response.addTransferEntity!.responseCode ==
                MyConstants.response400) {
              setState(() {
                Navigator.of(context, rootNavigator: true).pop();
                PreferenceUtils.setString(
                    MyConstants.token, response.addTransferEntity!.token!);
                setToastMessage(context, response.addTransferEntity!.message!);
              });
            } else if (response.addTransferEntity!.responseCode ==
                MyConstants.response500) {
              Navigator.of(context, rootNavigator: true).pop();
              setToastMessage(context, response.addTransferEntity!.message!);
            }
          } else {
            Navigator.of(context, rootNavigator: true).pop();
            setToastMessage(context, MyConstants.internalServerError);
          }
        }
      } else {
        setToastMessage(context, MyConstants.fromDateError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void saveAsPDF() async {
    if (await checkInternetConnection() == true) {
      if (_fromDateController.text.trim().isNotEmpty) {
        if (_toDateController.text.trim().isEmpty) {
          setToastMessage(context, MyConstants.toDateError);
        } else {
          String? downloadedPdf;
          downloadingDialog(context);

          /* post travel claim details to server*/
          Map<String, String> getTravelDetailsData = {
            'technician_code':
                PreferenceUtils.getString(MyConstants.technicianCode),
            'from_date': DateFormat('yyyy-MM-dd').format(_selectedFromDate),
            'to_date': DateFormat('yyyy-MM-dd').format(_selectedToDate)
          };

          final Response<String> result = await Dio().request(
              'https://genworks.kaspontech.com/djadmin/reimbursement_web_view/',
              options: Options(
                  method: 'POST',
                  headers: {'Content-Type': 'application/json'},
                  extra: <String, dynamic>{}),
              data: getTravelDetailsData);

          final value = result.data;

          int idx = value!.indexOf(",");
          var cut = value.substring(1, idx).trim();
          int status = int.parse(cut.split(":")[1].trim());

          switch (status) {
            case 1:
              {
                var idx = value.split(",");
                var cut = idx.sublist(1).join(",");
                var idx1 = cut.split(":");
                var cut1 = idx1.sublist(1).join(":");
                String convertedData =
                    cut1.replaceAll('"', '').replaceAll('}', '');

                setState(() {
                  downloadedPdf = convertedData;
                });

                if (Platform.isAndroid) {
                  final FileDirectory fileDirectory =
                      FileDirectory(context, MyConstants.imageFolder);
                  Directory? getDirectory;
                  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

                  await _requestPermission(Permission.storage);

                  if (androidInfo.version.sdkInt >=
                      int.parse(MyConstants.osVersion)) {
                    Directory appDocDir =
                        await getApplicationDocumentsDirectory();
                    var generatedPdfFile =
                        await FlutterHtmlToPdf.convertFromHtmlContent(
                            downloadedPdf!, appDocDir.path, timestamp());
                    Navigator.of(context, rootNavigator: true).pop();
                    OpenFile.open(generatedPdfFile.path);
                  } else {
                    fileDirectory.createFolder().then((value) async {
                      getDirectory = value;
                      if (!await getDirectory!.exists()) {
                        await getDirectory!.create(recursive: true);
                      }

                      var generatedPdfFile =
                          await FlutterHtmlToPdf.convertFromHtmlContent(
                              downloadedPdf!,
                              getDirectory!.path,
                              timestamp());
                      Navigator.of(context, rootNavigator: true).pop();
                      OpenFile.open(generatedPdfFile.path);
                    });
                  }
                } else if (Platform.isIOS) {
                  var status = await Permission.storage.request();
                  Directory? directory = await getApplicationSupportDirectory();

                  setToastMessage(context, "Downloading please wait");

                  if (status == PermissionStatus.granted) {
                    var generatedPdfFile =
                        await FlutterHtmlToPdf.convertFromHtmlContent(
                            downloadedPdf!,
                            directory.path,
                            timestamp());
                    Navigator.of(context, rootNavigator: true).pop();
                    OpenFile.open(generatedPdfFile.path);
                  } else if (status == PermissionStatus.denied) {
                    saveAsPDF();
                  } else if (status == PermissionStatus.permanentlyDenied) {
                    openAppSettings();
                  }
                }

                break;
              }
            case 0:
              {
                Navigator.of(context, rootNavigator: true).pop();
                setToastMessage(context, MyConstants.noClaimsFoundError);

                break;
              }
          }
        }
      } else {
        setToastMessage(context, MyConstants.fromDateError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
}
