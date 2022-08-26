import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:location/location.dart' as pl;
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';

import '../../network/api_services.dart';
import '../../network/db/app_database.dart';
import '../../network/db/consumed_spare_request_data.dart';
import '../../network/db/spare_request_data.dart';
import '../../network/model/on_hand_spare_model.dart';
import '../../network/model/pending_frm_model.dart';
import '../../network/model/requested_spare_list_model.dart';
import '../../network/model/select_technician_model.dart';
import '../../network/model/spare_receive_request_model.dart';
import '../../network/model/spare_status_model.dart';
import '../../network/model/spare_transfer_model.dart';
import '../../utility/shared_preferences.dart';
import '../../utility/store_strings.dart';
import '../../utility/technician_punch.dart';
import '../../utility/validator.dart';
import '../dashboard.dart';
import 'on_hand_spare.dart';
import 'spare_cart.dart';

class SpareInventory extends StatefulWidget {
  final int selectedIndex;
  final String backButton;

  const SpareInventory(this.selectedIndex, this.backButton, {super.key});

  @override
  _SpareInventory createState() => _SpareInventory();
}

class _SpareInventory extends State<SpareInventory> {
  bool _showSpareStatusFragment = false,
      _showImprestStatusFragment = false,
      _showSpareTransferFragment = false,
      _isLoading = true,
      _showTransferButton = false,
      _showReceiveButton = false,
      _noDataAvailable = false;

