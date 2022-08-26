import 'dart:io';

import 'package:fieldpro_genworks_healthcare/utility/shared_preferences.dart';
import 'package:fieldpro_genworks_healthcare/utility/store_strings.dart';
import 'package:fieldpro_genworks_healthcare/utility/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as pl;
import 'package:dio/dio.dart' as dio;
import 'package:permission_handler/permission_handler.dart';

import '../network/api_services.dart';
import '../screens/dashboard_bottom_sheet.dart';
import '../screens/profile.dart';

pl.Location location = pl.Location();
double? latitude, longitude;
String? _currentLocation;
bool ratingStatus = false;
Position? currentLocation, position;
final _controller = PageController();
const _kDuration = Duration(milliseconds: 300);
const _kCurve = Curves.ease;
final _kArrowColor = Colors.black.withOpacity(0.8);
final List<Widget> _pages = <Widget>[
  ConstrainedBox(
    constraints: const BoxConstraints.expand(),
    child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 2 / 1,
        children: List.generate(choices.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Center(
              child: ChoiceCard(choice: choices[index]),
            ),
          );
        })),
  ),
  ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 2 / 1,
          children: List.generate(choices1.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Center(
                child: ChoiceCard(choice: choices1[index]),
              ),
            );
          }))),
];

Future<void> technicianPunchIn(
    BuildContext context, StateSetter myState) async {
  if (await checkInternetConnection() == true) {
    setToastMessageLoading(context);

    position = await _getGeoLocationPosition(context, myState);

    if (Platform.isIOS) {
      showAlertDialog(context);
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          position!.latitude, position!.longitude);
      Placemark place = placeMarks[0];
      _currentLocation =
      '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

      final Map<String, dynamic> loginData = {
        'technician_code':
        PreferenceUtils.getString(MyConstants.technicianCode),
        'current_location': _currentLocation,
        'current_lat': position!.latitude,
        'current_long': position!.longitude
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.technicianPunchIn(
          PreferenceUtils.getString(MyConstants.token), loginData);

      if (response.response!.responseCode == MyConstants.response200) {
        myState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.response!.token!);
          PreferenceUtils.setInteger(
              MyConstants.attendanceId, response.response!.attendenceId!);
          PreferenceUtils.setInteger(
              MyConstants.punchStatus, response.response!.punchStatus!);
          ratingStatus = true;
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, response.response!.message!);
        });
      }
    }
    else {
      // Using Permission Handler Package
      if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
        showAlertDialog(context);
        List<Placemark> placeMarks = await placemarkFromCoordinates(
            position!.latitude, position!.longitude);
        Placemark place = placeMarks[0];
        _currentLocation =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

        final Map<String, dynamic> loginData = {
          'technician_code':
          PreferenceUtils.getString(MyConstants.technicianCode),
          'current_location': _currentLocation,
          'current_lat': position!.latitude,
          'current_long': position!.longitude
        };

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.technicianPunchIn(
            PreferenceUtils.getString(MyConstants.token), loginData);

        if (response.response!.responseCode == MyConstants.response200) {
          myState(() {
            PreferenceUtils.setString(
                MyConstants.token, response.response!.token!);
            PreferenceUtils.setInteger(
                MyConstants.attendanceId, response.response!.attendenceId!);
            PreferenceUtils.setInteger(
                MyConstants.punchStatus, response.response!.punchStatus!);
            ratingStatus = true;
            Navigator.of(context, rootNavigator: true).pop();
            setToastMessage(context, response.response!.message!);
          });
        }
      }
    }
  } else {
    setToastMessage(context, MyConstants.internetConnection);
  }
}

