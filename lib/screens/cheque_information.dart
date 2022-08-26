import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;
import 'package:number_to_words/number_to_words.dart';
import 'package:shimmer/shimmer.dart';

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'amc_details.dart';
import 'dashboard.dart';

class ChequeInformation extends StatefulWidget {
  final int? contractId, amcId, amcDuration;
  final String? amount, customerName;

  const ChequeInformation(
      {Key? key,
      this.contractId,
      this.amcId,
      this.amcDuration,
      this.amount,
      @required this.customerName})
      : super(key: key);

  @override
  _ChequeInformationState createState() => _ChequeInformationState();
}

class _ChequeInformationState extends State<ChequeInformation> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _payController = TextEditingController();
  final TextEditingController _rupeeController = TextEditingController();
  final TextEditingController _totalRupeeController = TextEditingController();
  final TextEditingController _chequeNumberController = TextEditingController();
  DateTime? selectedDate = DateTime.now();
  String? _contractStartDate;
  bool? _isLoading = true;

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AMC()));
  }

  void setDetails() async {
    setState(() {
      _isLoading = true;
      _payController.value = TextEditingValue(text: widget.customerName!);
      _totalRupeeController.value = TextEditingValue(text: widget.amount!);

      String? numberToWords;

      if (widget.amount!.split(".")[0].trim() == "0") {
        numberToWords = "zero rupee";
      } else {
        numberToWords = "${NumberToWord().convert(
                'en-in', int.parse(widget.amount!.split(".")[0].trim()))}rupee";
      }

      String paisa = widget.amount!.split(".")[1].trim();
      String? joinPaisa;
      if (paisa == "00") {
        joinPaisa = "zero paisa";
      } else if (paisa.startsWith('0')) {
        joinPaisa =
            "${NumberToWord().convert('en-in', int.parse(paisa.substring(1)))}paisa";
      } else {
        joinPaisa = "${NumberToWord().convert('en-in', int.parse(paisa))}paisa";
      }
      _rupeeController.value =
          TextEditingValue(text: "$numberToWords $joinPaisa");
      _isLoading = !_isLoading!;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate!,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)));
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          _contractStartDate = formatter.format(selectedDate!);
          _dateController.value =
              TextEditingValue(text: DateFormat('dd-MM-yyyy').format(picked));
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  @override
  void initState() {
    super.initState();
    setDetails();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop()),
              title: const Text(MyConstants.appTittle),
              backgroundColor: Color(int.parse("0xfff" "507a7d"))),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: _isLoading == true
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[400]!,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 0,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(int.parse(
                                                  "0xfff" "507a7d")),
                                              Color(
                                                  int.parse("0xfff" "507a7d"))
                                            ],
                                          ),
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(8.0),
                                              topLeft: Radius.circular(8.0),
                                              topRight: Radius.circular(8.0),
                                              bottomRight:
                                                  Radius.circular(8.0)),
                                        ),
                                        child: Center(
                                          child: GestureDetector(
                                            child: const Text(
                                                MyConstants.chequeInformation,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Expanded(
                              flex: 0,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: TextFormField(
                                    autofocus: false,
                                    decoration: const InputDecoration(
                                      labelText: MyConstants.dateHint,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Expanded(
                              flex: 0,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        AssetImage("assets/images/cheque.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 35.0,
                                      right: 35.0,
                                      top: 25.0,
                                      bottom: 25.0),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 0,
                                        child: TextFormField(
                                          autofocus: false,
                                          enabled: false,
                                          decoration: const InputDecoration(
                                            labelText: MyConstants.pay,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 10, 10, 0),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: TextFormField(
                                          autofocus: false,
                                          enabled: false,
                                          decoration: const InputDecoration(
                                            labelText: MyConstants.rupee,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 10, 10, 0),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15.0,
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: TextFormField(
                                              autofocus: false,
                                              enabled: false,
                                              decoration: const InputDecoration(
                                                labelText: MyConstants.rupee,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        10, 10, 10, 0),
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Expanded(
                            flex: 0,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: TextFormField(
                                  autofocus: false,
                                  decoration: const InputDecoration(
                                    labelText: MyConstants.chequeNumber,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Expanded(
                              flex: 0,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                                  child: const Text(MyConstants.submitButton,
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ))
                        ],
                      ),
                    ))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(
                                                int.parse("0xfff" "507a7d")),
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
                                          child: const Text(
                                              MyConstants.chequeInformation,
                                              style: TextStyle(
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Expanded(
                            flex: 0,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: TextFormField(
                                  autofocus: false,
                                  keyboardType: TextInputType.text,
                                  onTap: () {
                                    _selectDate(context);
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                  },
                                  controller: _dateController,
                                  decoration: const InputDecoration(
                                    labelText: MyConstants.dateHint,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Expanded(
                            flex: 0,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/images/cheque.png"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 35.0,
                                    right: 35.0,
                                    top: 25.0,
                                    bottom: 25.0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 0,
                                      child: TextFormField(
                                        autofocus: false,
                                        enabled: false,
                                        controller: _payController,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        decoration: const InputDecoration(
                                          labelText: MyConstants.pay,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              10, 10, 10, 0),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Expanded(
                                      flex: 0,
                                      child: TextFormField(
                                        autofocus: false,
                                        enabled: false,
                                        controller: _rupeeController,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        decoration: const InputDecoration(
                                          labelText: MyConstants.rupee,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              10, 10, 10, 0),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Expanded(
                                      flex: 0,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          child: TextFormField(
                                            autofocus: false,
                                            enabled: false,
                                            keyboardType: TextInputType.text,
                                            controller: _totalRupeeController,
                                            decoration: const InputDecoration(
                                              labelText: MyConstants.rupee,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 10, 10, 0),
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Expanded(
                          flex: 0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: TextFormField(
                                autofocus: false,
                                controller: _chequeNumberController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: MyConstants.chequeNumber,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Expanded(
                            flex: 0,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () => checkMethod(),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                                child: const Text(MyConstants.submitButton,
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ))
                      ],
                    ),
                  ),
          ),
        ),
      ),
      onWillPop: () async {
        pushPage(context);
        return true;
      },
    );
  }

  bool? validateCheque() {
    bool? validate = true;

    if (_dateController.text.isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.dateError);
    } else if (_chequeNumberController.text.isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.chequeError);
    } else if (_chequeNumberController.text.length < 6) {
      setToastMessage(context, MyConstants.chequeLengthError);
    }

    return validate;
  }

  void checkMethod() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final amcTicketDetailsDao = database.amcTicketDetailsDao;
    final newAMCCreationDataDao = database.newAMCCreationDataDao;
    var amcTicketDetailsData =
        await amcTicketDetailsDao.findAmcTicketDetailsByTicketId(
            PreferenceUtils.getString(MyConstants.ticketIdStore));
    var newAMCCreationData =
        await newAMCCreationDataDao.findNewAMCCreationDataByCheckable(true);

    if (newAMCCreationData.isNotEmpty) {
      if (newAMCCreationData[0].customerCode!.isNotEmpty) {
        addNewProductSelection();
      } else {
        newAmcCreationSubmit();
      }
    } else if (amcTicketDetailsData.isNotEmpty) {
      activityAmcTicketDetailsAmcTicket(
          MyConstants.cheque, amcTicketDetailsData[0].ticketId);
    } else {
      updateAMCContract();
    }
  }

  void activityAmcTicketDetailsAmcTicket(
      String? selectedItem, String? ticketId) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      final Map<String, dynamic> apiBodyData = {
        "technician_code":
            PreferenceUtils.getString(MyConstants.technicianCode),
        "ticket_id": ticketId,
        "mode_of_payment": selectedItem,
        "cheque_no": _chequeNumberController.text.trim(),
        "cheque_date": _contractStartDate
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.submitAMCTicket(
          PreferenceUtils.getString(MyConstants.token), apiBodyData);

      if (response.addTransferEntity != null) {
        if (response.addTransferEntity!.responseCode ==
            MyConstants.response200) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            PreferenceUtils.setString(
                MyConstants.token, response.addTransferEntity!.token!);

            if (response.addTransferEntity!.message != null) {
              setToastMessage(context, response.addTransferEntity!.message!);
            } else {
              setToastMessage(context, MyConstants.ticketCompleted);
            }

            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashBoard()));
            });
          });
        } else if (response.addTransferEntity!.responseCode ==
            MyConstants.response400) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            PreferenceUtils.setString(
                MyConstants.token, response.addTransferEntity!.token!);
          });
        } else if (response.addTransferEntity!.responseCode ==
            MyConstants.response500) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        setToastMessage(context, MyConstants.internalServerError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void addNewProductSelection() async {
    if (await checkInternetConnection() == true) {
      if (validateCheque()!) {
        showAlertDialog(context);

        final database = await $FloorAppDatabase
            .databaseBuilder('floor_database.db')
            .build();
        final newAMCCreationDataDao = database.newAMCCreationDataDao;
        final serialNoDataDao = database.serialNoDataDao;
        var serialNoData = await serialNoDataDao.findAllSerialNoData();
        var newAMCCreationDataList =
            await newAMCCreationDataDao.findNewAMCCreationDataByCheckable(true);

        final combinedData = <Map<String, dynamic>>[];

        for (int i = 0; i < serialNoData.length; i++) {
          String name = serialNoData[i].serialNo;
          Map<String, String> hi = {'serial_no': name};
          combinedData.add(hi);
        }

        final Map<String, dynamic> newProductData = {
          "technician_code":
              PreferenceUtils.getString(MyConstants.technicianCode),
          "contract_ammount": newAMCCreationDataList[0].totalAmount,
          "city_id": newAMCCreationDataList[0].cityId,
          "amc_type_id": newAMCCreationDataList[0].amcTypeId,
          "amc_period": newAMCCreationDataList[0].amcPeriod,
          "customer_code": newAMCCreationDataList[0].customerCode,
          "invoice_id": newAMCCreationDataList[0].invoiceNo,
          "location_id": newAMCCreationDataList[0].locationId,
          "model_no": newAMCCreationDataList[0].modelNo,
          "plot_number": newAMCCreationDataList[0].flatNoStreet,
          "post_code": newAMCCreationDataList[0].postCode,
          "product_id": newAMCCreationDataList[0].productId,
          "product_sub_id": newAMCCreationDataList[0].subCategoryId,
          "serial_array": combinedData,
          "country_id": newAMCCreationDataList[0].countryId,
          "state_id": newAMCCreationDataList[0].stateId,
          "landmark": MyConstants.empty,
          "start_date": newAMCCreationDataList[0].startDate,
          "mode_of_payment": newAMCCreationDataList[0].modeOfPayment,
          "cheque_no": _chequeNumberController.text.trim(),
          "cheque_date": _contractStartDate,
          "street": newAMCCreationDataList[0].street
        };

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.technicianRenewAmc(
            PreferenceUtils.getString(MyConstants.token), newProductData);

        if (response.addTransferEntity != null) {
          if (response.addTransferEntity!.responseCode ==
              MyConstants.response200) {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              PreferenceUtils.setString(
                  MyConstants.token, response.addTransferEntity!.token!);

              if (response.addTransferEntity!.message != null) {
                setToastMessage(context, response.addTransferEntity!.message!);
              } else {
                setToastMessage(context, MyConstants.amcProductCreated);
              }

              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const AMC()));
              });
            });
          } else if (response.addTransferEntity!.responseCode ==
              MyConstants.response400) {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              PreferenceUtils.setString(
                  MyConstants.token, response.addTransferEntity!.token!);
              if (response.addTransferEntity!.message != null) {
                setToastMessage(context, response.addTransferEntity!.message!);
              } else {
                setToastMessage(context, MyConstants.amcProductCreated);
              }
            });
          } else if (response.addTransferEntity!.responseCode ==
              MyConstants.response500) {
            Navigator.of(context, rootNavigator: true).pop();
            if (response.addTransferEntity!.message != null) {
              setToastMessage(context, response.addTransferEntity!.message!);
            } else {
              setToastMessage(context, MyConstants.amcProductCreated);
            }
          }
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, MyConstants.internalServerError);
        }
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void newAmcCreationSubmit() async {
    if (await checkInternetConnection() == true) {
      if (validateCheque()!) {
        showAlertDialog(context);

        final database = await $FloorAppDatabase
            .databaseBuilder('floor_database.db')
            .build();
        final newAMCCreationDataDao = database.newAMCCreationDataDao;
        final serialNoDataDao = database.serialNoDataDao;
        var serialNoData = await serialNoDataDao.findAllSerialNoData();
        var newAMCCreationDataList =
            await newAMCCreationDataDao.findNewAMCCreationDataByCheckable(true);

        final combinedData = <Map<String, dynamic>>[];

        for (int i = 0; i < serialNoData.length; i++) {
          String name = serialNoData[i].serialNo;
          Map<String, String> hi = {'serial_no': name};
          combinedData.add(hi);
        }

        // String? key;
        // String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
        // RegExp regExp = RegExp(pattern);

        // if (regExp.hasMatch(newAMCCreationDataList[0].contactNumber!.trim())) {
        //   key = "contact_number";
        // } else if (!regExp.hasMatch(
        //     newAMCCreationDataList[0].contactNumber!.trim())) {
        //   key = "amc_id";
        // }

        final Map<String, dynamic> apiBodyData = {
          "technician_code":
              PreferenceUtils.getString(MyConstants.technicianCode),
          "total_ammount": newAMCCreationDataList[0].totalAmount,
          "city_id": newAMCCreationDataList[0].cityId,
          "amc_type": newAMCCreationDataList[0].amcTypeId,
          "customer_name": newAMCCreationDataList[0].customerName,
          "email_id": newAMCCreationDataList[0].customerEmail,
          "contact_number": newAMCCreationDataList[0].contactNumber,
          "alternate_number": MyConstants.empty,
          "contract_duration": newAMCCreationDataList[0].amcPeriod,
          "invoice_id": newAMCCreationDataList[0].invoiceNo,
          "location_id": newAMCCreationDataList[0].locationId,
          "model_no": newAMCCreationDataList[0].modelNo,
          "plot_number": newAMCCreationDataList[0].flatNoStreet,
          "post_code": newAMCCreationDataList[0].postCode,
          "product_id": newAMCCreationDataList[0].productId,
          "product_sub_id": newAMCCreationDataList[0].subCategoryId,
          "serial_array": combinedData,
          "country_id": newAMCCreationDataList[0].countryId,
          "state_id": newAMCCreationDataList[0].stateId,
          "landmark": MyConstants.empty,
          "start_date": newAMCCreationDataList[0].startDate,
          "call_category": newAMCCreationDataList[0].callCategoryId,
          "mode_of_payment": newAMCCreationDataList[0].modeOfPayment,
          "cheque_no": _chequeNumberController.text.trim(),
          "cheque_date": _contractStartDate,
          "priority": newAMCCreationDataList[0].priority,
          "street": newAMCCreationDataList[0].street
        };

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.createNewAmcResult(
            PreferenceUtils.getString(MyConstants.token), apiBodyData);

        if (response.addTransferEntity != null) {
          if (response.addTransferEntity!.responseCode ==
              MyConstants.response200) {
            await newAMCCreationDataDao.deleteNewAMCCreationData();
            await serialNoDataDao.deleteSerialNoData();
            setState(() {
              PreferenceUtils.setString(
                  MyConstants.token, response.addTransferEntity!.token!);
              if (response.addTransferEntity!.message != null) {
                setToastMessage(context, response.addTransferEntity!.message!);
              } else {
                setToastMessage(context, MyConstants.amcCreated);
              }

              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => const AMC()));
              });
            });
          } else if (response.addTransferEntity!.responseCode ==
              MyConstants.response400) {
            Navigator.of(context, rootNavigator: true).pop();
            if (response.addTransferEntity!.message != null) {
              setToastMessage(context, response.addTransferEntity!.message!);
            } else {
              setToastMessage(context, MyConstants.amcCreated);
            }
            setState(() {
              PreferenceUtils.setString(
                  MyConstants.token, response.addTransferEntity!.token!);
            });
          } else if (response.addTransferEntity!.responseCode ==
              MyConstants.response500) {
            Navigator.of(context, rootNavigator: true).pop();
            if (response.addTransferEntity!.message != null) {
              setToastMessage(context, response.addTransferEntity!.message!);
            } else {
              setToastMessage(context, MyConstants.amcCreated);
            }
          }
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, MyConstants.internalServerError);
        }
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void updateAMCContract() async {
    if (await checkInternetConnection() == true) {
      if (validateCheque()!) {
        showAlertDialog(context);

        Map<String, dynamic> othersData = {
          'technician_code':
              PreferenceUtils.getString(MyConstants.technicianCode),
          'contract_id': widget.contractId,
          'amc_type_id': widget.amcId,
          'contract_duration': widget.amcDuration
        };

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.technicianRenewAmc(
            PreferenceUtils.getString(MyConstants.token), othersData);

        if (response.addTransferEntity != null) {
          if (response.addTransferEntity!.responseCode ==
              MyConstants.response200) {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              PreferenceUtils.setString(
                  MyConstants.token, response.addTransferEntity!.token!);
              if (response.addTransferEntity!.message != null) {
                setToastMessage(context, response.addTransferEntity!.message!);
              } else {
                setToastMessage(context, MyConstants.amcRenewed);
              }

              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const AMC()));
              });
            });
          } else if (response.addTransferEntity!.responseCode ==
              MyConstants.response400) {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              PreferenceUtils.setString(
                  MyConstants.token, response.addTransferEntity!.token!);
              if (response.addTransferEntity!.message != null) {
                setToastMessage(context, response.addTransferEntity!.message!);
              } else {
                setToastMessage(context, MyConstants.amcRenewed);
              }
            });
          } else if (response.addTransferEntity!.responseCode ==
              MyConstants.response500) {
            Navigator.of(context, rootNavigator: true).pop();
            if (response.addTransferEntity!.message != null) {
              setToastMessage(context, response.addTransferEntity!.message!);
            } else {
              setToastMessage(context, MyConstants.amcRenewed);
            }
          }
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, MyConstants.internalServerError);
        }
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }
}
