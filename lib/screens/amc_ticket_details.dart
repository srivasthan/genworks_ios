import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart' as dio;

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'cheque_information.dart';
import 'dashboard.dart';
import 'ticket_list.dart';

class AMCTicketDetails extends StatefulWidget {
  final String? ticketId;

  const AMCTicketDetails({Key? key, @required this.ticketId}) : super(key: key);

  @override
  _AMCTicketDetailsState createState() => _AMCTicketDetailsState();
}

class _AMCTicketDetailsState extends State<AMCTicketDetails> {
  bool? _isLoading = true;
  final TextEditingController _amcTypeController = TextEditingController();
  final TextEditingController _amcPeriodController = TextEditingController();
  final TextEditingController _modelNumber = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _plotNumber = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _subProductController = TextEditingController();
  final TextEditingController _othersController = TextEditingController();
  final _serialNoList = <String>[];
  String? _selectedMode;

  setDetails() async {
    setState(() {
      _isLoading = true;
    });

    _serialNoList.clear();

    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final amcTicketDetailsDao = database.amcTicketDetailsDao;
    final serialNoDataDao = database.serialNoDataDao;
    var amcTicketDetailsData = await amcTicketDetailsDao
        .findAmcTicketDetailsByTicketId(widget.ticketId!);
    var serialNoData =
        await serialNoDataDao.findSerialNoDataByTicketId(widget.ticketId!);

    for (int i = 0; i < serialNoData.length; i++) {
      _serialNoList.add(
          "${MyConstants.serialNo}${MyConstants.space}${i + 1}${MyConstants.space}:${MyConstants.space}${serialNoData[i].serialNo}");
    }

    setState(() {
      _nameController.value =
          TextEditingValue(text: amcTicketDetailsData[0].customerName);
      _contactController.value =
          TextEditingValue(text: amcTicketDetailsData[0].contactNumber);
      _plotNumber.value =
          TextEditingValue(text: amcTicketDetailsData[0].plotNumber);
      _street.value = TextEditingValue(text: amcTicketDetailsData[0].street);
      _countryController.value =
          TextEditingValue(text: amcTicketDetailsData[0].country);
      _stateController.value =
          TextEditingValue(text: amcTicketDetailsData[0].state);
      _cityController.value =
          TextEditingValue(text: amcTicketDetailsData[0].city);
      _locationController.value =
          TextEditingValue(text: amcTicketDetailsData[0].location);
      _amcTypeController.value =
          TextEditingValue(text: amcTicketDetailsData[0].amcType);
      _amcPeriodController.value = TextEditingValue(
          text: "${amcTicketDetailsData[0].amcDuration} months");
      _productController.value =
          TextEditingValue(text: amcTicketDetailsData[0].productName);
      _subProductController.value =
          TextEditingValue(text: amcTicketDetailsData[0].subProductName);
      _modelNumber.value =
          TextEditingValue(text: amcTicketDetailsData[0].modelNo);
      _quantityController.value =
          TextEditingValue(text: amcTicketDetailsData[0].quantity);
      _amount.value = TextEditingValue(
          text: double.parse(amcTicketDetailsData[0].totalAmount)
              .toStringAsFixed(2));

      _isLoading = !_isLoading!;
    });
  }

