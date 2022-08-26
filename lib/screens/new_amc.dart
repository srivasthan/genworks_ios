import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/db/new_amc_creation_data.dart';
import '../network/db/serial_no_data.dart';
import '../network/model/add_amc_model.dart';
import '../network/model/amc_product_model.dart';
import '../network/model/callCategory.dart';
import '../network/model/city.dart';
import '../network/model/country.dart';
import '../network/model/location.dart';
import '../network/model/state.dart';
import '../network/model/subProduct.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'amc_details.dart';
import 'cheque_information.dart';
import 'dashboard.dart';

class AddAmc extends StatefulWidget {
  final String? type, customerContact;
  final int? id;

  const AddAmc(
      {Key? key,
      required this.type,
      required this.customerContact,
      required this.id})
      : super(key: key);

  @override
  _AddAmc createState() => _AddAmc();
}

class _AddAmc extends State<AddAmc> {
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  final formKey = GlobalKey<FormState>();
  bool? isValidate = true,
      serialRowVisible = false,
      itemsRowVisible = false,
      _isLoading = true,
      isVisible = false;
  String? _cusCode, _dummy, _contractStartDate, _priority, _selectedMode;
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
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _othersController = TextEditingController();
  DateTime? selectedPurchaseDate = DateTime.now();
  var product = <AMCProductModel>[];
  var amc = <AddAMCModel>[];
  var country = <CountryModel>[];
  var state = <StateModel>[];
  var city = <CityModel>[];
  var location = <LocationModel>[];
  var subProduct = <AMCSubProductModel>[];
  var callCategory = <CallCategoryModel>[];
  var serialNumberList = <String>[];
  CountryModel? countryModel;
  StateModel? stateModel;
  CityModel? cityModel;
  LocationModel? locationModel;
  AMCProductModel? productModel;
  AMCSubProductModel? subProductModel;
  AddAMCModel? amcModel;
  CallCategoryModel? callCategoryModel;
  String? _contractCall;
  int? _productId,
      _amcId,
      _workTypeId,
      _countryId,
      _stateId,
      _cityId,
      _locationId,
      _contractDuration,
      _getAmount,
      _subProductId = -1;

