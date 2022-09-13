import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:fieldpro_genworks_healthcare/screens/new_amc.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shimmer/shimmer.dart';

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/db/search_amc_contract_data.dart';
import '../network/model/amc_model.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/technician_punch.dart';
import '../utility/validator.dart';
import 'dashboard.dart';
import 'update_amc.dart';

class AMC extends StatefulWidget {
  const AMC({Key? key}) : super(key: key);

  @override
  _AMCState createState() => _AMCState();
}

class _AMCState extends State<AMC> {
  final TextEditingController _searchAmcController = TextEditingController();
  final _amcList = <AMCModel>[];
  String? _invoiceId;
  bool? _isLoading, _searchAMCScreen = false;

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashBoard()));
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);

    return WillPopScope(
      onWillPop: () async {
        pushPage(context);
        return true;
      },
      child: MaterialApp(
        home: SafeArea(
            child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashBoard())),
            ),
            title: const Text(MyConstants.amcTittle),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 0,
                    child: Row(children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _searchAmcController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              labelText: MyConstants.searchAmc,
                              prefixIcon: Icon(Icons.search),
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: ElevatedButton(
                            onPressed: () => searchAMC(),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "2a9d8f"))),
                            child: const Text(MyConstants.searchButton,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white)),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Expanded(
                      flex: 0,
                      child: Visibility(
                          visible: _searchAMCScreen!,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: regExp.hasMatch(_searchAmcController.text.trim()) ? ElevatedButton(
                              onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddAmc(
                                            type: MyConstants.createProduct,
                                            customerContact:
                                                _searchAmcController.text
                                                    .trim(),
                                            id: MyConstants.updateQuantity,
                                          ))),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "2a9d8f"))),
                              child: const Text(MyConstants.addNewProductButton,
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white)),
                            ) : null,
                          ))),
                  Expanded(
                      flex: 0,
                      child: _isLoading == true
                          ? Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[400]!,
                              child: ListView.builder(
                                  itemCount: 5,
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(16.0),
                                  itemBuilder: (context, index) {
                                    return Container(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Card(
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              Row(children: [
                                                const Padding(
                                                    padding: EdgeInsets.all(
                                                        5.0)),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: const <Widget>[
                                                      Text("",
                                                          style: TextStyle(
                                                              fontSize: 15)),
                                                    ],
                                                  ),
                                                )
                                              ])
                                            ])));
                                  }))
                          : Visibility(
                              visible: _searchAMCScreen!,
                              child: searchAMCScreen()))
                ],
              ),
            ),
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

  Widget searchAMCScreen() {
    return RefreshIndicator(
        onRefresh: refreshAMC,
        child: ListView.builder(
            itemCount: _amcList.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 10.0),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (_amcList[index].daysLeft == MyConstants.chargeable) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateAMC(
                                  id: index + 1,
                                  invoice: _invoiceId,
                                )));
                  } else {
                    ArtSweetAlert.show(
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            title: MyConstants.appTittle,
                            text: MyConstants.whenRemaining +
                                _amcList[index].daysLeft.toString() +
                                MyConstants.wantContinue,
                            showCancelBtn: true,
                            confirmButtonText: MyConstants.yesButton,
                            cancelButtonText: MyConstants.noButton,
                            onConfirm: () {
                              Navigator.of(context, rootNavigator: true).pop();

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdateAMC(
                                            id: index + 1,
                                            invoice: _invoiceId,
                                          )));
                            },
                            onCancel: () =>
                                Navigator.of(context, rootNavigator: true)
                                    .pop(),
                            cancelButtonColor:
                                Color(int.parse("0xfff" "C5C5C5")),
                            confirmButtonColor:
                                Color(int.parse("0xfff" "507a7d"))));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 0),
                  child: Card(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Expanded(
                        flex: 0,
                        child: Container(
                            padding: const EdgeInsets.only(top: 0),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Expanded(
                                    flex: 0,
                                    child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: Color(
                                                int.parse("0xfff" "5C7E7F")),
                                            borderRadius: BorderRadius.zero),
                                        child: Padding(
                                            padding: const EdgeInsets.only(left: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                Text(
                                                  _amcList[index].customerName!,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  _amcList[index]
                                                          .daysLeft
                                                          .toString() +
                                                      MyConstants.daysLeft,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ))),
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Row(
                                      children: [
                                        const Padding(
                                            padding: EdgeInsets.all(5.0)),
                                        Expanded(
                                          flex: 0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const <Widget>[
                                              Text(
                                                  "${MyConstants.product}            :",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(left: 10.0),
                                                child: Text(
                                                    _amcList[index]
                                                        .productName!,
                                                    style: const TextStyle(
                                                        fontSize: 15)),
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
                                  Expanded(
                                    flex: 0,
                                    child: Row(
                                      children: [
                                        const Padding(
                                            padding: EdgeInsets.all(5.0)),
                                        Expanded(
                                          flex: 0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const <Widget>[
                                              Text(
                                                  "${MyConstants.subCategory}  :",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(left: 10.0),
                                                child: Text(
                                                    _amcList[index]
                                                        .subCategoryName!,
                                                    style: const TextStyle(
                                                        fontSize: 15)),
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
                                  Expanded(
                                    flex: 0,
                                    child: Row(
                                      children: [
                                        const Padding(
                                            padding: EdgeInsets.all(5.0)),
                                        Expanded(
                                          flex: 0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const <Widget>[
                                              Text(
                                                  "${MyConstants.amcView}                 :",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(left: 10.0),
                                                child: Text(
                                                    capitalize(_amcList[index]
                                                        .contractType!),
                                                    style: const TextStyle(
                                                        fontSize: 15)),
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
                                  Expanded(
                                    flex: 0,
                                    child: Row(
                                      children: [
                                        const Padding(
                                            padding: EdgeInsets.all(5.0)),
                                        Expanded(
                                          flex: 0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const <Widget>[
                                              Text(
                                                  "${MyConstants.serialNo}         :",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(left: 10.0),
                                                child: Text(
                                                    _amcList[index].serialNo!,
                                                    style: const TextStyle(
                                                        fontSize: 15)),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                ])),
                      )
                    ]),
                  ),
                ),
              );
            }));
  }

  Future<void> refreshAMC() async {
    await Future.delayed(const Duration(seconds: 0));
    searchAMC();

    return;
  }

  void searchAMC() async {
    if (_searchAmcController.text.trim().isEmpty) {
      setToastMessage(context, MyConstants.amcError);
    } else {
      if (await checkInternetConnection() == true) {
        setState(() {
          _isLoading = true;
          _searchAMCScreen = false;
          PreferenceUtils.setString(
              MyConstants.technicianStatus, MyConstants.free);
        });

        _amcList.clear();

        String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
        RegExp regExp = RegExp(pattern);

        Map<String, dynamic> searchAMCData = {
          'technician_code':
              PreferenceUtils.getString(MyConstants.technicianCode),
          'contact_number': regExp.hasMatch(_searchAmcController.text.trim())
              ? _searchAmcController.text.trim()
              : MyConstants.empty,
          'amc_id': !regExp.hasMatch(_searchAmcController.text.trim())
              ? _searchAmcController.text.trim()
              : MyConstants.empty
        };

        FocusScope.of(context).requestFocus(FocusNode());

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.amcSearch(
            PreferenceUtils.getString(MyConstants.token), searchAMCData);

        final database = await $FloorAppDatabase
            .databaseBuilder('floor_database.db')
            .build();
        final searchAMCContractDataDao = database.searchAMCContractDataDao;

        if (response.response != null) {
          if (response.response!.responseCode == MyConstants.response200) {
            await searchAMCContractDataDao.deleteSearchAMCContractDataTable();
            setState(() {
              PreferenceUtils.setString(
                  MyConstants.token, response.response!.token!);

              for (int i = 0; i < response.response!.data!.length; i++) {
                _amcList.add(AMCModel(
                    serialNo: response.response!.data![i]!.serialNo ?? "",
                    location: response.response!.data![i]!.location ?? "",
                    productId: response.response!.data![i]!.productId ?? 0,
                    productName: response.response!.data![i]!.productName ?? "",
                    city: response.response!.data![i]!.city ?? "",
                    street: response.response!.data![i]!.street ?? "",
                    country: response.response!.data![i]!.country ?? "",
                    state: response.response!.data![i]!.state ?? "",
                    contactNumber:
                        response.response!.data![i]!.contactNumber ?? "",
                    contractType:
                        response.response!.data![i]!.contractType ?? "",
                    contractAmmount:
                        response.response!.data![i]!.contractAmmount ?? 0,
                    contractDuration:
                        response.response!.data![i]!.contractDuration ?? 0,
                    contractId: response.response!.data![i]!.contractId ?? 0,
                    customerName:
                        response.response!.data![i]!.customerName ?? "",
                    customerCode:
                        response.response!.data![i]!.customerCode ?? "",
                    daysLeft: response.response!.data![i]!.daysLeft ?? 0,
                    emailId: response.response!.data![i]!.emailId ?? "",
                    expiryDay: response.response!.data![i]!.expiryDay ?? "",
                    flag: response.response!.data![i]!.flag ?? 0,
                    modelNo: response.response!.data![i]!.modelNo ?? "",
                    plotNumber: response.response!.data![i]!.plotNumber ?? "",
                    postCode: response.response!.data![i]!.postCode ?? 0,
                    startDate: response.response!.data![i]!.contractType ?? "",
                    subCategoryId:
                        response.response!.data![i]!.subCategoryId ?? 0,
                    subCategoryName:
                        response.response!.data![i]!.subCategoryName ?? "",
                    invoiceId: response.response!.data![i]!.invoiceId ?? ""));

                SearchAMCContractDataTable searchAMCContractDataTable =
                    SearchAMCContractDataTable(
                        id: i + 1,
                        serialNo: response.response!.data![i]!.serialNo ?? "",
                        location: response.response!.data![i]!.location ?? "",
                        productId: response.response!.data![i]!.productId ?? 0,
                        productName: response
                                .response!.data![i]!.productName ??
                            "",
                        city: response.response!.data![i]!.city ?? "",
                        street: response.response!.data![i]!.street ?? "",
                        country: response.response!.data![i]!.country ?? "",
                        state: response.response!.data![i]!.state ?? "",
                        contactNumber:
                            response.response!.data![i]!.contactNumber ?? "",
                        contractType:
                            response.response!.data![i]!.contractType ?? "",
                        contractAmmount:
                            response.response!.data![i]!.contractAmmount ?? 0,
                        contractDuration:
                            response.response!.data![i]!.contractDuration ?? 0,
                        contractId:
                            response.response!.data![i]!.contractId ?? 0,
                        customerName:
                            response.response!.data![i]!.customerName ?? "",
                        customerCode:
                            response.response!.data![i]!.customerCode ?? "",
                        daysLeft: response.response!.data![i]!.daysLeft ?? 0,
                        emailId: response.response!.data![i]!.emailId ?? "",
                        expiryDay: response.response!.data![i]!.expiryDay ?? "",
                        flag: response.response!.data![i]!.flag ?? 0,
                        modelNo: response.response!.data![i]!.modelNo ?? "",
                        plotNumber:
                            response.response!.data![i]!.plotNumber ?? "",
                        postCode: response.response!.data![i]!.postCode ?? 0,
                        startDate:
                            response.response!.data![i]!.contractType ?? "",
                        subCategoryId:
                            response.response!.data![i]!.subCategoryId ?? 0,
                        subCategoryName:
                            response.response!.data![i]!.subCategoryName ?? "",
                        invoiceId: response.response!.data![i]!.invoiceId ?? "");

                searchAMCContractDataDao
                    .insertSearchAMCContractData(searchAMCContractDataTable);
                _isLoading = false;
                _searchAMCScreen = true;
              }
            });
          } else {
            setState(() {
              if (response.response!.responseCode == MyConstants.response400) {
                PreferenceUtils.setString(
                    MyConstants.token, response.response!.token!);
              }
              _isLoading = !_isLoading!;
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      title: MyConstants.appTittle,
                      text:
                          response.response!.message ?? MyConstants.noContract,
                      showCancelBtn: true,
                      confirmButtonText: MyConstants.yesButton,
                      cancelButtonText: MyConstants.noButton,
                      onConfirm: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddAmc(
                                    type: MyConstants.createAMC,
                                    customerContact:
                                        _searchAmcController.text.trim(),
                                    id: 0)));
                      },
                      onCancel: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      cancelButtonColor: Color(int.parse("0xfff" "C5C5C5")),
                      confirmButtonColor:
                          Color(int.parse("0xfff" "507a7d"))));
            });
          }
        } else {
          setToastMessage(context, MyConstants.internalServerError);
        }
      } else {
        setToastMessage(context, MyConstants.internetConnection);
      }
    }
  }
}
