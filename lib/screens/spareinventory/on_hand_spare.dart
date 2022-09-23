import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shimmer/shimmer.dart';

import '../../network/api_services.dart';
import '../../network/db/app_database.dart';
import '../../network/db/consumed_spare_request_data.dart';
import '../../network/model/on_hand_primary_model.dart';
import '../../network/model/on_hand_spare_model.dart';
import '../../utility/shared_preferences.dart';
import '../../utility/store_strings.dart';
import '../../utility/validator.dart';
import '../start_ticket.dart';
import 'consumed_spare_listener.dart';
import 'spare_inventory.dart';

class OnHandSpare extends StatefulWidget {
  final String? status, ticketId;

  const OnHandSpare(this.status, this.ticketId, {super.key});

  @override
  _OnHandSpareState createState() => _OnHandSpareState();
}

class _OnHandSpareState extends State<OnHandSpare> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true, _noDataAvailable = false;
  String? _getToken;
  int _cartIncrement = 0;
  var onHandSpareList = <OnHandSpareModel>[];
  var onHandPrimarySpareList = <OnHandPrimaryModel>[];
  var consumedSpareRequestDataList = <OnHandPrimaryModel>[];
  var showTickList = <bool>[];
  String? _cart;

  Future<void> getOnHandSpareList() async {
    if (await checkInternetConnection() == true) {

      if(widget.status == MyConstants.selectedOnHand) {

        setState(() {
          _isLoading = true;
          _noDataAvailable = false;
        });

        String getToken = PreferenceUtils.getString(MyConstants.token);
        String getTechnicianCode =
        PreferenceUtils.getString(MyConstants.technicianCode);

        //clear the list
        onHandSpareList.clear();

        ApiService apiService = ApiService(dio.Dio());
        final response =
        await apiService.onHandSpareGetApi(getToken, getTechnicianCode);
        if (response.onHandSpareEntity!.responseCode == MyConstants.response200) {
          setState(() {
            PreferenceUtils.setString(
                MyConstants.token, response.onHandSpareEntity!.token!);
            for (int i = 0; i < response.onHandSpareEntity!.data!.length; i++) {
              onHandSpareList.add(OnHandSpareModel(
                  statusName: response.onHandSpareEntity!.data![i]!.statusName,
                  statusCode: response.onHandSpareEntity!.data![i]!.statusCode,
                  spareCode: response.onHandSpareEntity!.data![i]!.spareCode,
                  spareLocation:
                  response.onHandSpareEntity!.data![i]!.spareLocation,
                  spareName: response.onHandSpareEntity!.data![i]!.spareName,
                  quantity: response.onHandSpareEntity!.data![i]!.quantity,
                  spareLocationId:
                  response.onHandSpareEntity!.data![i]!.spareLocationId));
            }
            getConsumeSpareGetApi();
          });
        } else if (response.onHandSpareEntity!.responseCode ==
            MyConstants.response400 ||
            response.onHandSpareEntity!.responseCode == MyConstants.response500) {
          setState(() {
            if(response.onHandSpareEntity!.token != null) {
              PreferenceUtils.setString(
                  MyConstants.token, response.onHandSpareEntity!.token!);
            }
            getConsumeSpareGetApi();
          });
        }
      }
      else {
        getConsumeSpareGetApi();
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> getConsumeSpareGetApi() async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
    });

    if (await checkInternetConnection() == true) {
      _getToken = PreferenceUtils.getString(MyConstants.token);
      String? getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      Map<String, dynamic> consumedSpareListData = {
        'technician_code': getTechnicianCode
      };

      //clear the list
      onHandPrimarySpareList.clear();

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getConsumedSpareList(
          _getToken!, consumedSpareListData);
      if (response.onHandPrimaryEntity!.responseCode ==
          MyConstants.response200) {
        final database = await $FloorAppDatabase
            .databaseBuilder('floor_database.db')
            .build();
        final consumedSpareRequestDataDao =
            database.consumedSpareRequestDataDao;
        await consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.onHandPrimaryEntity!.token!);
          for (int i = 0; i < response.onHandPrimaryEntity!.data!.length; i++) {
            onHandPrimarySpareList.add(OnHandPrimaryModel(
                spareName: response.onHandPrimaryEntity!.data![i]!.spareName,
                quantity: response.onHandPrimaryEntity!.data![i]!.quantity,
                spareCode: response.onHandPrimaryEntity!.data![i]!.spareCode,
                locationId: response.onHandPrimaryEntity!.data![i]!.locationId,
                spareId: response.onHandPrimaryEntity!.data![i]!.spareId));
            ConsumedSpareRequestDataTable consumedSpareRequestData =
                ConsumedSpareRequestDataTable(
                    i + 1,
                    response.onHandPrimaryEntity!.data![i]!.spareId.toString(),
                    response.onHandPrimaryEntity!.data![i]!.spareCode!,
                    response.onHandPrimaryEntity!.data![i]!.spareName!,
                    response.onHandPrimaryEntity!.data![i]!.quantity!,
                    false,
                    MyConstants.updateQuantity,
                    response.onHandPrimaryEntity!.data![i]!.price ?? 0,
                    response.onHandPrimaryEntity!.data![i]!.location ??
                        MyConstants.na,
                    response.onHandPrimaryEntity!.data![i]!.locationId!);
            consumedSpareRequestDataDao
                .insertConsumedSpareRequestData(consumedSpareRequestData);
            showTickList.add(false);
          }
          _isLoading = !_isLoading;
        });
      } else if (response.onHandPrimaryEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.onHandPrimaryEntity!.token!);
          if (response.onHandPrimaryEntity!.message != null) {
            setToastMessage(context, response.onHandPrimaryEntity!.message!);
          }
          _noDataAvailable = true;
        });
      } else if (response.onHandPrimaryEntity!.responseCode ==
          MyConstants.response403) {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.onHandPrimaryEntity!.token!);
          intentView();
          if (response.onHandPrimaryEntity!.message != null) {
            setToastMessage(context, response.onHandPrimaryEntity!.message!);
          }
        });
      } else if (response.onHandPrimaryEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
          intentView();
          if (response.onHandPrimaryEntity!.message != null) {
            setToastMessage(context, response.onHandPrimaryEntity!.message!);
          }
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void getConsumedSpareData(int index, String source) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
    var result =
        await consumedSpareRequestDataDao.findAllConsumedSpareRequestData();
    List<ConsumedSpareRequestDataTable> consumedSpareRequestData = result;
    setState(() {
      if (consumedSpareRequestData[index].upDateSpare == true) {
        _cartIncrement--;
        if(source == MyConstants.api) {
          consumedSpareRequestDataDao.updateConsumedSpare(
              false, onHandPrimarySpareList[index].spareId.toString());
        } else if(source == MyConstants.searchedSpare) {
          consumedSpareRequestDataDao.updateConsumedSpare(
              false, onHandPrimarySpareList[index].spareId.toString());
        }
        _cart = MyConstants.addToCartButton +
            MyConstants.openBracket +
            _cartIncrement.toString() +
            MyConstants.closedBracket;
        showTickList[index] = false;
      }
      else {
        _cartIncrement++;
        if(source == MyConstants.api) {
          consumedSpareRequestDataDao.updateConsumedSpare(
              true, consumedSpareRequestDataList[index].spareId.toString());
        } else if(source == MyConstants.searchedSpare) {
          consumedSpareRequestDataDao.updateConsumedSpare(
              true, consumedSpareRequestDataList[index].spareId.toString());
        }
        _cart = MyConstants.addToCartButton +
            MyConstants.openBracket +
            _cartIncrement.toString() +
            MyConstants.closedBracket;
        showTickList[index] = true;
      }
    });
  }

  void onCartClicked() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
    var result = await consumedSpareRequestDataDao.updateSpareCart(true);
    List<ConsumedSpareRequestDataTable?> consumedSpareRequestData = result;
    if (consumedSpareRequestData.isNotEmpty) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ConsumedSpareListener(widget.status, widget.ticketId!)));
    } else {
      setToastMessage(context, MyConstants.selectSpare);
    }
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    getOnHandSpareList();
  }

  Future<T?> pushPage<T>(BuildContext context, Widget? page) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page!));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.status == MyConstants.imprestStatus) {
          pushPage(context, const SpareInventory(2, MyConstants.bar));
        } else  if (widget.status == MyConstants.selectedOnHand) {
          pushPage(
              context,
              StartTicket(
                status: MyConstants.ticketStarted,
                ticketId: widget.ticketId,
              ));
        } else if (widget.status == MyConstants.complete) {
          pushPage(
              context,
              StartTicket(
                status: MyConstants.ticketStarted,
                ticketId: widget.ticketId,
              ));
        }
        return true;
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text(MyConstants.appName,
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
            leading: IconButton(
                onPressed: () {
                  if (widget.status == MyConstants.imprestStatus) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SpareInventory(2, MyConstants.bar)));
                  } else if (widget.status == MyConstants.selectedOnHand) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StartTicket(
                              status: MyConstants.ticketStarted,
                              ticketId: widget.ticketId,
                            )));
                  } else if (widget.status == MyConstants.complete) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StartTicket(
                                  status: MyConstants.ticketStarted,
                                  ticketId: widget.ticketId,
                                )));
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_outlined)),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _searchController,
                  onChanged: onSearchTextChanged,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      labelText: MyConstants.searchSpare,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search)),
                ),
              ),
              Row(children: const <Widget>[
                Expanded(
                    child: Divider(
                  thickness: 2.0,
                  color: Colors.black,
                )),
                Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Text(
                      MyConstants.onHandSpare,
                      style: TextStyle(fontSize: 20.0, color: Colors.blue),
                    )),
                Expanded(
                    child: Divider(
                  thickness: 2.0,
                  color: Colors.black,
                )),
              ]),
              onHandScreen(),
              _searchController.text.isEmpty ||
                      consumedSpareRequestDataList.isEmpty
                  ? consumedSpareGetApi()
                  : searchConsumedSpareGetApi(),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, bottom: 10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          onCartClicked();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                        child: Text(_cart == null ? MyConstants.cart : _cart!,
                            style:
                                const TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget onHandScreen() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: SizedBox(
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
                      child: const Text(MyConstants.spareCode,
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 1,
          ),
          Expanded(
            child: SizedBox(
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
                    child: const Text(MyConstants.spareName,
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 1,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: SizedBox(
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
                      child: const Text(MyConstants.quantity,
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> refreshConsumedList() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getConsumeSpareGetApi();
    });

    return;
  }

  Widget consumedSpareGetApi() {
    return Expanded(
      flex: 5,
      child: RefreshIndicator(
        onRefresh: refreshConsumedList,
        child: _isLoading == true
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[400]!,
                child: ListView.builder(
                    itemCount: 5,
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
                    itemCount: onHandPrimarySpareList.length,
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            getConsumedSpareData(index, MyConstants.api);
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.only(top: 10),
                            child: Card(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 7.5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Padding(
                                            padding: EdgeInsets.all(5.0)),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  onHandPrimarySpareList[index]
                                                              .spareCode ==
                                                          null
                                                      ? MyConstants.na
                                                      : onHandPrimarySpareList[
                                                              index]
                                                          .spareCode!,
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      const TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  onHandPrimarySpareList[index]
                                                              .spareName ==
                                                          null
                                                      ? MyConstants.na
                                                      : onHandPrimarySpareList[
                                                              index]
                                                          .spareName!,
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      const TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  onHandPrimarySpareList[index]
                                                              .quantity ==
                                                          null
                                                      ? MyConstants.na
                                                      : onHandPrimarySpareList[
                                                              index]
                                                          .quantity!
                                                          .toString(),
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      const TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(right: 5.0),
                                            child: showTickList[index] == true
                                                ? Image.asset(
                                                    'assets/images/check.png',
                                                    width: 25,
                                                    height: 25,
                                                  )
                                                : null),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                ]))),
                      );
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

  Widget searchConsumedSpareGetApi() {
    return Expanded(
        child: ListView.builder(
            itemCount: consumedSpareRequestDataList.length,
            padding: const EdgeInsets.only(left: 16, right: 16),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    getConsumedSpareData(index, MyConstants.searchedSpare);
                  });
                },
                child: Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Card(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: <
                                Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 7.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Padding(padding: EdgeInsets.all(5.0)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      consumedSpareRequestDataList[index]
                                                  .spareCode ==
                                              null
                                          ? MyConstants.na
                                          : consumedSpareRequestDataList[index]
                                              .spareCode!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      consumedSpareRequestDataList[index]
                                                  .spareName ==
                                              null
                                          ? MyConstants.na
                                          : consumedSpareRequestDataList[index]
                                              .spareName!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      consumedSpareRequestDataList[index]
                                                  .quantity ==
                                              null
                                          ? MyConstants.na
                                          : consumedSpareRequestDataList[index]
                                              .quantity!
                                              .toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: showTickList[index] == true
                                    ? Image.asset(
                                        'assets/images/check.png',
                                        width: 25,
                                        height: 25,
                                      )
                                    : null),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                    ]))),
              );
            }));
  }

  onSearchTextChanged(String text) async {
    consumedSpareRequestDataList.clear();
    setState(() {
      if (text.isEmpty) {
        return;
      }

      for (var userDetail in onHandPrimarySpareList) {
        if (userDetail.spareName!.toLowerCase().contains(text) ||
            userDetail.spareCode!.toLowerCase().contains(text)) {
          consumedSpareRequestDataList.add(userDetail);
        }
      }
    });
  }

  Future<void> insertConsumedSpareData(int index) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
    await consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();
  }

  Future<void> intentView() async {
    String ticketID = PreferenceUtils.getString(MyConstants.ticketId);
    if (ticketID != null) {
      // Intent intent1 = new Intent(consumedSpareActivity, SubmitComplete.class);
      // consumedSpareActivity.startActivity(intent1);
      // consumedSpareActivity.finish();
    } else {
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
      var result = await consumedSpareRequestDataDao.updateSpareCart(true);
      List<ConsumedSpareRequestDataTable?> consumedSpareRequestData = result;
      if (consumedSpareRequestData.isNotEmpty) {
        consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();
      }
    }
  }
}
