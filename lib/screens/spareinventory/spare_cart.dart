import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shimmer/shimmer.dart';

import '../../network/api_services.dart';
import '../../network/db/app_database.dart';
import '../../network/db/spare_request_data.dart';
import '../../network/model/drop_location.dart';
import '../../network/model/spare_cart_model.dart';
import '../../utility/shared_preferences.dart';
import '../../utility/store_strings.dart';
import '../../utility/validator.dart';
import '../start_ticket.dart';
import '../ticket_list.dart';
import '../work_in_progress.dart';
import 'spare_inventory.dart';
import 'spare_listner.dart';

class SpareCart extends StatefulWidget {
  final String? ticketUpdate, ticketId;

  SpareCart(this.ticketUpdate, this.ticketId);

  @override
  _SpareCartState createState() => _SpareCartState();
}

class _SpareCartState extends State<SpareCart> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true, _noDataAvailable = false;
  var spareCartList = <SpareCartModel>[];
  var filteredList = <SpareCartModel>[];
  var dropLocationList = <DropLocationModel>[];
  var showTickList = <bool>[];
  int _cartIncrement = 0;
  DropLocationModel? _selectedDropdownValue;
  String? _addToCart;

  getLocationSpinnerData(BuildContext context) async {
    if (await checkInternetConnection() == true) {

      setState(() {
        _isLoading = true;
        _noDataAvailable = false;
      });

      dropLocationList.clear();

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getDropLocationApi();
      if (response.dropLocationEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          dropLocationList.add(DropLocationModel(
              warehouseId: 0,
              warehouseName: "All",
              leadTime: 1));
          for (int i = 0; i < response.dropLocationEntity!.data!.length; i++) {
            dropLocationList.add(DropLocationModel(
                warehouseId: response.dropLocationEntity!.data![i]!.warehouseId,
                warehouseName:
                response.dropLocationEntity!.data![i]!.warehouseName,
                leadTime: response.dropLocationEntity!.data![i]!.leadTime));
          }

          initializeView();
        });
      } else if (response.dropLocationEntity!.responseCode ==
          MyConstants.response400 ||
          response.dropLocationEntity!.responseCode ==
              MyConstants.response500) {
       initializeView();
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void initializeView() {
    if (widget.ticketId != null) {
      getOnHandSpareList("0", widget.ticketId, "1", "0");
    } else {
      getOnHandSpareList("0", MyConstants.wareHouseId, "1", "0");
    }
  }

  Future<void> getOnHandSpareList(String? wareHouseId, String? ticketId,
      String? spareId, String? frmSpare) async {
    if (await checkInternetConnection() == true) {
      String getToken = PreferenceUtils.getString(MyConstants.token);
      String? getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      setState(() {
        _isLoading = true;
        _noDataAvailable = false;
      });

      //clear the list
      spareCartList.clear();

      print(spareId);

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getSpareCart(
          getToken,
          getTechnicianCode,
          wareHouseId!,
          ticketId!,
          spareId!,
          frmSpare!);
      if (response.spareCartEntity!.responseCode == MyConstants.response200) {
        final database = await $FloorAppDatabase
            .databaseBuilder('floor_database.db')
            .build();
        final spareRequestDataDao = database.spareRequestDataDao;
        await spareRequestDataDao.deleteSpareRequestDataTable();
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.spareCartEntity!.token!);

          for (int i = 0; i < response.spareCartEntity!.data!.length; i++) {
            spareCartList.add(SpareCartModel(
                spareName: response.spareCartEntity!.data![i]!.spareName,
                quantity: response.spareCartEntity!.data![i]!.quantity,
                spareCode: response.spareCartEntity!.data![i]!.spareCode,
                productId: response.spareCartEntity!.data![i]!.productId,
                productSubId: response.spareCartEntity!.data![i]!.productSubId,
                location: response.spareCartEntity!.data![i]!.location,
                price: response.spareCartEntity!.data![i]!.price,
                spareModel: response.spareCartEntity!.data![i]!.spareModel,
                leadTime: response.spareCartEntity!.data![i]!.leadTime,
                locationId: response.spareCartEntity!.data![i]!.locationId,
                spareId: response.spareCartEntity!.data![i]!.spareId));
            SpareRequestDataTable spareRequestData = SpareRequestDataTable(
                i + 1,
                response.spareCartEntity!.data![i]!.spareId.toString(),
                response.spareCartEntity!.data![i]!.spareCode!,
                response.spareCartEntity!.data![i]!.spareName!,
                response.spareCartEntity!.data![i]!.productId!,
                response.spareCartEntity!.data![i]!.productSubId!,
                response.spareCartEntity!.data![i]!.location!,
                response.spareCartEntity!.data![i]!.quantity!,
                response.spareCartEntity!.data![i]!.price!.toDouble(),
                response.spareCartEntity!.data![i]!.spareModel!,
                false,
                MyConstants.updateQuantity,
                MyConstants.chargeable,
                response.spareCartEntity!.data![i]!.leadTime!,
                MyConstants.chargeable.toDouble(),
                response.spareCartEntity!.data![i]!.locationId!);
            spareRequestDataDao.insertSpareRequestData(spareRequestData);
            showTickList.add(false);
          }
          _isLoading = !_isLoading;
        });
      } else if (response.spareCartEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.spareCartEntity!.token!);
          _noDataAvailable = true;
        });
      } else if (response.spareCartEntity!.responseCode ==
          MyConstants.response403) {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.spareCartEntity!.token!);
        });
      } else if (response.spareCartEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void getConsumedSpareData(int index) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final spareRequestDataDao = database.spareRequestDataDao;
    var result = await spareRequestDataDao.findAllSpareRequestData();
    List<SpareRequestDataTable> spareRequestData = result;
    setState(() {
      if (spareRequestData[index].upDateSpare == true) {
        _cartIncrement--;
        spareRequestDataDao.updateConsumedSpare(
            false, spareRequestData[index].spareId);
        _addToCart = MyConstants.addToCartButton +
            MyConstants.openBracket +
            _cartIncrement.toString() +
            MyConstants.closedBracket;
        showTickList[index] = false;
      }
      else {
        _cartIncrement++;
        spareRequestDataDao.updateConsumedSpare(
            true, spareRequestData[index].spareId);
        _addToCart = MyConstants.addToCartButton +
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
    final spareRequestDataDao = database.spareRequestDataDao;
    var result = await spareRequestDataDao.updateSpareRequestData(true);
    List<SpareRequestDataTable?> spareRequestData = result;
    if (spareRequestData.isNotEmpty) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SpareListener(widget.ticketUpdate, widget.ticketId)));
    } else {
      setToastMessage(context, MyConstants.selectSpare);
    }
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    Future.delayed(Duration.zero, () {
      getLocationSpinnerData(context);
    });
  }

  Future<T?> pushPage<T>(BuildContext context, Widget? page) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page!));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.ticketUpdate == MyConstants.complete) {
          pushPage(context, const TicketList(2));
        } else if (widget.ticketUpdate == MyConstants.spareRequest) {
          pushPage(
              context,
              StartTicket(
                  ticketId: widget.ticketId,
                  status: MyConstants.ticketStarted));
        } else if (widget.ticketUpdate == MyConstants.workInProgressAlert) {
          pushPage(
              context,
              WorkInProgress(
                  MyConstants.workInProgressAlert, widget.ticketId!, false));
        } else {
          pushPage(context, const SpareInventory(1, MyConstants.bar));
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
                  if (widget.ticketUpdate == MyConstants.complete) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TicketList(2)));
                  } else if (widget.ticketUpdate == MyConstants.spareRequest) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StartTicket(
                                ticketId: widget.ticketId,
                                status: MyConstants.ticketStarted)));
                  } else if (widget.ticketUpdate ==
                      MyConstants.workInProgressAlert) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WorkInProgress(
                                MyConstants.workInProgressAlert,
                                widget.ticketId!,
                                false)));
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SpareInventory(1, MyConstants.bar)));
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
                      labelText: MyConstants.searchSpare,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search)),
                ),
              ),
              Row(children: <Widget>[
                const Expanded(
                    child: Divider(
                  thickness: 2.0,
                  color: Colors.black,
                )),
                Expanded(
                  flex: 2,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: SizedBox(
                        height: 50,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            contentPadding: const EdgeInsets.only(
                                left: 5.0, right: 5.0, bottom: 5.0),
                          ),
                          child: DropdownButtonFormField<DropLocationModel?>(
                            isExpanded: true,
                            value: _selectedDropdownValue,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(5),
                            ),
                            hint: const Text(
                              MyConstants.all,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15)
                            ),
                            onChanged: (DropLocationModel? value) {
                              String? wareHouseId,
                                  ticketId,
                                  spareId,
                                  frmSpare;
                              setState(() {
                                _selectedDropdownValue = value;
                                if(widget.ticketId != null) {
                                  wareHouseId = value!.warehouseId.toString();
                                  ticketId = widget.ticketId;
                                  spareId = MyConstants.wareHouseId;
                                  frmSpare = MyConstants.wareHouseId;

                                  getOnHandSpareList(wareHouseId, ticketId, spareId, frmSpare);
                                } else {
                                  wareHouseId = value!.warehouseId.toString();
                                  ticketId = MyConstants.wareHouseId;
                                  spareId = MyConstants.wareHouseId;
                                  frmSpare = MyConstants.wareHouseId;

                                  getOnHandSpareList(wareHouseId, ticketId, spareId, frmSpare);
                                }
                                // if (value!.warehouseName == MyConstants.all) {
                                //   wareHouseId = "0";
                                //   ticketId = MyConstants.wareHouseId;
                                //   spareId = MyConstants.spareIdGetSpare;
                                //   frmSpare = MyConstants.wareHouseId;
                                //   if (widget.ticketUpdate ==
                                //           MyConstants.spareRequest ||
                                //       widget.ticketUpdate ==
                                //           MyConstants.workInProgressAlert) {
                                //     getOnHandSpareList(
                                //         wareHouseId,
                                //         widget.ticketId,
                                //         spareId,
                                //         frmSpare);
                                //   } else {
                                //     getOnHandSpareList(wareHouseId, ticketId,
                                //         spareId, frmSpare);
                                //   }
                                // }
                                // else {
                                //   wareHouseId = value.warehouseId!.toString();
                                //   ticketId = MyConstants.wareHouseId;
                                //   spareId = MyConstants.spareIdGetSpare;
                                //   frmSpare = MyConstants.wareHouseId;
                                //   if (widget.ticketUpdate ==
                                //           MyConstants.spareRequest ||
                                //       widget.ticketUpdate ==
                                //           MyConstants.workInProgressAlert) {
                                //     getOnHandSpareList(
                                //         wareHouseId,
                                //         widget.ticketId,
                                //         spareId,
                                //         frmSpare);
                                //   } else {
                                //     getOnHandSpareList(wareHouseId, ticketId,
                                //         spareId, frmSpare);
                                //   }
                                // }
                              });
                            },
                            items: dropLocationList.map((DropLocationModel? value) {
                              return DropdownMenuItem<DropLocationModel?>(
                                value: value,
                                child: Text(
                                  value!.warehouseName!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )),
                ),
                const Expanded(
                    child: Divider(
                  thickness: 2.0,
                  color: Colors.black,
                )),
              ]),
              spareCartScreen(),
              _searchController.text.isEmpty || filteredList.isEmpty
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
                        child: Text(
                            _addToCart == null
                                ? MyConstants.addToCartButton
                                : _addToCart!,
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

  Widget spareCartScreen() {
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
      if(widget.ticketId != null) {
        getOnHandSpareList(_selectedDropdownValue != null ? _selectedDropdownValue!.warehouseId.toString() : MyConstants.wareHouseId,
            widget.ticketId,
            _selectedDropdownValue != null ? MyConstants.spareIdGetSpare : MyConstants.wareHouseId,
            MyConstants.wareHouseId);
      } else {
        getOnHandSpareList(_selectedDropdownValue != null ? _selectedDropdownValue!.warehouseId.toString() : MyConstants.wareHouseId,
            MyConstants.wareHouseId,
            _selectedDropdownValue != null ? MyConstants.spareIdGetSpare : MyConstants.wareHouseId,
            MyConstants.wareHouseId);
      }
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
                    itemCount: spareCartList.length,
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            getConsumedSpareData(index);
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
                                                  spareCartList[index]
                                                              .spareCode ==
                                                          null
                                                      ? MyConstants.na
                                                      : spareCartList[index]
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
                                                  spareCartList[index]
                                                              .spareName ==
                                                          null
                                                      ? MyConstants.na
                                                      : spareCartList[index]
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
                                                  spareCartList[index]
                                                              .quantity ==
                                                          null
                                                      ? MyConstants.na
                                                      : spareCartList[index]
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
            itemCount: filteredList.length,
            padding: const EdgeInsets.only(left: 16, right: 16),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    getConsumedSpareData(index);
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Padding(padding: EdgeInsets.all(5.0)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          filteredList[index].spareCode == null
                                              ? MyConstants.na
                                              : filteredList[index].spareCode!,
                                          textAlign: TextAlign.center,
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
                                          filteredList[index].spareName == null
                                              ? MyConstants.na
                                              : filteredList[index].spareName!,
                                          textAlign: TextAlign.center,
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
                                          filteredList[index].quantity == null
                                              ? MyConstants.na
                                              : filteredList[index]
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
    filteredList.clear();
    setState(() {
      if (text.isEmpty) {
        return;
      }

      for (var userDetail in spareCartList) {
        if (userDetail.spareName!.toLowerCase().contains(text) ||
            userDetail.spareCode!.toLowerCase().contains(text)) {
          filteredList.add(userDetail);
        }
      }
    });
  }
}
