import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:fieldpro_genworks_healthcare/screens/show_image.dart';
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
import '../network/model/post_spare_array_pojo.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'dashboard.dart';
import 'file_directory.dart';

class SpareRequest extends StatefulWidget {
  final String? status;

  const SpareRequest({Key? key, required this.status}) : super(key: key);

  @override
  _SpareRequestState createState() => _SpareRequestState();
}

class _SpareRequestState extends State<SpareRequest> {
  final TextEditingController _leadTimeController = TextEditingController();
  final TextEditingController _nextScheduleController = TextEditingController();
  final TextEditingController _spareCostController = TextEditingController();
  final TextEditingController _customerAcceptanceController =
      TextEditingController();
  final TextEditingController _resolutionSummaryController =
      TextEditingController();
  File? image, capturedImage;
  File? signatureImage;
  int id = 0;
  String? _selectedDate;
  bool _showTick = false, _isLoading = true, _isListVisible = false;
  final _sign = GlobalKey<SignatureState>();
  var spareRequestDataList = <SpareRequestDataTable?>[];
  var checkBoxList = <bool>[];
  var totalCostList = <double>[];
  var leadTimeList = <int>[];
  var postSpareArrayList = <PostSpareArrayPojo>[];

  getSpareRequestData() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final spareRequestDataDao = database.spareRequestDataDao;
    spareRequestDataList =
        await spareRequestDataDao.updateSpareRequestData(true);
    for (int i = 0; i < spareRequestDataList.length; i++) {
      checkBoxList.add(false);
      totalCostList.add(0);
      leadTimeList.add(spareRequestDataList[i]!.leadTime);
    }
    setState(() {
      _isLoading = !_isLoading;
      signatureImage = null;
      leadTimeList.sort();
      _leadTimeController.text = leadTimeList.last.toString();
      _spareCostController.text = "0.00";
      id = 0;
      _isListVisible = true;
    });
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    getSpareRequestData();
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => StartTicket(
                  status: MyConstants.ticketStarted,
                  ticketId:
                      PreferenceUtils.getString(MyConstants.ticketIdStore),
                )));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        pushPage(context);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StartTicket(
                              status: MyConstants.ticketStarted,
                              ticketId: PreferenceUtils.getString(
                                  MyConstants.ticketIdStore),
                            ))),
              ),
              title: const Text(MyConstants.appName),
              backgroundColor: Color(int.parse("0xfff" "507a7d")),
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                                                    "0xfff" "507a7d")),
                                                Color(
                                                    int.parse("0xfff" "507a7d"))
                                              ],
                                            ),
                                            borderRadius:
                                                const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(8.0),
                                                    topLeft:
                                                        Radius.circular(8.0),
                                                    topRight:
                                                        Radius.circular(8.0),
                                                    bottomRight:
                                                        Radius.circular(8.0)),
                                          ),
                                          child: Center(
                                            child: GestureDetector(
                                              child: const Text(
                                                  MyConstants.spareRequest,
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
                              Visibility(
                                  visible: _isListVisible,
                                  child: getSelectedList()),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                enabled: false,
                                controller: _leadTimeController,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.leadTime,
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
                              const SizedBox(height: 10.0),
                              TextFormField(
                                enabled: false,
                                controller: _spareCostController,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.spareCost,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
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
                                  return null;
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
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (signatureImage != null) {
                                            if (await signatureImage!
                                                .exists()) {
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
                                                    BorderRadius.circular(5.0)),
                                            backgroundColor: Color(
                                                int.parse("0xfff" "5C7E7F"))),
                                        child: const Text(
                                            MyConstants.clearButton,
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
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
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
                                  onPressed: () => spareRequestSubmitPostApi(),
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      backgroundColor:
                                          Color(int.parse("0xfff" "5C7E7F"))),
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
                                                      "0xfff" "507a7d")),
                                                  Color(int.parse(
                                                      "0xfff" "507a7d"))
                                                ],
                                              ),
                                              borderRadius: const BorderRadius
                                                      .only(
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
                                  controller: _leadTimeController,
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
                                  controller: _spareCostController,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.spareCost,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 10.0),
                                TextFormField(
                                  controller: _customerAcceptanceController,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.subTotal,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Row(children: [
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: _customerAcceptanceController,
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
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            backgroundColor: Color(
                                                int.parse("0xfff" "2a9d8f"))),
                                        child: const Text(
                                            MyConstants.submitButton,
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
                                    return null;
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
                                                BorderRadius.circular(10.0)),
                                        backgroundColor:
                                            Color(int.parse("0xfff" "5C7E7F"))),
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
        if (androidInfo.version.sdkInt >= int.parse(MyConstants.osVersion)) {
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
        if (option == MyConstants.camera) {
          status = await Permission.camera.request();
        } else if (option == MyConstants.gallery) {
          status = await Permission.storage.request();
        }
        Directory? directory = await getApplicationSupportDirectory();

        if (status == PermissionStatus.granted) {
          if (await _requestPermission(Permission.photos)) {
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
      if (option == MyConstants.camera) {
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

      if (androidInfo.version.sdkInt >= int.parse(MyConstants.osVersion)) {
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
      Directory? directory = await getApplicationSupportDirectory();

      if (await _requestPermission(Permission.photos)) {
        signatureImage =
            await File('$directory/${timestamp()}.png').writeAsBytes(bytes);
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
    return SizedBox(
      height: 120,
      child: Column(children: [
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
        SizedBox(
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
                      const Text(MyConstants.camera,
                          style: TextStyle(fontSize: 15))
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
                    const Text(MyConstants.gallery,
                        style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget getSelectedList() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: spareRequestDataList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Column(children: [
            Container(
                padding: const EdgeInsets.only(top: 5),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      const Padding(padding: EdgeInsets.all(5.0)),
                      Expanded(
                        flex: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text("${MyConstants.spareCost}          :",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                  spareRequestDataList[index]!
                                      .price
                                      .toStringAsFixed(2),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text("${MyConstants.spareName}        :",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                  spareRequestDataList[index]!.spareName,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text("${MyConstants.source}                 :",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(spareRequestDataList[index]!.location,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text("${MyConstants.quantity}               :",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                  spareRequestDataList[index]!
                                      .updateQuantity
                                      .toString(),
                                  style: const TextStyle(fontSize: 15)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Padding(padding: EdgeInsets.all(5.0)),
                      Expanded(
                        flex: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text("${MyConstants.isItChargeable}   :",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.0,
                            child: Checkbox(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: checkBoxList[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkBoxList[index] = value!;
                                    if (value == true) {
                                      isCheckBoxChecked(
                                          spareRequestDataList[index]!.price,
                                          spareRequestDataList[index]!
                                              .updateQuantity,
                                          index,
                                          spareRequestDataList[index]!.spareId);
                                    } else if (value == false) {
                                      isCheckBoxNotChecked(
                                          spareRequestDataList[index]!.price,
                                          spareRequestDataList[index]!
                                              .updateQuantity,
                                          index,
                                          spareRequestDataList[index]!.spareId);
                                    }
                                  });
                                },
                                activeColor: Theme.of(context).primaryColor),
                          ),
                          const Text(
                            MyConstants.yesButton,
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          backgroundColor: Color(int.parse("0xfff" "3eccbb")),
                          minimumSize: const Size(140, 35)),
                      child: Text(
                          MyConstants.costPerQuantity +
                              totalCostList[index].toStringAsFixed(2),
                          style: const TextStyle(
                              fontSize: 15, color: Colors.white)),
                    ),
                  )
                ]))
          ]);
        });
  }

  isCheckBoxChecked(
      double price, int updateQuantity, int index, String spareId) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final spareRequestDataDao = database.spareRequestDataDao;

    totalCostList[index] = price * updateQuantity.toDouble();

    spareRequestDataDao.updatespareischargeable(
        1, price * updateQuantity.toDouble(), int.parse(spareId));

    setState(() {
      double sum = totalCostList.reduce((a, b) => a + b);

      _spareCostController.text = sum.toStringAsFixed(2);
    });
  }

  isCheckBoxNotChecked(
      double price, int updateQuantity, int index, String spareId) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final spareRequestDataDao = database.spareRequestDataDao;

    totalCostList[index] = 0;

    spareRequestDataDao.updatespareischargeable(0, 0, int.parse(spareId));

    setState(() {
      double sum = totalCostList.reduce((a, b) => a + b);

      _spareCostController.text = sum.toStringAsFixed(2);
    });
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
    if (_leadTimeController.text.isEmpty) {
      setToastMessage(context, MyConstants.leadTimeError);
      validate = false;
    } else if (_nextScheduleController.text.isEmpty) {
      setToastMessage(context, MyConstants.nextVisitError);
      validate = false;
    } else if (_spareCostController.text.isEmpty) {
      setToastMessage(context, MyConstants.spareCostError);
      validate = false;
    } else if (id == 0) {
      setToastMessage(context, MyConstants.customerAcceptanceError);
      validate = false;
    } else if (_resolutionSummaryController.text.isEmpty) {
      setToastMessage(context, MyConstants.resolutionSummaryError);
      validate = false;
    }

    return validate;
  }

  spareRequestSubmitPostApi() async {
    if (await checkInternetConnection() == true) {
      if (validation()!) {
        double? spareCost;
        PostSpareArrayPojo? postSpareArrayPojo;

        final image = await _sign.currentState!.getData();
        var sign = await image.toByteData(format: ui.ImageByteFormat.png);
        final encoded = base64.encode(sign!.buffer.asUint8List());
        bool? isSaved = await saveImage(encoded);

        if (isSaved!) {
          if (signatureImage == null) {
            setToastMessage(context, MyConstants.signedError);
          } else {
            showAlertDialog(context);

            if (PreferenceUtils.getBool(MyConstants.customerAcceptanceBool) ==
                true) {
            } else {}

            final database = await $FloorAppDatabase
                .databaseBuilder('floor_database.db')
                .build();
            final spareRequestDataDao = database.spareRequestDataDao;
            var spareRequestData =
                await spareRequestDataDao.updateSpareRequestData(true);

            for (var getData in spareRequestData) {
              if (getData!.isChargeable == MyConstants.updateQuantity) {
                spareCost = getData.totalCost + MyConstants.chargeable;
              } else {
                spareCost = 0.00;
              }

              postSpareArrayPojo = PostSpareArrayPojo(
                  getData.spareCode,
                  getData.locationId,
                  getData.updateQuantity,
                  getData.isChargeable,
                  spareCost);
              postSpareArrayList.add(postSpareArrayPojo);
            }

            dio.FormData formData = dio.FormData.fromMap({
              "technician_code":
                  PreferenceUtils.getString(MyConstants.technicianCode),
              "ticket_id": PreferenceUtils.getString(MyConstants.ticketIdStore),
              "avilability": _leadTimeController.text.trim(),
              "next_visit": _selectedDate,
              "cust_acceptance": id == 2 ? 0 : 1,
              "resolution_summary": _resolutionSummaryController.text.trim(),
              "spare": jsonEncode(postSpareArrayList),
              "customer_sign": await dio.MultipartFile.fromFile(
                  signatureImage!.path,
                  filename: path.basename(signatureImage!.path)),
              "image": capturedImage != null
                  ? await dio.MultipartFile.fromFile(capturedImage!.path,
                      filename: path.basename(capturedImage!.path))
                  : ""
            });

            ApiService apiService = ApiService(dio.Dio());
            final response = await apiService.submitFromRequestSpare(
                PreferenceUtils.getString(MyConstants.token), formData);

            if (response.addTransferEntity != null) {
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
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => DashBoard()));
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
