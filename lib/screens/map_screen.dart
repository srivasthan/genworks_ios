import 'dart:convert';
import 'dart:io';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui' as ui;
import 'package:location/location.dart' as prefixLocation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fieldpro_genworks_healthcare/network/Response/google_direction_results.dart';
import 'package:fieldpro_genworks_healthcare/network/api_services.dart';
import 'package:fieldpro_genworks_healthcare/network/db/app_database.dart';
import 'package:fieldpro_genworks_healthcare/network/db/direction_details.dart';
import 'package:fieldpro_genworks_healthcare/network/db/direction_details_dao.dart';
import 'package:fieldpro_genworks_healthcare/network/db/ticket_for_the_day.dart';
import 'package:fieldpro_genworks_healthcare/screens/amc_ticket_details.dart';
import 'package:fieldpro_genworks_healthcare/screens/file_directory.dart';
import 'package:fieldpro_genworks_healthcare/screens/show_image.dart';
import 'package:fieldpro_genworks_healthcare/screens/start_ticket.dart';
import 'package:fieldpro_genworks_healthcare/screens/ticket_list.dart';
import 'package:fieldpro_genworks_healthcare/utility/shared_preferences.dart';
import 'package:fieldpro_genworks_healthcare/utility/store_strings.dart';
import 'package:fieldpro_genworks_healthcare/utility/validator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

///created by srivasthan
///modified by sharubala
///changes suggested by senthilkumar

class MapView extends StatefulWidget {
  final double? destinationLatitude, destinationLongitude;
  final String? ticketId, priority, location, screenType, status;
  final int? ticketType;

  const MapView(
      this.destinationLatitude,
      this.destinationLongitude,
      this.ticketId,
      this.priority,
      this.location,
      this.status,
      this.ticketType,
      this.screenType);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialLocation = const CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController? mapController;
  File? image, capturedImage;
  bool? _showLocationAlert = false, _showDoneAlert = true, _reachedClicked = false;

  late Position _currentPosition;
  String? showInfoWindow;
  late BitmapDescriptor spoint, dpoint;
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();
  String? _selectedMode;
  bool _showReachButton = false, _showBottomSheet = false, _showTick = false;
  TextEditingController _travelCostController = TextEditingController();