  getCountry() async {
    if (await checkInternetConnection() == true) {
      FocusScope.of(context).requestFocus(FocusNode());

      setState(() {
        _isLoading = true;
        countryModel = null;
      });
      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getCountry();

      if (response.countryEntity != null) {
        if (response.countryEntity!.responseCode == MyConstants.response200) {
          setState(() {
            for (var i = 0; i < response.countryEntity!.data!.length; i++) {
              country.add(CountryModel(
                  countryId: response.countryEntity!.data![i]!.countryId,
                  countryName: response.countryEntity!.data![i]!.countryName));
            }
          });
        }
      } else {
        setToastMessage(context, MyConstants.internalServerError);
        setState(() {
          _isLoading = !_isLoading!;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  getState(int countryId) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getState(countryId);

      if (response.stateEntity != null) {
        if (response.stateEntity!.responseCode == MyConstants.response200) {
          setState(() {
            for (var i = 0; i < response.stateEntity!.data!.length; i++) {
              state.add(StateModel(
                  stateId: response.stateEntity!.data![i]!.stateId,
                  stateName: response.stateEntity!.data![i]!.stateName));
            }
            Navigator.of(context, rootNavigator: true).pop();
          });
        } else {
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

  getCity(int stateId) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getCity(stateId);

      if (response.cityEntity != null) {
        if (response.cityEntity!.responseCode == MyConstants.response200) {
          setState(() {
            for (var i = 0; i < response.cityEntity!.data!.length; i++) {
              city.add(CityModel(
                  cityId: response.cityEntity!.data![i]!.cityId,
                  cityName: response.cityEntity!.data![i]!.cityName));
            }
          });

          Navigator.of(context, rootNavigator: true).pop();
        } else {
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

  getLocation(int cityId) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getLocation(cityId);

      if (response.locationEnity != null) {
        if (response.locationEnity!.responseCode == MyConstants.response200) {
          setState(() {
            for (var i = 0; i < response.locationEnity!.data!.length; i++) {
              location.add(LocationModel(
                  locationId: response.locationEnity!.data![i]!.locationId,
                  locationName:
                      response.locationEnity!.data![i]!.locationName));
            }
            Navigator.of(context, rootNavigator: true).pop();
          });
        } else {
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

  getProduct() async {
    if (await checkInternetConnection() == true) {
      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getAMCProduct();

      if (response.amcProductEntity != null) {
        if (response.amcProductEntity!.responseCode ==
            MyConstants.response200) {
          setState(() {
            for (var i = 0; i < response.amcProductEntity!.data!.length; i++) {
              product.add(AMCProductModel(
                  productId: response.amcProductEntity!.data![i]!.productId,
                  productName:
                      response.amcProductEntity!.data![i]!.productName));
            }
          });
        }
      } else {
        setToastMessage(context, MyConstants.internalServerError);
        setState(() {
          _isLoading = !_isLoading!;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  getCallCategory() async {
    if (await checkInternetConnection() == true) {
      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getCallCategory();

      if (response.callCategoryEntity != null) {
        if (response.callCategoryEntity!.responseCode ==
            MyConstants.response200) {
          setState(() {
            for (var i = 0;
                i < response.callCategoryEntity!.data!.length;
                i++) {
              callCategory.add(CallCategoryModel(
                  callCategoryId:
                      response.callCategoryEntity!.data![i]!.callCategoryId,
                  callCategory:
                      response.callCategoryEntity!.data![i]!.callCategoryName));
            }
          });
        }
      } else {
        setToastMessage(context, MyConstants.internalServerError);
        setState(() {
          _isLoading = !_isLoading!;
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  getAmc() async {
    if (await checkInternetConnection() == true) {
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
                  MyConstants.contractCall) {
                _workTypeId = response.workTypeEntity!.data![i]!.workTypeId;
              }
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
      if (picked != null && picked != selectedPurchaseDate) {
        setState(() {
          selectedPurchaseDate = picked;
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          _contractStartDate = formatter.format(selectedPurchaseDate!);
          _contractDurationDate.value =
              TextEditingValue(text: DateFormat('dd-MM-yyyy').format(picked));
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  setDetails(BuildContext context) async {
    if (widget.type == MyConstants.createAMC) {
      setState(() {
        _contactController.text = widget.customerContact!;
      });
    } else {
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final searchAMCContractDataDao = database.searchAMCContractDataDao;
      var searchAMCContractDataList =
          await searchAMCContractDataDao.findSearchAMCContractData(widget.id!);

      setState(() {
        _cusCode = searchAMCContractDataList[widget.id! - 1].customerCode;
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
            text:
                searchAMCContractDataList[widget.id! - 1].postCode!.toString());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    Future.delayed(Duration.zero, () {
      setDetails(context);
    });
    getCountry();
    getProduct();
    getCallCategory();
    getWorkType();
    getAmc();
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const AMC()));
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
                          const Text(MyConstants.country),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            color: Color(int.parse("0xfff" "778899")),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              ),
                              child: DropdownButtonFormField<CountryModel?>(
                                isExpanded: true,
                                iconEnabledColor: Colors.white,
                                dropdownColor:
                                    Color(int.parse("0xfff" "778899")),
                                value: countryModel,
                                hint: const Text(
                                  MyConstants.countryHint,
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              int.parse("0xfff" "778899")))),
                                  contentPadding: const EdgeInsets.all(5),
                                ),
                                onChanged: (CountryModel? data) {},
                                items: country.map((CountryModel? value) {
                                  return DropdownMenuItem<CountryModel?>(
                                    value: value,
                                    child: Text(
                                      value!.countryName!,
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
                          const Text(MyConstants.state),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            color: Color(int.parse("0xfff" "778899")),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              ),
                              child: DropdownButtonFormField<StateModel?>(
                                isExpanded: true,
                                iconEnabledColor: Colors.white,
                                dropdownColor:
                                    Color(int.parse("0xfff" "778899")),
                                value: stateModel,
                                hint: const Text(
                                  MyConstants.stateHint,
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              int.parse("0xfff" "778899")))),
                                  contentPadding: const EdgeInsets.all(5),
                                ),
                                onChanged: (StateModel? data) {},
                                items: state.map((StateModel? value) {
                                  return DropdownMenuItem<StateModel?>(
                                    value: value,
                                    child: Text(
                                      value!.stateName!,
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
                          const Text(MyConstants.city),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            color: Color(int.parse("0xfff" "778899")),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              ),
                              child: DropdownButtonFormField<CityModel?>(
                                isExpanded: true,
                                iconEnabledColor: Colors.white,
                                dropdownColor:
                                    Color(int.parse("0xfff" "778899")),
                                value: cityModel,
                                hint: const Text(
                                  MyConstants.cityHint,
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              int.parse("0xfff" "778899")))),
                                  contentPadding: const EdgeInsets.all(5),
                                ),
                                onChanged: (CityModel? data) {},
                                items: city.map((CityModel? value) {
                                  return DropdownMenuItem<CityModel?>(
                                    value: value,
                                    child: Text(
                                      value!.cityName!,
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
                          const Text(MyConstants.location),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            color: Color(int.parse("0xfff" "778899")),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              ),
                              child: DropdownButtonFormField<LocationModel?>(
                                isExpanded: true,
                                iconEnabledColor: Colors.white,
                                dropdownColor:
                                    Color(int.parse("0xfff" "778899")),
                                value: locationModel,
                                hint: const Text(
                                  MyConstants.locationHint,
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              int.parse("0xfff" "778899")))),
                                  contentPadding: const EdgeInsets.all(5),
                                ),
                                onChanged: (LocationModel? data) {},
                                items: location.map((LocationModel? value) {
                                  return DropdownMenuItem<LocationModel?>(
                                    value: value,
                                    child: Text(
                                      value!.locationName!,
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
                          const Text(MyConstants.priority),
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
                              child: DropdownButtonFormField<String?>(
                                isExpanded: true,
                                iconEnabledColor: Colors.white,
                                dropdownColor:
                                    Color(int.parse("0xfff" "778899")),
                                value: _priority,
                                hint: const Text(
                                  MyConstants.priorityHint,
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              int.parse("0xfff" "778899")))),
                                  contentPadding: const EdgeInsets.all(5),
                                ),
                                onChanged: (String? value) {},
                                items: <String?>[
                                  MyConstants.p1,
                                  MyConstants.p2,
                                  MyConstants.p3,
                                  MyConstants.p4
                                ].map((String? value) {
                                  return DropdownMenuItem<String?>(
                                    value: value,
                                    child: Text(
                                      value!,
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
                          keyboardType: TextInputType.number,
                          controller: _contactController,
                          decoration: InputDecoration(
                            labelText: RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)')
                                    .hasMatch(widget.customerContact!.trim())
                                ? MyConstants.contact
                                : MyConstants.amcId,
                            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          autofocus: false,
                          keyboardType: TextInputType.emailAddress,
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
                          keyboardType: TextInputType.text,
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
                          keyboardType: TextInputType.number,
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
                          controller: _street,
                          keyboardType: TextInputType.text,
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
                          keyboardType: TextInputType.number,
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
                        const Text(MyConstants.country),
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
                            child: DropdownButtonFormField<CountryModel?>(
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              dropdownColor:
                                  Color(int.parse("0xfff" "778899")),
                              value: countryModel,
                              hint: const Text(
                                MyConstants.countryHint,
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            int.parse("0xfff" "778899")))),
                                contentPadding: const EdgeInsets.all(5),
                              ),
                              onChanged: (CountryModel? data) {
                                setState(() {
                                  countryModel = data;
                                  _countryId = countryModel!.countryId;

                                  state.clear();
                                  stateModel = null;
                                  city.clear();
                                  location.clear();
                                  cityModel = null;
                                  locationModel = null;
                                  getState(_countryId!);
                                });
                              },
                              items: country.map((CountryModel? value) {
                                return DropdownMenuItem<CountryModel?>(
                                  value: value,
                                  child: Text(
                                    value!.countryName!,
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
                        const Text(MyConstants.state),
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
                            child: DropdownButtonFormField<StateModel?>(
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              dropdownColor:
                                  Color(int.parse("0xfff" "778899")),
                              value: stateModel,
                              hint: const Text(
                                MyConstants.stateHint,
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            int.parse("0xfff" "778899")))),
                                contentPadding: const EdgeInsets.all(5),
                              ),
                              onChanged: (StateModel? data) {
                                setState(() {
                                  stateModel = data;
                                  _stateId = stateModel!.stateId;

                                  city.clear();
                                  location.clear();
                                  cityModel = null;
                                  locationModel = null;
                                  getCity(_stateId!);
                                });
                              },
                              items: state.map((StateModel? value) {
                                return DropdownMenuItem<StateModel?>(
                                  value: value,
                                  child: Text(
                                    value!.stateName!,
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
                        const Text(MyConstants.city),
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
                            child: DropdownButtonFormField<CityModel?>(
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              dropdownColor:
                                  Color(int.parse("0xfff" "778899")),
                              value: cityModel,
                              hint: const Text(
                                MyConstants.cityHint,
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            int.parse("0xfff" "778899")))),
                                contentPadding: const EdgeInsets.all(5),
                              ),
                              onChanged: (CityModel? data) {
                                setState(() {
                                  cityModel = data;
                                  _cityId = cityModel!.cityId;

                                  location.clear();
                                  locationModel = null;
                                  getLocation(_cityId!);
                                });
                              },
                              items: city.map((CityModel? value) {
                                return DropdownMenuItem<CityModel?>(
                                  value: value,
                                  child: Text(
                                    value!.cityName!,
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
                        const Text(MyConstants.location),
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
                            child: DropdownButtonFormField<LocationModel?>(
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              dropdownColor:
                                  Color(int.parse("0xfff" "778899")),
                              value: locationModel,
                              hint: const Text(
                                MyConstants.locationHint,
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            int.parse("0xfff" "778899")))),
                                contentPadding: const EdgeInsets.all(5),
                              ),
                              onChanged: (LocationModel? data) {
                                setState(() {
                                  locationModel = data;
                                  _locationId = locationModel!.locationId;
                                });
                              },
                              items: location.map((LocationModel? value) {
                                return DropdownMenuItem<LocationModel?>(
                                  value: value,
                                  child: Text(
                                    value!.locationName!,
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
                        const Text(MyConstants.priority),
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
                            child: DropdownButtonFormField<String?>(
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              dropdownColor:
                                  Color(int.parse("0xfff" "778899")),
                              value: _priority,
                              hint: const Text(
                                MyConstants.priorityHint,
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            int.parse("0xfff" "778899")))),
                                contentPadding: const EdgeInsets.all(5),
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  _priority = value!;
                                });
                              },
                              items: <String?>[
                                MyConstants.p1,
                                MyConstants.p2,
                                MyConstants.p3,
                                MyConstants.p4
                              ].map((String? value) {
                                return DropdownMenuItem<String?>(
                                  value: value,
                                  child: Text(
                                    value!,
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
                              dropdownColor:
                                  Color(int.parse("0xfff" "778899")),
                              value: amcModel,
                              hint: const Text(
                                MyConstants.amcHint,
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            int.parse("0xfff" "778899")))),
                                contentPadding: const EdgeInsets.all(5),
                              ),
                              onChanged: (AddAMCModel? data) {
                                setState(() {
                                  amcModel = data;
                                  _amcId = amcModel!.amcId;
                                  _contractDuration = amcModel!.duration;
                                  _dummy =
                                      "$_contractDuration  months";
                                  _duration.value =
                                      TextEditingValue(text: _dummy!);
                                  _getAmount = amcModel!.cost!.toInt();
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
                            FocusScope.of(context)
                                .requestFocus(FocusNode());
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
                            FocusScope.of(context)
                                .requestFocus(FocusNode());
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
                        const Text(MyConstants.product),
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
                            child: DropdownButtonFormField<AMCProductModel?>(
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              dropdownColor:
                                  Color(int.parse("0xfff" "778899")),
                              value: productModel,
                              hint: const Text(
                                MyConstants.productHint,
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            int.parse("0xfff" "778899")))),
                                contentPadding: const EdgeInsets.all(5),
                              ),
                              onChanged: (AMCProductModel? data) {
                                setState(() {
                                  productModel = data;
                                  _productId = productModel!.productId;

                                  subProduct.clear();
                                  subProductModel = null;
                                  getSubProduct(_productId);
                                });
                              },
                              items: product.map((AMCProductModel? value) {
                                return DropdownMenuItem<AMCProductModel?>(
                                  value: value,
                                  child: Text(
                                    value!.productName!,
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
                        const Text(MyConstants.subProduct),
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
                            child: DropdownButtonFormField<AMCSubProductModel?>(
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              dropdownColor:
                                  Color(int.parse("0xfff" "778899")),
                              value: subProductModel,
                              hint: const Text(
                                MyConstants.subProductHint,
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            int.parse("0xfff" "778899")))),
                                contentPadding: const EdgeInsets.all(5),
                              ),
                              onChanged: (AMCSubProductModel? data) {
                                setState(() {
                                  subProductModel = data;
                                  _subProductId = subProductModel!.productSubId;
                                });
                              },
                              items:
                                  subProduct.map((AMCSubProductModel? value) {
                                return DropdownMenuItem<AMCSubProductModel?>(
                                  value: value,
                                  child: Text(
                                    value!.productSubName!,
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
                        const Text(MyConstants.callCategory),
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
                            child: DropdownButtonFormField<CallCategoryModel?>(
                              isExpanded: true,
                              iconEnabledColor: Colors.white,
                              dropdownColor:
                                  Color(int.parse("0xfff" "778899")),
                              value: callCategoryModel,
                              hint: const Text(
                                MyConstants.callCategoryHint,
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            int.parse("0xfff" "778899")))),
                                contentPadding: const EdgeInsets.all(5),
                              ),
                              onChanged: (CallCategoryModel? data) {
                                setState(() {
                                  callCategoryModel = data;
                                  _contractCall = MyConstants.contractCall;
                                });
                              },
                              items:
                                  callCategory.map((CallCategoryModel? value) {
                                return DropdownMenuItem<CallCategoryModel?>(
                                  value: value,
                                  child: Text(
                                    value!.callCategory!,
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
                          autofocus: false,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
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
                          keyboardType: TextInputType.text,
                          controller: _invoiceNumber,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: MyConstants.invoice,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                autofocus: false,
                                controller: _quantity,
                                enabled: false,
                                decoration: const InputDecoration(
                                  labelText: MyConstants.quantity,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 50.0,
                            ),
                            Expanded(
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        serialRowVisible = true;
                                      });
                                    },
                                    child: const Text(
                                      MyConstants.addButton,
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )))
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Visibility(
                          visible: serialRowVisible!,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  autofocus: false,
                                  controller: _serialNumber,
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    labelText: MyConstants.serialNo,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 50.0,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      itemsRowVisible = true;
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      checkSerialNo();
                                    });
                                  },
                                  child: const Text(
                                    MyConstants.saveButton,
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        getTasListView(),
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
                                    borderRadius:
                                        BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                            child: const Text(MyConstants.generateButton,
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
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context, rootNavigator: true).pop();
                    if (_othersController.text.isEmpty) {
                      setToastMessage(context, MyConstants.reasonError);
                    } else {
                      checkSearchAMCContractData(MyConstants.others);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                child: const Text(MyConstants.submitButton,
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  getSubProduct(int? productId) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.getAMCSubProduct(productId);

      if (response.amcSubProductEntity != null) {
        if (response.amcSubProductEntity!.responseCode ==
            MyConstants.response200) {
          setState(() {
            for (var i = 0;
                i < response.amcSubProductEntity!.data!.length;
                i++) {
              subProduct.add(AMCSubProductModel(
                  productSubId:
                      response.amcSubProductEntity!.data![i]!.productSubId,
                  productSubName:
                      response.amcSubProductEntity!.data![i]!.productSubName));
            }
            Navigator.of(context, rootNavigator: true).pop();
          });
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  bool? validateSerialNo() {
    bool? validate = true;

    if (productModel == null) {
      validate = false;
      setToastMessage(context, MyConstants.productError);
    } else if (subProductModel == null) {
      validate = false;
      setToastMessage(context, MyConstants.subProductError);
    } else if (_serialNumber.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.serialNoError);
    } else if (_modelNumber.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.modelNoError);
    }

    return validate;
  }

  Future<void> checkSerialNo() async {
    if (await checkInternetConnection() == true) {
      if (validateSerialNo()!) {
        showAlertDialog(context);
        final Map<String, dynamic> serialNoData = {
          'product_id': _productId,
          'product_sub_id': _subProductId,
          'model_no': _modelNumber.text,
          'serial_no': _serialNumber.text
        };

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.validateSerialNo(serialNoData);

        if (response.addTransferEntity != null) {
          if (response.addTransferEntity!.responseCode ==
              MyConstants.response200) {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              setToastMessage(context, response.addTransferEntity!.message!);
              serialNumberList.add(_serialNumber.text.trim());
              _serialNumber.text = "";
              _quantity.value =
                  TextEditingValue(text: serialNumberList.length.toString());
              _amount.value = TextEditingValue(
                  text: (serialNumberList.length * _getAmount!).toString());
            });
          } else {
            Navigator.of(context, rootNavigator: true).pop();
            setToastMessage(context, response.addTransferEntity!.message!);
          }
        }
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  bool? validateAddAMC() {
    bool? validate = true;

    if (_contactController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.contactError);
    } else if (_nameController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.nameError);
    } else if (_emailController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.emailError);
    } else if (_plotNumber.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.plotNumber);
    } else if (_street.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.streetError);
    } else if (_postCode.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.postCodeError);
    } else if (countryModel == null) {
      validate = false;
      setToastMessage(context, MyConstants.countryError);
    } else if (stateModel == null) {
      validate = false;
      setToastMessage(context, MyConstants.stateError);
    } else if (cityModel == null) {
      validate = false;
      setToastMessage(context, MyConstants.cityError);
    } else if (locationModel == null) {
      validate = false;
      setToastMessage(context, MyConstants.locationError);
    } else if (_priority == null) {
      validate = false;
      setToastMessage(context, MyConstants.priorityError);
    } else if (amcModel == null) {
      validate = false;
      setToastMessage(context, MyConstants.amcDropdownError);
    } else if (_duration.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.contractDurationError);
    } else if (_contractDurationDate.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.contractDateError);
    }
    if (productModel == null) {
      validate = false;
      setToastMessage(context, MyConstants.productError);
    } else if (subProductModel == null) {
      validate = false;
      setToastMessage(context, MyConstants.subProductError);
    } else if (_modelNumber.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.modelNoError);
    }
    if (_invoiceNumber.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.invoiceError);
    } else if (_quantity.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.quantity);
    } else if (_amount.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.amountError);
    }

    return validate;
  }

  void createNewProductAMC(String? selectedItem) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      final combinedData = <Map<String, dynamic>>[];

      for (int i = 0; i < serialNumberList.length; i++) {
        String name = serialNumberList[i];
        Map<String, String> hi = {'serial_no': name};
        combinedData.add(hi);
      }

      final Map<String, dynamic> apiBodyData = {
        "technician_code":
            PreferenceUtils.getString(MyConstants.technicianCode),
        "contract_ammount": int.parse(_amount.text),
        "city_id": _cityId,
        "amc_type_id": _amcId,
        "amc_period": _contractDuration,
        "customer_code": _cusCode,
        "invoice_id": _invoiceNumber.text,
        "location_id": _locationId,
        "model_no": _modelNumber.text,
        "plot_number": _plotNumber.text,
        "post_code": int.parse(_postCode.text),
        "product_id": _productId,
        "product_sub_id": _subProductId,
        "serial_array": combinedData,
        //  "call_category": _contractCall,
        "priority": _priority,
        "country_id": _countryId,
        "state_id": _stateId,
        "landmark": MyConstants.empty,
        "start_date": _contractStartDate,
        "mode_of_payment": selectedItem,
        "cheque_no": MyConstants.empty,
        "cheque_date": MyConstants.empty,
        "street": _street.text,
        // "work_type": _workTypeId
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.addNewProductAmc(
          PreferenceUtils.getString(MyConstants.token), apiBodyData);

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
            setToastMessage(context, MyConstants.amcProductCreated);
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
            setToastMessage(context, MyConstants.amcProductCreated);
          }
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        setToastMessage(context, MyConstants.internalServerError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void newCreationAMCContract(String? selectedItem) async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);

      final combinedData = <Map<String, dynamic>>[];

      for (int i = 0; i < serialNumberList.length; i++) {
        String name = serialNumberList[i];
        Map<String, String> hi = {'serial_no': name};
        combinedData.add(hi);
      }

      String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
      RegExp regExp = RegExp(pattern);

      if(regExp.hasMatch(_contactController.text.trim())) {
      } else if(!regExp.hasMatch(_contactController.text.trim())) {
      }

      final Map<String, dynamic> apiBodyData = {
        "technician_code":
            PreferenceUtils.getString(MyConstants.technicianCode),
        "total_ammount": int.parse(_amount.text),
        "city_id": _cityId,
        "amc_type": _amcId,
        "customer_name": _nameController.text.trim(),
        "email_id": _emailController.text.trim(),
        "contact_number": _contactController.text.trim(),
        "alternate_number": MyConstants.empty,
        "contract_duration": _contractDuration,
        "invoice_id": _invoiceNumber.text,
        "location_id": _locationId,
        "model_no": _modelNumber.text,
        "plot_number": _plotNumber.text,
        "post_code": int.parse(_postCode.text),
        "product_id": _productId,
        "product_sub_id": _subProductId,
        "serial_array": combinedData,
        "country_id": _countryId,
        "state_id": _stateId,
        "landmark": MyConstants.empty,
        "start_date": _contractStartDate,
        "call_category": _contractCall,
        "mode_of_payment": selectedItem,
        "cheque_no": MyConstants.empty,
        "cheque_date": MyConstants.empty,
        "priority": _priority,
        "street": _street.text,
        "work_type": _workTypeId
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.createNewAmcResult(
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
              setToastMessage(context, MyConstants.amcCreated);
            }

            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashBoard()));
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
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  _travelPlanAlert(BuildContext context) {
    if (validateAddAMC()!) {
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
                              checkSearchAMCContractData(MyConstants.cash);
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
                                        checkSearchAMCContractData(
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

  void checkSearchAMCContractData(String? selectItem) async {
    if (widget.type == MyConstants.createAMC) {
      newCreationAMCContract(selectItem);
    } else if (widget.type == MyConstants.createProduct) {
      createNewProductAMC(selectItem);
    }
  }

  void chequeMode() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final searchAMCContractDataDao = database.serialNoDataDao;
    final newAMCCreationDataDao = database.newAMCCreationDataDao;
    await searchAMCContractDataDao.deleteSerialNoData();

    for (int i = 0; i < serialNumberList.length; i++) {
      SerialNoDataTable serialNoDataTable =
          SerialNoDataTable(i + 1, serialNumberList[i], MyConstants.empty);

      searchAMCContractDataDao.insertSerialNoData(serialNoDataTable);
    }

    NewAMCCreationDataTable newAMCCreationDataTable = NewAMCCreationDataTable(
        id: 1,
        contactNumber: _contactController.text.trim(),
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        flatNoStreet: _plotNumber.text.trim(),
        street: _street.text.trim(),
        postCode: int.parse(_postCode.text.trim()),
        countryId: _countryId,
        stateId: _stateId,
        cityId: _cityId,
        locationId: _locationId,
        priority: _priority,
        amcTypeId: _amcId,
        amcPeriod: _contractDuration,
        startDate: _contractStartDate,
        productId: _productId,
        subCategoryId: _subProductId,
        modelNo: _modelNumber.text.trim(),
        invoiceNo: _modelNumber.text.trim(),
        totalAmount: int.parse(_amount.text.trim()),
        modeOfPayment: MyConstants.cheque,
        checkable: true,
        customerCode: widget.type == MyConstants.createAMC
            ? MyConstants.empty
            : _cusCode);

    newAMCCreationDataDao.insertNewAMCCreationData(newAMCCreationDataTable);

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChequeInformation(
                  amount: double.parse(_amount.text.trim()).toStringAsFixed(2),
                  customerName: _nameController.text.trim(),
                )));
  }

  Widget getTasListView() {
    return serialNumberList.isNotEmpty
        ? ListView.builder(
            itemCount: serialNumberList.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(children: [
                Card(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            serialNumberList[index],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          iconSize: 25,
                          onPressed: () {
                            setState(() {
                              serialNumberList.removeAt(index);
                              _quantity.value = TextEditingValue(
                                  text: serialNumberList.length.toString());
                              _amount.value = TextEditingValue(
                                  text: (serialNumberList.length * _getAmount!)
                                      .toString());
                            });
                          },
                        )
                      ]),
                )
              ]);
            })
        : const Center(
            child: Text(
              MyConstants.serialNoError,
              style: TextStyle(fontSize: 15),
            ),
          );
  }
}
