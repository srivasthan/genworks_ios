import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shimmer/shimmer.dart';

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/db/installation_report_data.dart';
import '../network/db/selected_onhand_spare.dart';
import '../network/db/ticket_for_the_day_dao.dart';
import '../network/model/installation_complete.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'escalate.dart';
import 'spareinventory/on_hand_spare.dart';
import 'spareinventory/spare_cart.dart';
import 'start_ticket.dart';
import 'submit_complete.dart';
import 'work_in_progress.dart';

class InstallationReportComplete extends StatefulWidget {
  final String? ticketStatusData;

  InstallationReportComplete({Key? key, required this.ticketStatusData})
      : super(key: key);

  @override
  _InstallationReportCompleteState createState() =>
      _InstallationReportCompleteState();
}

class _InstallationReportCompleteState
    extends State<InstallationReportComplete> {
  final formKey = GlobalKey<FormState>();
  bool _questionOne = false,
      _questionTwo = false,
      _nextButtonVisible = true,
      _noDataAvailable = false,
      _isLoading = true,
      _submitButtonVisible = false;
  final TextEditingController _workTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _remarkControllerCheck = TextEditingController();
  final TextEditingController _remarkControllerBox = TextEditingController();
  bool? _yesCheckBox = false, _noCheckBox = false;
  String? tracker = "first_time", pro_id;
  final _installationCompleteList = <InstallationCompleteModel>[];
  int j = 0;

  Future<void> getQuestions() async {
    if (await checkInternetConnection() == true) {
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final ticketForTheDayDao = database.ticketForTheDayDao;
      var ticketForTheDayData =
          await ticketForTheDayDao.findTicketForTheDayByTicketId(
              PreferenceUtils.getString(MyConstants.ticketIdStore));
      final installationReportDataDao = database.installationReportDataDao;
      var ticketForDayData =
          await ticketForTheDayDao.findTicketForTheDayByTicketId(
              PreferenceUtils.getString(MyConstants.ticketIdStore));

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.serviceCategory(
          PreferenceUtils.getString(MyConstants.token),
          PreferenceUtils.getString(MyConstants.technicianCode),
          ticketForTheDayData[0].serviceId.toString());

      if (response.installationCompleteEntity!.responseCode ==
          MyConstants.response200) {
        installationReportDataDao.deleteTicketForTheDayTable();
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.installationCompleteEntity!.token!);
          for (int i = 0;
              i < response.installationCompleteEntity!.data!.length;
              i++) {
            _installationCompleteList.add(InstallationCompleteModel(
                serCheckListId: response
                    .installationCompleteEntity!.data![i]!.serCheckListId,
                serviceGroup:
                    response.installationCompleteEntity!.data![i]!.serviceGroup,
                description:
                    response.installationCompleteEntity!.data![i]!.description,
                quationType: response
                    .installationCompleteEntity!.data![i]!.quationType));

            InstallationReportDataTable installationReportDataTable =
                InstallationReportDataTable(
                    i + 1,
                    response.installationCompleteEntity!.data![i]!
                            .serCheckListId ??
                        0,
                    response.installationCompleteEntity!.data![i]!
                            .serviceGroup ??
                        "",
                    response.installationCompleteEntity!.data![i]!
                            .description ??
                        "",
                    response.installationCompleteEntity!.data![i]!
                            .quationType ??
                        0,
                    ticketForTheDayData[0].serviceId.toString(),
                    "",
                    "",
                    false,
                    false);
            installationReportDataDao
                .insertInstallationReportData(installationReportDataTable);
          }

          oninstallationreport(false, false);
        });
      } else if (response.installationCompleteEntity!.responseCode ==
          MyConstants.response400) {
        setState(() {
          PreferenceUtils.setString(
              MyConstants.token, response.installationCompleteEntity!.token!);
          _isLoading = !_isLoading;
          _noDataAvailable = true;
          if (response.installationCompleteEntity!.message != null)
            setToastMessage(
                context, response.installationCompleteEntity!.message!);
          else
            setToastMessage(context, MyConstants.noDataAvailable);
          commonIntentMethod(ticketForTheDayDao, ticketForDayData[0].ticketId);
        });
      } else if (response.installationCompleteEntity!.responseCode ==
          MyConstants.response500) {
        setState(() {
          _isLoading = !_isLoading;
          _noDataAvailable = true;
          if (response.installationCompleteEntity!.message != null)
            setToastMessage(
                context, response.installationCompleteEntity!.message!);
          else
            setToastMessage(context, MyConstants.tokenError);
          commonIntentMethod(ticketForTheDayDao, ticketForDayData[0].ticketId);
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
    getQuestions();
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => StartTicket(
                ticketId: PreferenceUtils.getString(MyConstants.ticketIdStore),
                status: MyConstants.ticketStarted)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //  pushPage(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => StartTicket(
                        ticketId: PreferenceUtils.getString(
                            MyConstants.ticketIdStore),
                        status: MyConstants.ticketStarted))),
          ),
          title: const Text(MyConstants.appName),
          backgroundColor: Color(int.parse("0xfff" "507a7d")),
        ),
        body: Form(
          key: formKey,
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                  child: _isLoading == true
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[400]!,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(children: [
                                TextFormField(
                                  controller: _workTypeController,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.workType,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 10.0),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.description,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 10.0)
                              ]),
                              const SizedBox(height: 10.0),
                              Column(children: [
                                TextFormField(
                                  controller: _answerController,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.answer,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 10.0),
                                TextFormField(
                                  controller: _remarkControllerBox,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.remarks,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                )
                              ]),
                              Column(children: [
                                Row(
                                  children: [
                                    Transform.scale(
                                      scale: 1.0,
                                      child: Checkbox(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: _yesCheckBox,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _yesCheckBox = value!;
                                              _noCheckBox = false;
                                              changeDbValue(true, false);
                                            });
                                          },
                                          activeColor:
                                              Theme.of(context).primaryColor),
                                    ),
                                    const Text(
                                      MyConstants.yesButton,
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Transform.scale(
                                      scale: 1.0,
                                      child: Checkbox(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: _noCheckBox,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _noCheckBox = value!;
                                              _yesCheckBox = false;
                                              changeDbValue(false, true);
                                            });
                                          },
                                          activeColor:
                                              Theme.of(context).primaryColor),
                                    ),
                                    const Text(
                                      MyConstants.noButton,
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                TextFormField(
                                  controller: _remarkControllerCheck,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants.remarks,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                )
                              ]),
                              const SizedBox(height: 15.0),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    10.0)), backgroundColor: Color(
                                            int.parse("0xfff" "5C7E7F"))),
                                    child: const Text(MyConstants.nextButton,
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white)),
                                  )),
                            ],
                          ))
                      : _noDataAvailable == false
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(children: [
                                  TextFormField(
                                    controller: _workTypeController,
                                    decoration: const InputDecoration(
                                        labelText: MyConstants.workType,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 0),
                                        border: OutlineInputBorder()),
                                  ),
                                  const SizedBox(height: 10.0),
                                  TextFormField(
                                    controller: _descriptionController,
                                    decoration: const InputDecoration(
                                        labelText: MyConstants.description,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 0),
                                        border: OutlineInputBorder()),
                                  ),
                                  const SizedBox(height: 10.0)
                                ]),
                                const SizedBox(height: 10.0),
                                Visibility(
                                  visible: _questionTwo,
                                  child: Column(children: [
                                    TextFormField(
                                      controller: _answerController,
                                      decoration: const InputDecoration(
                                          labelText: MyConstants.answer,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              10, 10, 10, 0),
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 10.0),
                                    TextFormField(
                                      controller: _remarkControllerBox,
                                      decoration: const InputDecoration(
                                          labelText: MyConstants.remarks,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              10, 10, 10, 0),
                                          border: OutlineInputBorder()),
                                    )
                                  ]),
                                ),
                                Visibility(
                                    visible: _questionOne,
                                    child: Column(children: [
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.0,
                                            child: Checkbox(
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: _yesCheckBox,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    _yesCheckBox = value!;
                                                    _noCheckBox = false;
                                                    changeDbValue(true, false);
                                                  });
                                                },
                                                activeColor: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          const Text(
                                            MyConstants.yesButton,
                                            style: TextStyle(fontSize: 18),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.0,
                                            child: Checkbox(
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: _noCheckBox,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    _noCheckBox = value!;
                                                    _yesCheckBox = false;
                                                    changeDbValue(false, true);
                                                  });
                                                },
                                                activeColor: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          const Text(
                                            MyConstants.noButton,
                                            style: TextStyle(fontSize: 18),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                      TextFormField(
                                        controller: _remarkControllerCheck,
                                        decoration: const InputDecoration(
                                            labelText: MyConstants.remarks,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 10, 10, 0),
                                            border: OutlineInputBorder()),
                                      )
                                    ])),
                                const SizedBox(height: 15.0),
                                Visibility(
                                  visible: _nextButtonVisible,
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_installationCompleteList[j]
                                                    .quationType ==
                                                MyConstants.updateQuantity) {
                                              if (_yesCheckBox == true ||
                                                  _noCheckBox == true) {
                                                onNextButtonClick(false, false);
                                              } else
                                                setToastMessage(context,
                                                    MyConstants.checkBoxError);
                                            } else if (_installationCompleteList[
                                                        j]
                                                    .quationType ==
                                                MyConstants.amcTicketType) {
                                              if (_answerController
                                                  .text.isNotEmpty) {
                                                onNextButtonClick(false, false);
                                              } else
                                                setToastMessage(context,
                                                    MyConstants.answerError);
                                            }
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)), backgroundColor: Color(
                                                int.parse("0xfff" "5C7E7F"))),
                                        child: const Text(MyConstants.nextButton,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white)),
                                      )),
                                ),
                                Visibility(
                                  visible: _submitButtonVisible,
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_installationCompleteList[j]
                                                    .quationType ==
                                                MyConstants.updateQuantity) {
                                              if (_yesCheckBox == true ||
                                                  _noCheckBox == true) {
                                                submitButtonClick();
                                              } else
                                                setToastMessage(context,
                                                    MyConstants.checkBoxError);
                                            } else if (_installationCompleteList[
                                                        j]
                                                    .quationType ==
                                                MyConstants.amcTicketType) {
                                              if (_answerController
                                                  .text.isNotEmpty) {
                                                submitButtonClick();
                                              } else
                                                setToastMessage(context,
                                                    MyConstants.answerError);
                                            }
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)), backgroundColor: Color(
                                                int.parse("0xfff" "5C7E7F"))),
                                        child: const Text(MyConstants.submitButton,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white)),
                                      )),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: const Center(
                                  child: Text(MyConstants.noDataAvailable))))),
        ),
      ),
    );
  }

  changeDbValue(bool yesValue, bool noValue) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final installationReportDataDao = database.installationReportDataDao;
    var installationReportData =
        await installationReportDataDao.findAllInstallationReportData();

    installationReportDataDao.updateDataCheckBox(
        yesValue, noValue, installationReportData[j].ser_check_list_id);
  }

  Future<void> oninstallationreport(bool isCheckedYes, bool isCheckedNo) async {
    setState(() {
      _workTypeController.text = _installationCompleteList[j].serviceGroup!;
      _descriptionController.text = _installationCompleteList[j].description!;
      if (_installationCompleteList[j].quationType ==
          MyConstants.updateQuantity) {
        _questionOne = true;
        _questionTwo = false;
        _yesCheckBox = isCheckedYes;
        _noCheckBox = isCheckedNo;
      } else if (_installationCompleteList[j].quationType ==
          MyConstants.amcTicketType) {
        _questionTwo = true;
        _questionOne = false;
      }

      if (j == _installationCompleteList.length - 1) {
        _nextButtonVisible = false;
        _submitButtonVisible = true;
      } else {
        _submitButtonVisible = false;
        _nextButtonVisible = true;
      }

      if (tracker == "first_time") {
        tracker = "second_time";
        _isLoading = !_isLoading;
      }

      _answerController.value = TextEditingValue.empty;
      _remarkControllerCheck.value = TextEditingValue.empty;
      _remarkControllerBox.value = TextEditingValue.empty;
    });
  }

  Future<void> onNextButtonClick(bool yesValue, bool noValue) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final installationReportDataDao = database.installationReportDataDao;
    var installationReportData =
        await installationReportDataDao.findAllInstallationReportData();

    if (installationReportData[j].qsatype1 ||
        installationReportData[j].qsatype2) {
      String? answerValue;
      if (installationReportData[j].qsatype1) {
        answerValue = MyConstants.yesButton;
      } else {
        answerValue = MyConstants.noButton;
      }
      installationReportDataDao.updateData(
          answerValue,
          _remarkControllerCheck.text,
          installationReportData[j].ser_check_list_id);
    } else {
      installationReportDataDao.updateData(
          _answerController.text,
          _remarkControllerBox.text,
          installationReportData[j].ser_check_list_id);
    }

    j++;

    oninstallationreport(yesValue, noValue);
  }

  submitButtonClick() async {
    FocusScope.of(context).requestFocus(FocusNode());

    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final installationReportDataDao = database.installationReportDataDao;
    var installationReportData =
        await installationReportDataDao.findAllInstallationReportData();

    String? answerValue;
    if (installationReportData[j].qsatype1 ||
        installationReportData[j].qsatype2) {
      if (installationReportData[j].qsatype1) {
        answerValue = MyConstants.yesButton;
      } else {
        answerValue = MyConstants.noButton;
      }

      installationReportDataDao.updateData(
          answerValue,
          _remarkControllerCheck.text,
          installationReportData[j].ser_check_list_id);
    } else {
      installationReportDataDao.updateData(
          _answerController.text,
          _remarkControllerBox.text,
          installationReportData[j].ser_check_list_id);
    }

    onSubmitCompleteCreateServiceApi();
  }

  onSubmitCompleteCreateServiceApi() async {
    if (await checkInternetConnection() == true) {
      showAlertDialog(context);
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final installationReportDataDao = database.installationReportDataDao;
      final ticketForTheDayDao = database.ticketForTheDayDao;
      var installationReportData =
          await installationReportDataDao.findAllInstallationReportData();
      var ticketForDayData =
          await ticketForTheDayDao.findTicketForTheDayByTicketId(
              PreferenceUtils.getString(MyConstants.ticketIdStore));

      final combinedData = <Map<String, dynamic>>[];

      for (int i = 0; i < installationReportData.length; i++) {
        pro_id = installationReportData[i].product_id;
        String remarks = installationReportData[i].remarks;
        String answer = installationReportData[i].answer_value;
        String description = installationReportData[i].description;

        Map<String, dynamic> installationCompleteData = {
          'question': description,
          'answer_value': answer,
          'remarks': remarks
        };
        combinedData.add(installationCompleteData);
      }

      Map<String, dynamic> submitCompleteData = {
        'technician_code': ticketForDayData[0].technicianCode,
        'service_id': ticketForDayData[0].serviceId,
        'ticket_id': ticketForDayData[0].ticketId,
        'product_id': pro_id,
        'service_activites': combinedData
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.serviceActivity(
          PreferenceUtils.getString(MyConstants.token), submitCompleteData);

      if (response.addTransferEntity!.responseCode == MyConstants.response200) {
        setState(() {
          Navigator.of(context, rootNavigator: true).pop();
          PreferenceUtils.setString(
              MyConstants.token, response.addTransferEntity!.token!);
          setToastMessage(context, response.addTransferEntity!.message!);
          installationReportDataDao.deleteTicketForTheDayTable();
          commonIntentMethod(ticketForTheDayDao, ticketForDayData[0].ticketId);
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
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void commonIntentMethod(
      TicketForTheDayDao ticketForTheDayDao, String ticketId) async {

    if (widget.ticketStatusData == MyConstants.spareRequest) {
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
      consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SpareCart(MyConstants.spareRequest, ticketId)));
    } else if (widget.ticketStatusData == MyConstants.workInProgressAlert) {
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
      consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();

      PreferenceUtils.setString(
          MyConstants.customerAcceptance, MyConstants.empty);
      PreferenceUtils.setBool(MyConstants.customerAcceptanceBool, false);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WorkInProgress(
                  MyConstants.workInProgressAlert, ticketId, true)));
    } else if (widget.ticketStatusData == MyConstants.escalate) {
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
      consumedSpareRequestDataDao.deleteConsumedSpareRequestDataTable();

      PreferenceUtils.setString(
          MyConstants.customerAcceptance, MyConstants.empty);
      PreferenceUtils.setBool(MyConstants.customerAcceptanceBool, false);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Escalate(MyConstants.escalate, ticketId)));
    } else {

      final database = await $FloorAppDatabase
          .databaseBuilder('floor_database.db')
          .build();
      final selectedOnHandSpareDao = database.selectedOnHandSpareDao;
      List<SelectedOnHandSpareDataTable> list = await selectedOnHandSpareDao.getSelectedSpareByTicketId(true, ticketId);

      if(list.isNotEmpty){
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                title: MyConstants.appTittle,
                text: MyConstants.alreadySpareSelected,
                confirmButtonText: MyConstants.okButton,
                onConfirm: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubmitComplete(
                            ticketId: ticketId,
                            status: MyConstants.submitComplete,
                          )));
                },
                confirmButtonColor: Color(int.parse("0xfff" "507a7d"))));
      } else {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                title: MyConstants.appTittle,
                text: MyConstants.installationSpareAlert,
                showCancelBtn: true,
                confirmButtonText: MyConstants.yesButton,
                cancelButtonText: MyConstants.noButton,
                onConfirm: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          OnHandSpare(MyConstants.selectedOnHand, ticketId)));
                },
                onCancel: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubmitComplete(
                            ticketId: ticketId,
                            status: MyConstants.submitComplete,
                          )));
                },
                cancelButtonColor: Color(int.parse("0xfff" "C5C5C5")),
                confirmButtonColor: Color(int.parse("0xfff" "507a7d"))));
      }
    }
  }
}
