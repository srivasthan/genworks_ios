import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/model/add_amc_model.dart';
import '../network/model/callCategory.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'amc_details.dart';
import 'cheque_information.dart';

class UpdateAMC extends StatefulWidget {
  final int? id;
  final String? invoice;

  const UpdateAMC({Key? key, required this.id, required this.invoice}) : super(key: key);

  @override
  _AddAmc createState() => _AddAmc();
}

class _AddAmc extends State<UpdateAMC> {
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  final formKey = GlobalKey<FormState>();
  bool? isValidate = true,
      serialRowVisible = false,
      itemsRowVisible = false,
      _isLoading = true,
      isVisible = false;
  String? _selectedDate, _selectedMode;
  final TextEditingController _duration = TextEditingController();
  final TextEditingController _contractDurationDate = TextEditingController();
  final TextEditingController _modelNumber = TextEditingController();
  final TextEditingController _serialNumber = TextEditingController();
  final TextEditingController _invoiceNumber = TextEditingController();
  final TextEditingController _plotNumber = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _postCode = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _othersController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _subProductController = TextEditingController();
  DateTime? selectedPurchaseDate = DateTime.now();
  var amc = <AddAMCModel>[];
  var callCategory = <CallCategoryModel>[];
  AddAMCModel? amcModel;
  CallCategoryModel? callCategoryModel;
  int? _amcId, _contractId, _contractDuration, _workTypeId;