  Set<Marker> markers = {};
  String? _startAddress, _destinationAddress, _time, _distance, encImageBase64;

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polyLines = {};
  Set<Polyline> _directionPolyline = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
  }

  // Method for retrieving the current location
  _getCurrentLocation(BuildContext context) async {
    showAlertDialog(context);
    if (widget.status == MyConstants.accepted ||
        widget.status == MyConstants.spareDelivered ||
        widget.status == MyConstants.workInProgress) {
      _showBottomSheet = true;
    } else if (widget.status == MyConstants.travelStarted ||
        widget.status == MyConstants.reached) {
      _showReachButton = true;
    }

    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
      });
      await _showMap();
    }).catchError((e) {
      print(e);
    });
  }

  _showMap() async {
    startAddressFocusNode.unfocus();
    desrinationAddressFocusNode.unfocus();
    setState(() {
      if (markers.isNotEmpty) markers.clear();
      if (polyLines.isNotEmpty) polyLines.clear();
      if (polylineCoordinates.isNotEmpty) polylineCoordinates.clear();
    });
    _calculateDistance(context);
  }

  // Method for calculating the distance between two places
  Future<void> _calculateDistance(BuildContext context) async {
    try {
      double startLatitude = _currentPosition.latitude;

      double startLongitude = _currentPosition.longitude;

      double destinationLatitude = widget.destinationLatitude!;
      double destinationLongitude = widget.destinationLongitude!;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      showInfoWindow = startCoordinatesString;
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Create storage
      final storage = const FlutterSecureStorage();

      // Write value
      await storage.write(
          key: MyConstants.mapKey,
          value: 'AIzaSyDvBBdsJ6qNhhxB8m3skN7X4UN_ec5djr8');

      //Read value
      String? mapKey = await storage.read(key: MyConstants.mapKey);

      // Accommodate the two locations within the
      // camera view of the map
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          175.0,
        ),

      );

      final database =
      await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final directionDetailsDao = database.directionDetailsDao;

      var directionDetails = await directionDetailsDao
          .findDirectionDetailsTableByTicketId(widget.ticketId!);

      if (directionDetails.length > 0) {
        setToastMessage(context, "Direction from database");

        _startAddress = directionDetails[0].startAddress;
        _destinationAddress = directionDetails[0].endAddress;
        _time = directionDetails[0].duration;
        _distance = directionDetails[0].distance;
      } else {
        setToastMessage(context, "Direction from api");

        Map<String, String> queryParams = {
          'origin': "${_currentPosition.latitude.toStringAsFixed(6)},${_currentPosition.longitude.toStringAsFixed(6)}",
          'destination': "$destinationLatitude,$destinationLongitude",
          'region': 'es',
          'key': mapKey!
        };

        String queryString = Uri(queryParameters: queryParams).query;
        final Response<Map<String, dynamic>> result = await Dio().request(
            'https://maps.googleapis.com/maps/api/directions/json?$queryString',
            queryParameters: <String, dynamic>{},
            options: Options(
                method: 'GET',
                headers: <String, dynamic>{},
                extra: <String, dynamic>{}));

        final value = DirectionResults.fromJson(result.data!);

        _startAddress = value.routes![0]!.legs![0]!.startAddress;
        _destinationAddress = value.routes![0]!.legs![0]!.endAddress;
        _time = value.routes![0]!.legs![0]!.duration!.text!;
        _distance = value.routes![0]!.legs![0]!.distance!.text!;

        DirectionDetailsTable directionDetailsTable = DirectionDetailsTable(
            distance: _distance,
            duration: _time,
            startAddress: _startAddress,
            endAddress: _destinationAddress,
            ticketId: widget.ticketId);
        directionDetailsDao.insertDirectionDetailsTable(directionDetailsTable);
      }

      final Uint8List smarkerIcon =
      await getBytesFromAsset('assets/images/spoint.png', 100);
      final Uint8List dmarkerIcon =
      await getBytesFromAsset('assets/images/dpoint.png', 100);

      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: widget.status != MyConstants.travelStarted
            ? InfoWindow(
            title: 'DISTANCE: ${_distance!}',
            snippet: 'Time: ${_time!}',
            onTap: () => _travelPlanAlert(context))
            : const InfoWindow(),
        icon: BitmapDescriptor.fromBytes(smarkerIcon),
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: widget.status != MyConstants.travelStarted
            ? InfoWindow(
            title: 'DISTANCE: ${_distance!}',
            snippet: 'Time: ${_time!}',
            onTap: () => _travelPlanAlert(context))
            : const InfoWindow(),
        icon: BitmapDescriptor.fromBytes(dmarkerIcon),
      );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude, directionDetailsDao, mapKey);

      setState(() {});

      markers.add(startMarker);
      markers.add(destinationMarker);

      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      print(e);
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // Create the polylines for showing the route between two places
  _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      DirectionDetailsDao directionDetailsDao,
      String? mapKey,
      ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      mapKey!, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.indigo,
      points: polylineCoordinates,
      width: 3,
    );
    polyLines[id] = polyline;
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const TicketList(2)));
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // pushPage(context);
        return false;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TicketList(2))),
            ),
            title: const Text(MyConstants.travelPlan),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: Stack(
            children: <Widget>[
              // Map View
              GoogleMap(
                markers: Set<Marker>.from(markers),
                initialCameraPosition: _initialLocation,
                myLocationButtonEnabled: false,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                minMaxZoomPreference: const MinMaxZoomPreference(5,10),
                polylines: Set<Polyline>.of(polyLines.values),
                onMapCreated: (GoogleMapController controller) async {
                  mapController = controller;

                  if (Platform.isIOS) {
                    await Permission.location.request();
                    prefixLocation.Location location =
                    prefixLocation.Location();
                    var permissionGranted = await location.hasPermission();

                    if (permissionGranted !=
                        prefixLocation.PermissionStatus.granted) {
                      showAlert(context);
                      setState(() {
                        _showLocationAlert = true;
                      });
                    } else {
                      _getCurrentLocation(context);
                    }
                  } else if (Platform.isAndroid) {
                    _getCurrentLocation(context);
                  }
                },
              ),
              // Show zoom buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: Colors.blue.shade100, // button color
                          child: InkWell(
                            splashColor: Colors.blue, // inkwell color
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.add),
                            ),
                            onTap: () {
                              mapController!.animateCamera(
                                CameraUpdate.zoomIn(),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipOval(
                        child: Material(
                          color: Colors.blue.shade100, // button color
                          child: InkWell(
                            splashColor: Colors.blue, // inkwell color
                            child: const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.remove),
                            ),
                            onTap: () {
                              mapController!.animateCamera(
                                CameraUpdate.zoomOut(),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Show the place input fields & button for
              // showing the route
              // Show current location button
              SafeArea(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                    child: ClipOval(
                      child: Material(
                        color: Colors.orange.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.orange, // inkwell color
                          child: const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.my_location),
                          ),
                          onTap: () {
                            mapController!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    _currentPosition.latitude,
                                    _currentPosition.longitude,
                                  ),
                                  zoom
                                      : 8.0,///value changed
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _showBottomSheet,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          onTap: () {
                            mapController!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    _currentPosition.latitude,
                                    _currentPosition.longitude,
                                  ),
                                  zoom: 10.0,///value changed
                                ),
                              ),
                            );
                            mapController!.showMarkerInfoWindow(
                                MarkerId(showInfoWindow!));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                flex: 0,
                                child: Row(
                                  children: [
                                    const Expanded(
                                        flex: 0,
                                        child: Text(
                                          "${MyConstants.ticketId}   :",
                                          style: TextStyle(fontSize: 14.0),///font size changed
                                        )),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15.0),
                                          child: Text(
                                            widget.ticketId!,
                                            style: const TextStyle(fontSize: 14.0),///font size changed
                                          ),
                                        )),
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
                                    const Expanded(
                                        flex: 0,
                                        child: Text(
                                          "${MyConstants.priority}      :",
                                          style: TextStyle(fontSize: 14.0),///font size changed
                                        )),
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15.0),
                                          child: Text(
                                            widget.priority!,
                                            style: const TextStyle(fontSize: 14.0),///font size changed
                                          ),
                                        )),
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
                                    const Expanded(
                                        flex: 0,
                                        child: Text(
                                          "${MyConstants.location}   :",
                                          style: TextStyle(fontSize: 14.0),///font size changed
                                        )),
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15.0),
                                          child: Text(
                                            widget.location!,
                                            style: const TextStyle(fontSize: 14.0),///font size changed
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
              ),
              Visibility(
                visible: _showReachButton,
                child: _reachedClicked == false ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if(_reachedClicked == true) {
                                setToastMessage(context, MyConstants.requestAlready);
                              } else {
                                onReachedTechnician(context);
                              }
                              _reachedClicked = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8.0),
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0)///Button size changed
                                ),
                              ), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                          child: const Text(MyConstants.reachedButton,
                              style:
                              TextStyle(fontSize: 15, color: Colors.white)),
                        ),
                      )),
                ) : Container(),
              )
            ],
          )
      )
    );
  }

  _travelPlanAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: const Center(child: Text(MyConstants.chooseModeOfTransport)),
              content: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(
                        height: 15.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMode = MyConstants.walk;
                            startTicketPostApi(
                                _currentPosition.latitude,
                                _currentPosition.longitude,
                                MyConstants.walk,
                                context);
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.walk,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.walk,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = MyConstants.walk;
                                      startTicketPostApi(
                                          _currentPosition.latitude,
                                          _currentPosition.longitude,
                                          MyConstants.walk,
                                          context);
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
                            _selectedMode = MyConstants.twoWheeler;
                            startTicketPostApi(
                                _currentPosition.latitude,
                                _currentPosition.longitude,
                                MyConstants.twoWheeler,
                                context);
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.twoWheeler,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.twoWheeler,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = MyConstants.twoWheeler;
                                      startTicketPostApi(
                                          _currentPosition.latitude,
                                          _currentPosition.longitude,
                                          MyConstants.twoWheeler,
                                          context);
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
                            _selectedMode = MyConstants.fourWheeler;
                            startTicketPostApi(
                                _currentPosition.latitude,
                                _currentPosition.longitude,
                                MyConstants.fourWheeler,
                                context);
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.fourWheeler,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.fourWheeler,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = MyConstants.fourWheeler;
                                      startTicketPostApi(
                                          _currentPosition.latitude,
                                          _currentPosition.longitude,
                                          MyConstants.fourWheeler,
                                          context);
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
                            _selectedMode = MyConstants.cab;
                            startTicketPostApi(
                                _currentPosition.latitude,
                                _currentPosition.longitude,
                                MyConstants.cab,
                                context);
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.cab,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.cab,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = MyConstants.cab;
                                      startTicketPostApi(
                                          _currentPosition.latitude,
                                          _currentPosition.longitude,
                                          MyConstants.cab,
                                          context);
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
                            _selectedMode = MyConstants.publicTransport;
                            startTicketPostApi(
                                _currentPosition.latitude,
                                _currentPosition.longitude,
                                MyConstants.publicTransport,
                                context);
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.publicTransport,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.publicTransport,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode =
                                          MyConstants.publicTransport;
                                      startTicketPostApi(
                                          _currentPosition.latitude,
                                          _currentPosition.longitude,
                                          MyConstants.publicTransport,
                                          context);
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
                              onTap: () {
                                Navigator.of(context, rootNavigator: true).pop();
                                // Navigator.of(context, rootNavigator: true).pop();
                              },
                              child: Text(
                                MyConstants.cancelButton,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color:
                                    Color(int.parse("0xfff" "507a7d"))),
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

  Future<void> startTicketPostApi(double? latitude, double? longitude,
      String? value, BuildContext context) async {
    if (await checkInternetConnection() == true) {
      Navigator.of(context, rootNavigator: true).pop();
      // Navigator.of(context, rootNavigator: true).pop();
      setToastMessageLoading(context);

      final database =
      await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final ticketForTheDayDao = database.ticketForTheDayDao;

      Map<String, dynamic> startTravelData = {
        'destination': _destinationAddress,
        'estimated_time': _time,
        'mode_of_travel': value,
        'no_of_km_travelled': _distance,
        'source': _startAddress,
        'source_lat': latitude,
        'source_long': longitude,
        'technician_code':
        PreferenceUtils.getString(MyConstants.technicianCode),
        'ticket_id': widget.ticketId
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.fieldProstarttravel(
          PreferenceUtils.getString(MyConstants.token), startTravelData);
      if (response.transferResponseEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          _showReachButton = true;
          _showBottomSheet = false;
          PreferenceUtils.setString(
              MyConstants.token, response.transferResponseEntity!.token!);
          ticketForTheDayDao.updateTravelPlanTicketData(
              value!, widget.ticketId!);
        });
      }
      else if (response.transferResponseEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.transferResponseEntity!.token!);
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> onReachedTechnician(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      setToastMessageLoading(context);

      final database =
      await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final ticketForTheDayDao = database.ticketForTheDayDao;
      List<TicketForTheDayTable> ticketForTheDayAccess =
      await ticketForTheDayDao
          .findTicketForTheDayByTicketId(widget.ticketId!);

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getDistance(
          _currentPosition.latitude.toString(),
          _currentPosition.longitude.toString(),
          widget.destinationLatitude.toString(),
          widget.destinationLongitude.toString());

      if (response.getDistanceEntity!.responseCode == MyConstants.response200) {

        if(response.getDistanceEntity!.flag == 0) {
          setState(() {
            if (ticketForTheDayAccess[0].travelPlanTransport ==
                MyConstants.cab ||
                ticketForTheDayAccess[0].travelPlanTransport ==
                    MyConstants.publicTransport) {
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      type: ArtSweetAlertType.warning,
                      title: MyConstants.appTittle,
                      text: MyConstants.updateTravel,
                      showCancelBtn: true,
                      confirmButtonText: MyConstants.nowButton,
                      cancelButtonText: MyConstants.laterButton,
                      onConfirm: () {
                        setState(() {
                          Navigator.of(context, rootNavigator: true)
                              .pop();
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return travelCostBottomSheet(
                                    context,
                                    _startAddress,
                                    _destinationAddress,
                                    _distance,
                                    _time,
                                    ticketForTheDayAccess[0]
                                        .travelPlanTransport);
                              });
                        });
                      },
                      onCancel: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop();
                        endTravelPostApi(MyConstants.noButton);
                      },
                      cancelButtonColor:
                      Color(int.parse("0xfff" + "C5C5C5")),
                      confirmButtonColor:
                      Color(int.parse("0xfff" + "507a7d"))));
            } else {
              endTravelPostApi(MyConstants.noButton);
            }
          });
        }
        else {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.warning,
                  title: MyConstants.appTittle,
                  text: response.getDistanceEntity!.message! +
                      MyConstants.wantToContinue,
                  showCancelBtn: true,
                  confirmButtonText: MyConstants.yesButton,
                  cancelButtonText: MyConstants.noButton,
                  onConfirm: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    setState(() {
                      if (ticketForTheDayAccess[0].travelPlanTransport ==
                          MyConstants.cab ||
                          ticketForTheDayAccess[0].travelPlanTransport ==
                              MyConstants.publicTransport) {
                        ArtSweetAlert.show(
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                                type: ArtSweetAlertType.warning,
                                title: MyConstants.appTittle,
                                text: MyConstants.updateTravel,
                                showCancelBtn: true,
                                confirmButtonText: MyConstants.nowButton,
                                cancelButtonText: MyConstants.laterButton,
                                onConfirm: () {
                                  setState(() {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return travelCostBottomSheet(
                                              context,
                                              _startAddress,
                                              _destinationAddress,
                                              _distance,
                                              _time,
                                              ticketForTheDayAccess[0]
                                                  .travelPlanTransport);
                                        });
                                  });
                                },
                                onCancel: () {

                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  endTravelPostApi(MyConstants.yesButton);
                                },
                                cancelButtonColor:
                                Color(int.parse("0xfff" + "C5C5C5")),
                                confirmButtonColor:
                                Color(int.parse("0xfff" + "507a7d"))));
                      } else {
                        endTravelPostApi(MyConstants.yesButton);
                      }
                    });
                  },
                  onCancel: () {
                    setState(() {
                      _reachedClicked = false;
                    });
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  cancelButtonColor: Color(int.parse("0xfff" + "C5C5C5")),
                  confirmButtonColor: Color(int.parse("0xfff" + "507a7d"))));
        }
      } else if (response.getDistanceEntity!.responseCode ==
          MyConstants.response400 ||
          response.getDistanceEntity!.responseCode == MyConstants.response500) {
        setState(() {
          //Navigator.of(context, rootNavigator: true).pop();
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.warning,
                  title: MyConstants.appTittle,
                  text: response.getDistanceEntity!.message! +
                      MyConstants.wantToContinue,
                  showCancelBtn: true,
                  confirmButtonText: MyConstants.yesButton,
                  cancelButtonText: MyConstants.noButton,
                  onConfirm: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    setState(() {
                      if (ticketForTheDayAccess[0].travelPlanTransport ==
                          MyConstants.cab ||
                          ticketForTheDayAccess[0].travelPlanTransport ==
                              MyConstants.publicTransport) {
                        ArtSweetAlert.show(
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                                type: ArtSweetAlertType.warning,
                                title: MyConstants.appTittle,
                                text: MyConstants.updateTravel,
                                showCancelBtn: true,
                                confirmButtonText: MyConstants.nowButton,
                                cancelButtonText: MyConstants.laterButton,
                                onConfirm: () {
                                  setState(() {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return travelCostBottomSheet(
                                              context,
                                              _startAddress,
                                              _destinationAddress,
                                              _distance,
                                              _time,
                                              ticketForTheDayAccess[0]
                                                  .travelPlanTransport);
                                        });
                                  });
                                },
                                onCancel: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  endTravelPostApi(MyConstants.yesButton);
                                },
                                cancelButtonColor:
                                Color(int.parse("0xfff" "C5C5C5")),
                                confirmButtonColor:
                                Color(int.parse("0xfff" "507a7d"))));
                      } else {
                        endTravelPostApi(MyConstants.yesButton);
                      }
                    });
                  },
                  onCancel: () {
                    setState(() {
                      _reachedClicked = false;
                    });
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  cancelButtonColor: Color(int.parse("0xfff" "C5C5C5")),
                  confirmButtonColor: Color(int.parse("0xfff" "507a7d"))));
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Widget travelCostBottomSheet(
      BuildContext context,
      String? startAddress,
      String? destinationAddress,
      String? distance,
      String? time,
      String travelPlanTransport) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter myState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                                  MyConstants.travelCost,
                                  style: TextStyle(fontSize: 13.0, color: Colors.white),
                                ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _reachedClicked = false;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                    ))
                              ],
                            ))),
                    Container(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(mainAxisSize: MainAxisSize.min, children: <
                            Widget>[
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: [
                              const Padding(padding: EdgeInsets.all(5.0)),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Text(MyConstants.origin,
                                        style: TextStyle(
                                            fontSize: 13.0)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 0, child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(':',
                                      style: TextStyle(
                                          fontSize: 13.0)),
                                ],
                              )),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text(startAddress!,
                                          style: const TextStyle(fontSize: 13.0)),
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
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Text(MyConstants.destination,
                                        style: TextStyle(
                                            fontSize: 13.0)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 0, child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(':',
                                      style: TextStyle(
                                          fontSize: 13.0)),
                                ],
                              )),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text(destinationAddress!,
                                          style: const TextStyle(fontSize: 13.0)),
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
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Text(MyConstants.travelDistance,
                                        style: TextStyle(
                                          fontSize: 13.0,)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 0, child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(':',
                                      style: TextStyle(
                                          fontSize: 13.0)),
                                ],
                              )),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text(distance!,
                                          style: const TextStyle(fontSize: 13.0)),
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
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Text(MyConstants.travelTime,
                                        style: TextStyle(
                                            fontSize: 13.0)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 0, child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(':',
                                      style: TextStyle(
                                          fontSize: 13.0)),
                                ],
                              )),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child:
                                      Text(time!, style: const TextStyle(fontSize: 13.0)),
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
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Text(MyConstants.travelMode,
                                        style: TextStyle(
                                            fontSize: 13.0)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 0, child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(':',
                                      style: TextStyle(
                                          fontSize: 13.0)),
                                ],
                              )),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: Text(travelPlanTransport,
                                          style: const TextStyle(fontSize: 13.0)),
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
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Text(MyConstants.travelCharge,
                                        style: TextStyle(
                                            fontSize: 13.0)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 0, child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(':',
                                      style: TextStyle(
                                          fontSize: 13.0)),
                                ],
                              )),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 80.0),
                                      child: TextFormField(
                                        textInputAction: TextInputAction.done,
                                        maxLength: 5,
                                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d*')),
                                          FilteringTextInputFormatter.allow(
                                              RegExp('[0-9.,]+'))
                                        ],
                                        controller: _travelCostController,
                                        autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                            labelText: MyConstants.enterAmount,
                                            labelStyle: const TextStyle(fontSize: 13.0),
                                            isDense: true,
                                            contentPadding: const EdgeInsets.fromLTRB(10, 10, 2, 2),
                                            counterText: MyConstants.empty,
                                            border: const OutlineInputBorder()),
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
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Text('Attachment',
                                        style: TextStyle(
                                            fontSize: 13.0)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 0, child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(':',
                                      style: TextStyle(
                                          fontSize: 13.0)),
                                ],
                              )),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                              context: context,
                                              barrierColor:
                                              Colors.black.withAlpha(150),
                                              builder: (context) {
                                                return imageBottomSheet(context, myState);
                                              });
                                        },
                                        //captureImage(Myconstants.camera, myState),
                                        child: const Text(MyConstants.attachmentString,
                                            style: TextStyle(
                                                color: Colors.lightBlue, fontSize: 13.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 0,
                                child: Visibility(
                                  visible: _showTick,
                                  child: IconButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ShowImage(
                                                image: "",
                                                capturedImage: capturedImage))),
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
                            height: 20.0,
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_travelCostController.text.isEmpty)
                                  setToastMessage(context, MyConstants.travelCostError);
                                else {
                                  Navigator.of(context).pop();
                                  callTravelPlanTransportBill();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F")),
                                  minimumSize: const Size(140, 35)),
                              child: const Text(MyConstants.submitButton,
                                  style: TextStyle(fontSize: 15.0, color: Colors.white)),
                            ),
                          )
                        ]))
                  ])
            )
          );
        });
  }

  Widget imageBottomSheet(BuildContext context, StateSetter myState) {
    return Container(
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
                              onPressed: () => captureImage(MyConstants.camera, myState),
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
                            onPressed: () => captureImage(MyConstants.gallery, myState),
                            icon: const Icon(Icons.photo))),
                    const Text(MyConstants.gallery, style: TextStyle(fontSize: 15)),
                  ],
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Future<void> captureImage(String? option, StateSetter myState) async {
    var photo, status;

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
      myState(() {
        image = File(photo.path);

        List<int> imageBytes = image!.readAsBytesSync();
        encImageBase64 = base64Encode(imageBytes);
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
              print(capturedImage!.path);
            } else {
              capturedImage =
              await image!.copy('${getDirectory!.path}/${timestamp()}.png');
              print(capturedImage!.path);
            }
          });
        }
      } else if (Platform.isIOS) {
        if (option == MyConstants.camera) {
          status = await Permission.camera.request();
        } else if (option == MyConstants.gallery) {
          status = await Permission.storage.request();
        }
        Directory? directory = await getApplicationSupportDirectory();

        if (status == PermissionStatus.granted) {
          if (await _requestPermission(Permission.photos)) {
            capturedImage =
            await image!.copy('${directory.path}/${timestamp()}.png');
          }
        } else if (status == PermissionStatus.denied) {
          captureImage(option, myState);
        } else if (status == PermissionStatus.permanentlyDenied) {
          openAppSettings();
        }
      }

      //print(capturedImage!.path);

      myState(() {
        _showTick = true;
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pop();
          FocusScope.of(context).requestFocus(FocusNode());
        });
      });
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
      FocusScope.of(context).requestFocus(FocusNode());
      if(option == MyConstants.camera) {
        setToastMessage(context, MyConstants.captureImageError);
      } else {
        setToastMessage(context, MyConstants.selectImageError);
      }
    }
  }

  Future<void> endTravelPostApi(String? choice) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);
      //setToastMessageLoading(context);

      final database =
      await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final ticketForTheDayDao = database.ticketForTheDayDao;

      Map<String, dynamic> endTravelData = {
        'ticket_id': widget.ticketId,
        'technician_code':
        PreferenceUtils.getString(MyConstants.technicianCode),
        'reached_customer_location': choice == MyConstants.yesButton ? MyConstants.spareIdGetSpare : MyConstants.wareHouseId,
        'dest_lat': widget.destinationLatitude,
        'dest_long': widget.destinationLongitude
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.endTravel(
          PreferenceUtils.getString(MyConstants.token), endTravelData);
      if (response.addTransferEntity!.responseCode == MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, response.addTransferEntity!.message!);
          ticketForTheDayDao.updateTicketData(
              MyConstants.reached, widget.ticketId!);
          Future.delayed(const Duration(seconds: 1), () {
            if (widget.screenType == MyConstants.amcTypeTicket) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      AMCTicketDetails(ticketId: widget.ticketId)));
            } else if (widget.screenType == MyConstants.startTicketType) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StartTicket(
                          status: MyConstants.reached,
                          ticketId: widget.ticketId)));
            }
          });
        });
      } else if (response.addTransferEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, response.addTransferEntity!.message!);
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

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

  Future<void> callTravelPlanTransportBill() async {
    if (await checkInternetConnection() == true) {
      if(encImageBase64 != null){
        showAlertDialog(context);

        final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
        final ticketForTheDayDao = database.ticketForTheDayDao;

        var listAddress = await placemarkFromCoordinates(
            _currentPosition.latitude, _currentPosition.longitude);

        Map<String, dynamic> travelPlanData = {
          'ticket_id': widget.ticketId,
          'technician_code':
          PreferenceUtils.getString(MyConstants.technicianCode),
          'travelling_charges': _travelCostController.text,
          'attachment': encImageBase64,
          'reached_customer_location': listAddress.first.subLocality,
          'dest_lat': widget.destinationLatitude,
          'dest_long': widget.destinationLongitude
        };

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.fieldProTransportBill(
            PreferenceUtils.getString(MyConstants.token), travelPlanData);
        if (response.addTransferEntity!.responseCode == MyConstants.response200) {
          try {
            if (capturedImage != null) {
              if (await capturedImage!.exists()) {
                await capturedImage!.delete();
              }
            }
          } catch (e) {
            print(e);
          }
          setState(() {
            PreferenceUtils.setString(
                MyConstants.token, response.addTransferEntity!.token!);
            Navigator.of(context, rootNavigator: true).pop();
            setToastMessage(context, response.addTransferEntity!.message!);

            ticketForTheDayDao.updateTicketData(
                MyConstants.reached, widget.ticketId!);
            Future.delayed(const Duration(seconds: 1), () {
              if (widget.screenType == MyConstants.amcTypeTicket) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        AMCTicketDetails(ticketId: widget.ticketId)));
              } else if (widget.screenType == MyConstants.startTicketType) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StartTicket(
                            status: MyConstants.reached,
                            ticketId: widget.ticketId)));
              }
            });
          });
        } else if (response.addTransferEntity!.responseCode ==
            MyConstants.response400 ||
            response.addTransferEntity!.responseCode == MyConstants.response500) {
          setState(() {
            if (response.addTransferEntity!.responseCode ==
                MyConstants.response400) {
              PreferenceUtils.setString(
                  MyConstants.token,
                  response.addTransferEntity!.token ??
                      PreferenceUtils.getString(MyConstants.token));
            }
            setToastMessage(context, response.addTransferEntity!.message!);
            Navigator.of(context, rootNavigator: true).pop();
            Future.delayed(const Duration(seconds: 1), () {
              if (widget.screenType == MyConstants.amcTypeTicket) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        AMCTicketDetails(ticketId: widget.ticketId)));
              } else if (widget.screenType == MyConstants.startTicketType) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StartTicket(
                            status: MyConstants.reached,
                            ticketId: widget.ticketId)));
              }
            });
          });
        }
      } else {
        Fluttertoast.showToast(
            msg: MyConstants.attachmentImageError,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  showAlert(BuildContext context) {
    if (_showLocationAlert == true || _showDoneAlert == true) {
      showDialog(
          context: context,
          builder: (context) {
            return _showLocationAlert == true
                ? AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                                'Turn on your location settings in ${MyConstants.appTittle}')),
                        const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('1. Select Location')),
                        const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('2. Tap Alyways or While Using')),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: GestureDetector(
                                onTap: () {
                                  openAppSettings();
                                  setState(() {
                                    _showLocationAlert = false;
                                    _showDoneAlert = true;
                                  });
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  showAlert(context);
                                },
                                child: Text(
                                  MyConstants.settingsButton,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(
                                          int.parse("0xfff" "507a7d"))),
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 10.0,
                        )
                      ],
                    ),
                  ),
                ))
                : AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('Location services are enabled')),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: GestureDetector(
                                onTap: () {
                                  _getCurrentLocation(context);
                                  setState(() {
                                    _showDoneAlert = false;
                                  });
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Text(
                                  MyConstants.okButton,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(
                                          int.parse("0xfff" "507a7d"))),
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 10.0,
                        )
                      ],
                    ),
                  ),
                ));
          });
    }
  }
}
