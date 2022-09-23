import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart' as dio;
import 'package:video_compress/video_compress.dart';

import '../network/api_services.dart';
import '../network/model/suggested_technician_model.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'dashboard.dart';
import 'file_directory.dart';
import 'show_image.dart';
import 'show_video.dart';
import 'start_ticket.dart';

class Escalate extends StatefulWidget {
  final String ticketUpdate, ticketId;

  const Escalate(this.ticketUpdate, this.ticketId);

  @override
  _EscalateState createState() => _EscalateState();
}

class _EscalateState extends State<Escalate> {
  final _sign = GlobalKey<SignatureState>();
  bool _showTick = false, _showVideoTick = false, _showDropdown = false;
  String? _videoPath;
  File? image,
      capturedImage,
      signatureImage,
      _capturedVideo,
      _convertedVideo,
      _showVideo;
  final TextEditingController _resolutionSummaryController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _suggestionLevel, _selectedTechnician;
  SuggestedTechnicianModel? _suggestedTechnicianModel;
  final _technicianList = <SuggestedTechnicianModel?>[];

  assignNullValue() {
    setState(() {
      signatureImage = null;
      capturedImage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    assignNullValue();
  }

  Future<T?> pushPage<T>(BuildContext context) {
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //  pushPage(context);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StartTicket(
                            status: widget.ticketUpdate,
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
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Expanded(
                        child: SizedBox(
                          child: Container(
                            height: 40,
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
                                child: const Text(MyConstants.escalate,
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        MyConstants.suggestionLevel,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 50,
                      color: Color(int.parse("0xfff" "778899")),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.all(2),
                        ),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _suggestionLevel,
                          iconEnabledColor: Colors.white,
                          dropdownColor: Color(int.parse("0xfff" "778899")),
                          hint: const Text(
                            MyConstants.escalateTechnicianLevel,
                            style: TextStyle(color: Colors.white),
                          ),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(int.parse("0xfff" "778899")))),
                            contentPadding: const EdgeInsets.all(5),
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              _suggestionLevel = value!;
                              _showDropdown = false;
                              _technicianList.clear();
                              _suggestedTechnicianModel = null;
                            });
                            getSuggestedTechnicians(value);
                          },
                          items: <String>[
                            MyConstants.l1,
                            MyConstants.l2,
                            MyConstants.l3,
                            MyConstants.l4,
                            MyConstants.l5
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Visibility(
                      visible: _showDropdown,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          MyConstants.suggestionTechnicianName,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _showDropdown,
                      child: const SizedBox(
                        height: 10.0,
                      ),
                    ),
                    Visibility(
                      visible: _showDropdown,
                      child: Container(
                        height: 50,
                        color: Color(int.parse("0xfff" "778899")),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            contentPadding: const EdgeInsets.all(2),
                          ),
                          child: DropdownButtonFormField<
                              SuggestedTechnicianModel?>(
                            isExpanded: true,
                            value: _suggestedTechnicianModel,
                            iconEnabledColor: Colors.white,
                            dropdownColor: Color(int.parse("0xfff" "778899")),
                            hint: const Text(
                              MyConstants.escalateTechnician,
                              style: TextStyle(color: Colors.white),
                            ),
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(
                                          int.parse("0xfff" "778899")))),
                              contentPadding: const EdgeInsets.all(5),
                            ),
                            onChanged: (SuggestedTechnicianModel? value) {
                              _suggestedTechnicianModel = value!;
                              _selectedTechnician = value.technicianCode;
                            },
                            items: _technicianList
                                .map((SuggestedTechnicianModel? value) {
                              return DropdownMenuItem<
                                  SuggestedTechnicianModel?>(
                                value: value,
                                child: Text(
                                  value!.technicianName!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                          labelText: MyConstants.description,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      controller: _resolutionSummaryController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                          labelText: MyConstants.resolutionSummary,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          MyConstants.customerSignature,
                          style: TextStyle(fontWeight: FontWeight.w700),
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
                                if(signatureImage != null){
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
                                          BorderRadius.circular(5.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                              child: const Text(MyConstants.clearButton,
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return imageBottomSheet(context);
                                        });
                                  },
                                  child: const Text(MyConstants.attachmentString,
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
                                        builder: (context) => ShowImage(
                                            image: "",
                                            capturedImage: capturedImage)));
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
                    Row(
                      children: [
                        const Padding(padding: EdgeInsets.all(5.0)),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const <Widget>[
                              Text(MyConstants.video,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: GestureDetector(
                                  onTap: () => captureVideo(),
                                  child: const Text(MyConstants.attachmentString,
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
                            onPressed: () => captureVideo(),
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
                            visible: _showVideoTick,
                            child: IconButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowVideo(
                                            video: _showVideo,
                                            videoPath: MyConstants.empty,
                                          ))),
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
                        onPressed: () => submitEscalateDetailsPostApi(),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                        child: const Text(MyConstants.submitButton,
                            style:
                                TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    )
                  ],
                )),
              ))),
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

  Future<void> captureVideo() async {
    MediaInfo? info;
    var photo = await ImagePicker().pickVideo(
        preferredCameraDevice: CameraDevice.rear,
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 1));

    if (photo != null) {
      setState(() {
        _capturedVideo = File(photo.path);
      });

      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        final FileDirectory fileDirectory =
        FileDirectory(context, MyConstants.imageFolder);
        Directory? getDirectory;

        await _requestPermission(Permission.storage);

        if (androidInfo.version.sdkInt >=
            int.parse(MyConstants.osVersion)) {
          showVideoDialog(context);

          _convertedVideo = File(photo.path);

          _videoPath = _convertedVideo!.path;

          info = await VideoCompress.compressVideo(
            _videoPath!,
            quality: VideoQuality.LowQuality,
            deleteOrigin: false, // default(false)
          );

          _showVideo = await File(info!.path!).copy(_videoPath!);
          Navigator.of(context, rootNavigator: true).pop();

          setState(() {
            _showVideoTick = true;
            FocusScope.of(context).requestFocus(FocusNode());
          });
        } else {
          fileDirectory.createFolder().then((value) async {
            getDirectory = value;
            if (!await getDirectory!.exists()) {
              await getDirectory!.create(recursive: true);
            }

            showVideoDialog(context);

            _convertedVideo = await _capturedVideo!
                .copy('${getDirectory!.path}/${timestamp()}.mp4');
            _videoPath = _convertedVideo!.path;

            info = await VideoCompress.compressVideo(
              _videoPath!,
              quality: VideoQuality.LowQuality,
              deleteOrigin: false, // default(false)
            );

            _showVideo = await File(info!.path!).copy(_videoPath!);
            Navigator.of(context, rootNavigator: true).pop();

            setState(() {
              _showVideoTick = true;
              FocusScope.of(context).requestFocus(FocusNode());
            });
          });
        }
      } else if (Platform.isIOS) {
        Directory? directory = await getTemporaryDirectory();

        if (await _requestPermission(Permission.photos)) {
          showVideoDialog(context);

          _convertedVideo = await _capturedVideo!
              .copy('${directory.path}/${timestamp()}.mp4');
          _videoPath = _convertedVideo!.path;

          info = await VideoCompress.compressVideo(
            _videoPath!,
            quality: VideoQuality.LowQuality,
            deleteOrigin: false, // default(false)
          );

          _showVideo = await File(info!.path!).copy(_videoPath!);
          Navigator.of(context, rootNavigator: true).pop();

          setState(() {
            _showVideoTick = true;
            FocusScope.of(context).requestFocus(FocusNode());
          });
        }
      }

      PreferenceUtils.setString(MyConstants.videoPath, _showVideo!.path);
    } else {
      setToastMessage(context, MyConstants.videoError);
    }
  }

