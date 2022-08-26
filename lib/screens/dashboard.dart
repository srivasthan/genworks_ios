import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart' as pl;
import 'package:location/location.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../network/api_services.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/technician_punch.dart';
import '../utility/validator.dart';
import 'change_password.dart';
import 'circular_progress_view.dart';
import 'login.dart';
import 'open_paint.dart';
import 'profile.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  bool? _isLoading = true;
  var _monthlyListSize;
  String? _overAllRank, _techRewardPoints, _nextRewardPoints;
  int? _taskCount, _totalTaskCount;
  double? latitude, longitude, _percent, _nextLevelPercentage;
  pl.Location location = pl.Location();
  final List<Color> colors = <Color>[Colors.black];
  Timer? timer;
  var trackLocation = Location();

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();

    Future.delayed(Duration.zero, () {
      getToken(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: MaterialApp(
        home: Stack(
          children: <Widget>[
            Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(MyConstants.dashBoard,
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Color(int.parse("0xfff" "507a7d")),
                actions: [
                  Theme(
                    data: Theme.of(context).copyWith(
                        dividerColor: Colors.white,
                        iconTheme: const IconThemeData(color: Colors.white)),
                    child: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                            value: 1,
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text("Profile")
                              ],
                            )),
                        PopupMenuItem<int>(
                            value: 2,
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.phonelink_lock,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text("Change Password")
                              ],
                            )),
                        PopupMenuItem<int>(
                            value: 3,
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.logout,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text("Logout")
                              ],
                            )),
                      ],
                      onSelected: (item) => selectedItem(context, item),
                    ),
                  ),
                ],
              ),
              body: _isLoading == true
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[400]!,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 0,
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: Color(int.parse(
                                                  "0xfff" "5C7E7F")),
                                              borderRadius: BorderRadius.zero),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, right: 15.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: const <Widget>[
                                                  Text(
                                                    MyConstants.todayActivity,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    "0/0",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ))),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      CircularProgressView(90),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      const Text(MyConstants.timeToBegin),
                                      const SizedBox(
                                        height: 20.0,
                                      )
                                    ],
                                  )),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Expanded(
                              flex: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 0,
                                      child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: Color(int.parse(
                                                  "0xfff" "5C7E7F")),
                                              borderRadius: BorderRadius.zero),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, right: 15.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: const <Widget>[
                                                  Text(
                                                    MyConstants.todayActivity,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    MyConstants.overAllRank +
                                                        "1",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ))),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Expanded(
                                      flex: 0,
                                      child: Row(
                                        children: const <Widget>[
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              MyConstants.points,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              MyConstants.nextLevel,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 0,
                                      child: Row(
                                        children: <Widget>[
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              "0",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                          const Expanded(
                                            flex: 0,
                                            child: Text("0" +
                                                MyConstants.percentageSymbol),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: LinearPercentIndicator(
                                              width: 140.0,
                                              lineHeight: 5.0,
                                              percent: 0.5,
                                              backgroundColor: Colors.grey,
                                              progressColor: Colors.blue,
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
                                        child: Center(
                                            child: Column(
                                          children: [
                                            //LineChartSample7(),
                                            Container()
                                          ],
                                        ))),
                                    const SizedBox(
                                      height: 20.0,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ))
                  : Column(
                      children: [
                        Expanded(
                          flex: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, left: 16.0, right: 16.0),
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Color(
                                              int.parse("0xfff" "5C7E7F")),
                                          borderRadius: BorderRadius.zero),
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, right: 15.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              const Text(
                                                MyConstants.ticketForTheDay,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                _taskCount.toString() +
                                                    MyConstants.bar +
                                                    _totalTaskCount.toString(),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ))),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  CircularProgressView(_percent!),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  const Text(MyConstants.timeToBegin),
                                  const SizedBox(
                                    height: 20.0,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 0,
                                    child: Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: Color(
                                                int.parse("0xfff" "5C7E7F")),
                                            borderRadius: BorderRadius.zero),
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                const Text(
                                                  MyConstants.leaderShip,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  MyConstants.overAllRank +
                                                      _overAllRank!,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ))),
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Row(
                                      children: const <Widget>[
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            MyConstants.points,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            MyConstants.nextLevel,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Row(
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            _techRewardPoints!,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 0,
                                          child: Text(
                                              _nextRewardPoints.toString() +
                                                  MyConstants.percentageSymbol),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: LinearPercentIndicator(
                                            width: 140.0,
                                            lineHeight: 5.0,
                                            percent: _nextLevelPercentage!,
                                            backgroundColor: Colors.grey,
                                            progressColor: Colors.blue,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Expanded(
                                    child: Center(
                                        child: _monthlyListSize == 0
                                            ? Text(
                                                MyConstants.noDataAvailable,
                                                style: TextStyle(
                                                    color: Color(int.parse(
                                                        "0xfff" "ffbf88"))),
                                              )
                                            : SingleChildScrollView(
                                                child: Column(
                                                children: [
                                                  Container(),
                                                  //LineChartSample7(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                          width: 50,
                                                          height: 50,
                                                          child: CustomPaint(
                                                            painter:
                                                                OpenPainter(),
                                                          )),
                                                      const Text("Month")
                                                    ],
                                                  ),
                                                ],
                                              ))),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
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
                  : FloatingActionButton(
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
                    ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> selectedItem(BuildContext context, item) async {
    switch (item) {
      case 1:
        {
          if (timer != null) timer!.cancel();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileTechnician()));
          break;
        }
      case 2:
        {
          if (timer != null) timer!.cancel();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangePassword()));
          break;
        }
      case 3:
        {
          if (PreferenceUtils.getInteger(MyConstants.punchStatus) == 1) {
            setToastMessage(context, MyConstants.punchOut);
            dashBoardBottomSheet(context, true);
          } else {
            String technicianCode =
                PreferenceUtils.getString(MyConstants.technicianCode);
            if (await checkInternetConnection() == true) {
              showAlertDialog(context);
              ApiService apiService = ApiService(dio.Dio());
              Map<String, dynamic> data = {'technician_code': technicianCode};
              final response = await apiService.logout(data);
              if (response.forgotPasswordEntity!.responseCode == "200") {
                Navigator.of(context, rootNavigator: true).pop();
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.clear();
                setToastMessage(
                    context, response.forgotPasswordEntity!.message!);
                if (timer != null) timer!.cancel();
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Login()));
                });
              } else {
                Navigator.of(context, rootNavigator: true).pop();
                setToastMessage(
                    context, response.forgotPasswordEntity!.message!);
              }
            } else {
              setToastMessage(context, MyConstants.internetConnection);
            }
          }
          break;
        }
    }
  }

  Future<void> getToken(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService
          .getToken(PreferenceUtils.getString(MyConstants.technicianCode));
      if (response.tokenEntity!.responseCode == "200") {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.tokenEntity!.data!);
          PreferenceUtils.setString(MyConstants.videoPath, MyConstants.clear);
          PreferenceUtils.setString(
              MyConstants.technicianStatus, MyConstants.free);
          getDashBoardDetails();
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void getDashBoardDetails() async {
    if (await checkInternetConnection() == true) {
      Map<String, dynamic> dashBoardData = {
        'technician_code': PreferenceUtils.getString(MyConstants.technicianCode)
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.technicianDashboard(dashBoardData);

      if (response.dashBoardEntity!.responseCode == MyConstants.response200) {
        setState(() {
          _taskCount = response.dashBoardEntity!.data!.taskCount;
          _totalTaskCount = response.dashBoardEntity!.data!.totalTaskCount;
          _overAllRank = response.dashBoardEntity!.data!.overallRank;
          _techRewardPoints = response.dashBoardEntity!.data!.techRewardPoint;
          _nextRewardPoints = response.dashBoardEntity!.data!.nextRewardPoint;

          if (response.dashBoardEntity!.data!.monthlyTarget!.isNotEmpty) {
            _monthlyListSize =
                response.dashBoardEntity!.data!.monthlyTarget!.length;
          } else {
            _monthlyListSize = 0;
          }
          if (int.parse(_nextRewardPoints!) > -1 &&
              int.parse(_nextRewardPoints!) < 101) {
            _nextLevelPercentage = int.parse(_nextRewardPoints!) / 100;
          } else {
            _nextRewardPoints = "0";
            _nextLevelPercentage = 0.0;
          }

          if (_totalTaskCount != 0) {
            _percent = (_taskCount! / _totalTaskCount!) * 100;
          } else {
            _percent = 0.0;
          }
          _isLoading = !_isLoading!;
        });
      } else {
        setState(() {
          _isLoading = !_isLoading!;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }
}