  @override
  void initState() {
    super.initState();
    setDetails();
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const TicketList(2)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        pushPage(context);
        return true;
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TicketList(2)))),
              title: const Text(MyConstants.amcTittle),
              backgroundColor: Color(int.parse("0xfff" "507a7d"))),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: _isLoading == true
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[400]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 15.0,
                          ),
                          const Center(
                            child: Text(
                              MyConstants.customerInformation,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: MyConstants.contact,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: MyConstants.emailHint,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: MyConstants.nameHint,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: MyConstants.plotNumber,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: MyConstants.street,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: MyConstants.postCode,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: MyConstants.country,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: MyConstants.state,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: MyConstants.city,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: MyConstants.location,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Center(
                            child: Text(
                              MyConstants.contractInformation,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          )
                        ],
                      ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15.0,
                        ),
                        const Center(
                          child: Text(
                            MyConstants.customerInformation,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.nameHint,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _contactController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.contact,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _plotNumber,
                          decoration: const InputDecoration(
                            labelText: MyConstants.plotNumber,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _street,
                          decoration: const InputDecoration(
                            labelText: MyConstants.street,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.country,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.state,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.city,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.location,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Center(
                          child: Text(
                            MyConstants.contractInformation,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _amcTypeController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.amcTypeTicket,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _amcPeriodController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.amcPeriod,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Center(
                          child: Text(
                            MyConstants.productInformation,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _productController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.product,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _subProductController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.subProduct,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _modelNumber,
                          decoration: const InputDecoration(
                            labelText: MyConstants.modelNo,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        getTasListView(),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          enabled: false,
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: MyConstants.quantity,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          controller: _amount,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: MyConstants.amount,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Center(
                            child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: () => _travelPlanAlert(context),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                backgroundColor:
                                    Color(int.parse("0xfff" "5C7E7F"))),
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
    );
  }

  Widget getTasListView() {
    return ListView.builder(
        itemCount: _serialNoList.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Column(children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _serialNoList[index],
                      ),
                      const Icon(Icons.delete)
                    ]),
              ),
            )
          ]);
        });
  }

  _travelPlanAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: const Text(MyConstants.chooseModeOfPayment),
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
                            _selectedMode = MyConstants.cash;
                            Navigator.of(context, rootNavigator: true).pop();
                            activityAmcTicketDetailsAmcTicket(MyConstants.cash);
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.cash,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.cash,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = MyConstants.cash;
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      activityAmcTicketDetailsAmcTicket(
                                          MyConstants.cash);
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
                            _selectedMode = MyConstants.cheque;
                            Navigator.of(context, rootNavigator: true).pop();
                            PreferenceUtils.setString(
                                MyConstants.ticketIdStore, widget.ticketId!);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChequeInformation(
                                          amount: _amount.text.trim(),
                                          customerName:
                                              _nameController.text.trim(),
                                        )));
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.cheque,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.cheque,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = MyConstants.cheque;
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      PreferenceUtils.setString(
                                          MyConstants.ticketIdStore,
                                          widget.ticketId!);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChequeInformation(
                                                    amount: _amount.text.trim(),
                                                    customerName:
                                                        _nameController.text
                                                            .trim(),
                                                  )));
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
                            _selectedMode = MyConstants.others;
                            Navigator.of(context, rootNavigator: true).pop();
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return othersBottomSheet();
                                });
                          });
                        },
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 1,
                                child: Text(
                                  MyConstants.others,
                                  style: TextStyle(fontSize: 22.0),
                                )),
                            Expanded(
                                flex: 0,
                                child: Radio(
                                  value: MyConstants.others,
                                  groupValue: _selectedMode,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedMode = MyConstants.others;
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return othersBottomSheet();
                                          });
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
                              onTap: () => Navigator.of(context).pop(),
                              child: Text(
                                MyConstants.cancelButton,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Color(int.parse("0xfff" "507a7d"))),
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

  Widget othersBottomSheet() {
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
                      const Text(
                        MyConstants.others,
                        style: TextStyle(color: Colors.white),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
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
                  controller: _othersController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      labelText: MyConstants.others,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      border: OutlineInputBorder()),
                ),
              ),
            ]),
          ),
        ),
        Expanded(
          flex: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context, rootNavigator: true).pop();
                    if (_othersController.text.isEmpty) {
                      setToastMessage(context, MyConstants.reasonError);
                    } else {
                      activityAmcTicketDetailsAmcTicket(MyConstants.others);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                child: const Text(MyConstants.submitButton,
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void activityAmcTicketDetailsAmcTicket(String? selectedItem) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      final Map<String, dynamic> apiBodyData = {
        "technician_code":
            PreferenceUtils.getString(MyConstants.technicianCode),
        "ticket_id": widget.ticketId!,
        "mode_of_payment": selectedItem,
        "cheque_no": MyConstants.empty,
        "cheque_date": MyConstants.empty
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
}
