import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shimmer/shimmer.dart';

import '../network/api_services.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'dashboard.dart';

class ProfileTechnician extends StatefulWidget {
  @override
  _ProfileTechnicianState createState() => _ProfileTechnicianState();
}

class _ProfileTechnicianState extends State<ProfileTechnician> {
  final formKey = GlobalKey<FormState>();
  String? _getToken,
      _getTechnicianCode,
      _name,
      _email,
      _assignedSte,
      _assignedDistricts,
      _assignedMandals,
      _assignedServiceDesk,
      _profilePicture,
      _contactNumber,
      encImageBase64;
  TextEditingController emailController = TextEditingController();
  double _rating = 0.0;
  File? image, imageResized;
  bool _enabled = true;
  bool _statesExpand = false, _districtExpand = false, _mandalExpand = false;

  takeCamera() async {
    PermissionStatus? status;

    Future.delayed(const Duration(seconds: 1), () {
      showImageDialog(context);
    });

    if (Platform.isAndroid) {
      status = await Permission.storage.request();
    } else if (Platform.isIOS) {
      await Permission.location.request();
      status = await Permission.camera.request();
    }

    if (status == PermissionStatus.granted) {
      var photo = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 50);

      if (photo != null) {
        imageResized = await FlutterNativeImage.compressImage(photo.path,
            quality: 100, targetWidth: 120, targetHeight: 120);

        Navigator.of(context, rootNavigator: false).pop();
        Navigator.of(context).pop();

        //cropping image
        CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: photo.path,
            aspectRatioPresets: Platform.isAndroid
                ? [
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9
                  ]
                : [
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio5x3,
                    CropAspectRatioPreset.ratio5x4,
                    CropAspectRatioPreset.ratio7x5,
                    CropAspectRatioPreset.ratio16x9
                  ],
            uiSettings: [
              AndroidUiSettings(
                  toolbarTitle: 'Image Cropper',
                  statusBarColor: Color(int.parse("0xfff" "5C7E7F")),
                  toolbarColor: Color(int.parse("0xfff" "5C7E7F")),
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.original,
                  lockAspectRatio: false),
              IOSUiSettings(
                title: 'Image Cropper',
              )
            ]);

        setState(() {
          image = File(croppedFile!.path);
          Future<Uint8List> imageBytes = croppedFile.readAsBytes();
          imageBytes.then((value) {
            encImageBase64 = base64Encode(value);
            File imagePath = File(encImageBase64!);
            uploadProfilePhoto(imagePath.path, context);
          });
        });
      } else {
        Navigator.of(context).pop();
        setToastMessage(context, MyConstants.incError);
        encImageBase64 = "";
      }
    } else if (status == PermissionStatus.denied) {
      takeCamera();
    } else if (status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  galleryPicker() async {
    PermissionStatus? status;

    if (Platform.isAndroid) status = await Permission.storage.request();
    if (Platform.isIOS) status = await Permission.storage.request();

    Future.delayed(const Duration(seconds: 1), () {
      showImageDialog(context);
    });

    if (status == PermissionStatus.granted) {
      var photo = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (photo != null) {
        imageResized = await FlutterNativeImage.compressImage(photo.path,
            quality: 100, targetWidth: 120, targetHeight: 120);

        Navigator.of(context, rootNavigator: false).pop();
        Navigator.of(context).pop();

        //cropping image
        CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: photo.path,
            aspectRatioPresets: Platform.isAndroid
                ? [
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9
                  ]
                : [
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio5x3,
                    CropAspectRatioPreset.ratio5x4,
                    CropAspectRatioPreset.ratio7x5,
                    CropAspectRatioPreset.ratio16x9
                  ],
            uiSettings: [
              AndroidUiSettings(
                  toolbarTitle: 'Image Cropper',
                  statusBarColor: Color(int.parse("0xfff" "5C7E7F")),
                  toolbarColor: Color(int.parse("0xfff" "5C7E7F")),
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.original,
                  lockAspectRatio: false),
              IOSUiSettings(
                title: 'Image Cropper',
              )
            ]
        );

        setState(() {
          image = File(croppedFile!.path);
          Future<Uint8List> imageBytes = croppedFile.readAsBytes();
          imageBytes.then((value) {
            encImageBase64 = base64Encode(value);
            File imagePath = File(encImageBase64!);
            uploadProfilePhoto(imagePath.path, context);
          });
        });
      } else {
        Navigator.of(context).pop();
        setToastMessage(context, MyConstants.insError);
        encImageBase64 = "";
      }
    } else if (status == PermissionStatus.denied) {
      galleryPicker();
    } else if (status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setDetails(context);
      getDetails(context);
    });
    PreferenceUtils.init();
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashBoard()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        pushPage(context);
        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashBoard())),
            ),
            title: const Text('Profile'),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/profile_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: _enabled == false
                  ? Container(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Expanded(
                              flex: 0,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 3, right: 35, top: 20),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "V 2.0",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              )),
                          Expanded(
                            flex: 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 3, right: 3, top: 25),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.only(left: 15),
                                        child: Text(
                                          _name!,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Stack(
                                      children: <Widget>[
                                        SizedBox(
                                          width: 100.0,
                                          height: 100.0,
                                          child: ClipOval(
                                              child: _profilePicture == null
                                                  ? ClipOval(
                                                      child: Image.asset(
                                                          'assets/images/user_image.png'),
                                                    )
                                                  : image == null
                                                      ? Image.network(
                                                          _profilePicture!,
                                                          fit: BoxFit.cover,
                                                          width: 100.0,
                                                          height: 100.0,
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget? child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child!;
                                                            }
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        loadingProgress
                                                                            .expectedTotalBytes!
                                                                            .toInt()
                                                                    : null,
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : ClipOval(
                                                          child: Image.file(
                                                              image!),
                                                        )),
                                        ),
                                        Positioned(
                                            bottom: 1,
                                            right: 1,
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: const BoxDecoration(
                                                  color: Colors.black45,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.add_a_photo,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return SizedBox(
                                                          height: 120,
                                                          child: Column(
                                                              children: [
                                                                Container(
                                                                    height: 40,
                                                                    decoration: BoxDecoration(
                                                                        color: Color(int.parse("0xfff" "5C7E7F")),
                                                                        borderRadius: const BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0))),
                                                                    child: Padding(
                                                                        padding: const EdgeInsets.only(left: 15),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: <
                                                                              Widget>[
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
                                                                    children: <
                                                                        Widget>[
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 15),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Expanded(child: IconButton(onPressed: takeCamera, icon: const Icon(Icons.camera))),
                                                                              const Text("Camera", style: TextStyle(fontSize: 15))
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            50,
                                                                      ),
                                                                      Center(
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Expanded(child: IconButton(onPressed: galleryPicker, icon: const Icon(Icons.photo))),
                                                                            const Text("Gallery",
                                                                                style: TextStyle(fontSize: 15))
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ]),
                                                        );
                                                      });
                                                },
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Center(
                                              child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  margin:
                                                      const EdgeInsets.only(right: 5),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6.0),
                                                    child: Image.asset(
                                                        'assets/images/p_name.png',
                                                        width: 24,
                                                        height: 24),
                                                  )),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 7,
                                                  ),
                                                  const Text("Full Name",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(_name!),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Center(
                                              child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  margin:
                                                      const EdgeInsets.only(right: 5),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6.0),
                                                    child: Image.asset(
                                                        'assets/images/p_email.png',
                                                        width: 24,
                                                        height: 24),
                                                  )),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 7,
                                                  ),
                                                  const Text("Email",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(_email!),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Center(
                                              child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  margin:
                                                      const EdgeInsets.only(right: 5),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6.0),
                                                    child: Image.asset(
                                                        'assets/images/p_call.png',
                                                        width: 24,
                                                        height: 24),
                                                  )),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 7,
                                                  ),
                                                  const Text("Mobile no",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(_contactNumber!),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Center(
                                              child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  margin:
                                                      const EdgeInsets.only(right: 5),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(6.0),
                                                      child: Image.asset(
                                                          'assets/images/assigned_state.png',
                                                          width: 24,
                                                          height: 24))),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 7,
                                                  ),
                                                  const Text("Assigned States",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(_assignedSte!,
                                                          maxLines:
                                                              _statesExpand
                                                                  ? 8
                                                                  : 2,
                                                          textAlign: TextAlign
                                                              .start),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _statesExpand =
                                                                !_statesExpand;
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  right:
                                                                      15.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: <
                                                                Widget>[
                                                              _assignedSte ==
                                                                      "All"
                                                                  ? const Text('')
                                                                  : _statesExpand
                                                                      ? const Text(
                                                                          "Show Less",
                                                                          style:
                                                                              TextStyle(color: Colors.blue),
                                                                        )
                                                                      : const Text(
                                                                          "Show More",
                                                                          style:
                                                                              TextStyle(color: Colors.blue))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Center(
                                              child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  margin:
                                                      const EdgeInsets.only(right: 5),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6.0),
                                                    child: Image.asset(
                                                        'assets/images/assigned_district.png',
                                                        width: 24,
                                                        height: 24),
                                                  )),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 7,
                                                  ),
                                                  const Text("Assigned Districts",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                          _assignedDistricts!,
                                                          maxLines:
                                                              _districtExpand
                                                                  ? 8
                                                                  : 2,
                                                          textAlign: TextAlign
                                                              .start),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _districtExpand =
                                                                !_districtExpand;
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  right:
                                                                      15.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: <
                                                                Widget>[
                                                              _assignedDistricts ==
                                                                      "All"
                                                                  ? const Text('')
                                                                  : _districtExpand
                                                                      ? const Text(
                                                                          "Show Less",
                                                                          style:
                                                                              TextStyle(color: Colors.blue),
                                                                        )
                                                                      : const Text(
                                                                          "Show More",
                                                                          style:
                                                                              TextStyle(color: Colors.blue))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Center(
                                              child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  margin:
                                                      const EdgeInsets.only(right: 5),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6.0),
                                                    child: Image.asset(
                                                        'assets/images/assigned_mandals.png',
                                                        width: 24,
                                                        height: 24),
                                                  )),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 7,
                                                  ),
                                                  const Text("Assigned Mandals",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(_assignedMandals!,
                                                          maxLines:
                                                              _mandalExpand
                                                                  ? 8
                                                                  : 2,
                                                          textAlign: TextAlign
                                                              .start),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _mandalExpand =
                                                                !_mandalExpand;
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  right:
                                                                      15.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: <
                                                                Widget>[
                                                              _assignedMandals ==
                                                                      "All"
                                                                  ? const Text('')
                                                                  : _mandalExpand
                                                                      ? const Text(
                                                                          "Show Less",
                                                                          style:
                                                                              TextStyle(color: Colors.blue),
                                                                        )
                                                                      : const Text(
                                                                          "Show More",
                                                                          style:
                                                                              TextStyle(color: Colors.blue))
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Center(
                                              child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  margin:
                                                      const EdgeInsets.only(right: 5),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(6.0),
                                                    child: Image.asset(
                                                        'assets/images/assigned_service_desk.png',
                                                        width: 24,
                                                        height: 24),
                                                  )),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 7,
                                                  ),
                                                  const Text('Assigned Service Desk',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                          child: Text(
                                                              _assignedServiceDesk!))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[400]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 3, right: 3, top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Padding(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Text(
                                              "Nila",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15, top: 2),
                                          child: RatingBar.builder(
                                            itemSize: 26,
                                            initialRating: _rating,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemPadding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            itemBuilder: (context, _) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              if (kDebugMode) {
                                                print(rating);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Stack(
                                      children: <Widget>[
                                        ClipOval(
                                          child: image == null
                                              ? const CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                      'assets/images/user_image.png'),
                                                  radius: 50.0,
                                                )
                                              : CircleAvatar(
                                                  backgroundImage:
                                                      FileImage(image!),
                                                  radius: 50.0,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Center(
                                            child: Container(
                                                width: 50,
                                                height: 50,
                                                margin:
                                                    const EdgeInsets.only(right: 5),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons.person_rounded,
                                                    size: 30,
                                                  ),
                                                )),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                const SizedBox(
                                                  height: 7,
                                                ),
                                                const Text("Full Name",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: const <Widget>[
                                                    Text("Nila"),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Center(
                                            child: Container(
                                                width: 50,
                                                height: 50,
                                                margin:
                                                    const EdgeInsets.only(right: 5),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons.email_outlined,
                                                    size: 30,
                                                  ),
                                                )),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                const SizedBox(
                                                  height: 7,
                                                ),
                                                const Text("Email",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: const <Widget>[
                                                    Text(
                                                        "sureka1@mailinator.com"),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Center(
                                            child: Container(
                                                width: 50,
                                                height: 50,
                                                margin:
                                                    const EdgeInsets.only(right: 5),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons.call,
                                                    size: 30,
                                                  ),
                                                )),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                const SizedBox(
                                                  height: 7,
                                                ),
                                                const Text("Mobile no",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: const <Widget>[
                                                    Text("9999999999"),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Center(
                                            child: Container(
                                                width: 50,
                                                height: 50,
                                                margin:
                                                    const EdgeInsets.only(right: 5),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons.location_on_outlined,
                                                    size: 30,
                                                  ),
                                                )),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                const SizedBox(
                                                  height: 7,
                                                ),
                                                const Text("Address",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: const <Widget>[
                                                    Flexible(
                                                      child: Text(
                                                          "kandhanchavadi",
                                                          overflow: TextOverflow
                                                              .visible),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Center(
                                            child: Container(
                                                width: 50,
                                                height: 50,
                                                margin:
                                                    const EdgeInsets.only(right: 5),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons.location_city,
                                                    size: 30,
                                                  ),
                                                )),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                const SizedBox(
                                                  height: 7,
                                                ),
                                                const Text("Work Location",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: const <Widget>[
                                                    Flexible(
                                                        child: Text(
                                                      "kandhanchavadi",
                                                      overflow:
                                                          TextOverflow.visible,
                                                    )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ))),
        ),
      ),
    );
  }

  void setDetails(BuildContext context) async {
    _getToken = PreferenceUtils.getString(MyConstants.token);
    _getTechnicianCode = PreferenceUtils.getString(MyConstants.technicianCode);
  }

  void getDetails(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      setDetails(context);
      ApiService apiService = ApiService(dio.Dio());
      final response =
          await apiService.getProfileDetails(_getToken!, _getTechnicianCode!);
      switch (response.response!.responseCode) {
        case "200":
          {
            setState(() {
              PreferenceUtils.setString(
                  MyConstants.token, response.response!.token!);
              _name = capitalize(response.response!.data!.fullName!);
              _email = response.response!.data!.emailId;
              _contactNumber = response.response!.data!.contactNumber;

              if (response.response!.data!.assignedState
                      .toString()
                      .replaceAll('[', '')
                      .replaceAll(']', '') ==
                  "All") {
                _assignedSte = "All";
                _assignedDistricts = "All";
                _assignedMandals = "All";
              } else if (response.response!.data!.assignedCity
                      .toString()
                      .replaceAll('[', '')
                      .replaceAll(']', '') ==
                  "All") {
                _assignedSte = response.response!.data!.assignedState
                    .toString()
                    .replaceAll('[', '')
                    .replaceAll(']', '');
                _assignedDistricts = "All";
                _assignedMandals = "All";
              } else if (response.response!.data!.assignedLocation
                      .toString()
                      .replaceAll('[', '')
                      .replaceAll(']', '') ==
                  "All") {
                _assignedSte = response.response!.data!.assignedState
                    .toString()
                    .replaceAll('[', '')
                    .replaceAll(']', '');
                _assignedDistricts = response.response!.data!.assignedCity
                    .toString()
                    .replaceAll('[', '')
                    .replaceAll(']', '');
                _assignedMandals = "All";
              } else {
                _assignedSte = response.response!.data!.assignedState
                    .toString()
                    .replaceAll('[', '')
                    .replaceAll(']', '');
                _assignedDistricts = response.response!.data!.assignedCity
                    .toString()
                    .replaceAll('[', '')
                    .replaceAll(']', '');
                _assignedMandals = response.response!.data!.assignedLocation
                    .toString()
                    .replaceAll('[', '')
                    .replaceAll(']', '');
              }
              _assignedServiceDesk = response
                  .response!.data!.assignedServiceDesk!.assignedServiceDeskName;
              _rating = response.response!.data!.technicianRating!.toDouble();
              PreferenceUtils.setString(
                  MyConstants.technicianStatus, MyConstants.free);
              if (response.response!.data!.profilePic != null) {
                _profilePicture =
                    MyConstants.baseurl + response.response!.data!.profilePic!;
                PreferenceUtils.setString(MyConstants.profilePicture,
                    response.response!.data!.profilePic!);
              }
              _enabled = false;
            });
            break;
          }
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> uploadProfilePhoto(String s, BuildContext context) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      setDetails(context);

      final Map<String, dynamic> data = {
        'technician_code': _getTechnicianCode,
        'profile_pic': MyConstants.base64 + s
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.uploadImage(_getToken!, data);
      if (response.changePasswordEntity!.responseCode == "200") {
        setState(() {
          setToastMessage(context, response.changePasswordEntity!.message!);
          PreferenceUtils.setString(
              MyConstants.token, response.changePasswordEntity!.token!);
          getDetails(context);
          Navigator.of(context, rootNavigator: true).pop();
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }
}