Future<Position> _getGeoLocationPosition(
    BuildContext context, StateSetter myState) async {
  LocationPermission permission;
  Position? locationStatus;

  await Permission.location.request();

  if (Platform.isIOS) {
    bool serviceEnabled;

    var permissionGranted = await location.hasPermission();
    serviceEnabled = await location.serviceEnabled();

    if(!serviceEnabled){
      serviceEnabled = await location.requestService();
    } else {
      if (permissionGranted != pl.PermissionStatus.granted) {
        openAppSettings();
        technicianPunchIn(context, myState);
      } else {
        locationStatus = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      }
    }
  } else if (Platform.isAndroid) {
    // Test if location services are enabled.
    var permissionGranted = await location.hasPermission();

    if (permissionGranted == pl.PermissionStatus.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // print('calling one time');
        // technicianPunchIn(context, myState);
      } else {
        technicianPunchIn(context, myState);
      }
    } else if (permissionGranted == pl.PermissionStatus.granted) {
      locationStatus = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }
  }

  return locationStatus!;
}

Future<void> technicianPunchOut(
    BuildContext context, StateSetter myState) async {
  if (await checkInternetConnection() == true) {
    showAlertDialog(context);
    final Map<String, dynamic> punchOutData = {
      'attendence_id': PreferenceUtils.getInteger(MyConstants.attendanceId)
    };

    ApiService apiService = ApiService(dio.Dio());
    final response = await apiService.technicianPunchOut(
        PreferenceUtils.getString(MyConstants.token), punchOutData);
    if (response.response!.responseCode == MyConstants.response200) {
      myState(() {
        PreferenceUtils.setString(MyConstants.token, response.response!.token!);
        PreferenceUtils.setInteger(
            MyConstants.punchStatus, response.response!.punchStatus!);
        ratingStatus = false;
        Navigator.of(context, rootNavigator: true).pop();
        setToastMessage(context, response.response!.message!);
      });
    }
  } else {
    setToastMessage(context, MyConstants.internetConnection);
  }
}

void dashBoardBottomSheet(BuildContext context, bool ratingStatus) {
  String? profileImage = PreferenceUtils.getString(MyConstants.profilePicture);
  ratingStatus = ratingStatus;
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter myState) {
              return Container(
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/menu_bg_drawable.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 3, right: 3, top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileTechnician())),
                            child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: SizedBox(
                                  width: 51.25,
                                  height: 51.25,
                                  child: ClipOval(
                                      child: profileImage.isEmpty
                                          ? ClipOval(
                                        child: Image.asset(
                                            'assets/images/user_image.png'),
                                      )
                                          : Image.network(
                                        MyConstants.baseurl + profileImage,
                                        fit: BoxFit.cover,
                                        width: 51.25,
                                        height: 51.25,
                                        loadingBuilder: (BuildContext context,
                                            Widget? child,
                                            ImageChunkEvent?
                                            loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child!;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
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
                                      )),
                                )),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  PreferenceUtils.getString(MyConstants.name),
                                  style:
                                  const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: FlutterSwitch(
                              activeColor: Color(int.parse("0xfff" "4a777c")),
                              value: ratingStatus,
                              borderRadius: 15.0,
                              height: 30.0,
                              showOnOff: true,
                              onToggle: (bool value) {
                                myState(() {
                                  if (ratingStatus == false) {
                                    ratingStatus = value;
                                    technicianPunchIn(context, myState);
                                  } else {
                                    ratingStatus = value;
                                    technicianPunchOut(context, myState);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: IconTheme(
                        data: IconThemeData(color: _kArrowColor),
                        child: Stack(
                          children: <Widget>[
                            PageView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: _controller,
                              itemBuilder: (BuildContext context, int index) {
                                return _pages[index % _pages.length];
                              },
                            ),
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              child: Container(
                                padding: const EdgeInsets.all(20.0),
                                child: Center(
                                  child: DotsIndicator(
                                    controller: _controller,
                                    itemCount: _pages.length,
                                    onPageSelected: (int page) {
                                      _controller.animateToPage(
                                        page,
                                        duration: _kDuration,
                                        curve: _kCurve,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      });
}