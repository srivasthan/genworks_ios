import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart' as dio;

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/db/spare_request_dao.dart';
import '../network/model/drop_location.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'dashboard.dart';
import 'spareinventory/spare_cart.dart';
import 'ticket_list.dart';

class FieldReturnMaterial extends StatefulWidget {
  final String? ticketUpdate;

  const FieldReturnMaterial({Key? key, required this.ticketUpdate})
      : super(key: key);

  @override
  _FieldReturnMaterialState createState() => _FieldReturnMaterialState();
}

class _FieldReturnMaterialState extends State<FieldReturnMaterial> {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  final TextEditingController _ticketIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _requiredSpareController = TextEditingController();
  final TextEditingController _dropOffController = TextEditingController();
  var dropLocationList = <DropLocationModel>[];
  String? _discountType;
  DropLocationModel? _dropLocationModel;
  String _showConsumedSpareData = "";
  String? _ticketId, _name;

  getLocationSpinnerData() async {
    if (await checkInternetConnection() == true) {
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final spareRequestDataDao = database.spareRequestDataDao;
      final ticketForTheDayDao = database.ticketForTheDayDao;
      final ongoingTicketDao = database.ongoingTicketDao;
      var spareRequestData =
          await spareRequestDataDao.updateSpareRequestData(true);
      var ticketForTheDayData =
          await ticketForTheDayDao.findTicketForTheDayByTicketId(
              PreferenceUtils.getString(MyConstants.ticketIdStore));

      if (ticketForTheDayData.length > -1) {
        _ticketId = ticketForTheDayData[0].ticketId;
        _name = ticketForTheDayData[0].customerName;
      } else {
        var ongoingTicketData = await ongoingTicketDao.findOngoingTicketById(
            PreferenceUtils.getString(MyConstants.ticketIdStore));
        _ticketId = ongoingTicketData[0]!.ticketId;
        _name = ongoingTicketData[0]!.customerName;
      }

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getDropLocationApi();
      if (response.dropLocationEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          _isLoading = !_isLoading;
          if (spareRequestData.isNotEmpty) {
            for (var spareData in spareRequestData) {
              String showConsumedSpareDataset = "${spareData!.spareName}${MyConstants.openBracket}${spareData.updateQuantity}${MyConstants.closedBracket},";
              _showConsumedSpareData =
                  (showConsumedSpareDataset + _showConsumedSpareData);
            }
            _requiredSpareController.text = _showConsumedSpareData;
          }

          for (int i = 0; i < response.dropLocationEntity!.data!.length; i++) {
            dropLocationList.add(DropLocationModel(
                warehouseId: response.dropLocationEntity!.data![i]!.warehouseId,
                warehouseName:
                    response.dropLocationEntity!.data![i]!.warehouseName,
                leadTime: response.dropLocationEntity!.data![i]!.leadTime));
          }
          _ticketIdController.text = _ticketId!;
          _nameController.text = _name!;
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('dd-MM-yyyy').format(now);
          _dropOffController.text = formattedDate;
        });
      } else if (response.dropLocationEntity!.responseCode ==
              MyConstants.response400 ||
          response.dropLocationEntity!.responseCode ==
              MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //  pushPage(context);

        if (widget.ticketUpdate == MyConstants.ongoingTicket) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const TicketList(1)));
        } else if (widget.ticketUpdate == MyConstants.complete) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const TicketList(2)));
        }

        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                if (widget.ticketUpdate == MyConstants.ongoingTicket) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TicketList(1)));
                } else if (widget.ticketUpdate == MyConstants.complete) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TicketList(2)));
                }
              },
            ),
            title: const Text(MyConstants.appName),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                  child: _isLoading == false
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      child: Container(
                                        height: 35,
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
                                                MyConstants.fieldReturnMaterial,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                            const SizedBox(height: 15.0),
                            const SizedBox(height: 10.0),
                            TextFormField(
                              controller: _ticketIdController,
                              enabled: false,
                              decoration: const InputDecoration(
                                  labelText: MyConstants.ticketId,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 10.0),
                            TextFormField(
                              controller: _nameController,
                              enabled: false,
                              decoration: const InputDecoration(
                                  labelText: MyConstants.nameCapital,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 10.0),
                            Row(children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _requiredSpareController,
                                  keyboardType: TextInputType.multiline,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.requiredSpare,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SpareCart(
                                                MyConstants.complete, _ticketId!))),
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    10.0)), backgroundColor: Color(
                                            int.parse("0xfff" "2a9d8f"))),
                                    child: const Text(MyConstants.addButton,
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white)),
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: _dropOffController,
                              decoration: const InputDecoration(
                                  labelText: MyConstants.dropOffDateHint,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 10.0),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                MyConstants.dropOffLocation,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Container(
                              height: 50,
                              color: Color(int.parse("0xfff" "778899")),
                              child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    contentPadding: const EdgeInsets.all(2),
                                  ),
                                  child: DropdownButtonFormField<
                                      DropLocationModel>(
                                    isExpanded: true,
                                    value: _dropLocationModel,
                                    iconEnabledColor: Colors.white,
                                    dropdownColor:
                                        Color(int.parse("0xfff" "778899")),
                                    hint: const Text(
                                      MyConstants.selectLocation,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(int.parse(
                                                  "0xfff" "778899")))),
                                      contentPadding: const EdgeInsets.all(5),
                                    ),
                                    onChanged: (DropLocationModel? value) {
                                      _dropLocationModel = value;
                                      _discountType = value!.warehouseName;
                                    },
                                    items: dropLocationList
                                        .map((DropLocationModel value) {
                                      return DropdownMenuItem<
                                          DropLocationModel>(
                                        value: value,
                                        child: Text(
                                          value.warehouseName!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      );
                                    }).toList(),
                                  )),
                            ),
                            const SizedBox(height: 15.0),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () => fieldReturnMaterialPostCall(),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                                child: const Text(MyConstants.submitButton,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white)),
                              ),
                            )
                          ],
                        )
                      : Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[400]!,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        child: Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(int.parse(
                                                    "0xfff" "507a7d")),
                                                Color(int.parse(
                                                    "0xfff" "507a7d"))
                                              ],
                                            ),
                                            borderRadius: const BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(8.0),
                                                topLeft: Radius.circular(8.0),
                                                topRight: Radius.circular(8.0),
                                                bottomRight:
                                                    Radius.circular(8.0)),
                                          ),
                                          child: Center(
                                            child: GestureDetector(
                                              child: const Text(
                                                  MyConstants
                                                      .fieldReturnMaterial,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  )),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                              const SizedBox(height: 15.0),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                controller: _ticketIdController,
                                enabled: false,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.ticketId,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                controller: _nameController,
                                enabled: false,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.nameCapital,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _requiredSpareController,
                                    keyboardType: TextInputType.multiline,
                                    decoration: const InputDecoration(
                                        labelText: MyConstants.requiredSpare,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 0),
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.0)), backgroundColor: Color(
                                              int.parse("0xfff" "2a9d8f"))),
                                      child: const Text(MyConstants.addButton,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                controller: _dropOffController,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.dropOffDateHint,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              Container(
                                height: 50,
                                color: Color(int.parse("0xfff" "778899")),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    contentPadding: const EdgeInsets.all(5),
                                  ),
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    value: _discountType,
                                    iconEnabledColor: Colors.white,
                                    dropdownColor:
                                        Color(int.parse("0xfff" "778899")),
                                    hint: const Text(
                                      MyConstants.priceTypeHint,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(int.parse(
                                                  "0xfff" "778899")))),
                                      contentPadding: const EdgeInsets.all(5),
                                    ),
                                    onChanged: (String? value) {
                                      _discountType = value!;
                                    },
                                    items: <String>[
                                      MyConstants.value,
                                      MyConstants.percentage
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                                  child: const Text(MyConstants.submitButton,
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                ),
                              )
                            ],
                          ))),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    getLocationSpinnerData();
  }

  bool validation() {
    bool validate = true;

    if (_nameController.text.isEmpty) {
      setToastMessage(context, MyConstants.nameError);
      validate = false;
    } else if (_ticketIdController.text.isEmpty) {
      setToastMessage(context, MyConstants.ticketError);
      validate = false;
    } else if (_requiredSpareController.text.isEmpty) {
      setToastMessage(context, MyConstants.requiredSpareError);
      validate = false;
    } else if (_dropOffController.text.isEmpty) {
      setToastMessage(context, MyConstants.dropOffDateError);
      validate = false;
    } else if (_dropLocationModel == null) {
      setToastMessage(context, MyConstants.locationError);
      validate = false;
    }

    return validate;
  }

  fieldReturnMaterialPostCall() async {
    if (await checkInternetConnection() == true) {
      if (validation()) {
        final database = await $FloorAppDatabase
            .databaseBuilder('floor_database.db')
            .build();
        final spareRequestDataDao = database.spareRequestDataDao;
        var spareRequestData =
            await spareRequestDataDao.updateSpareRequestData(true);

        final combinedData = <Map<String, dynamic>>[];
        int? frmStatus, frm;

        for (int i = 0; i < spareRequestData.length; i++) {
          Map<String, dynamic> installationCompleteData = {
            'spare_code': spareRequestData[i]!.spareCode,
            'spare_name': spareRequestData[i]!.spareName,
            'warehouse_id': spareRequestData[i]!.locationId,
            'quantity': spareRequestData[i]!.updateQuantity
          };
          combinedData.add(installationCompleteData);
        }

        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                title: MyConstants.appTittle,
                text: MyConstants.optAlert,
                showCancelBtn: true,
                confirmButtonText: MyConstants.nowButton,
                cancelButtonText: MyConstants.laterButton,
                onConfirm: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  frmStatus = MyConstants.updateQuantity;
                  frm = MyConstants.updateQuantity;
                  showAlertDialog(context);
                  callPostApi(
                      frmStatus, combinedData, frm, spareRequestDataDao);
                },
                onCancel: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  frmStatus = MyConstants.updateQuantity;
                  frm = MyConstants.chargeable;
                  showAlertDialog(context);
                  callPostApi(
                      frmStatus, combinedData, frm, spareRequestDataDao);
                },
                cancelButtonColor: Color(int.parse("0xfff" "C5C5C5")),
                confirmButtonColor: Color(int.parse("0xfff" "507a7d"))));
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  callPostApi(int? frmStatus, List<Map<String, dynamic>> combinedData, int? frm,
      SpareRequestDataDao spareRequestDataDao) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    Map<String, dynamic> fieldRequestData = {
      'technician_code': PreferenceUtils.getString(MyConstants.technicianCode),
      'ticket_id': _ticketId,
      'frm_status': frmStatus,
      'drop_spare': combinedData,
      'drop_of_location': _dropLocationModel!.warehouseName,
      'drop_of_date': formattedDate,
      'frm': frm,
    };

    ApiService apiService = ApiService(dio.Dio());
    final response = await apiService.getupdateFieldReturnMatrial(
        PreferenceUtils.getString(MyConstants.token), fieldRequestData);

    if (response.addTransferEntity != null) {
      if (response.addTransferEntity!.responseCode == MyConstants.response200) {
        setState(() {
          Navigator.of(context, rootNavigator: true).pop();
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          spareRequestDataDao.deleteSpareRequestDataTable();
          setToastMessage(context, response.addTransferEntity!.message!);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashBoard()));
          });
        });
      } else if (response.addTransferEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          Navigator.of(context, rootNavigator: true).pop();
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          setToastMessage(context, response.addTransferEntity!.message!);
        });
      } else if (response.addTransferEntity!.responseCode ==
          MyConstants.response500) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      setToastMessage(context, MyConstants.internalServerError);
    }
  }
}
