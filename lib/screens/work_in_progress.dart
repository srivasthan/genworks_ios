import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:fieldpro_genworks_healthcare/screens/show_image.dart';
import 'package:fieldpro_genworks_healthcare/screens/spareinventory/spare_cart.dart';
import 'package:fieldpro_genworks_healthcare/screens/start_ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart' as dio;

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/db/spare_request_data.dart';
import '../network/model/work_in_progress_pojo.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'dashboard.dart';
import 'file_directory.dart';

class WorkInProgress extends StatefulWidget {
  final String ticketUpdate, ticketId;
  final bool intro;

  const WorkInProgress(this.ticketUpdate, this.ticketId, this.intro, {super.key});

  @override
  _WorkInProgressState createState() => _WorkInProgressState();
}

class _WorkInProgressState extends State<WorkInProgress> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _nextScheduleController = TextEditingController();
  final TextEditingController _pointOfActionController = TextEditingController();
  final TextEditingController _resolutionSummaryController =
      TextEditingController();
  final TextEditingController _spareRequiredController = TextEditingController();
  final _sign = GlobalKey<SignatureState>();
  bool _showTick = false, _isLoading = true;
  File? image, capturedImage, signatureImage;
  var spareRequestDataList = <SpareRequestDataTable?>[];
  String? _selectedDate, _showConsumedSpareData = "";
  int id = 0;
  var workInProgressArrayList = <WorkInProgressPojo>[];

  getWorkInProgressData() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final spareRequestDataDao = database.spareRequestDataDao;
    spareRequestDataList =
        await spareRequestDataDao.updateSpareRequestData(true);

    if (spareRequestDataList.isNotEmpty) {
      for (int i = 0; i < spareRequestDataList.length; i++) {
        String showConsumedSpareDataset = "${spareRequestDataList[i]!.spareName}${MyConstants.openBracket}${spareRequestDataList[i]!.updateQuantity}${MyConstants.closedBracket},";
        _showConsumedSpareData =
            (showConsumedSpareDataset + _showConsumedSpareData!);
      }
      _spareRequiredController.text = _showConsumedSpareData!;
    }

    setState(() {
      if (!widget.intro) {
        _reasonController.value = TextEditingValue(
            text: PreferenceUtils.getString(MyConstants.wipReason));
        _pointOfActionController.value = TextEditingValue(
            text: PreferenceUtils.getString(MyConstants.wipPoa));
        _nextScheduleController.value = TextEditingValue(
            text: PreferenceUtils.getString(MyConstants.wipSnw));
        id = PreferenceUtils.getInteger(MyConstants.wipCa);
        _resolutionSummaryController.value = TextEditingValue(
            text: PreferenceUtils.getString(MyConstants.wipRs));

        if (PreferenceUtils.getString(MyConstants.wipSnw).isNotEmpty) {
          _selectedDate = DateFormat('yyyy-MM-dd').format(
              DateFormat('dd-MM-yyyy')
                  .parse(PreferenceUtils.getString(MyConstants.wipSnw)));
        }
      }

      _isLoading = !_isLoading;
    });
  }

  Future<T?> pushPage<T>(BuildContext context) {
    PreferenceUtils.setString(MyConstants.wipReason, MyConstants.empty);
    PreferenceUtils.setString(MyConstants.wipPoa, MyConstants.empty);
    PreferenceUtils.setString(MyConstants.wipSnw, MyConstants.empty);
    PreferenceUtils.setInteger(MyConstants.wipCa, 0);
    PreferenceUtils.setString(MyConstants.wipRs, MyConstants.empty);

    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => StartTicket(
                  status: widget.ticketUpdate,
                  ticketId:
                      PreferenceUtils.getString(MyConstants.ticketIdStore),
                )));
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    getWorkInProgressData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // pushPage(context);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  PreferenceUtils.setString(
                      MyConstants.wipReason, MyConstants.empty);
                  PreferenceUtils.setString(
                      MyConstants.wipPoa, MyConstants.empty);
                  PreferenceUtils.setString(
                      MyConstants.wipSnw, MyConstants.empty);
                  PreferenceUtils.setInteger(MyConstants.wipCa, 0);
                  PreferenceUtils.setString(
                      MyConstants.wipRs, MyConstants.empty);

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StartTicket(
                                status: widget.ticketUpdate,
                                ticketId: PreferenceUtils.getString(
                                    MyConstants.ticketIdStore),
                              )));
                },
              ),
              title: const Text(MyConstants.workInProgressAlert),
              backgroundColor: Color(int.parse("0xfff" + "507a7d")),
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                    child: _isLoading == false
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        child: Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(int.parse(
                                                    "0xfff" + "507a7d")),
                                                Color(int.parse(
                                                    "0xfff" + "507a7d"))
                                              ],
                                            ),
                                            borderRadius: const BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(8.0),
                                                topLeft: Radius.circular(8.0),
                                                topRight: Radius.circular(8.0),
                                                bottomRight:
                                                    Radius.circular(8.0)),
                                          ),
                                          child: Center(
                                            child: GestureDetector(
                                              child: const Text(
                                                  MyConstants
                                                      .workInProgressAlert,
                                                  style: TextStyle(
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
                                controller: _reasonController,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.reason,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                controller: _pointOfActionController,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.pointOfAction,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                controller: _nextScheduleController,
                                onTap: () => _selectDate(context),
                                decoration: const InputDecoration(
                                    labelText: MyConstants.scheduleNextVisit,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    enabled: false,
                                    showCursor: false,
                                    controller: _spareRequiredController,
                                    keyboardType: TextInputType.multiline,
                                    decoration: const InputDecoration(
                                        labelText: MyConstants.spareTaken,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 0),
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        PreferenceUtils.setString(
                                            MyConstants.wipReason,
                                            _reasonController.text.trim());
                                        PreferenceUtils.setString(
                                            MyConstants.wipPoa,
                                            _pointOfActionController.text
                                                .trim());
                                        PreferenceUtils.setString(
                                            MyConstants.wipSnw,
                                            _nextScheduleController.text
                                                .trim());
                                        PreferenceUtils.setInteger(
                                            MyConstants.wipCa, id);
                                        PreferenceUtils.setString(
                                            MyConstants.wipRs,
                                            _resolutionSummaryController.text
                                                .trim());

                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SpareCart(
                                                        MyConstants
                                                            .workInProgressAlert,
                                                        widget.ticketId)));
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.0)), backgroundColor: Color(
                                              int.parse("0xfff" + "2a9d8f"))),
                                      child: const Text(MyConstants.addButton,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Row(children: [
                                const Expanded(
                                    flex: 0,
                                    child: Text(
                                      "${MyConstants.customerAcceptance}  :",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    )),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Radio(
                                        value: 1,
                                        groupValue: id,
                                        onChanged: (val) {
                                          setState(() {
                                            id = 1;
                                            PreferenceUtils.setString(
                                                MyConstants.customerAcceptance,
                                                MyConstants.customerAcceptance);
                                            PreferenceUtils.setBool(
                                                MyConstants
                                                    .customerAcceptanceBool,
                                                true);
                                          });
                                        },
                                      ),
                                      const Text(
                                        MyConstants.yesButton,
                                      ),
                                      Radio(
                                        value: 2,
                                        groupValue: id,
                                        onChanged: (val) {
                                          setState(() {
                                            id = 2;
                                            PreferenceUtils.setString(
                                                MyConstants.customerAcceptance,
                                                MyConstants.customerAcceptance);
                                            PreferenceUtils.setBool(
                                                MyConstants
                                                    .customerAcceptanceBool,
                                                false);
                                          });
                                        },
                                      ),
                                      const Text(MyConstants.noButton)
                                    ],
                                  ),
                                ),
                              ]),
                              const SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                controller: _resolutionSummaryController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyConstants.resolutionSummaryError;
                                  }
                                },
                                decoration: const InputDecoration(
                                    labelText: MyConstants.resolutionSummary,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    MyConstants.customerSignature,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  )),
                              const SizedBox(
                                height: 15.0,
                              ),
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black12)),
                                child: Signature(
                                  color: Colors.black,
                                  key: _sign,
                                  onSign: () {},
                                  strokeWidth: 3.0,
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15.0),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (signatureImage != null) {
                                            if (await signatureImage!.exists()) {
                                              await signatureImage!.delete();
                                            }
                                          }
                                          setState(() {
                                            _sign.currentState!.clear();
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        5.0)), backgroundColor: Color(
                                                int.parse("0xfff" + "5C7E7F"))),
                                        child: const Text(MyConstants.clearButton,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white)),
                                      ),
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
                                      children: <Widget>[
                                        const Text(MyConstants.attachment,
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
                                            onTap: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (context) {
                                                    return imageBottomSheet(
                                                        context);
                                                  });
                                            },
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
                                    child: IconButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return imageBottomSheet(context);
                                            });
                                      },
                                      icon: Image.asset(
                                        'assets/images/photo.png',
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Visibility(
                                      visible: _showTick,
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShowImage(
                                                          image: "",
                                                          capturedImage:
                                                              capturedImage)));
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
                              const SizedBox(height: 15.0),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      workInProgressSubmitPostApi(),
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" + "5C7E7F"))),
                                  child: const Text(MyConstants.submitButton,
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                ),
                              )
                            ],
                          )
                        : Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[400]!,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          child: Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(int.parse(
                                                      "0xfff" + "507a7d")),
                                                  Color(int.parse(
                                                      "0xfff" + "507a7d"))
                                                ],
                                              ),
                                              borderRadius: const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(8.0),
                                                  topLeft: Radius.circular(8.0),
                                                  topRight:
                                                      Radius.circular(8.0),
                                                  bottomRight:
                                                      Radius.circular(8.0)),
                                            ),
                                            child: Center(
                                              child: GestureDetector(
                                                child: const Text(
                                                    MyConstants
                                                        .billingInformation,
                                                    style: TextStyle(
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
                                  controller: _reasonController,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.leadTime,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 10.0),
                                TextFormField(
                                  controller: _nextScheduleController,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.scheduleNextVisit,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 10.0),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.spareCost,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 10.0),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.subTotal,
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Row(children: [
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          labelText:
                                              MyConstants.customerAcceptance,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              10, 10, 10, 0),
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15.0),
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)), backgroundColor: Color(
                                                int.parse("0xfff" + "2a9d8f"))),
                                        child: const Text(MyConstants.submitButton,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ]),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                TextFormField(
                                  controller: _resolutionSummaryController,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return MyConstants.resolutionSummaryError;
                                    }
                                  },
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.resolutionSummary,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 15.0),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    10.0)), backgroundColor: Color(
                                            int.parse("0xfff" + "5C7E7F"))),
                                    child: const Text(MyConstants.submitButton,
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white)),
                                  ),
                                )
                              ],
                            ))),
              ),
            )),
      ),
    );
  }

  Future<void> captureImage(String? option) async {
    XFile? photo;

    Future.delayed(const Duration(seconds: 1), () {
      showImageDialog(context);
    });

    if (option == MyConstants.camera) {
      photo = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 50);
    } else if (option == MyConstants.gallery) {
      photo = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 50);
    }

    if (photo != null) {
      setState(() {
        image = File(photo!.path);
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
          capturedImage = File(photo.path);
        } else {
          fileDirectory.createFolder().then((value) async {
            getDirectory = value;
            if (!await getDirectory!.exists()) {
              await getDirectory!.create(recursive: true);
              capturedImage =
              await image!.copy('${getDirectory!.path}/${timestamp()}.png');
            } else {
              capturedImage =
              await image!.copy('${getDirectory!.path}/${timestamp()}.png');
            }
          });
        }
      } else if (Platform.isIOS) {
        PermissionStatus? status;
        if(option == MyConstants.camera) {
          status = await Permission.camera.request();
        } else if(option == MyConstants.gallery) {
          status = await Permission.storage.request();
        }
        Directory? directory = await getApplicationSupportDirectory();

        if (status == PermissionStatus.granted) {
          if (await _requestPermission(Permission.photos)){
            showImageDialog(context);
            capturedImage =
            await image!.copy('${directory.path}/${timestamp()}.png');
          }
        } else if (status == PermissionStatus.denied) {
          captureImage(option);
        } else if (status == PermissionStatus.permanentlyDenied) {
          openAppSettings();
        }
      }

      setState(() {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context, rootNavigator: false).pop();
          _showTick = true;
          Navigator.of(context).pop();
          FocusScope.of(context).requestFocus(FocusNode());
        });
      });
    } else {
      Navigator.of(context).pop();
      if(option == MyConstants.camera) {
        setToastMessage(context, MyConstants.captureImageError);
      } else {
        setToastMessage(context, MyConstants.selectImageError);
      }
    }
  }

  Future<bool?> saveImage(String encoded) async {
    bool isSaved = false;
    Uint8List? bytes = base64.decode(encoded);

    if (Platform.isAndroid) {
      String? directory = PreferenceUtils.getString(MyConstants.dirPath);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >=
          int.parse(MyConstants.osVersion)) {
        String dir = (await getApplicationDocumentsDirectory()).path;
        File file = File("$dir/${DateTime.now().millisecondsSinceEpoch}.png");
        await file.writeAsBytes(bytes);
        signatureImage = file;
      } else {
        signatureImage =
            await File('$directory/${timestamp()}.png').writeAsBytes(bytes);
      }

      isSaved = true;
    } else if (Platform.isIOS) {
      Directory? directory = await getTemporaryDirectory();

      if (await _requestPermission(Permission.storage)) {
        signatureImage = await File('${directory.path}/${timestamp()}.png')
            .writeAsBytes(bytes);
      }

      isSaved = true;
    }

    return isSaved;
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

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Widget imageBottomSheet(BuildContext context) {
    return Container(
      height: 120,
      child: Column(children: [
        Container(
            height: 40,
            decoration: BoxDecoration(
                color: Color(int.parse("0xfff" + "5C7E7F")),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0))),
            child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      MyConstants.imageBottomSheetOption,
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.white,
                        ))
                  ],
                ))),
        Container(
          height: 65,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: IconButton(
                              onPressed: () => captureImage(MyConstants.camera),
                              icon: const Icon(Icons.camera))),
                      const Text(MyConstants.camera, style: TextStyle(fontSize: 15))
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 50,
              ),
              Center(
                child: Column(
                  children: [
                    Expanded(
                        child: IconButton(
                            onPressed: () => captureImage(MyConstants.gallery),
                            icon: const Icon(Icons.photo))),
                    const Text(MyConstants.gallery, style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      FocusScope.of(context).requestFocus(FocusNode());
      DateTime selectedDate = DateTime.now();

      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate.add(const Duration(days: 1)),
          firstDate: selectedDate.add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 30)));
      if (picked != selectedDate) {
        setState(() {
          selectedDate = picked!;
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          _selectedDate = formatter.format(selectedDate).toString();
          final DateFormat uiDate = DateFormat('dd-MM-yyyy');
          setState(() {
            _nextScheduleController.value =
                TextEditingValue(text: uiDate.format(selectedDate).toString());
          });
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  bool? validation() {
    bool? validate = true;
    if (_reasonController.text.isEmpty) {
      setToastMessage(context, MyConstants.reasonError);
      validate = false;
    } else if (_pointOfActionController.text.isEmpty) {
      setToastMessage(context, MyConstants.pointOfActionError);
      validate = false;
    } else if (_nextScheduleController.text.isEmpty) {
      setToastMessage(context, MyConstants.nextVisitError);
      validate = false;
    } else if (id == 0) {
      setToastMessage(context, MyConstants.customerAcceptanceError);
      validate = false;
    } else if (_resolutionSummaryController.text.isEmpty) {
      setToastMessage(context, MyConstants.resolutionSummaryError);
      validate = false;
    } else if (_sign.currentState?.points.length == 0) {
      setToastMessage(context, MyConstants.signedError);
      validate = false;
    }
    return validate;
  }

  workInProgressSubmitPostApi() async {
    if (await checkInternetConnection() == true) {
      if (validation()!) {
        WorkInProgressPojo? workInProgressPojo;

        final image = await _sign.currentState!.getData();
        var sign = await image.toByteData(format: ui.ImageByteFormat.png);
        final encoded = base64.encode(sign!.buffer.asUint8List());
        bool? isSaved = await saveImage(encoded);

        if (isSaved!) {
          if (signatureImage == null) {
            setToastMessage(context, MyConstants.signedError);
          } else {
            showAlertDialog(context);

            final database = await $FloorAppDatabase
                .databaseBuilder('floor_database.db')
                .build();
            final spareRequestDataDao = database.spareRequestDataDao;
            var spareRequestData =
                await spareRequestDataDao.updateSpareRequestData(true);

            for (var getData in spareRequestData) {
              workInProgressPojo = WorkInProgressPojo(
                  getData!.spareCode,
                  getData.locationId,
                  getData.updateQuantity,
                  getData.isChargeable);
              workInProgressArrayList.add(workInProgressPojo);
            }

            dio.FormData formData = dio.FormData.fromMap({
              "technician_code":
                  PreferenceUtils.getString(MyConstants.technicianCode),
              "ticket_id": widget.ticketId,
              "inprogress_reason": _reasonController.text.trim(),
              "schedule_next": _selectedDate,
              "cust_acceptance": id == 2 ? 0 : 1,
              "resolution_summary": _resolutionSummaryController.text.trim(),
              "spare": jsonEncode(workInProgressArrayList),
              "plan_of_action": _pointOfActionController.text.trim(),
              "customer_sign": await dio.MultipartFile.fromFile(
                  signatureImage!.path,
                  filename: path.basename(signatureImage!.path)),
              "image": capturedImage != null
                  ? await dio.MultipartFile.fromFile(capturedImage!.path,
                      filename: path.basename(capturedImage!.path))
                  : ""
            });

            ApiService apiService = ApiService(dio.Dio());
            final response = await apiService.submitFromWorkInProgressFrom(
                PreferenceUtils.getString(MyConstants.token), formData);

            if (response.addTransferEntity != null) {
              PreferenceUtils.setString(
                  MyConstants.wipReason, MyConstants.empty);
              PreferenceUtils.setString(MyConstants.wipPoa, MyConstants.empty);
              PreferenceUtils.setString(MyConstants.wipSnw, MyConstants.empty);
              PreferenceUtils.setInteger(MyConstants.wipCa, 0);
              PreferenceUtils.setString(MyConstants.wipRs, MyConstants.empty);

              if (response.addTransferEntity!.responseCode ==
                  MyConstants.response200) {
                if (signatureImage != null) {
                  if (await signatureImage!.exists()) {
                    await signatureImage!.delete();
                  }
                }
                if (capturedImage != null) {
                  if (await capturedImage!.exists()) {
                    await capturedImage!.delete();
                  }
                }

                setState(() {
                  Navigator.of(context, rootNavigator: true).pop();
                  PreferenceUtils.setString(
                      MyConstants.token, response.addTransferEntity!.token!);
                  setToastMessage(
                      context, response.addTransferEntity!.message!);
                  spareRequestDataDao.deleteSpareRequestDataTable();
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
                  setToastMessage(
                      context, response.addTransferEntity!.message!);
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
        }
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }
}