  String _showConsumedSpareData = "";
  String? _toTechId;
  int _currentSelection = 0,
      selectedSpareTransferItem = 0,
      selectedSpareReceiveItem = 0;
  String? _getToken, _getTechnicianCode;
  double? latitude, longitude;
  final PageController _spareStatus = PageController();
  final PageController _imprestStatus = PageController();
  final PageController _showTransfer = PageController();
  TextEditingController requiredSpareController = TextEditingController();
  TextEditingController onHandSpareRequiredController =
      TextEditingController();
  TextEditingController onHandSpareCommentController =
      TextEditingController();
  pl.Location location = pl.Location();
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);
  var spareStatusList = <SpareStatusModel>[];
  var pendingFrmList = <PendingFrmModel>[];
  var onHandSpareList = <OnHandSpareModel>[];
  var requestedSpareList = <RequestSpareListModel>[];
  var transferSpareList = <SpareTransferModel>[];
  var receiveSpareList = <SpareReceiveRequestModel>[];
  var selectTechnicianList = <SelectTechnicianModel>[];
  var consumedSpareRequestDataList = <ConsumedSpareRequestDataTable>[];
  SelectTechnicianModel? _selectTechnicianModel;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  final Map<int, Widget> _children = {
    0: Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
      child: Row(
        children: [
          Image.asset('assets/images/ic_ss.png', width: 18, height: 18),
          const SizedBox(
            width: 5.0,
          ),
          const Text(
            'Spare Status',
            style: TextStyle(fontSize: 11.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
    1: Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
      child: Row(
        children: [
          Image.asset('assets/images/ic_is.png', width: 18, height: 18),
          const SizedBox(
            width: 5.0,
          ),
          const Text(
            'Impreset Spare',
            style: TextStyle(fontSize: 11.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
    2: Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
      child: Row(
        children: [
          Image.asset('assets/images/ic_st.png', width: 18, height: 18),
          const SizedBox(
            width: 5.0,
          ),
          const Text(
            'Spare Transfer',
            style: TextStyle(fontSize: 11.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
  };

  Future<void> getSpareStatusList() async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
    });

    if (await checkInternetConnection() == true) {
      _getToken = PreferenceUtils.getString(MyConstants.token);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      //clear the list
      spareStatusList.clear();

      ApiService apiService = ApiService(dio.Dio());
      final response =
          await apiService.spareStatusGetApi(_getToken!, _getTechnicianCode!);
      if (response.spareStatusEntity!.responseCode == MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.spareStatusEntity!.token!);
          for (int i = 0; i < response.spareStatusEntity!.data!.length; i++) {
            spareStatusList.add(SpareStatusModel(
                ticketId: response.spareStatusEntity!.data![i]!.ticketId,
                frmStatus: response.spareStatusEntity!.data![i]!.frmStatus,
                spareCode: response.spareStatusEntity!.data![i]!.spareCode,
                spareName: response.spareStatusEntity!.data![i]!.spareName,
                invoiceNumber: response.spareStatusEntity!.data![i]!.invoiceNumber ?? MyConstants.na,
                docketNumber: response.spareStatusEntity!.data![i]!.docketNumber ?? MyConstants.na,
                spareLocation:
                    response.spareStatusEntity!.data![i]!.spareLocation,
                approvedQuantity: response.spareStatusEntity!.data![i]!.approvedQuantity ?? 0,
                spareQuantity:
                    response.spareStatusEntity!.data![i]!.spareQuantity));
          }
          _isLoading = !_isLoading;
        });
      } else if (response.spareStatusEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.spareStatusEntity!.token!);
          _noDataAvailable = true;
        });
      } else if (response.spareStatusEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
          setToastMessage(context, response.spareStatusEntity!.message!);
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> getPendingFrmList() async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
    });

    if (await checkInternetConnection() == true) {
      _getToken = PreferenceUtils.getString(MyConstants.token);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      //clear the list
      pendingFrmList.clear();

      ApiService apiService = ApiService(dio.Dio());
      final response =
          await apiService.pendingFrmGetApi(_getToken!, _getTechnicianCode!);
      if (response.pendingFrmEntity!.responseCode == MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.pendingFrmEntity!.token!);
          for (int i = 0; i < response.pendingFrmEntity!.data!.length; i++) {
            pendingFrmList.add(PendingFrmModel(
                ticketId: response.pendingFrmEntity!.data![i]!.ticketId,
                frmStatus: response.pendingFrmEntity!.data![i]!.frmStatus,
                spareCode: response.pendingFrmEntity!.data![i]!.spareCode,
                spareLocation:
                    response.pendingFrmEntity!.data![i]!.spareLocation ?? MyConstants.na,
                spareQuantity:
                    response.pendingFrmEntity!.data![i]!.spareQuantity));
          }
          _isLoading = !_isLoading;
        });
      } else if (response.pendingFrmEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.pendingFrmEntity!.token!);
          _noDataAvailable = true;
        });
      } else if (response.pendingFrmEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> getOnHandSpareList() async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
    });

    if (widget.selectedIndex == 1) {
      _currentSelection = 1;
    }

    if (await checkInternetConnection() == true) {
      _getToken = PreferenceUtils.getString(MyConstants.token);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      //clear the list
      onHandSpareList.clear();

      ApiService apiService = ApiService(dio.Dio());
      final response =
          await apiService.onHandSpareGetApi(_getToken!, _getTechnicianCode!);
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
          _isLoading = !_isLoading;
        });
        if (widget.backButton == MyConstants.backButton) {
          if (widget.selectedIndex == 1) {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                barrierColor: Colors.black.withAlpha(150),
                builder: (context) {
                  return addConsumedSpareBottomSheet();
                });
          } else {
            final database = await $FloorAppDatabase
                .databaseBuilder('floor_database.db')
                .build();
            final spareRequestDataDao = database.spareRequestDataDao;
            await spareRequestDataDao.deleteSpareRequestDataTable();
          }
        }
      } else if (response.onHandSpareEntity!.responseCode ==
          MyConstants.response400) {
        if (widget.backButton == MyConstants.backButton) {
          if (widget.selectedIndex == 1) {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                barrierColor: Colors.black.withAlpha(150),
                builder: (context) {
                  return addConsumedSpareBottomSheet();
                });
          } else {
            final database = await $FloorAppDatabase
                .databaseBuilder('floor_database.db')
                .build();
            final spareRequestDataDao = database.spareRequestDataDao;
            await spareRequestDataDao.deleteSpareRequestDataTable();
          }
        }
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.onHandSpareEntity!.token!);
          _noDataAvailable = true;
        });
      } else if (response.onHandSpareEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> getRequestedSpareList() async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
    });

    if (await checkInternetConnection() == true) {
      _getToken = PreferenceUtils.getString(MyConstants.token);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      //clear the list
      requestedSpareList.clear();

      ApiService apiService = ApiService(dio.Dio());
      final response =
          await apiService.requestedSpareList(_getToken!, _getTechnicianCode!);
      if (response.requestedSpareListEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.requestedSpareListEntity!.token!);
          for (int i = 0;
              i < response.requestedSpareListEntity!.data!.length;
              i++) {
            requestedSpareList.add(RequestSpareListModel(
                status: response.requestedSpareListEntity!.data![i]!.status,
                spareCode:
                    response.requestedSpareListEntity!.data![i]!.spareCode,
                spareName:
                    response.requestedSpareListEntity!.data![i]!.spareName,
                quantity:
                    response.requestedSpareListEntity!.data![i]!.quantity));
          }
          _isLoading = !_isLoading;
        });
      } else if (response.requestedSpareListEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          _isLoading = !_isLoading;
          setToastMessage(context, response.requestedSpareListEntity!.message!);
          _noDataAvailable = true;
        });
      } else if (response.requestedSpareListEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> getSpareTransferList() async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
    });

    if (widget.selectedIndex == 2) {
      _currentSelection = 2;
    }

    if (await checkInternetConnection() == true) {
      _getToken = PreferenceUtils.getString(MyConstants.token);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      if (PreferenceUtils.getInteger(MyConstants.punchStatus) == 1) {
        ratingStatus = true;
      }

      //clear the list
      transferSpareList.clear();

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.spareTransferListGetApi(
          _getToken!, _getTechnicianCode!);
      if (response.spareTransferEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.spareTransferEntity!.token!);
          for (int i = 0; i < response.spareTransferEntity!.data!.length; i++) {
            for (int j = 0;
                j <
                    response
                        .spareTransferEntity!.data![i]!.transferData!.length;
                j++) {
              transferSpareList.add(SpareTransferModel(
                  spareTransferId:
                      response.spareTransferEntity!.data![i]!.spareTransferId,
                  transferStatusCode: response
                      .spareTransferEntity!.data![i]!.transferStatusCode,
                  toTech: response.spareTransferEntity!.data![i]!.toTech,
                  transferStatusName: response
                      .spareTransferEntity!.data![i]!.transferStatusName,
                  spareCode: response.spareTransferEntity!.data![i]!
                      .transferData![j]!.spareCode,
                  quantity: response.spareTransferEntity!.data![i]!
                      .transferData![j]!.quantity));
            }
          }
          _isLoading = !_isLoading;
        });
        if (widget.backButton == MyConstants.backButton) {
          if (widget.selectedIndex == 2) {
            Future.delayed(const Duration(milliseconds: 250), () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  barrierColor: Colors.black.withAlpha(150),
                  builder: (context) {
                    return addSpareTransferBottomSheet();
                  });
            });
          } else {
            final database = await $FloorAppDatabase
                .databaseBuilder('floor_database.db')
                .build();
            final consumedSpareRequestDataDao =
                database.consumedSpareRequestDataDao;
            await consumedSpareRequestDataDao
                .deleteConsumedSpareRequestDataTable();
          }
        }
      } else if (response.spareTransferEntity!.responseCode ==
          MyConstants.response400) {
        if (widget.backButton == MyConstants.backButton) {
          if (widget.selectedIndex == 2) {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                barrierColor: Colors.black.withAlpha(150),
                builder: (context) {
                  return addSpareTransferBottomSheet();
                });
          } else {
            final database = await $FloorAppDatabase
                .databaseBuilder('floor_database.db')
                .build();
            final consumedSpareRequestDataDao =
                database.consumedSpareRequestDataDao;
            await consumedSpareRequestDataDao
                .deleteConsumedSpareRequestDataTable();
          }
        }
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.spareTransferEntity!.token!);
          _noDataAvailable = true;
        });
      } else if (response.spareTransferEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> getReceiveTransferList() async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
    });

    if (await checkInternetConnection() == true) {
      _getToken = PreferenceUtils.getString(MyConstants.token);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      //clear the list
      receiveSpareList.clear();

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.spareReceiveListGetApi(
          _getToken!, _getTechnicianCode!);
      if (response.spareReceiveEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.spareReceiveEntity!.token!);
          for (int i = 0; i < response.spareReceiveEntity!.data!.length; i++) {
            for (int j = 0;
                j < response.spareReceiveEntity!.data![i]!.transferData!.length;
                j++) {
              receiveSpareList.add(SpareReceiveRequestModel(
                  spareTransferId:
                      response.spareReceiveEntity!.data![i]!.spareTransferId,
                  fromTech: response.spareReceiveEntity!.data![i]!.fromTech,
                  transferStatus:
                      response.spareReceiveEntity!.data![i]!.transferStatus,
                  spareCode: response.spareReceiveEntity!.data![i]!
                      .transferData![j]!.spareCode,
                  quantity: response.spareReceiveEntity!.data![i]!
                      .transferData![j]!.quantity));
            }
          }
          _isLoading = !_isLoading;
        });
      } else if (response.spareReceiveEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.spareReceiveEntity!.token!);
          _noDataAvailable = true;
        });
      } else if (response.spareReceiveEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> getSelectTechnician() async {
    if (await checkInternetConnection() == true) {
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);

      //clear the list
      selectTechnicianList.clear();

      Map<String, dynamic> selectTechnicianData = {
        'technician_code': _getTechnicianCode
      };

      ApiService apiService = ApiService(dio.Dio());
      final response =
          await apiService.selectTechnicianList(selectTechnicianData);
      if (response.selectTechnicianEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          for (int i = 0;
              i < response.selectTechnicianEntity!.data!.length;
              i++) {
            selectTechnicianList.add(SelectTechnicianModel(
                technicianCode:
                    response.selectTechnicianEntity!.data![i]!.technicianCode,
                technicianName:
                    response.selectTechnicianEntity!.data![i]!.technicianName));
          }
        });
      } else {
        selectTechnicianList.clear();
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      getSpareStatusList();
    });

    return;
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    if (widget.selectedIndex == 0) {
      _showSpareStatusFragment = true;
      getSpareStatusList();
    } else if (widget.selectedIndex == 1) {
      _showImprestStatusFragment = true;
      getOnHandSpareList();
    } else if (widget.selectedIndex == 2) {
      getSelectTechnician();
      _showSpareTransferFragment = true;
      getSpareTransferList();
    }
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashBoard()));
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;

    return WillPopScope(
      onWillPop: () async {
        pushPage(context);
        return false;
      },
      child: MaterialApp(
        home: SafeArea(
            child: Scaffold(
          appBar: AppBar(
            title: const Text(MyConstants.spareInventory,
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
            leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashBoard()));
                },
                icon: const Icon(Icons.arrow_back_ios_outlined)),
          ),
          body: RefreshIndicator(
            onRefresh: refreshList,
            key: refreshKey,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MaterialSegmentedControl(
                      children: _children,
                      selectionIndex: _currentSelection,
                      borderColor: Colors.grey,
                      selectedColor: Color(int.parse("0xfff" "507a7d")),
                      unselectedColor: Colors.white,
                      borderRadius: 32.0,
                      horizontalPadding: const EdgeInsets.only(top: 10.0),
                      disabledChildren: const [
                        3,
                      ],
                      onSegmentChosen: (int index) {
                        setState(() {
                          if (_isLoading == true) {
                            setToastMessage(
                                context, MyConstants.requestAlready);
                          } else {
                            _currentSelection = index;
                            if (index == 0) {
                              _showSpareStatusFragment = true;
                              _showImprestStatusFragment = false;
                              _showSpareTransferFragment = false;
                              getSpareStatusList();
                            } else if (index == 1) {
                              _showImprestStatusFragment = true;
                              _showSpareStatusFragment = false;
                              _showSpareTransferFragment = false;
                              getOnHandSpareList();
                            } else if (index == 2) {
                              _showImprestStatusFragment = false;
                              _showSpareStatusFragment = false;
                              _showSpareTransferFragment = true;
                              getSpareTransferList();
                              getSelectTechnician();
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _showSpareStatusFragment,
                child: Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                            itemCount: 2,
                            controller: _spareStatus,
                            physics: _isLoading == true
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            onPageChanged: (index) {
                              setState(() {
                                _pageNotifier.value = index;
                                if (index == 0) {
                                  if (_isLoading == false) {
                                    getSpareStatusList();
                                  }
                                } else {
                                  if (_isLoading == false) {
                                    getPendingFrmList();
                                  }
                                }
                              });
                            },
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Container(
                                  child: spareStatusScreen(),
                                );
                              } else {
                                return Container(
                                  child: pendingFrmScreen(),
                                );
                              }
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SmoothPageIndicator(
                          controller: _spareStatus,
                          count: 2,
                          effect: WormEffect(
                              activeDotColor:
                                  Color(int.parse("0xfff" "2b6c72"))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _showImprestStatusFragment,
                child: Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                            itemCount: 2,
                            controller: _imprestStatus,
                            physics: _isLoading == true
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            onPageChanged: (index) {
                              setState(() {
                                _pageNotifier.value = index;
                                if (index == 0) {
                                  if (_isLoading == false) {
                                    getOnHandSpareList();
                                  }
                                } else {
                                  if (_isLoading == false) {
                                    getRequestedSpareList();
                                  }
                                }
                              });
                            },
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Container(
                                  child: onHandScreen(),
                                );
                              } else {
                                return Container(
                                  child: requestSpareScreen(),
                                );
                              }
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SmoothPageIndicator(
                          controller: _imprestStatus,
                          count: 2,
                          effect: WormEffect(
                              activeDotColor:
                                  Color(int.parse("0xfff" "2b6c72"))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _showSpareTransferFragment,
                child: Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                            itemCount: 2,
                            controller: _showTransfer,
                            physics: _isLoading == true
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            onPageChanged: (index) {
                              setState(() {
                                _pageNotifier.value = index;
                                if (index == 0) {
                                  if (_isLoading == false) {
                                    getSpareTransferList();
                                    getSelectTechnician();
                                  }
                                } else {
                                  if (_isLoading == false) {
                                    getReceiveTransferList();
                                  }
                                }
                              });
                            },
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Container(
                                  child: transferRequestScreen(),
                                );
                              } else {
                                return Container(
                                  child: transferReceiveScreen(),
                                );
                              }
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SmoothPageIndicator(
                          controller: _showTransfer,
                          count: 2,
                          effect: WormEffect(
                              activeDotColor:
                                  Color(int.parse("0xfff" "2b6c72"))),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]),
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
              : showFab
                  ? FloatingActionButton(
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
                    )
                  : null,
        )),
      ),
    );
  }

  Widget spareStatusScreen() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
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
                      child: const Text(MyConstants.spareStatus,
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                height: 40,
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
                    child: const Text(MyConstants.ticketId,
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 1,
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 40,
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
                    child: const Text(MyConstants.spareId,
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 1,
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 40,
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
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Text(MyConstants.spareName,
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 1,
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 40,
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
                    child: const Text(MyConstants.status,
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            )
          ],
        ),
        spareStatusGetApi()
      ]),
    );
  }

  Widget pendingFrmScreen() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                child: Container(
                  height: 25,
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
                      child: const Text(MyConstants.pendingFrm,
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
        Row(
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
                        child: const Text(MyConstants.ticketId,
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
              child: Padding(
                padding: const EdgeInsets.only(right: 0.0),
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
                        child: const Text(MyConstants.status,
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
        pendingFrmGetApi()
      ]),
    );
  }

  Widget onHandScreen() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                child: Container(
                  height: 35,
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
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: GestureDetector(
                              child: const Text(MyConstants.onHandSpare,
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: IconButton(
                            onPressed: () {
                              showModalBottomSheet<dynamic>(
                                  context: context,
                                  isScrollControlled: true,
                                  barrierColor: Colors.black.withAlpha(150),
                                  builder: (context) {
                                    return addConsumedSpareBottomSheet();
                                  });
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      ]),
                ),
              ),
            ),
          )
        ]),
        Row(
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
        onHandSpareGetApi()
      ]),
    );
  }

  Widget requestSpareScreen() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
              child: SizedBox(
                child: Container(
                  height: 25,
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
                      child: const Text(MyConstants.requestSpare,
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
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
            const SizedBox(
              width: 1,
            ),
            Expanded(
              flex: 1,
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
            const SizedBox(
              width: 1,
            ),
            Expanded(
              flex: 1,
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
                    child: const Text(MyConstants.quantity,
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 1,
            ),
            Expanded(
              flex: 1,
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
                    child: const Text(MyConstants.status,
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            )
          ],
        ),
        requestedSpareGetApi()
      ]),
    );
  }

  Widget transferRequestScreen() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                child: Container(
                  height: 35,
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
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: GestureDetector(
                              child: const Text(MyConstants.transferRequest,
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  barrierColor: Colors.black.withAlpha(150),
                                  builder: (context) {
                                    return addSpareTransferBottomSheet();
                                  });
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      ]),
                ),
              ),
            ),
          )
        ]),
        Row(
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
                        child: const Text(MyConstants.id,
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
                      child: const Text(MyConstants.toTechnician,
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
                        child: const Text(MyConstants.status,
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
        transferSpareGetAPi()
      ]),
    );
  }

  Widget transferReceiveScreen() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                child: Container(
                  height: 25,
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
                      child: const Text(MyConstants.receiveRequest,
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
        Row(
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
                        child: const Text(MyConstants.id,
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
                      child: const Text(MyConstants.toTechnician,
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
                        child: const Text(MyConstants.status,
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
        transferReceiveGetApi()
      ]),
    );
  }

  Widget spareStatusGetApi() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: refreshSpareStatus,
        child: _isLoading == true
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[400]!,
                child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
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
                    itemCount: spareStatusList.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              barrierColor: Colors.black.withAlpha(150),
                              builder: (context) {
                                return spareStatusBottomSheet(index);
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
                                                  spareStatusList[index]
                                                              .ticketId ==
                                                          null
                                                      ? MyConstants.na
                                                      : spareStatusList[index]
                                                          .ticketId!,
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
                                                  spareStatusList[index]
                                                              .spareCode ==
                                                          null
                                                      ? MyConstants.na
                                                      : spareStatusList[index]
                                                          .spareCode!,
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
                                                  spareStatusList[index]
                                                              .spareName ==
                                                          null
                                                      ? MyConstants.na
                                                      : spareStatusList[index]
                                                          .spareName!
                                                          .toString(),
                                                  textAlign: TextAlign.center ,
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
                                                  spareStatusList[index]
                                                              .spareCode ==
                                                          null
                                                      ? MyConstants.na
                                                      : spareStatusList[index]
                                                          .frmStatus!,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        )
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

  Widget pendingFrmGetApi() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: refreshPendingFrm,
        child: Container(
            child: _isLoading == true
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[400]!,
                    child: ListView.builder(
                        itemCount: 5,
                        shrinkWrap: true,
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
                                                    style: TextStyle(
                                                        fontSize: 11)),
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
                        itemCount: pendingFrmList.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  barrierColor: Colors.black.withAlpha(150),
                                  builder: (context) {
                                    return pendingFrmBottomSheet(index);
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
                                          children: [
                                            const Padding(
                                                padding:
                                                    EdgeInsets.all(5.0)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                      pendingFrmList[index]
                                                                  .ticketId ==
                                                              null
                                                          ? MyConstants.na
                                                          : pendingFrmList[
                                                                  index]
                                                              .ticketId!,
                                                      style: const TextStyle(
                                                          fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                      pendingFrmList[index]
                                                                  .spareCode ==
                                                              null
                                                          ? MyConstants.na
                                                          : pendingFrmList[
                                                                  index]
                                                              .spareCode!,
                                                      style: const TextStyle(
                                                          fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                      pendingFrmList[index]
                                                                  .spareCode ==
                                                              null
                                                          ? MyConstants.na
                                                          : pendingFrmList[
                                                                  index]
                                                              .frmStatus!,
                                                      style: const TextStyle(
                                                          fontSize: 11)),
                                                ],
                                              ),
                                            )
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
                      )),
      ),
    );
  }

  Widget onHandSpareGetApi() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: refreshOnHandSpare,
        child: _isLoading == true
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[400]!,
                child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
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
                    itemCount: onHandSpareList.length,
                    shrinkWrap: true,
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
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                                onHandSpareList[index]
                                                            .spareCode ==
                                                        null
                                                    ? MyConstants.na
                                                    : onHandSpareList[index]
                                                        .spareCode!,
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
                                                onHandSpareList[index]
                                                            .spareName ==
                                                        null
                                                    ? MyConstants.na
                                                    : onHandSpareList[index]
                                                        .spareName!,
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
                                                onHandSpareList[index]
                                                            .quantity ==
                                                        null
                                                    ? MyConstants.na
                                                    : onHandSpareList[index]
                                                        .quantity!
                                                        .toString(),
                                                style: const TextStyle(fontSize: 11)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ])));
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

  Widget requestedSpareGetApi() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: refreshRequestedSpare,
        child: _isLoading == true
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[400]!,
                child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
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
                    itemCount: requestedSpareList.length,
                    shrinkWrap: true,
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
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                                requestedSpareList[index]
                                                            .spareCode ==
                                                        null
                                                    ? MyConstants.na
                                                    : requestedSpareList[index]
                                                        .spareCode!,
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
                                                requestedSpareList[index]
                                                            .spareName ==
                                                        null
                                                    ? MyConstants.na
                                                    : requestedSpareList[index]
                                                        .spareName!,
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
                                                requestedSpareList[index]
                                                            .quantity ==
                                                        null
                                                    ? MyConstants.na
                                                    : requestedSpareList[index]
                                                        .quantity!
                                                        .toString(),
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
                                                requestedSpareList[index]
                                                            .status ==
                                                        null
                                                    ? MyConstants.na
                                                    : requestedSpareList[index]
                                                        .status!,
                                                style: const TextStyle(fontSize: 11)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ])));
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

  Widget transferSpareGetAPi() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: refreshTransferRequest,
        child: _isLoading == true
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[400]!,
                child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
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
                    itemCount: transferSpareList.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              barrierColor: Colors.black.withAlpha(150),
                              builder: (context) {
                                return spareTransferBottomSheet(index);
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
                                      children: [
                                        const Padding(
                                            padding: EdgeInsets.all(5.0)),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  transferSpareList[index]
                                                              .spareTransferId ==
                                                          null
                                                      ? MyConstants.na
                                                      : transferSpareList[index]
                                                          .spareTransferId!,
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
                                                  transferSpareList[index]
                                                              .toTech ==
                                                          null
                                                      ? MyConstants.na
                                                      : transferSpareList[index]
                                                          .toTech!,
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
                                                  transferSpareList[index]
                                                              .transferStatusName ==
                                                          null
                                                      ? MyConstants.na
                                                      : transferSpareList[index]
                                                          .transferStatusName!
                                                          .toString(),
                                                  style:
                                                      const TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        )
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

  Widget transferReceiveGetApi() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: refreshTransferReceive,
        child: _isLoading == true
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[400]!,
                child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
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
                    itemCount: receiveSpareList.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              barrierColor: Colors.black.withAlpha(150),
                              builder: (context) {
                                return spareReceiveBottomSheet(index);
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
                                      children: [
                                        const Padding(
                                            padding: EdgeInsets.all(5.0)),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  receiveSpareList[index]
                                                              .spareTransferId ==
                                                          null
                                                      ? MyConstants.na
                                                      : receiveSpareList[index]
                                                          .spareTransferId!,
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
                                                  receiveSpareList[index]
                                                              .fromTech ==
                                                          null
                                                      ? MyConstants.na
                                                      : receiveSpareList[index]
                                                          .fromTech!,
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
                                                  receiveSpareList[index]
                                                              .transferStatus ==
                                                          null
                                                      ? MyConstants.na
                                                      : receiveSpareList[index]
                                                          .transferStatus!
                                                          .toString(),
                                                  style:
                                                      const TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        )
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

  Future<void> refreshSpareStatus() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getSpareStatusList();
    });

    return;
  }

  Future<void> refreshPendingFrm() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getPendingFrmList();
    });

    return;
  }

  Future<void> refreshOnHandSpare() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getOnHandSpareList();
    });

    return;
  }

  Future<void> refreshRequestedSpare() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getRequestedSpareList();
    });

    return;
  }

  Future<void> refreshTransferRequest() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getSpareTransferList();
      getSelectTechnician();
    });

    return;
  }

  Future<void> refreshTransferReceive() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getReceiveTransferList();
    });

    return;
  }

  Widget spareStatusBottomSheet(int selectedSpareStatusItem) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Expanded(
                flex: 0,
                child: Container(
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
                            Text(
                              spareStatusList[selectedSpareStatusItem]
                                  .ticketId ==
                                  null
                                  ? MyConstants.na
                                  : spareStatusList[selectedSpareStatusItem]
                                  .ticketId!,
                              style: const TextStyle(color: Colors.white),
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
              ),
              Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 3,
                          child: Text(
                            MyConstants.ticketId,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          )),
                      const Expanded(
                        flex: 0,
                        child: Text(
                          ":",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                                spareStatusList[selectedSpareStatusItem].ticketId ==
                                    null
                                    ? MyConstants.na
                                    : spareStatusList[selectedSpareStatusItem]
                                    .ticketId!),
                          ))
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 3,
                          child: Text(
                            MyConstants.status,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          )),
                      const Expanded(
                        flex: 0,
                        child: Text(
                          ":",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                                spareStatusList[selectedSpareStatusItem].frmStatus ==
                                    null
                                    ? MyConstants.na
                                    : spareStatusList[selectedSpareStatusItem]
                                    .frmStatus!),
                          ))
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 3,
                          child: Text(
                            MyConstants.invoiceNumber,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          )),
                      const Expanded(
                        flex: 0,
                        child: Text(
                          ":",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                                spareStatusList[selectedSpareStatusItem].invoiceNumber ==
                                    null
                                    ? MyConstants.na
                                    : spareStatusList[selectedSpareStatusItem]
                                    .invoiceNumber!),
                          ))
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 3,
                          child: Text(
                            MyConstants.docketNumber,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          )),
                      const Expanded(
                        flex: 0,
                        child: Text(
                          ":",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                                spareStatusList[selectedSpareStatusItem].docketNumber ==
                                    null
                                    ? MyConstants.na
                                    : spareStatusList[selectedSpareStatusItem]
                                    .docketNumber!),
                          ))
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
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
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: SizedBox(
                            child: Container(
                              height: 25,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(int.parse("0xfff" "507a7d")),
                                    Color(int.parse("0xfff" "507a7d"))
                                  ],
                                ),
                              ),
                              child: Center(
                                child: GestureDetector(
                                  child: const Text(MyConstants.location,
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
                ),
              ),
              Expanded(
                flex: 0,
                child: ListView.builder(
                    itemCount: 1,
                    shrinkWrap: true,
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
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          // new Padding(
                                          //     padding: new EdgeInsets.all(5.0)),
                                          Expanded(
                                            flex: 0,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                    spareStatusList[
                                                    selectedSpareStatusItem]
                                                        .spareCode!,
                                                    style:
                                                    const TextStyle(fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                    spareStatusList[selectedSpareStatusItem]
                                                        .spareLocation ==
                                                        null ||  spareStatusList[selectedSpareStatusItem]
                                                        .spareLocation!.isEmpty
                                                        ? MyConstants.na
                                                        : spareStatusList[
                                                    selectedSpareStatusItem]
                                                        .spareLocation ?? MyConstants.na,
                                                    style:
                                                    const TextStyle(fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 0,
                                                  child: Text(
                                                      spareStatusList[selectedSpareStatusItem]
                                                          .spareQuantity ==
                                                          null
                                                          ? MyConstants.na
                                                          : spareStatusList[
                                                      selectedSpareStatusItem]
                                                          .spareQuantity!
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 11)),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                  ])));
                    }),
              )
            ]),
          );
        });
  }

  Widget pendingFrmBottomSheet(int selectedSpareReceiveItem) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
            flex: 0,
            child: Container(
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
                        Text(
                          pendingFrmList[selectedSpareReceiveItem]
                                      .ticketId ==
                                  null
                              ? MyConstants.na
                              : pendingFrmList[selectedSpareReceiveItem]
                                  .ticketId!,
                          style: const TextStyle(color: Colors.white),
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
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 15.0),
              child: Row(
                children: [
                  const Expanded(
                      flex: 0,
                      child: Text(
                        "${MyConstants.ticketId}     :",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                        pendingFrmList[selectedSpareReceiveItem].ticketId ==
                                null
                            ? MyConstants.na
                            : pendingFrmList[selectedSpareReceiveItem]
                                .ticketId!),
                  ))
                ],
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 15.0),
              child: Row(
                children: [
                  const Expanded(
                      flex: 0,
                      child: Text(
                        "${MyConstants.status}          :",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                        pendingFrmList[selectedSpareReceiveItem].frmStatus ==
                                null
                            ? MyConstants.na
                            : pendingFrmList[selectedSpareReceiveItem]
                                .frmStatus!),
                  ))
                ],
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: SizedBox(
                        child: Container(
                          height: 25,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(int.parse("0xfff" "507a7d")),
                                Color(int.parse("0xfff" "507a7d"))
                              ],
                            ),
                          ),
                          child: Center(
                            child: GestureDetector(
                              child: const Text(MyConstants.location,
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
            ),
          ),
          Expanded(
            flex: 0,
            child: ListView.builder(
                itemCount: 1,
                shrinkWrap: true,
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
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  // new Padding(
                                  //     padding: new EdgeInsets.all(5.0)),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                            pendingFrmList[
                                                    selectedSpareReceiveItem]
                                                .spareCode!,
                                            style:
                                                const TextStyle(fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                            pendingFrmList[selectedSpareReceiveItem]
                                                        .spareLocation ==
                                                    null ||  pendingFrmList[selectedSpareReceiveItem]
                                                .spareLocation!.isEmpty
                                                ? MyConstants.na
                                                : pendingFrmList[
                                                        selectedSpareReceiveItem]
                                                    .spareLocation ?? MyConstants.na,
                                            style:
                                                const TextStyle(fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 0,
                                          child: Text(
                                              pendingFrmList[selectedSpareReceiveItem]
                                                          .spareQuantity ==
                                                      null
                                                  ? MyConstants.na
                                                  : pendingFrmList[
                                                          selectedSpareReceiveItem]
                                                      .spareQuantity!
                                                      .toString(),
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                          ])));
                }),
          ),
          Expanded(
            flex: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  callFieldReturnMaterialSubmit(
                      context,
                      pendingFrmList[selectedSpareReceiveItem].ticketId,
                      pendingFrmList[selectedSpareReceiveItem].spareCode,
                      pendingFrmList[selectedSpareReceiveItem].spareQuantity,
                      pendingFrmList[selectedSpareReceiveItem].spareLocation,
                      selectedSpareReceiveItem);
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)), backgroundColor: Color(int.parse("0xfff" "2a9d8f")),
                    minimumSize: const Size(140, 35)),
                child: const Text(MyConstants.transfer,
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(
            height: 15.0,
          )
        ]),
      );
    });
  }

  Widget spareTransferBottomSheet(int selectedSpareTransferItem) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
      mystate(() {
        if (transferSpareList[selectedSpareTransferItem].transferStatusName ==
            MyConstants.accepted) {
          _showTransferButton = true;
          _showReceiveButton = false;
        } else {
          _showTransferButton = false;
          _showReceiveButton = false;
        }
      });
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
            flex: 0,
            child: Container(
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
                        Text(
                          transferSpareList[selectedSpareTransferItem]
                                      .spareTransferId ==
                                  null
                              ? MyConstants.na
                              : transferSpareList[selectedSpareTransferItem]
                                  .spareTransferId!,
                          style: const TextStyle(color: Colors.white),
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
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 15.0),
              child: Row(
                children: [
                  const Expanded(
                      flex: 0,
                      child: Text(
                        "${MyConstants.toTechnician}     :",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                        transferSpareList[selectedSpareTransferItem].toTech ==
                                null
                            ? MyConstants.na
                            : transferSpareList[selectedSpareTransferItem]
                                .toTech!),
                  ))
                ],
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 15.0),
              child: Row(
                children: [
                  const Expanded(
                      flex: 0,
                      child: Text(
                        "${MyConstants.status}                   :",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(transferSpareList[selectedSpareTransferItem]
                                .transferStatusName ==
                            null
                        ? MyConstants.na
                        : transferSpareList[selectedSpareTransferItem]
                            .transferStatusName!),
                  ))
                ],
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
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
            ),
          ),
          Expanded(
            flex: 0,
            child: ListView.builder(
                itemCount: 1,
                shrinkWrap: true,
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
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                            transferSpareList[
                                                            selectedSpareTransferItem]
                                                        .spareCode ==
                                                    null
                                                ? MyConstants.na
                                                : transferSpareList[
                                                        selectedSpareTransferItem]
                                                    .spareCode!,
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
                                            transferSpareList[
                                                            selectedSpareTransferItem]
                                                        .quantity ==
                                                    null
                                                ? MyConstants.na
                                                : transferSpareList[
                                                        selectedSpareTransferItem]
                                                    .quantity!
                                                    .toString(),
                                            style:
                                                const TextStyle(fontSize: 11)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                          ])));
                }),
          ),
          Expanded(
            flex: 0,
            child: Visibility(
              visible: _showTransferButton,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      transferSparePostApi(
                          context,
                          transferSpareList[selectedSpareTransferItem]
                              .spareTransferId,
                          selectedSpareTransferItem);
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                    child: const Text(MyConstants.transfer,
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15.0,
          )
        ]),
      );
    });
  }

  Widget spareReceiveBottomSheet(int selectedSpareReceiveItem) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
      mystate(() {
        if (receiveSpareList[selectedSpareReceiveItem].transferStatus ==
            MyConstants.trans) {
          _showTransferButton = false;
          _showReceiveButton = true;
        } else {
          _showTransferButton = false;
          _showReceiveButton = false;
        }
      });

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
            flex: 0,
            child: Container(
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
                        Text(
                          receiveSpareList[selectedSpareReceiveItem]
                                      .spareTransferId ==
                                  null
                              ? MyConstants.na
                              : receiveSpareList[selectedSpareReceiveItem]
                                  .spareTransferId!,
                          style: const TextStyle(color: Colors.white),
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
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 15.0),
              child: Row(
                children: [
                  const Expanded(
                      flex: 0,
                      child: Text(
                        "${MyConstants.fromTechnician}     :",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(receiveSpareList[selectedSpareReceiveItem]
                                .fromTech ==
                            null
                        ? MyConstants.na
                        : receiveSpareList[selectedSpareReceiveItem]
                            .fromTech!),
                  ))
                ],
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 15.0),
              child: Row(
                children: [
                  const Expanded(
                      flex: 0,
                      child: Text(
                        "${MyConstants.status}                       :",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(receiveSpareList[selectedSpareReceiveItem]
                                .transferStatus ==
                            null
                        ? MyConstants.na
                        : receiveSpareList[selectedSpareReceiveItem]
                            .transferStatus!),
                  ))
                ],
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
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
            ),
          ),
          Expanded(
            flex: 0,
            child: ListView.builder(
                itemCount: 1,
                shrinkWrap: true,
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
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                            receiveSpareList[
                                                            selectedSpareReceiveItem]
                                                        .spareCode ==
                                                    null
                                                ? MyConstants.na
                                                : receiveSpareList[
                                                        selectedSpareReceiveItem]
                                                    .spareCode!,
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
                                            receiveSpareList[
                                                            selectedSpareReceiveItem]
                                                        .quantity ==
                                                    null
                                                ? MyConstants.na
                                                : receiveSpareList[
                                                        selectedSpareReceiveItem]
                                                    .quantity!
                                                    .toString(),
                                            style:
                                                const TextStyle(fontSize: 11)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                          ])));
                }),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 0,
            child: Visibility(
              visible: _showReceiveButton,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    receiverSparePostApi(
                        context,
                        receiveSpareList[selectedSpareReceiveItem]
                            .spareTransferId,
                        selectedSpareReceiveItem);
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)), backgroundColor: Color(int.parse("0xfff" "2a9d8f")),
                      minimumSize: const Size(140, 40)),
                  child: const Text(MyConstants.receive,
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15.0,
          )
        ]),
      );
    });
  }

  Widget addSpareTransferBottomSheet() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
      getConsumedSpareData();
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Expanded(
              flex: 0,
              child: Container(
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
                            MyConstants.addSpareTransfer,
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
            ),
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 15.0, left: 15.0),
                child: Row(children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      enabled: false,
                      showCursor: false,
                      controller: requiredSpareController,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                          labelText: MyConstants.requiredSpare,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const OnHandSpare(
                                      MyConstants.imprestStatus, "")));
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "2a9d8f"))),
                        child: const Text(MyConstants.addButton,
                            style:
                                TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                child: Container(
                  height: 50,
                  color: Color(int.parse("0xfff" "778899")),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      contentPadding: const EdgeInsets.all(2),
                    ),
                    child: DropdownButtonFormField<SelectTechnicianModel>(
                      isExpanded: true,
                      menuMaxHeight: MediaQuery.of(context).size.height / 3,
                      value: _selectTechnicianModel,
                      iconEnabledColor: Colors.white,
                      dropdownColor: Color(int.parse("0xfff" "778899")),
                      hint: const Text(
                        MyConstants.selectTechnicianHint,
                        style: TextStyle(color: Colors.white),
                      ),
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(int.parse("0xfff" "778899")))),
                        contentPadding: const EdgeInsets.all(5),
                      ),
                      elevation: 0,
                      onChanged: (SelectTechnicianModel? data) {
                        setState(() {
                          _selectTechnicianModel = data!;
                          _toTechId = data.technicianCode;
                        });
                      },
                      items: selectTechnicianList
                          .map((SelectTechnicianModel value) {
                        return DropdownMenuItem<SelectTechnicianModel>(
                          value: value,
                          child: Text(
                            value.technicianName!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15.0, bottom: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (requiredSpareController.text.isEmpty) {
                      setToastMessage(
                          context, MyConstants.selectedTransferSpareError);
                    } else if (_selectTechnicianModel == null) {
                      setToastMessage(context,
                          MyConstants.selectedTransferSpareDropDownError);
                    } else {
                      requestSpareTransfer(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                  child: const Text(MyConstants.requestButton,
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }

  Widget addConsumedSpareBottomSheet() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
      getOnHandSpareData();
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Expanded(
              flex: 0,
              child: Container(
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
                            MyConstants.addConsumedSpare,
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
            ),
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 15.0, left: 15.0),
                child: Row(children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      enabled: false,
                      showCursor: false,
                      controller: onHandSpareRequiredController,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                          labelText: MyConstants.requiredSpare,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder()),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SpareCart(
                                      MyConstants.imprestStatus, null)));
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "2a9d8f"))),
                        child: const Text(MyConstants.addButton,
                            style:
                                TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 15.0, left: 15.0),
                child: TextFormField(
                  controller: onHandSpareCommentController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      labelText: MyConstants.comments,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      border: OutlineInputBorder()),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (onHandSpareRequiredController.text.isEmpty) {
                        setToastMessage(
                            context, MyConstants.selectedTransferSpareError);
                      } else if (onHandSpareCommentController.text.isEmpty) {
                        setToastMessage(context, MyConstants.commentError);
                      } else {
                        FocusScope.of(context).requestFocus(FocusNode());
                        requestOnHandTransfer(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                    child: const Text(MyConstants.requestButton,
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                ),
              ),
            ),
            const Expanded(
                flex: 0,
                child: SizedBox(
                  height: 10.0,
                ))
          ]),
        ),
      );
    });
  }

  Future<void> getConsumedSpareData() async {
    String? getSpareName;
    int? updateQuantity;
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
    var result = await consumedSpareRequestDataDao.updateSpareCart(true);
    List<ConsumedSpareRequestDataTable?> consumedSpareRequestData = result;
    if (requiredSpareController.text.isEmpty) {
      if (consumedSpareRequestData.isNotEmpty) {
        for (int i = 0; i < consumedSpareRequestData.length; i++) {
          getSpareName = consumedSpareRequestData[i]!.spareName;
          updateQuantity = consumedSpareRequestData[i]!.updateQuantity;
          String showConsumedSpareDataset = "$getSpareName${MyConstants.openBracket}$updateQuantity${MyConstants.closedBracket},";
          _showConsumedSpareData =
              (showConsumedSpareDataset + _showConsumedSpareData);
        }
        requiredSpareController.text = _showConsumedSpareData;
      }
    }
  }

  Future<void> getOnHandSpareData() async {
    String? getSpareName;
    int? updateQuantity;
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final spareRequestDataDao = database.spareRequestDataDao;
    var result = await spareRequestDataDao.updateSpareRequestData(true);
    List<SpareRequestDataTable?> onHandSpareData = result;
    if (onHandSpareRequiredController.text.isEmpty) {
      if (onHandSpareData.isNotEmpty) {
        for (int i = 0; i < onHandSpareData.length; i++) {
          getSpareName = onHandSpareData[i]!.spareName;
          updateQuantity = onHandSpareData[i]!.updateQuantity;
          String showConsumedSpareDataset = "$getSpareName${MyConstants.openBracket}$updateQuantity${MyConstants.closedBracket},";
          _showConsumedSpareData =
              (showConsumedSpareDataset + _showConsumedSpareData);
        }
        onHandSpareRequiredController.text = _showConsumedSpareData;
      }
    }
  }

  Future<void> requestSpareTransfer(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
      var result = await consumedSpareRequestDataDao.updateSpareCart(true);
      List<ConsumedSpareRequestDataTable?> consumedSpareRequestData = result;

      final combinedData = <Map<String, dynamic>>[];

      if (consumedSpareRequestData.isNotEmpty) {
        for (int i = 0; i < consumedSpareRequestData.length; i++) {
          Map<String, String> hi = {
            'quantity': consumedSpareRequestData[i]!.updateQuantity.toString(),
            'spare_code': consumedSpareRequestData[i]!.spareCode,
            'spare_location_id':
                consumedSpareRequestData[i]!.spareLocationId.toString()
          };
          combinedData.add(hi);
        }
      }

      final Map<String, dynamic> punchOutData = {
        'from_tech': PreferenceUtils.getString(MyConstants.technicianCode),
        'spare_array': combinedData,
        'to_tech': _toTechId
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.postAddSpareTransfer(
          PreferenceUtils.getString(MyConstants.token), punchOutData);
      if (response.addTransferEntity!.responseCode == MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          setToastMessage(context, response.addTransferEntity!.message!);
          consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();
          Navigator.of(context, rootNavigator: true).pop();
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashBoard()));
          });
        });
      } else if (response.addTransferEntity!.responseCode ==
          MyConstants.response400) {
        PreferenceUtils.setString(
            MyConstants.token, response.addTransferEntity!.token!);
        setToastMessage(context, MyConstants.authenticationError);
        consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> requestOnHandTransfer(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final spareRequestDataDao = database.spareRequestDataDao;
      var result = await spareRequestDataDao.updateSpareRequestData(true);
      List<SpareRequestDataTable?> onHandSpareRequestData = result;

      final combinedData = <Map<String, dynamic>>[];

      if (onHandSpareRequestData.isNotEmpty) {
        for (int i = 0; i < onHandSpareRequestData.length; i++) {
          Map<String, String> hi = {
            'quantity': onHandSpareRequestData[i]!.updateQuantity.toString(),
            'spare_code': onHandSpareRequestData[i]!.spareCode,
            'spare_location_id':
                onHandSpareRequestData[i]!.locationId.toString()
          };
          combinedData.add(hi);
        }
      }

      final Map<String, dynamic> onHandSubmitData = {
        'technician_code':
            PreferenceUtils.getString(MyConstants.technicianCode),
        'spare_array': combinedData,
        'comments': onHandSpareCommentController.text.trim()
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.postPersonalSpareRequest(
          PreferenceUtils.getString(MyConstants.token), onHandSubmitData);
      if (response.addTransferEntity!.responseCode == MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          setToastMessage(context, response.addTransferEntity!.message!);
          spareRequestDataDao.deleteSpareRequestDataTable();
          Navigator.of(context, rootNavigator: true).pop();
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashBoard()));
          });
        });
      } else if (response.addTransferEntity!.responseCode ==
          MyConstants.response400) {
        PreferenceUtils.setString(
            MyConstants.token, response.addTransferEntity!.token!);
        setToastMessage(context, MyConstants.authenticationError);
        spareRequestDataDao.deleteSpareRequestDataTable();
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> transferSparePostApi(BuildContext context,
      String? spareTransferId, int selectedSpareTransferItem) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);
      final Map<String, dynamic> punchOutData = {
        'technician_code': _getTechnicianCode,
        'spare_transfer_id': spareTransferId
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.acceptTransferSpare(
          PreferenceUtils.getString(MyConstants.token), punchOutData);
      if (response.transferResponseEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.transferResponseEntity!.token!);
          transferSpareList[selectedSpareTransferItem].transferStatusName =
              MyConstants.transfered;
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pop();
          setToastMessage(context, response.transferResponseEntity!.message!);
        });
      } else if (response.transferResponseEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.transferResponseEntity!.token!);
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pop();
          setToastMessage(context, response.transferResponseEntity!.message!);
        });
      } else if (response.transferResponseEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pop();
          setToastMessage(context, response.transferResponseEntity!.message!);
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> receiverSparePostApi(BuildContext context,
      String? spareTransferId, int selectedSpareTransferItem) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);
      _getTechnicianCode =
          PreferenceUtils.getString(MyConstants.technicianCode);
      final Map<String, dynamic> punchOutData = {
        'technician_code': _getTechnicianCode,
        'spare_transfer_id': spareTransferId
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.receiveTransferSpare(
          PreferenceUtils.getString(MyConstants.token), punchOutData);
      if (response.transferResponseEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.transferResponseEntity!.token!);
          receiveSpareList[selectedSpareTransferItem].transferStatus =
              MyConstants.received;
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pop();
          setToastMessage(context, response.transferResponseEntity!.message!);
        });
      } else if (response.transferResponseEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.transferResponseEntity!.token!);
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pop();
          setToastMessage(context, response.transferResponseEntity!.message!);
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> callFieldReturnMaterialSubmit(
      BuildContext context,
      String? ticketId,
      String? spareCode,
      int? spareQuantity,
      String? dropOfLocation,
      int selectedSpareTransferItem) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);

      final combinedData = <Map<String, dynamic>>[];

      for (int i = 0; i < 1; i++) {
        Map<String, dynamic> dropSpareData = {
          'spare_code': spareCode!,
          'spare_name': spareCode,
          'quantity': spareQuantity!
        };
        combinedData.add(dropSpareData);
      }

      final Map<String, dynamic> punchOutData = {
        'technician_code':
            PreferenceUtils.getString(MyConstants.technicianCode),
        'ticket_id': ticketId,
        'frm_status': MyConstants.updateQuantity,
        'drop_of_location': dropOfLocation,
        'drop_of_date': formattedDate,
        'drop_spare': combinedData,
        'frm': '1'
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getupdateFieldReturnMatrial(
          PreferenceUtils.getString(MyConstants.token), punchOutData);
      if (response.addTransferEntity!.responseCode == MyConstants.response200) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, response.addTransferEntity!.message!);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashBoard()));
          });
        });
      } else if (response.addTransferEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context).pop();
          setToastMessage(context, response.addTransferEntity!.message!);
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }
}