  getAmc() async {
    if (await checkInternetConnection() == true) {
      setState(() {
        _isLoading = true;
      });

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getAMC();

      if (response.addAMCEntity != null) {
        if (response.addAMCEntity!.responseCode == MyConstants.response200) {
          setState(() {
            for (var i = 0; i < response.addAMCEntity!.data!.length; i++) {
              amc.add(AddAMCModel(
                  amcId: response.addAMCEntity!.data![i]!.amcId,
                  duration: response.addAMCEntity!.data![i]!.duration,
                  cost: response.addAMCEntity!.data![i]!.cost,
                  amcType: response.addAMCEntity!.data![i]!.amcType));
            }

            _isLoading = !_isLoading!;
          });
        } else {
          setState(() {
            _isLoading = !_isLoading!;
          });
        }
      } else {
        setState(() {
          _isLoading = !_isLoading!;
        });
        setToastMessage(context, MyConstants.internalServerError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  getWorkType() async {
    if (await checkInternetConnection() == true) {
      setState(() {
        _isLoading = true;
      });

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getWorkType();

      if (response.workTypeEntity != null) {
        if (response.workTypeEntity!.responseCode == MyConstants.response200) {
          setState(() {
            for (var i = 0; i < response.workTypeEntity!.data!.length; i++) {
              if (response.workTypeEntity!.data![i]!.workType ==
                  MyConstants.contractCall)
                _workTypeId = response.workTypeEntity!.data![i]!.workTypeId;
            }
          });
        } else {
          setState(() {
            _isLoading = !_isLoading!;
          });
        }
      } else {
        setState(() {
          _isLoading = !_isLoading!;
        });
        setToastMessage(context, MyConstants.internalServerError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> _selectContractDurationDate(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedPurchaseDate!,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)));
      if (picked != null && picked != selectedPurchaseDate)
        setState(() {
          selectedPurchaseDate = picked;
          _contractDurationDate.value =
              TextEditingValue(text: DateFormat('dd-MM-yyyy').format(picked));
        });
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  setDetails(BuildContext context) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final searchAMCContractDataDao = database.searchAMCContractDataDao;
    var searchAMCContractDataList =
        await searchAMCContractDataDao.findSearchAMCContractData(widget.id!);

    setState(() {
      _contractId = searchAMCContractDataList[widget.id! - 1].contractId;
      _nameController.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].customerName!);
      _contactController.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].contactNumber!);
      _emailController.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].emailId!);
      _plotNumber.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].plotNumber!);
      _street.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].street!);
      _postCode.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].postCode!.toString());
      _countryController.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].country!);
      _stateController.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].state!);
      _cityController.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].city!);
      _locationController.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].location!);
      _productController.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].productName!);
      _subProductController.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].subCategoryName!);
      _modelNumber.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].modelNo!);
      _serialNumber.value = TextEditingValue(
          text: searchAMCContractDataList[widget.id! - 1].serialNo!);
        _invoiceNumber.value = TextEditingValue(text: searchAMCContractDataList[widget.id! -1].invoiceId!);
      //_invoiceNumber.value = TextEditingValue(text: MyConstants.empty);
      _amount.value = TextEditingValue(text: MyConstants.chargeable.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    Future.delayed(Duration.zero, () {
      setDetails(context);
    });
    getWorkType();
    getAmc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const AMC()))),
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
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: MyConstants.emailHint,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
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
                        decoration: const InputDecoration(
                          labelText: MyConstants.postCode,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
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
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: MyConstants.emailHint,
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
                    TextFormField(
                      autofocus: false,
                      enabled: false,
                      controller: _postCode,
                      decoration: const InputDecoration(
                        labelText: MyConstants.postCode,
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
                    const Text(MyConstants.amcType),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      height: 48,
                      color: Color(int.parse("0xfff" "778899")),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          contentPadding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        ),
                        child: DropdownButtonFormField<AddAMCModel?>(
                          isExpanded: true,
                          iconEnabledColor: Colors.white,
                          dropdownColor: Color(int.parse("0xfff" "778899")),
                          value: amcModel,
                          hint: const Text(
                            MyConstants.amcHint,
                            style: TextStyle(color: Colors.white),
                          ),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(int.parse("0xfff" "778899")))),
                            contentPadding: const EdgeInsets.all(5),
                          ),
                          onChanged: (AddAMCModel? data) {
                            setState(() {
                              amcModel = data;
                              _amcId = amcModel!.amcId;
                              _contractDuration = amcModel!.duration;
                              _selectedDate =
                                  _contractDuration.toString() + "  months";
                              _amount.value = TextEditingValue(
                                  text: amcModel!.cost.toString());
                              _duration.value =
                                  TextEditingValue(text: _selectedDate!);
                            });
                          },
                          items: amc.map((AddAMCModel? value) {
                            return DropdownMenuItem<AddAMCModel?>(
                              value: value,
                              child: Text(
                                value!.amcType!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: _duration,
                      autofocus: false,
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      decoration: const InputDecoration(
                        labelText: MyConstants.contractDuration,
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: _contractDurationDate,
                      autofocus: false,
                      onTap: () {
                        _selectContractDurationDate(context);
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      decoration: const InputDecoration(
                        labelText: MyConstants.contractDateHint,
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
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
                      height: 20.0,
                    ),
                    TextFormField(
                      autofocus: false,
                      enabled: false,
                      controller: _serialNumber,
                      decoration: const InputDecoration(
                        labelText: MyConstants.serialNo,
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
                      controller: _invoiceNumber,
                      decoration: const InputDecoration(
                        labelText: MyConstants.invoice,
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
                            primary: Color(int.parse("0xfff" "5C7E7F"))),
                        child: const Text(MyConstants.renewButton,
                            style: TextStyle(color: Colors.white)),
                      ),
                    ))
                  ],
                ),
        ),
      ),
    );
  }

  bool? validateRenewAMC() {
    bool? validate = true;

    if (amcModel == null) {
      validate = false;
      setToastMessage(context, MyConstants.amcDropdownError);
    } else if (_duration.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.contractDurationError);
    } else if (_contractDurationDate.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.contractDateError);
    }

    return validate;
  }

  void updateAMCContract() async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      Map<String, dynamic> othersData = {
        'technician_code':
            PreferenceUtils.getString(MyConstants.technicianCode),
        'contract_id': _contractId,
        'amc_type_id': _amcId,
        'contract_duration': _contractDuration
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
            setToastMessage(context, response.addTransferEntity!.message!);

            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AMC()));
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
          setToastMessage(context, response.addTransferEntity!.message!);
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        setToastMessage(context, MyConstants.internalServerError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  _travelPlanAlert(BuildContext context) {
    if (validateRenewAMC()!) {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                contentPadding: EdgeInsets.zero,
                title: const Text(MyConstants.chooseModeOfPayment),
                content: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
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
                              updateAMCContract();
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
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        updateAMCContract();
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
                              chequeMode();
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
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        chequeMode();
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
                                        Navigator.of(context,
                                                rootNavigator: true)
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
  }

  Widget othersBottomSheet() {
    return Container(
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
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      Navigator.of(context, rootNavigator: true).pop();
                      if (_othersController.text.isEmpty)
                        setToastMessage(context, MyConstants.reasonError);
                      else
                        updateAMCContract();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      primary: Color(int.parse("0xfff" "5C7E7F"))),
                  child: const Text(MyConstants.submitButton,
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void chequeMode() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final searchAMCContractDataDao = database.searchAMCContractDataDao;
    final newAMCCreationDataDao = database.newAMCCreationDataDao;
    await newAMCCreationDataDao.deleteNewAMCCreationData();
    var searchAMCContractData =
        await searchAMCContractDataDao.findSearchAMCContractData(widget.id!);

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChequeInformation(
                  amount: double.parse(_amount.text.trim()).toStringAsFixed(2),
                  customerName: searchAMCContractData[0].customerName,
                  amcDuration: _contractDuration,
                  amcId: _amcId,
                  contractId: searchAMCContractData[0].contractId,
                )));
  }
}
