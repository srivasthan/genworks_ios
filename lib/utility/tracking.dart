import 'dart:math';

import 'package:fieldpro_genworks_healthcare/utility/shared_preferences.dart';
import 'package:fieldpro_genworks_healthcare/utility/store_strings.dart';
import 'package:fieldpro_genworks_healthcare/utility/validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as pl;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart' as dio;

import '../network/api_services.dart';

pl.Location location = pl.Location();
double? latitude, longitude;
var uuid = const Uuid();

Future<void> technicianTracking(String? ticketId) async {
  if (await checkInternetConnection() == true) {
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double? previousLatitude =
            PreferenceUtils.getDouble('previous_latitude');
        double? previousLongitude =
            PreferenceUtils.getDouble('previous_longitude');
        latitude = position.latitude;
        longitude = position.longitude;
        String currentStatus = PreferenceUtils.getString("technician_status");
        PreferenceUtils.setDouble('previous_latitude', position.latitude);
        PreferenceUtils.setDouble('previous_longitude', position.longitude);

        var speed = position.speed * 2.2369;
        var distance = calculateDistance(
            previousLatitude, previousLongitude, latitude, longitude);
        List<Placemark> placeMarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placeMarks[0];
        String? currentAddress = place.subLocality;

        String queryString = "Current_location=${currentAddress!}&Current_status=$currentStatus&accuracy=${(position.accuracy * 3.28).toInt()}&direction=${(position.heading).toInt()}&phonenumber=''&sessionid=${uuid.v4()}&speed=${speed.toInt()}&technician_code=${PreferenceUtils.getString('technician_code')}&technician_name=${PreferenceUtils.getString('name').replaceAll(" ", "")}&ticket_id=${ticketId!}&distance=${distance * 1000}&latitude=${position.latitude}&longitude=${position.longitude}";

        ApiService apiService = ApiService(dio.Dio());

        final response =
            await apiService.technicianTracking(queryString: queryString);

        if (response.trackerEntity!.responseCode == MyConstants.response200) {
          if (kDebugMode) {
            print(response.trackerEntity!.message);
          }
        } else {
          if (kDebugMode) {
            print('Tracking Error');
          }
        }
      } on PlatformException catch (err) {
        if (kDebugMode) {
          print("Platform exception calling serviceEnabled(): $err");
        }
      }
    }
  }
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

String distance(
    double lat1, double lon1, double lat2, double lon2, String unit) {
  double theta = lon1 - lon2;
  double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +
      cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
  dist = acos(dist);
  dist = rad2deg(dist);
  dist = dist * 60 * 1.1515;
  if (unit == 'K') {
    dist = dist * 1.609344;
  } else if (unit == 'N') {
    dist = dist * 0.8684;
  }
  return dist.toStringAsFixed(2);
}

double deg2rad(double deg) {
  return (deg * pi / 180.0);
}

double rad2deg(double rad) {
  return (rad * 180.0 / pi);
}
