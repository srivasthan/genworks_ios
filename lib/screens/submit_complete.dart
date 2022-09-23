import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:fieldpro_genworks_healthcare/screens/show_document.dart';
import 'package:fieldpro_genworks_healthcare/screens/start_ticket.dart';
import 'package:fieldpro_genworks_healthcare/screens/ticket_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:ui' as ui;
import 'package:dio/dio.dart' as dio;
import 'package:shimmer/shimmer.dart';
import 'package:device_info/device_info.dart';

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/model/impreset_model.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'dashboard.dart';
import 'field_return_material.dart';
import 'file_directory.dart';
import 'show_image.dart';

class SubmitComplete extends StatefulWidget {
  final String? status, ticketId;

  const SubmitComplete({Key? key, required this.status, required this.ticketId})
      : super(key: key);

  @override
  _SubmitCompleteState createState() => _SubmitCompleteState();
}

class _SubmitCompleteState extends State<SubmitComplete> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _serviceChargeDisabledController =
      TextEditingController();
  final TextEditingController _serviceChargeEnabledController =
      TextEditingController();
  final TextEditingController _spareChargeDisabledController =
      TextEditingController();
  final TextEditingController _spareChargeEnabledController =
      TextEditingController();
  final TextEditingController _productValue = TextEditingController();
  final TextEditingController _serviceValue = TextEditingController();
  final TextEditingController _subtotalController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _totalChargeController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _othersController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _payController = TextEditingController();
  final TextEditingController _rupeeController = TextEditingController();
  final TextEditingController _totalRupeeController = TextEditingController();
  final TextEditingController _priceTypeController = TextEditingController();
  final TextEditingController _chequeNumberController = TextEditingController();
  DateTime? selectedDate = DateTime.now();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final TextEditingController _resolutionSummaryController =
      TextEditingController();
  String? _discountType, _selectedMode, _contractStartDate;
  File? image, capturedImage, signatureImage, _selectedDocument;
  bool _showTick = false,
      _isLoading = true,
      _isSigned = false,
      _showDiscountView = false,
      _serviceChargeDisable = false,
      _serviceChargeEnabled = false,
      _spareChargeDisabled = false,
      _spareChargeEnabled = false;
  final _sign = GlobalKey<SignatureState>();
  var impresetSpareList = <ImpresetModel>[];
  int? productGst, serviceGst, thresholdPercentage, expiryStatus;
  String? priceType;
  double? serviceCharge, spareCharge, value, discountValue, onHandSpareCost = 0;

  // getImprestSpareTracker() async {
  //   if (await checkInternetConnection() == true) {
  //     signatureImage = null;
  //     final combinedData = <Map<String, dynamic>>[];
  //     final database =
  //         await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
  //     final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
  //     var consumedSpareRequestData =
  //         await consumedSpareRequestDataDao.updateSpareCart(true);
  //
  //     if (consumedSpareRequestData.length > 0) {
  //       for (var spareRequestData in consumedSpareRequestData) {
  //         Map<String, dynamic> consumedSpareDataList = {
  //           'spare_code': spareRequestData!.spareCode,
  //           'spare_location_id': spareRequestData.spareLocationId,
  //           'quantity': spareRequestData.updateQuantity
  //         };
  //         combinedData.add(consumedSpareDataList);
  //       }
  //     }
  //
  //     Map<String, dynamic> body = {
  //       'ticket_id': PreferenceUtils.getString(MyConstants.ticketIdStore),
  //       'technician_code':
  //           PreferenceUtils.getString(MyConstants.technicianCode),
  //       'spare_array': combinedData
  //     };
  //
  //     ApiService apiService = ApiService(dio.Dio());
  //     final response = await apiService.consumedSpareRequest(
  //         PreferenceUtils.getString(MyConstants.token), body);
  //     if (response.impresetResponseEntity!.responseCode ==
  //         MyConstants.response200) {
  //       setState(() {
  //         _isLoading = !_isLoading;
  //         consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();
  //         PreferenceUtils.setString(
  //             MyConstants.token, response.impresetResponseEntity!.token!);
  //         setToastMessage(context, response.impresetResponseEntity!.message!);
  //         productGst = response.impresetResponseEntity!.data!.productGst;
  //         serviceGst = response.impresetResponseEntity!.data!.serviceGst;
  //         thresholdPercentage =
  //             response.impresetResponseEntity!.data!.thresholdPercent;
  //         serviceCharge =
  //             response.impresetResponseEntity!.data!.serviceCharge!.toDouble();
  //         spareCharge =
  //             response.impresetResponseEntity!.data!.spareCharge!.toDouble();
  //         double productValue =
  //             (response.impresetResponseEntity!.data!.spareCharge! *
  //                     response.impresetResponseEntity!.data!.productGst!) /
  //                 100;
  //         double serviceValue =
  //             (response.impresetResponseEntity!.data!.serviceCharge! *
  //                     response.impresetResponseEntity!.data!.serviceGst!) /
  //                 100;
  //         _productValue.text = productValue.toStringAsFixed(2);
  //         _serviceValue.text = serviceValue.toStringAsFixed(2);
  //         // _priceTypeController.text =
  //         //     response.impresetResponseEntity!.data!.priceType!;
  //         // _subtotalController.text = response
  //         //     .impresetResponseEntity!.data!.subTotal!
  //         //     .toDouble()
  //         //     .toStringAsFixed(2);
  //         double total = response.impresetResponseEntity!.data!.serviceCharge!
  //                 .toDouble() +
  //             productValue +
  //             serviceValue +
  //             response.impresetResponseEntity!.data!.spareCharge!.toDouble();
  //         _totalChargeController.text = total.toStringAsFixed(2);
  //         _subtotalController.text = total.toStringAsFixed(2);
  //         if (response.impresetResponseEntity!.data!.subTotal! > 0)
  //           _showDiscountView = true;
  //         else
  //           _showDiscountView = false;
  //         switch (response.impresetResponseEntity!.data!.priceLable) {
  //           case 1:
  //             {
  //               _spareChargeEnabled = true;
  //               _spareChargeDisabled = false;
  //               _serviceChargeDisable = true;
  //               _serviceChargeEnabled = false;
  //
  //               _spareChargeEnabledController.text = response
  //                   .impresetResponseEntity!.data!.spareCharge!
  //                   .toDouble()
  //                   .toStringAsFixed(2);
  //               _serviceChargeDisabledController.text = response
  //                   .impresetResponseEntity!.data!.serviceCharge!
  //                   .toDouble()
  //                   .toStringAsFixed(2);
  //               break;
  //             }
  //           case 2:
  //             {
  //               _spareChargeEnabled = false;
  //               _spareChargeDisabled = true;
  //               _serviceChargeDisable = false;
  //               _serviceChargeEnabled = true;
  //
  //               _spareChargeDisabledController.text = response
  //                   .impresetResponseEntity!.data!.spareCharge!
  //                   .toDouble()
  //                   .toStringAsFixed(2);
  //               _serviceChargeEnabledController.text = response
  //                   .impresetResponseEntity!.data!.serviceCharge!
  //                   .toDouble()
  //                   .toStringAsFixed(2);
  //               break;
  //             }
  //           case 3:
  //             {
  //               _spareChargeEnabled = false;
  //               _spareChargeDisabled = true;
  //               _serviceChargeDisable = true;
  //               _serviceChargeEnabled = false;
  //
  //               _spareChargeDisabledController.text = response
  //                   .impresetResponseEntity!.data!.spareCharge!
  //                   .toDouble()
  //                   .toStringAsFixed(2);
  //               _serviceChargeDisabledController.text = response
  //                   .impresetResponseEntity!.data!.serviceCharge!
  //                   .toDouble()
  //                   .toStringAsFixed(2);
  //               break;
  //             }
  //         }
  //       });
  //     } else if (response.impresetResponseEntity!.responseCode ==
  //         MyConstants.response400) {
  //       setState(() {
  //         _isLoading = !_isLoading;
  //         PreferenceUtils.setString(
  //             MyConstants.token, response.impresetResponseEntity!.token!);
  //         setToastMessage(context, MyConstants.noDataAvailable);
  //       });
  //     } else if (response.impresetResponseEntity!.responseCode ==
  //         MyConstants.response500) {
  //       setState(() {
  //         _isLoading = !_isLoading;
  //         if (response.impresetResponseEntity!.message != null)
  //           setToastMessage(context, response.impresetResponseEntity!.message!);
  //         else
  //           setToastMessage(context, MyConstants.tokenError);
  //       });
  //     }
  //   } else {
  //     setToastMessage(context, MyConstants.internetConnection);
  //   }
  // }

  /* based on genworks live*/
  // getImprestSpareTracker() async {
  //   if (await checkInternetConnection() == true) {
  //     signatureImage = null;
  //     final combinedData = <Map<String, dynamic>>[];
  //     final database =
  //         await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
  //     final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
  //     var consumedSpareRequestData =
  //         await consumedSpareRequestDataDao.updateSpareCart(true);
  //
  //     if (consumedSpareRequestData.length > 0) {
  //       for (var spareRequestData in consumedSpareRequestData) {
  //         Map<String, dynamic> consumedSpareDataList = {
  //           'spare_code': spareRequestData!.spareCode,
  //           'spare_location_id': spareRequestData.spareLocationId,
  //           'quantity': spareRequestData.updateQuantity
  //         };
  //         combinedData.add(consumedSpareDataList);
  //       }
  //     }
  //
  //     Map<String, dynamic> body = {
  //       'ticket_id': PreferenceUtils.getString(MyConstants.ticketIdStore),
  //       'technician_code':
  //           PreferenceUtils.getString(MyConstants.technicianCode),
  //       'spare_array': combinedData
  //     };
  //
  //     ApiService apiService = ApiService(dio.Dio());
  //     final response = await apiService.consumedSpareRequest(
  //         PreferenceUtils.getString(MyConstants.token), body);
  //     if (response.impresetResponseEntity!.responseCode ==
  //         MyConstants.response200) {
  //       setState(() {
  //         _isLoading = !_isLoading;
  //         consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();
  //         PreferenceUtils.setString(
  //             MyConstants.token, response.impresetResponseEntity!.token!);
  //         setToastMessage(context, response.impresetResponseEntity!.message!);
  //         productGst = response.impresetResponseEntity!.data!.productGst;
  //         serviceGst = response.impresetResponseEntity!.data!.serviceGst;
  //         thresholdPercentage =
  //             response.impresetResponseEntity!.data!.thresholdPercent;
  //         serviceCharge =
  //             response.impresetResponseEntity!.data!.serviceCharge!.toDouble();
  //         spareCharge =
  //             response.impresetResponseEntity!.data!.spareCharge!.toDouble();
  //         double productValue =
  //             (response.impresetResponseEntity!.data!.spareCharge! *
  //                     response.impresetResponseEntity!.data!.productGst!) /
  //                 100;
  //         double serviceValue =
  //             (response.impresetResponseEntity!.data!.serviceCharge! *
  //                     response.impresetResponseEntity!.data!.serviceGst!) /
  //                 100;
  //         double total = response.impresetResponseEntity!.data!.serviceCharge!
  //                 .toDouble() +
  //             productValue +
  //             serviceValue +
  //             response.impresetResponseEntity!.data!.spareCharge!.toDouble();
  //
  //         if (response.impresetResponseEntity!.data!.expirationStatus == 0) {
  //           if (spareCharge == 0) {
  //             if (total <= 0.0) {
  //               _showDiscountView = false;
  //             } else {
  //               _showDiscountView = true;
  //             }
  //
  //             _serviceChargeDisable = true;
  //
  //             _spareChargeDisabledController.text = response
  //                 .impresetResponseEntity!.data!.spareCharge!
  //                 .toDouble()
  //                 .toStringAsFixed(2);
  //             _serviceChargeDisabledController.text = response
  //                 .impresetResponseEntity!.data!.serviceCharge!
  //                 .toDouble()
  //                 .toStringAsFixed(2);
  //
  //             _productValue.text = "0.00";
  //             _serviceValue.text = "0.00";
  //
  //             _totalChargeController.text = total.toStringAsFixed(2);
  //             _subtotalController.text = total.toStringAsFixed(2);
  //           } else {
  //             if (total <= 0.0) {
  //               _showDiscountView = false;
  //             } else {
  //               _showDiscountView = true;
  //             }
  //
  //             _spareChargeDisabledController.text = response
  //                 .impresetResponseEntity!.data!.spareCharge!
  //                 .toDouble()
  //                 .toStringAsFixed(2);
  //             _serviceChargeDisabledController.text = response
  //                 .impresetResponseEntity!.data!.serviceCharge!
  //                 .toDouble()
  //                 .toStringAsFixed(2);
  //
  //             _serviceChargeDisable = true;
  //
  //             _productValue.text = productValue.toStringAsFixed(2);
  //             _serviceValue.text = "0.00";
  //             _totalChargeController.text = total.toStringAsFixed(2);
  //             _subtotalController.text = total.toStringAsFixed(2);
  //           }
  //         } else {
  //           if (spareCharge == 0) {
  //             if (total <= 0.0) {
  //               _showDiscountView = false;
  //             } else {
  //               _showDiscountView = true;
  //             }
  //
  //             _spareChargeDisabledController.text = response
  //                 .impresetResponseEntity!.data!.spareCharge!
  //                 .toDouble()
  //                 .toStringAsFixed(2);
  //             _serviceChargeEnabledController.text = response
  //                 .impresetResponseEntity!.data!.serviceCharge!
  //                 .toDouble()
  //                 .toStringAsFixed(2);
  //             _serviceChargeEnabled = true;
  //
  //             _productValue.text = "0.00";
  //             _serviceValue.text = "0.00";
  //             _totalChargeController.text = "0.00";
  //             _subtotalController.text = "0.00";
  //           } else {
  //             if (total <= 0.0) {
  //               _showDiscountView = false;
  //             } else {
  //               _showDiscountView = true;
  //             }
  //
  //             _spareChargeDisabledController.text = response
  //                 .impresetResponseEntity!.data!.spareCharge!
  //                 .toDouble()
  //                 .toStringAsFixed(2);
  //             _serviceChargeDisabledController.text = response
  //                 .impresetResponseEntity!.data!.serviceCharge!
  //                 .toDouble()
  //                 .toStringAsFixed(2);
  //             _serviceChargeEnabled = true;
  //
  //             _productValue.text = productValue.toStringAsFixed(2);
  //             _serviceValue.text = "0.00";
  //             _totalChargeController.text = "0.00";
  //             _subtotalController.text = "0.00";
  //           }
  //         }
  //       });
  //     } else if (response.impresetResponseEntity!.responseCode ==
  //         MyConstants.response400) {
  //       setState(() {
  //         _isLoading = !_isLoading;
  //         PreferenceUtils.setString(
  //             MyConstants.token, response.impresetResponseEntity!.token!);
  //         setToastMessage(context, MyConstants.noDataAvailable);
  //       });
  //     } else if (response.impresetResponseEntity!.responseCode ==
  //         MyConstants.response500) {
  //       setState(() {
  //         _isLoading = !_isLoading;
  //         if (response.impresetResponseEntity!.message != null)
  //           setToastMessage(context, response.impresetResponseEntity!.message!);
  //         else
  //           setToastMessage(context, MyConstants.tokenError);
  //       });
  //     }
  //   } else {
  //     setToastMessage(context, MyConstants.internetConnection);
  //   }
  // }

  getImprestSpareTracker() async {
    if (await checkInternetConnection() == true) {
      signatureImage = null;
      final combinedData = <Map<String, dynamic>>[];
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
      final selectedOnHandSpareDao = database.selectedOnHandSpareDao;
      var selectedSpareList = await selectedOnHandSpareDao
          .getSelectedSpareByTicketId(true, widget.ticketId!);

      if (selectedSpareList.isNotEmpty) {
        for (var selectedList in selectedSpareList) {
          Map<String, dynamic> consumedSpareDataList = {
            'spare_code': selectedList.spareCode,
            'spare_location_id': selectedList.locationId,
            'quantity': selectedList.quantity
          };
          combinedData.add(consumedSpareDataList);
        }
      }

      Map<String, dynamic> body = {
        'ticket_id': PreferenceUtils.getString(MyConstants.ticketIdStore),
        'technician_code':
            PreferenceUtils.getString(MyConstants.technicianCode),
        'spare_array': combinedData
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.consumedSpareRequest(
          PreferenceUtils.getString(MyConstants.token), body);
      if (response.impresetResponseEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          _isLoading = !_isLoading;
          consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();
          PreferenceUtils.setString(
              MyConstants.token, response.impresetResponseEntity!.token!);
          setToastMessage(context, response.impresetResponseEntity!.message!);
          productGst = response.impresetResponseEntity!.data!.productGst;
          serviceGst = response.impresetResponseEntity!.data!.serviceGst;
          priceType = response.impresetResponseEntity!.data!.priceType;
          if(response.impresetResponseEntity!.data!.priceLable! == "1") {
            _priceTypeController.text = response.impresetResponseEntity!.data!.priceType!;
          } else if(response.impresetResponseEntity!.data!.priceLable! == "2") {
            _priceTypeController.text = response.impresetResponseEntity!.data!.priceType!;
          } else if(response.impresetResponseEntity!.data!.priceLable! == "3") {
            _priceTypeController.text = response.impresetResponseEntity!.data!.priceType!;
          } else if(response.impresetResponseEntity!.data!.priceLable! == "4") {
            _priceTypeController.text = response.impresetResponseEntity!.data!.priceType!;
          }
          expiryStatus =
              response.impresetResponseEntity!.data!.expirationStatus;
          thresholdPercentage =
              response.impresetResponseEntity!.data!.thresholdPercent;
          serviceCharge =
              response.impresetResponseEntity!.data!.serviceCharge!.toDouble();
          spareCharge =
              response.impresetResponseEntity!.data!.spareCharge!.toDouble();
          double productValue =
              (response.impresetResponseEntity!.data!.spareCharge! *
                      response.impresetResponseEntity!.data!.productGst!) /
                  100;
          double serviceValue =
              (response.impresetResponseEntity!.data!.serviceCharge! *
                      response.impresetResponseEntity!.data!.serviceGst!) /
                  100;
          double total = serviceCharge!.toDouble().toDouble() +
              productValue +
              serviceValue +
              spareCharge!.toDouble();

          switch (response.impresetResponseEntity!.data!.priceLable) {
            case "1":
              {
                if (total <= 0.0) {
                  _showDiscountView = false;
                } else {
                  _showDiscountView = true;
                }

                _serviceChargeEnabled = false;
                _serviceChargeDisable = true;
                _spareChargeEnabled = true;
                _spareChargeDisabled = false;

                _spareChargeEnabledController.text =
                    spareCharge!.toStringAsFixed(2);
                _serviceChargeDisabledController.text =
                    serviceCharge!.toStringAsFixed(2);

                _productValue.text = productValue.toStringAsFixed(2);
                _serviceValue.text = serviceValue.toStringAsFixed(2);

                _totalChargeController.text = total.toStringAsFixed(2);
                _subtotalController.text = total.toStringAsFixed(2);

                break;
              }

            case "2":
              {
                if (total <= 0.0) {
                  _showDiscountView = false;
                } else {
                  _showDiscountView = true;
                }

                _serviceChargeEnabled = false;
                _serviceChargeDisable = true;
                _spareChargeEnabled = false;
                _spareChargeDisabled = true;

                _spareChargeDisabledController.text =
                    spareCharge!.toStringAsFixed(2);
                _serviceChargeDisabledController.text =
                    serviceCharge!.toStringAsFixed(2);

                _productValue.text = productValue.toStringAsFixed(2);
                _serviceValue.text = serviceValue.toStringAsFixed(2);

                _totalChargeController.text = total.toStringAsFixed(2);
                _subtotalController.text = total.toStringAsFixed(2);

                break;
              }

            case "3":
              {
                if (total <= 0.0) {
                  _showDiscountView = false;
                } else {
                  _showDiscountView = true;
                }

                _serviceChargeEnabled = true;
                _serviceChargeDisable = false;
                _spareChargeEnabled = true;
                _spareChargeDisabled = false;

                _spareChargeEnabledController.text =
                    spareCharge!.toStringAsFixed(2);
                _serviceChargeEnabledController.text =
                    serviceCharge!.toStringAsFixed(2);

                _productValue.text = productValue.toStringAsFixed(2);
                _serviceValue.text = serviceValue.toStringAsFixed(2);

                _totalChargeController.text = total.toStringAsFixed(2);
                _subtotalController.text = total.toStringAsFixed(2);

                break;
              }

            // case "4":
            //   {
            //     if (response.impresetResponseEntity!.data!.expirationStatus ==
            //         0) {
            //       if (total <= 0.0) {
            //         _showDiscountView = false;
            //       } else {
            //         _showDiscountView = true;
            //       }
            //
            //       _serviceChargeEnabled = true;
            //       _serviceChargeDisable = false;
            //       _spareChargeEnabled = true;
            //       _spareChargeDisabled = false;
            //
            //       _spareChargeEnabledController.text =
            //           spareCharge!.toStringAsFixed(2);
            //       _serviceChargeEnabledController.text =
            //           serviceCharge!.toStringAsFixed(2);
            //
            //       _productValue.text = productValue.toStringAsFixed(2);
            //       _serviceValue.text = serviceValue.toStringAsFixed(2);
            //
            //       _totalChargeController.text = total.toStringAsFixed(2);
            //       _subtotalController.text = total.toStringAsFixed(2);
            //     }
            //     else {
            //       if (total <= 0.0) {
            //         _showDiscountView = false;
            //       } else {
            //         _showDiscountView = true;
            //       }
            //
            //       _serviceChargeEnabled = true;
            //       _serviceChargeDisable = false;
            //       _spareChargeEnabled = true;
            //       _spareChargeDisabled = false;
            //
            //       _spareChargeEnabledController.text =
            //           spareCharge!.toStringAsFixed(2);
            //       _serviceChargeEnabledController.text =
            //           serviceCharge!.toStringAsFixed(2);
            //
            //       _productValue.text = productValue.toStringAsFixed(2);
            //       _serviceValue.text = serviceValue.toStringAsFixed(2);
            //
            //       _totalChargeController.text = total.toStringAsFixed(2);
            //       _subtotalController.text = total.toStringAsFixed(2);
            //     }
            //
            //     break;
            //   }
          }
        });
      } else if (response.impresetResponseEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.impresetResponseEntity!.token!);
          setToastMessage(context, MyConstants.noDataAvailable);
        });
      } else if (response.impresetResponseEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
          if (response.impresetResponseEntity!.message != null) {
            setToastMessage(context, response.impresetResponseEntity!.message!);
          } else {
            setToastMessage(context, MyConstants.tokenError);
          }
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  getDiscountDetails() async {
    if (await checkInternetConnection() == true) {
      signatureImage = null;

      final combinedData = <Map<String, dynamic>>[];
      final database =
      await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final selectedOnHandSpareDao = database.selectedOnHandSpareDao;
      var selectedSpareList = await selectedOnHandSpareDao
          .getSelectedSpareByTicketId(true, widget.ticketId!);

      Map<String, dynamic> body = {
        'ticket_id': PreferenceUtils.getString(MyConstants.ticketIdStore),
        'technician_code':
            PreferenceUtils.getString(MyConstants.technicianCode),
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.discountConsumedSpareRequest(
          PreferenceUtils.getString(MyConstants.token), body);

      if (response.discountResponseEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.discountResponseEntity!.token!);
          productGst =
              int.parse(response.discountResponseEntity!.data!.productGst!);
          serviceGst =
              int.parse(response.discountResponseEntity!.data!.serviceGst!);
          thresholdPercentage =
              response.discountResponseEntity!.data!.thresholdPercent;
          serviceCharge =
              int.parse(response.discountResponseEntity!.data!.serviceCharge!)
                  .toDouble();
          spareCharge =
              int.parse(response.discountResponseEntity!.data!.spareCharge!)
                  .toDouble();
          double productValue =
              (int.parse(response.discountResponseEntity!.data!.spareCharge!) *
                      productGst!) /
                  100;
          double serviceValue = (int.parse(
                      response.discountResponseEntity!.data!.serviceCharge!) *
                  serviceGst!) /
              100;
          _productValue.text = productValue.toStringAsFixed(2);
          _serviceValue.text = serviceValue.toStringAsFixed(2);
          if(response.discountResponseEntity!.data!.priceLable! == "1") {
            _priceTypeController.text = response.discountResponseEntity!.data!.priceType!;
          } else if(response.discountResponseEntity!.data!.priceLable! == "2") {
            _priceTypeController.text = response.discountResponseEntity!.data!.priceType!;
          } else if(response.discountResponseEntity!.data!.priceLable! == "3") {
            _priceTypeController.text = response.discountResponseEntity!.data!.priceType!;
          } else if(response.discountResponseEntity!.data!.priceLable! == "4") {
            _priceTypeController.text = response.discountResponseEntity!.data!.priceType!;
          }

          _subtotalController.text = response
              .discountResponseEntity!.data!.subTotal!
              .toDouble()
              .toStringAsFixed(2);
          _totalChargeController.text = response
              .discountResponseEntity!.data!.total!
              .toDouble()
              .toStringAsFixed(2);

          if (response.discountResponseEntity!.data!.subTotal! > 0) {
            _showDiscountView = true;
          } else {
            _showDiscountView = false;
          }

          if (response.discountResponseEntity!.data!.discountType ==
              MyConstants.updateQuantity) {
            _discountType = MyConstants.value;
            discountValue = double.parse(
                response.discountResponseEntity!.data!.discount!.toString());
            _discountController.text = double.parse(
                    response.discountResponseEntity!.data!.discount!.toString())
                .toStringAsFixed(2);
          } else if (response.discountResponseEntity!.data!.discountType ==
              MyConstants.dropDownPercent) {
            _discountType = MyConstants.percentage;
            discountValue = double.parse(
                response.discountResponseEntity!.data!.discount!.toString());
            _discountController.text = double.parse(
                    response.discountResponseEntity!.data!.discount!.toString())
                .toStringAsFixed(0);
          }

          switch (response.discountResponseEntity!.data!.priceLable) {
            case "1":
              {

                if(productGst == 0 && selectedSpareList.isEmpty){
                  _spareChargeEnabled = false;
                  _spareChargeDisabled = true;
                  _serviceChargeDisable = true;
                  _serviceChargeEnabled = false;

                  _spareChargeDisabledController.text = int.parse(
                      response.discountResponseEntity!.data!.spareCharge!)
                      .toDouble()
                      .toStringAsFixed(2);
                  _serviceChargeDisabledController.text = int.parse(
                      response.discountResponseEntity!.data!.serviceCharge!)
                      .toDouble()
                      .toStringAsFixed(2);
                } else if(productGst! > 0 && selectedSpareList.isNotEmpty) {
                  _spareChargeEnabled = true;
                  _spareChargeDisabled = true;
                  _serviceChargeDisable = true;
                  _serviceChargeEnabled = false;

                  _spareChargeDisabledController.text = int.parse(
                      response.discountResponseEntity!.data!.spareCharge!)
                      .toDouble()
                      .toStringAsFixed(2);
                  _serviceChargeDisabledController.text = int.parse(
                      response.discountResponseEntity!.data!.serviceCharge!)
                      .toDouble()
                      .toStringAsFixed(2);
                }

                break;
              }
            case "2":
              {
                _spareChargeEnabled = false;
                _spareChargeDisabled = true;
                _serviceChargeDisable = true;
                _serviceChargeEnabled = false;

                _spareChargeDisabledController.text = int.parse(
                        response.discountResponseEntity!.data!.spareCharge!)
                    .toDouble()
                    .toStringAsFixed(2);
                _serviceChargeDisabledController.text = int.parse(
                        response.discountResponseEntity!.data!.serviceCharge!)
                    .toDouble()
                    .toStringAsFixed(2);
                break;
              }
            case "3":
              {
                _spareChargeEnabled = true;
                _spareChargeDisabled = false;
                _serviceChargeDisable = false;
                _serviceChargeEnabled = true;

                _spareChargeEnabledController.text = int.parse(
                        response.discountResponseEntity!.data!.spareCharge!)
                    .toDouble()
                    .toStringAsFixed(2);
                _serviceChargeEnabledController.text = int.parse(
                        response.discountResponseEntity!.data!.serviceCharge!)
                    .toDouble()
                    .toStringAsFixed(2);
                break;
              }
            // case "4":
            //   {
            //     _spareChargeEnabled = true;
            //     _spareChargeDisabled = false;
            //     _serviceChargeDisable = false;
            //     _serviceChargeEnabled = true;
            //
            //     _spareChargeEnabledController.text = int.parse(
            //         response.discountResponseEntity!.data!.spareCharge!)
            //         .toDouble()
            //         .toStringAsFixed(2);
            //     _serviceChargeEnabledController.text = int.parse(
            //         response.discountResponseEntity!.data!.serviceCharge!)
            //         .toDouble()
            //         .toStringAsFixed(2);
            //     break;
            //   }
          }
        });
      } else if (response.discountResponseEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          _isLoading = !_isLoading;
          PreferenceUtils.setString(
              MyConstants.token, response.discountResponseEntity!.token!);
          setToastMessage(context, MyConstants.noDataAvailable);
        });
      } else if (response.discountResponseEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
          setToastMessage(context, MyConstants.tokenError);
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    // getImprestSpareTracker();

    if (widget.status == "Submit Complete") {
      getImprestSpareTracker();
    } else if (widget.status == "Ongoing Ticket") {
      getDiscountDetails();
    }
  }

  Future<T?> pushPage<T>(BuildContext context, Widget? page) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page!));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // if (widget.status == MyConstants.ongoingTicket) {
        //   pushPage(context, new TicketList(1));
        // } else if (widget.status == MyConstants.submitComplete) {
        //   pushPage(
        //       context,
        //       new InstallationReportComplete(
        //           ticketStatusData: MyConstants.complete));
        // }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          key: _key,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                if (widget.status == MyConstants.ongoingTicket) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TicketList(1)));
                } else if (widget.status == MyConstants.submitComplete) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StartTicket(
                                ticketId: widget.ticketId,
                                status: MyConstants.ticketStarted,
                              )));
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
                                                MyConstants.billingInformation,
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
                            Visibility(
                              visible: _serviceChargeDisable,
                              child: TextFormField(
                                enabled: false,
                                controller: _serviceChargeDisabledController,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.serviceCharge,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Visibility(
                              visible: _serviceChargeEnabled,
                              child: TextFormField(
                                controller: _serviceChargeEnabledController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.serviceCharge,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                                onChanged: (String? value) {
                                  if (value!.isNotEmpty) {
                                    serviceChargeEditable(double.parse(value));
                                  } else {
                                    setState(() {
                                      double serviceGstChanged, subTotalChanged;
                                      if (_spareChargeEnabled == true) {
                                        serviceGstChanged = 0.00;
                                        subTotalChanged = 0.00 +
                                            serviceGstChanged +
                                            double.parse(_productValue.text) +
                                            double.parse(
                                                _spareChargeEnabledController
                                                    .text);
                                      } else {
                                        serviceGstChanged = 0.00;
                                        subTotalChanged = 0.00 +
                                            serviceGstChanged +
                                            double.parse(_productValue.text) +
                                            double.parse(
                                                _spareChargeDisabledController
                                                    .text);
                                      }

                                      _serviceValue.text =
                                          serviceGstChanged.toStringAsFixed(2);
                                      _subtotalController.text =
                                          subTotalChanged.toStringAsFixed(2);
                                      _totalChargeController.text =
                                          subTotalChanged.toStringAsFixed(2);
                                      if (subTotalChanged > 0.0) {
                                        _showDiscountView = true;
                                      } else {
                                        _showDiscountView = false;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Visibility(
                              visible: _spareChargeDisabled,
                              child: TextFormField(
                                enabled: false,
                                controller: _spareChargeDisabledController,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.spareCharge,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Visibility(
                              visible: _spareChargeEnabled,
                              child: TextFormField(
                                controller: _spareChargeEnabledController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.spareCharge,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                                onChanged: (String? value) {
                                  if (value!.isNotEmpty) {
                                    spareChargeEditable(double.parse(value));
                                  } else {
                                    setState(() {
                                      double spareChargeChanged,
                                          subTotalChanged;
                                      if (_serviceChargeEnabled == true) {
                                        spareChargeChanged =
                                            spareChargeChanged = 0.00;
                                        subTotalChanged = double.parse(
                                                _serviceChargeEnabledController
                                                    .text) +
                                            double.parse(_serviceValue.text) +
                                            spareChargeChanged +
                                            0.00;
                                      } else {
                                        spareChargeChanged =
                                            spareChargeChanged = 0.00;
                                        subTotalChanged = double.parse(
                                                _serviceChargeDisabledController
                                                    .text) +
                                            double.parse(_serviceValue.text) +
                                            spareChargeChanged +
                                            0.00;
                                      }

                                      _productValue.text =
                                          spareChargeChanged.toStringAsFixed(2);
                                      _subtotalController.text =
                                          subTotalChanged.toStringAsFixed(2);
                                      _totalChargeController.text =
                                          subTotalChanged.toStringAsFixed(2);
                                      if (subTotalChanged > 0.0) {
                                        _showDiscountView = true;
                                      } else {
                                        _showDiscountView = false;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            TextFormField(
                              controller: _productValue,
                              enabled: false,
                              decoration: InputDecoration(
                                  labelText: MyConstants.productGst +
                                      productGst.toString() +
                                      MyConstants.percentClose,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: const OutlineInputBorder()),
                            ),
                            const SizedBox(height: 10.0),
                            TextFormField(
                              controller: _serviceValue,
                              enabled: false,
                              decoration: InputDecoration(
                                  labelText: MyConstants.serviceGst +
                                      serviceGst.toString() +
                                      MyConstants.percentClose,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: const OutlineInputBorder()),
                            ),
                            const SizedBox(height: 10.0),
                            TextFormField(
                              controller: _priceTypeController,
                              enabled: false,
                              decoration: const InputDecoration(
                                  labelText: "Support Scope",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 10.0),
                            const Divider(
                              thickness: 3.0,
                              color: Colors.black26,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              enabled: false,
                              controller: _subtotalController,
                              decoration: const InputDecoration(
                                  labelText: MyConstants.subTotal,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: OutlineInputBorder()),
                            ),
                            Visibility(
                                visible: _showDiscountView,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Container(
                                      color:
                                          Color(int.parse("0xfff" "778899")),
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
                                          dropdownColor: Color(
                                              int.parse("0xfff" "778899")),
                                          hint: const Text(
                                            MyConstants.priceTypeHint,
                                            style:
                                                TextStyle(color: Colors.white),
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
                                    const SizedBox(height: 10.0),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: _discountController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              labelText: MyConstants.discount,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 10, 10, 0),
                                              border: OutlineInputBorder()),
                                          onChanged: (String? data) {
                                            if (data!.isNotEmpty) {
                                              value = double.parse(data);
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (value.toString().isNotEmpty &&
                                                  _discountType != null &&
                                                  value != null) {
                                                discountCalculation(value!);
                                              } else if (value == null ||
                                                  value.toString().isEmpty) {
                                                setToastMessage(
                                                    context,
                                                    MyConstants
                                                        .discountTextBoxError);
                                              } else if (_discountType ==
                                                  null) {
                                                setToastMessage(context,
                                                    MyConstants.discountError);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                shape:
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                    .circular(
                                                                10.0)), backgroundColor: Color(int.parse(
                                                    "0xfff" "5C7E7F"))),
                                            child: const Text(
                                                MyConstants.submitButton,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ],
                                )),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const Divider(
                              thickness: 3.0,
                              color: Colors.black26,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              enabled: false,
                              controller: _totalChargeController,
                              decoration: const InputDecoration(
                                  labelText: MyConstants.totalCharge,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: OutlineInputBorder()),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const Divider(
                              thickness: 3.0,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 10.0),
                            TextFormField(
                              controller: _resolutionSummaryController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return MyConstants.resolutionSummaryError;
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  labelText: MyConstants.resolutionSummary,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  border: OutlineInputBorder()),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(MyConstants.customerSignature)),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12)),
                              child: Signature(
                                color: Colors.black,
                                key: _sign,
                                onSign: () {
                                  setState(() {
                                    _isSigned = true;
                                  });
                                },
                                strokeWidth: 3.0,
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (signatureImage != null) {
                                          if (await signatureImage!.exists()) {
                                            await signatureImage!.delete();
                                          }
                                        }
                                        setState(() {
                                          _isSigned = false;
                                          _sign.currentState!.clear();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      5.0)), backgroundColor: Color(
                                              int.parse("0xfff" "5C7E7F"))),
                                      child: const Text(MyConstants.clearButton,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                const Padding(padding: EdgeInsets.all(5.0)),
                                Expanded(
                                  flex: 0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const <Widget>[
                                      Text(MyConstants.attachment,
                                          style: TextStyle(fontSize: 15)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                barrierColor:
                                                    Colors.black.withAlpha(150),
                                                builder: (context) {
                                                  return imageBottomSheet(
                                                      context);
                                                });
                                          },
                                          child: const Text(
                                              MyConstants.attachmentString,
                                              style: TextStyle(
                                                  color: Colors.lightBlue,
                                                  fontSize: 15)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          barrierColor:
                                              Colors.black.withAlpha(150),
                                          builder: (context) {
                                            return imageBottomSheet(context);
                                          });
                                    },
                                    icon: Image.asset(
                                      'assets/images/photo.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: Visibility(
                                    visible: _showTick,
                                    child: IconButton(
                                      onPressed: () {
                                        if (_selectedDocument != null) {
                                          String fileName = _selectedDocument!
                                              .path
                                              .split('/')
                                              .last;
                                          String extension =
                                              fileName.split('.').last;
                                          if (extension == "pdf") {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DocumentViewer(
                                                            _selectedDocument)));
                                          } else {
                                            OpenFilex.open(
                                                _selectedDocument!.path);
                                          }
                                        } else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShowImage(
                                                          image: "",
                                                          capturedImage:
                                                              capturedImage)));
                                        }
                                      },
                                      icon: Image.asset(
                                        'assets/images/check.png',
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (widget.status ==
                                      MyConstants.ongoingTicket) {
                                    var checkingValue;
                                    if (_discountType == MyConstants.value) {
                                      checkingValue =
                                          discountValue!.toStringAsFixed(2);
                                    } else {
                                      checkingValue =
                                          discountValue!.toStringAsFixed(0);
                                    }
                                    if (_discountController.text ==
                                        checkingValue) {
                                      ArtSweetAlert.show(
                                          context: context,
                                          artDialogArgs: ArtDialogArgs(
                                              title: MyConstants.appTittle,
                                              text: MyConstants
                                                  .discountValueNotChangedError,
                                              showCancelBtn: true,
                                              confirmButtonText:
                                                  MyConstants.yesButton,
                                              cancelButtonText:
                                                  MyConstants.noButton,
                                              onConfirm: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                                _travelPlanAlert(context);
                                              },
                                              onCancel: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              },
                                              cancelButtonColor: Color(
                                                  int.parse(
                                                      "0xfff" "C5C5C5")),
                                              confirmButtonColor: Color(
                                                  int.parse(
                                                      "0xfff" "507a7d"))));
                                    }
                                  } else {
                                    _travelPlanAlert(context);
                                  }
                                },
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
                                                      .billingInformation,
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
                              TextFormField(
                                enabled: false,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.serviceCharge,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: MyConstants.serviceCharge,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                enabled: false,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.spareCharge,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: MyConstants.spareCharge,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: "${MyConstants.productGst}10${MyConstants.percentClose}",
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: "${MyConstants.serviceGst}10${MyConstants.percentClose}",
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: MyConstants.priceType,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10.0),
                              const Divider(
                                thickness: 3.0,
                                color: Colors.black26,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                enabled: false,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.subTotal,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        decoration: const InputDecoration(
                                            labelText: MyConstants.discount,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 10, 10, 0),
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
                                                          10.0)), backgroundColor: Color(int.parse(
                                                  "0xfff" "5C7E7F"))),
                                          child: const Text(MyConstants.submitButton,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  const SizedBox(height: 10.0),
                                  Container(
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
                                        dropdownColor: Color(
                                            int.parse("0xfff" "778899")),
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
                                        onChanged: (String? value) {},
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
                                ],
                              )
                            ],
                          ))),
            ),
          ),
        ),
      ),
    );
  }

  serviceChargeEditable(double value) {
    setState(() {
      double serviceGstChanged, subTotalChanged;
      if (_spareChargeEnabled == true) {
        serviceGstChanged = (value * serviceGst!) / 100;
        subTotalChanged = value +
            serviceGstChanged +
            double.parse(_productValue.text) +
            double.parse(_spareChargeEnabledController.text);
      } else {
        serviceGstChanged = (value * serviceGst!) / 100;
        subTotalChanged = value +
            serviceGstChanged +
            double.parse(_productValue.text) +
            double.parse(_spareChargeDisabledController.text);
      }

      _serviceValue.text = serviceGstChanged.toStringAsFixed(2);
      _subtotalController.text = subTotalChanged.toStringAsFixed(2);
      _totalChargeController.text = subTotalChanged.toStringAsFixed(2);
      if (subTotalChanged > 0.0) {
        _showDiscountView = true;
      } else {
        _showDiscountView = false;
      }
    });
  }

  spareChargeEditable(double value) {
    setState(() {
      double spareChargeChanged, subTotalChanged;
      if (_serviceChargeEnabled == true) {
        spareChargeChanged = (value * productGst!) / 100;
        subTotalChanged = double.parse(_serviceChargeEnabledController.text) +
            double.parse(_serviceValue.text) +
            spareChargeChanged +
            value;
      } else {
        spareChargeChanged = (value * productGst!) / 100;
        subTotalChanged = double.parse(_serviceChargeDisabledController.text) +
            double.parse(_serviceValue.text) +
            spareChargeChanged +
            value;
      }

      _productValue.text = spareChargeChanged.toStringAsFixed(2);
      _subtotalController.text = subTotalChanged.toStringAsFixed(2);
      _totalChargeController.text = subTotalChanged.toStringAsFixed(2);
      if (subTotalChanged > 0.0) {
        _showDiscountView = true;
      } else {
        _showDiscountView = false;
      }
    });
  }

  discountCalculation(double value) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_discountType == MyConstants.value) {
      setState(() {
        double? thresholdValue;
        double totalValue = double.parse(_subtotalController.text) - value;
        if (widget.status == MyConstants.submitComplete) {
          thresholdValue = double.parse(_subtotalController.text) *
              (thresholdPercentage! / 100);
        } else if (widget.status == MyConstants.complete) {
          thresholdValue = discountValue;
        }

        if (thresholdValue! >= value) {
          _totalChargeController.text = totalValue.toStringAsFixed(2);
        } else {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  title: MyConstants.appTittle,
                  text: MyConstants.discountFirstText +
                      thresholdValue.toStringAsFixed(2) +
                      MyConstants.discountSecondText,
                  showCancelBtn: true,
                  confirmButtonText: MyConstants.yesButton,
                  cancelButtonText: MyConstants.noButton,
                  onConfirm: () async {
                    if (await checkInternetConnection() == true) {
                      Navigator.of(context, rootNavigator: true).pop();

                      showAlertDialog(context);
                      Map<String, dynamic> discountData = {
                        'technician_code': PreferenceUtils.getString(
                            MyConstants.technicianCode),
                        'ticket_id': PreferenceUtils.getString(
                            MyConstants.ticketIdStore),
                        'service_charge': _serviceChargeEnabled == true
                            ? int.parse(double.parse(
                                    _serviceChargeEnabledController.text)
                                .toStringAsFixed(0))
                            : int.parse(double.parse(
                                    _serviceChargeDisabledController.text)
                                .toStringAsFixed(0)),
                        'spare_amount': _spareChargeEnabled == true
                            ? int.parse(
                                double.parse(_spareChargeEnabledController.text)
                                    .toStringAsFixed(0))
                            : int.parse(double.parse(
                                    _spareChargeDisabledController.text)
                                .toStringAsFixed(0)),
                        'product_gst': productGst,
                        'service_gst': serviceGst,
                        'discount': value.toInt(),
                        'discount_type': "1",
                        'discount_amount': value.toInt(),
                        'sub_total': int.parse(
                            double.parse(_subtotalController.text)
                                .toStringAsFixed(0)),
                        'total': totalValue.toInt(),
                      };

                      ApiService apiService = ApiService(dio.Dio());
                      final response = await apiService.discountDetail(
                          PreferenceUtils.getString(MyConstants.token),
                          discountData);
                      if (response.forgotPasswordEntity!.responseCode ==
                          MyConstants.response200) {
                        Navigator.of(context, rootNavigator: true).pop();
                        setToastMessage(
                            context, response.forgotPasswordEntity!.message!);
                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TicketList(1)));
                        });
                      } else {
                        Navigator.of(context, rootNavigator: true).pop();
                        setToastMessage(
                            context, MyConstants.discountSubmitError);
                      }
                    } else {
                      setToastMessage(context, MyConstants.internetConnection);
                    }
                  },
                  onCancel: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  cancelButtonColor: Color(int.parse("0xfff" "C5C5C5")),
                  confirmButtonColor: Color(int.parse("0xfff" "507a7d"))));
        }
      });
    } else if (_discountType == MyConstants.percentage) {
      setState(() {
        int? thresholdValue;
        double discountPercentage =
            double.parse(_subtotalController.text) * (value / 100);
        double totalValue =
            double.parse(_subtotalController.text) - discountPercentage;

        if (widget.status == MyConstants.submitComplete) {
          thresholdValue = thresholdPercentage;
        } else if (widget.status == MyConstants.complete) {
          thresholdValue = discountValue!.toInt();
        }

        if (int.parse(_discountController.text) < 100) {
          if (thresholdValue! >= value) {
            _totalChargeController.text = totalValue.toStringAsFixed(2);
          } else {
            ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                    title: MyConstants.appTittle,
                    text: MyConstants.discountPercentFirstText +
                        thresholdValue.toString() +
                        MyConstants.discountPercentSecondText,
                    showCancelBtn: true,
                    confirmButtonText: MyConstants.yesButton,
                    cancelButtonText: MyConstants.noButton,
                    onConfirm: () async {
                      if (await checkInternetConnection() == true) {
                        Navigator.of(context, rootNavigator: true).pop();

                        showAlertDialog(context);
                        Map<String, dynamic> discountData = {
                          'technician_code': PreferenceUtils.getString(
                              MyConstants.technicianCode),
                          'ticket_id': PreferenceUtils.getString(
                              MyConstants.ticketIdStore),
                          'service_charge': _serviceChargeEnabled == true
                              ? int.parse(double.parse(
                                      _serviceChargeEnabledController.text)
                                  .toStringAsFixed(0))
                              : int.parse(double.parse(
                                      _serviceChargeDisabledController.text)
                                  .toStringAsFixed(0)),
                          'spare_amount': _spareChargeEnabled == true
                              ? int.parse(double.parse(
                                      _spareChargeEnabledController.text)
                                  .toStringAsFixed(0))
                              : int.parse(double.parse(
                                      _spareChargeDisabledController.text)
                                  .toStringAsFixed(0)),
                          'product_gst': productGst,
                          'service_gst': serviceGst,
                          'discount': value.toInt(),
                          'discount_type': "2",
                          'discount_amount': discountPercentage.toInt(),
                          'sub_total': int.parse(
                              double.parse(_subtotalController.text)
                                  .toStringAsFixed(0)),
                          'total': totalValue.toInt(),
                        };

                        ApiService apiService = ApiService(dio.Dio());
                        final response = await apiService.discountDetail(
                            PreferenceUtils.getString(MyConstants.token),
                            discountData);
                        if (response.forgotPasswordEntity!.responseCode ==
                            MyConstants.response200) {
                          Navigator.of(context, rootNavigator: true).pop();
                          setToastMessage(
                              context, response.forgotPasswordEntity!.message!);
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const TicketList(1)));
                          });
                        } else {
                          Navigator.of(context, rootNavigator: true).pop();
                          setToastMessage(
                              context, MyConstants.discountSubmitError);
                        }
                      } else {
                        setToastMessage(
                            context, MyConstants.internetConnection);
                      }
                    },
                    onCancel: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    cancelButtonColor: Color(int.parse("0xfff" "C5C5C5")),
                    confirmButtonColor: Color(int.parse("0xfff" "507a7d"))));
          }
        } else {
          setToastMessage(context, MyConstants.percentageError);
        }
      });
    }
  }

  Future<void> captureImage(String? option) async {
    XFile? photo;

    Future.delayed(const Duration(seconds: 1), () {
      showImageDialog(context);
    });

    if (option == MyConstants.camera) {
      photo = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 50);
    } else if (option == MyConstants.gallery) {
      photo = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 50);
    }

    if (photo != null) {
      setState(() {
        image = File(photo!.path);
      });

      if (Platform.isAndroid) {
        final FileDirectory fileDirectory =
            FileDirectory(context, MyConstants.imageFolder);
        Directory? getDirectory;
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        await _requestPermission(Permission.storage);
        if (androidInfo.version.sdkInt >= int.parse(MyConstants.osVersion)) {
          capturedImage = File(photo.path);
        } else {
          fileDirectory.createFolder().then((value) async {
            getDirectory = value;
            if (!await getDirectory!.exists()) {
              await getDirectory!.create(recursive: true);
              capturedImage =
                  await image!.copy('${getDirectory!.path}/${timestamp()}.png');
            } else {
              capturedImage =
                  await image!.copy('${getDirectory!.path}/${timestamp()}.png');
            }
          });
        }
      } else if (Platform.isIOS) {
        PermissionStatus? status;
        if (option == MyConstants.camera) {
          status = await Permission.camera.request();
        } else if (option == MyConstants.gallery) {
          status = await Permission.storage.request();
        }
        Directory? directory = await getApplicationSupportDirectory();

        if (status == PermissionStatus.granted) {
          if (await _requestPermission(Permission.photos)) {
            showImageDialog(context);
            capturedImage =
                await image!.copy('${directory.path}/${timestamp()}.png');
          }
        } else if (status == PermissionStatus.denied) {
          captureImage(option);
        } else if (status == PermissionStatus.permanentlyDenied) {
          openAppSettings();
        }
      }

      setState(() {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context, rootNavigator: false).pop();
          _showTick = true;
          Navigator.of(context).pop();
          FocusScope.of(context).requestFocus(FocusNode());
        });
      });
    } else {
      Navigator.of(context).pop();
      if (option == MyConstants.camera) {
        setToastMessage(context, MyConstants.captureImageError);
      } else {
        setToastMessage(context, MyConstants.selectImageError);
      }
    }
  }

  Future<bool?> saveImage(String encoded) async {
    bool isSaved = false;
    String? directory = PreferenceUtils.getString(MyConstants.dirPath);
    Uint8List? bytes = base64.decode(encoded);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (Platform.isAndroid) {
      if (androidInfo.version.sdkInt >= int.parse(MyConstants.osVersion)) {
        String dir = (await getApplicationDocumentsDirectory()).path;
        File file = File("$dir/${DateTime.now().millisecondsSinceEpoch}.png");
        await file.writeAsBytes(bytes);
        signatureImage = file;
      } else {
        signatureImage =
            await File('$directory/${timestamp()}.png').writeAsBytes(bytes);
      }

      isSaved = true;
    } else if (Platform.isIOS) {
      Directory? directory = await getTemporaryDirectory();

      if (await _requestPermission(Permission.storage)) {
        signatureImage = await File('${directory.path}/${timestamp()}.png')
            .writeAsBytes(bytes);
      }

      isSaved = true;
    }

    return isSaved;
  }

  getDocument() async {
    setState(() {
      _selectedDocument = null;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'doc', 'xls', 'xlsx', 'docx'],
    );
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (result != null) {
      PlatformFile file = result.files.first;

      final FileDirectory fileDirectory =
          FileDirectory(context, MyConstants.documentFolder);
      Directory? getDirectory;
      File? convertedFile = File(file.path!);
      if (Platform.isAndroid) {
        await _requestPermission(Permission.storage);

        if (androidInfo.version.sdkInt >= int.parse(MyConstants.osVersion)) {
          _selectedDocument = File(file.path!);
        } else {
          fileDirectory.createFolder().then((value) async {
            getDirectory = value;
            if (!await getDirectory!.exists()) {
              await getDirectory!.create(recursive: true);
              _selectedDocument = await convertedFile.copy(
                  '${getDirectory!.path}/${timestamp()}.${file.extension}');
            } else {
              _selectedDocument = await convertedFile.copy(
                  '${getDirectory!.path}/${timestamp()}.${file.extension}');
            }
          });
        }
      } else if (Platform.isIOS) {
        Directory? directory = await getTemporaryDirectory();

        if (await _requestPermission(Permission.storage)) {
          _selectedDocument = await convertedFile
              .copy('${directory.path}/${timestamp()}.${file.extension}');
        }
      }

      setState(() {
        _showTick = true;
        Navigator.of(context).pop();
        FocusScope.of(context).requestFocus(FocusNode());
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  bool? validateSubmitComplete() {
    bool? validate = true;

    // if (_serviceChargeEnabledController.text.trim().isEmpty) {
    //   validate = false;
    //   setToastMessage(context, MyConstants.serviceChargeError);
    // } else if (_spareChargeEnabledController.text.trim().isEmpty) {
    //   validate = false;
    //   setToastMessage(context, MyConstants.spareChargeError);
    // } else if (_productValue.text.trim().isEmpty) {
    //   validate = false;
    //   setToastMessage(context, MyConstants.productGSTError);
    // } else if (_serviceValue.text.trim().isEmpty) {
    //   validate = false;
    //   setToastMessage(context, MyConstants.serviceGSTError);
    // } else if (_priceTypeController.text.trim().isEmpty) {
    //   validate = false;
    //   setToastMessage(context, MyConstants.priceTypeError);
    // } else
    if (_subtotalController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.subTotalError);
    } else if (_totalChargeController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.totalError);
    } else if (_resolutionSummaryController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.resolutionSummaryError);
    } else if (_isSigned == false) {
      validate = false;
      setToastMessage(context, MyConstants.signedError);
    }
    // else if (_descriptionController.text.trim().isEmpty) {
    //   validate = false;
    //   setToastMessage(context, MyConstants.descriptionError);
    // }
    else if (_showTick == false) {
      validate = false;
      setToastMessage(context, MyConstants.attachmentError);
    }

    return validate;
  }

  submitCompletePostAPi(String? option) async {
    final image = await _sign.currentState!.getData();
    var sign = await image.toByteData(format: ui.ImageByteFormat.png);
    final encoded = base64.encode(sign!.buffer.asUint8List());
    bool? isSaved = await saveImage(encoded);

    if (isSaved!) {
      if (signatureImage == null) {
        setToastMessage(context, MyConstants.signedError);
      } else {
        showAlertDialog(context);
        int serviceCharge, spareCharge;

        if (priceType == "3" && expiryStatus == 0) {
          serviceCharge = 0;
          spareCharge = 0;
        } else {
          serviceCharge = _serviceChargeEnabled == true
              ? int.parse(double.parse(_serviceChargeEnabledController.text)
                  .toStringAsFixed(0))
              : int.parse(double.parse(_serviceChargeDisabledController.text)
                  .toStringAsFixed(0));

          spareCharge = _spareChargeEnabled == true
              ? int.parse(double.parse(_spareChargeEnabledController.text)
                  .toStringAsFixed(0))
              : int.parse(double.parse(_spareChargeDisabledController.text)
                  .toStringAsFixed(0));
        }

        dio.FormData formData = dio.FormData.fromMap({
          "technician_code":
              PreferenceUtils.getString(MyConstants.technicianCode),
          "ticket_id": PreferenceUtils.getString(MyConstants.ticketIdStore),
          //"spare_amount": spareCharge,
          "service_charge": serviceCharge,
          "spare_amount": spareCharge,
          "product_gst": productGst,
          "service_gst": serviceGst,
          "frm": "0",
          "total_charge": int.parse(
              double.parse(_totalChargeController.text).toStringAsFixed(0)),
          "resolution_summary": _resolutionSummaryController.text,
          "drop_spare": MyConstants.empty,
          "drop_of_location": MyConstants.empty,
          "mode_of_payment": option,
          "cheque_no": option == MyConstants.cheque
              ? _chequeNumberController.text.trim()
              : MyConstants.chargeable,
          "cheque_date": option == MyConstants.cheque
              ? _contractStartDate
              : MyConstants.empty,
          "transaction_id": MyConstants.empty,
          "customer_sign": await dio.MultipartFile.fromFile(
              signatureImage!.path,
              filename: path.basename(signatureImage!.path)),
          "image": _selectedDocument == null
              ? await dio.MultipartFile.fromFile(capturedImage!.path,
                  filename: path.basename(capturedImage!.path))
              : await dio.MultipartFile.fromFile(_selectedDocument!.path,
                  filename: path.basename(_selectedDocument!.path))
        });

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.submitComplete(
            PreferenceUtils.getString(MyConstants.token), formData);
        if (response.addTransferEntity!.responseCode ==
            MyConstants.response200) {
          if (signatureImage != null) {
            if (await signatureImage!.exists()) await signatureImage!.delete();
          }
          if (capturedImage != null) {
            if (await capturedImage!.exists()) await capturedImage!.delete();
          }
          if (_selectedDocument != null) {
            if (await _selectedDocument!.exists()) {
              await _selectedDocument!.delete();
            }
          }

          setState(() {
            Navigator.of(context, rootNavigator: true).pop();
            PreferenceUtils.setString(
                MyConstants.token, response.addTransferEntity!.token!);
            setToastMessage(context, response.addTransferEntity!.message!);
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                barrierColor: Colors.black.withAlpha(150),
                builder: (context) {
                  return otpBottomSheet();
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
          setState(() {
            Navigator.of(context, rootNavigator: true).pop();
            setToastMessage(context, response.addTransferEntity!.message!);
          });
        }
      }
    }
  }

  Widget imageBottomSheet(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(children: [
        Container(
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
                      MyConstants.imageBottomSheetOption,
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
        SizedBox(
          height: 65,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: IconButton(
                              onPressed: () => captureImage(MyConstants.camera),
                              icon: const Icon(Icons.camera))),
                      const Text(MyConstants.camera, style: TextStyle(fontSize: 15))
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 50,
              ),
              Center(
                child: Column(
                  children: [
                    Expanded(
                        child: IconButton(
                            onPressed: () => captureImage(MyConstants.gallery),
                            icon: const Icon(Icons.photo))),
                    const Text(MyConstants.gallery, style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(
                width: 50,
              ),
              Center(
                child: Column(
                  children: [
                    Expanded(
                        child: IconButton(
                            onPressed: () => getDocument(),
                            icon: Image.asset(
                              'assets/images/file_storage.png',
                              width: 25,
                              height: 25,
                            ))),
                    const Text(MyConstants.document, style: TextStyle(fontSize: 15)),
                  ],
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget otpBottomSheet() {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
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
                        MyConstants.otp,
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
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: MyConstants.otpHint,
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
                onPressed: () => submitOtpPostApi(context),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                child: const Text(MyConstants.submitOtpButton,
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  submitOtpPostApi(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      if (_otpController.text.isNotEmpty) {
        showAlertDialog(context);

        Map<String, String> otpData = {
          'technician_code':
              PreferenceUtils.getString(MyConstants.technicianCode),
          'ticket_id': widget.ticketId!,
          'otp': _otpController.text
        };

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.verifyOtp(
            PreferenceUtils.getString(MyConstants.token), otpData);

        if (response.addTransferEntity!.responseCode ==
            MyConstants.response200) {
          final database = await $FloorAppDatabase
              .databaseBuilder('floor_database.db')
              .build();
          final selectedOnHandSpareDao = database.selectedOnHandSpareDao;
          await selectedOnHandSpareDao.deleteSelectedSpareByTicketId(
              true, widget.ticketId!);

          setState(() {
            PreferenceUtils.setString(
                MyConstants.token, response.addTransferEntity!.token!);
            setToastMessage(context, response.addTransferEntity!.message!);

            Navigator.of(context, rootNavigator: true).pop();

            ArtSweetAlert.show(
                context: context,
                artDialogArgs: ArtDialogArgs(
                    title: MyConstants.appTittle,
                    text: MyConstants.optAlert,
                    showCancelBtn: true,
                    confirmButtonText: MyConstants.yesButton,
                    cancelButtonText: MyConstants.noButton,
                    onConfirm: () async {
                      Navigator.of(context, rootNavigator: true).pop();
                      final database = await $FloorAppDatabase
                          .databaseBuilder('floor_database.db')
                          .build();
                      final spareRequestDataDao = database.spareRequestDataDao;
                      spareRequestDataDao.deleteSpareRequestDataTable();

                      PreferenceUtils.setString(
                          MyConstants.ticketIdStore, widget.ticketId!);

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FieldReturnMaterial(
                                    ticketUpdate: MyConstants.complete,
                                  )));
                    },
                    onCancel: () async {
                      if (await checkInternetConnection() == true) {
                        Navigator.of(context, rootNavigator: true).pop();

                        showAlertDialog(context);
                        Map<String, dynamic> pendingFrmData = {
                          'technician_code': PreferenceUtils.getString(
                              MyConstants.technicianCode),
                          'ticket_id': widget.ticketId,
                          'frm_status': 2,
                          'frm': 0,
                        };

                        ApiService apiService = ApiService(dio.Dio());
                        final response = await apiService.pendingFrm(
                            PreferenceUtils.getString(MyConstants.token),
                            pendingFrmData);
                        if (response.addTransferEntity!.responseCode ==
                            MyConstants.response200) {
                          Navigator.of(context, rootNavigator: true).pop();
                          setState(() {
                            PreferenceUtils.setString(MyConstants.token,
                                response.addTransferEntity!.token!);
                            setToastMessage(
                                context, response.addTransferEntity!.message!);
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DashBoard()));
                            });
                          });
                        } else if (response.addTransferEntity!.responseCode ==
                            MyConstants.response400) {
                          Navigator.of(context, rootNavigator: true).pop();
                          setState(() {
                            PreferenceUtils.setString(MyConstants.token,
                                response.addTransferEntity!.token!);
                          });
                        } else if (response.addTransferEntity!.responseCode ==
                            MyConstants.response500) {
                          Navigator.of(context, rootNavigator: true).pop();
                          setState(() {
                            setToastMessage(
                                context, response.addTransferEntity!.message!);
                          });
                        }
                      } else {
                        Navigator.of(context, rootNavigator: true).pop();
                        setToastMessage(
                            context, MyConstants.internetConnection);
                      }
                    },
                    cancelButtonColor: Color(int.parse("0xfff" "C5C5C5")),
                    confirmButtonColor: Color(int.parse("0xfff" "507a7d"))));
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
          setState(() {
            Navigator.of(context, rootNavigator: true).pop();
            PreferenceUtils.setString(
                MyConstants.token, response.addTransferEntity!.token!);
            setToastMessage(context, response.addTransferEntity!.message!);
          });
        }
      } else {
        setToastMessage(context, MyConstants.otpError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  _chequeAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, chequeState) {
            chequeState(() {
              String? total = double.parse(_totalChargeController.text.trim())
                  .toStringAsFixed(2);
              _payController.value = const TextEditingValue(text: 'Kaspon');
              _totalRupeeController.value = TextEditingValue(text: total);

              String? numberToWords;

              if (total.split(".")[0].trim() == "0") {
                numberToWords = "zero rupee";
              } else {
                numberToWords = "${NumberToWord().convert(
                        'en-in', int.parse(total.split(".")[0].trim()))}rupee";
              }

              String paisa = total.split(".")[1].trim();
              String? joinPaisa;
              if (paisa == "00") {
                joinPaisa = "zero paisa";
              } else if (paisa.startsWith('0')) {
                joinPaisa = "${NumberToWord()
                        .convert('en-in', int.parse(paisa.substring(1)))}paisa";
              } else {
                joinPaisa =
                    "${NumberToWord().convert('en-in', int.parse(paisa))}paisa";
              }
              _rupeeController.value =
                  TextEditingValue(text: "$numberToWords $joinPaisa");
            });

            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: const Text(MyConstants.cheque),
              content: Padding(
                padding: const EdgeInsets.all(10.0),
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
                                        child:
                                            const Text(MyConstants.chequeInformation,
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
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        child: TextFormField(
                                          autofocus: false,
                                          enabled: false,
                                          keyboardType: TextInputType.text,
                                          controller: _totalRupeeController,
                                          decoration: const InputDecoration(
                                            labelText: MyConstants.rupee,
                                            contentPadding: EdgeInsets.fromLTRB(
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
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                submitCompletePostAPi(MyConstants.cheque);
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                              child: const Text(MyConstants.submitButton,
                                  style: TextStyle(color: Colors.white)),
                            ),
                          )),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Expanded(
                          flex: 0,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                              child: const Text(MyConstants.cancelButton,
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            );
          });
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

  _travelPlanAlert(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      if (validateSubmitComplete()!) {
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
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  if (validateSubmitComplete()!) {
                                    submitCompletePostAPi(MyConstants.cash);
                                  }
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
                                            if (validateSubmitComplete()!) {
                                              submitCompletePostAPi(
                                                  MyConstants.cash);
                                            }
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
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  _chequeAlert(context);
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
                                            _chequeAlert(context);
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
                                          color: Color(
                                              int.parse("0xfff" "507a7d"))),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ));
              });
            });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
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
                    //Navigator.of(context, rootNavigator: true).pop();
                    if (_othersController.text.isEmpty) {
                      setToastMessage(context, MyConstants.reasonError);
                    } else {
                      if (validateSubmitComplete()!) {
                        submitCompletePostAPi(MyConstants.others);
                      }
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
}