  Future<bool?> saveImage(String encoded) async {
    bool isSaved = false;
    Uint8List? bytes = base64.decode(encoded);

    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String? directory = PreferenceUtils.getString(MyConstants.dirPath);

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

  getSuggestedTechnicians(String? selectedTechnicianLevel) async {
    if (await checkInternetConnection() == true) {
      setToastMessageLoading(context);

      Map<String, dynamic> suggestionLevelData = {
        'technician_code':
            PreferenceUtils.getString(MyConstants.technicianCode),
        'suggestion_level': selectedTechnicianLevel
      };

      ApiService apiService = ApiService(dio.Dio());
      final response =
          await apiService.getSuggestedTechnicians(suggestionLevelData);

      if (response.suggestedTechnicianEntity != null) {
        if (response.suggestedTechnicianEntity!.responseCode ==
            MyConstants.response200) {
          setState(() {
            for (int i = 0;
                i < response.suggestedTechnicianEntity!.data!.length;
                i++) {
              _showDropdown = true;
              //   if (_technicianList.length == 0) {
              _technicianList.add(SuggestedTechnicianModel(
                  technicianCode: response
                      .suggestedTechnicianEntity!.data![i]!.technicianCode,
                  technicianName: response
                      .suggestedTechnicianEntity!.data![i]!.technicianName));
              // } else {
              //   if (!_technicianList[i]!.technicianCode!.contains(response
              //       .suggestedTechnicianEntity!.data![i]!.technicianCode!)) {
              //     _technicianList.add(new SuggestedTechnicianModel(
              //         technicianCode: response
              //             .suggestedTechnicianEntity!.data![i]!.technicianCode,
              //         technicianName: response.suggestedTechnicianEntity!
              //             .data![i]!.technicianName));
              //   }
              //  }
            }
          });
        }
      } else {
        setToastMessage(context, MyConstants.internalServerError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  bool? validation() {
    bool? validate = true;
    if (_suggestionLevel == null) {
      setToastMessage(context, MyConstants.suggestTechnicianLevelError);
      validate = false;
    } else if (_descriptionController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.descriptionError);
    } else if (_resolutionSummaryController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.resolutionSummaryError);
    } else if (_technicianList.length > 0 && _selectedTechnician == null) {
      validate = false;
      setToastMessage(context, MyConstants.suggestTechnicianError);
    }
    else if (_sign.currentState?.points.length == 0) {
      setToastMessage(context, MyConstants.signedError);
      validate = false;
    }


    return validate;
  }

  submitEscalateDetailsPostApi() async {
    if (await checkInternetConnection() == true) {
      if (validation()!) {
        final image = await _sign.currentState!.getData();
        var sign = await image.toByteData(format: ui.ImageByteFormat.png);
        final encoded = base64.encode(sign!.buffer.asUint8List());
        bool? isSaved = await saveImage(encoded);

        if (isSaved!) {
          if (signatureImage == null) {
            setToastMessage(context, MyConstants.signedError);
          } else {
            showAlertDialog(context);

            dio.FormData formData = dio.FormData.fromMap({
              "raised_tech":
                  PreferenceUtils.getString(MyConstants.technicianCode),
              "ticket_id": widget.ticketId,
              "suggested_skill_level": _suggestionLevel,
              "sug_tech": _selectedTechnician,
              "escalated_description": _descriptionController.text.trim(),
              "resolution_summary": _resolutionSummaryController.text.trim(),
              "escalated_audio": MyConstants.empty,
              "customer_sign": await dio.MultipartFile.fromFile(
                  signatureImage!.path,
                  filename: path.basename(signatureImage!.path)),
              "escalated_image": capturedImage != null
                  ? await dio.MultipartFile.fromFile(capturedImage!.path,
                      filename: path.basename(capturedImage!.path))
                  : "",
              "escalated_video": _showVideo != null
                  ? await dio.MultipartFile.fromFile(_showVideo!.path,
                  filename: path.basename(_showVideo!.path))
                  : "",
            });

            ApiService apiService = ApiService(dio.Dio());
            final response = await apiService.submitEscalateTicket(
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
                if (PreferenceUtils.getString(MyConstants.videoPath) !=
                    MyConstants.clear) {
                  if (await File(
                          PreferenceUtils.getString(MyConstants.videoPath))
                      .exists()) {
                    await File(PreferenceUtils.getString(MyConstants.videoPath))
                        .delete();
                  }
                }

                setState(() {
                  Navigator.of(context, rootNavigator: true).pop();
                  PreferenceUtils.setString(
                      MyConstants.token, response.addTransferEntity!.token!);
                  setToastMessage(
                      context, response.addTransferEntity!.message!);
                  PreferenceUtils.setString(
                      MyConstants.videoPath, MyConstants.clear);

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
