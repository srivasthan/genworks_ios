import 'dart:async';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../main.dart';
import '../network/db/app_database.dart';
import '../network/db/smart_schedule_data.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/technician_punch.dart';
import '../utility/validator.dart';
import 'dashboard.dart';

class SmartScheduling extends StatefulWidget {
  const SmartScheduling({Key? key}) : super(key: key);

  @override
  _SmartSchedulingState createState() => _SmartSchedulingState();
}

class _SmartSchedulingState extends State<SmartScheduling> {
  bool? _showCalendarIcon = false, _showNewReminder = false, _showList = false;
  final TextEditingController _selectedDateController = TextEditingController();
  final TextEditingController _selectedTimeController = TextEditingController();
  final TextEditingController _tittleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? selectedTime = TimeOfDay.now();
  String? _hour, _minute, _buttonText = "Add Event", _scheduledTime;
  var _smartScheduleList = <SmartScheduleDataTable>[];
  int? _day, _month, _year, _notificationId;
  DateTime? _saveDateTime;

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashBoard()));
  }

  getSmartSchedule() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    var smartScheduleDataDao = database.smartScheduleDataDao;
    var smartScheduleList =
        await smartScheduleDataDao.findSmartScheduleDataByDate(
            DateFormat("dd-MM-yyyy").format(_selectedDate!));

    setState(() {
      _buttonText = MyConstants.addEventButton;
      _year = _selectedDate!.year;
      _month = _selectedDate!.month;
      _day = _selectedDate!.day;
      PreferenceUtils.setString(MyConstants.technicianStatus,
          MyConstants.free);
      _selectedDateController.value = TextEditingValue(
          text: DateFormat("dd-MM-yyyy").format(_selectedDate!));
    });

    _smartScheduleList.clear();

    for (var data in smartScheduleList) {
      String? scheduledTime;
      DateTime? checkDateTime;
      if (data.smartschedule_time!.endsWith("AM")) {
        scheduledTime = data.smartschedule_time!.replaceAll(" AM", '');
        checkDateTime = DateTime(
            _year!,
            _month!,
            _day!,
            int.parse(scheduledTime.split(":")[0].trim()),
            int.parse(scheduledTime.split(":")[1].trim()));
      } else if (data.smartschedule_time!.endsWith("PM")) {
        scheduledTime = data.smartschedule_time!.replaceAll(" PM", '');
        checkDateTime = DateTime(
            _year!,
            _month!,
            _day!,
            int.parse(scheduledTime.split(":")[0].trim()) + 12,
            int.parse(scheduledTime.split(":")[1].trim()));
      }

      if (checkDateTime!.millisecondsSinceEpoch >=
          DateTime.now().millisecondsSinceEpoch) {
        _smartScheduleList.add(data);
      } else {
        await smartScheduleDataDao
            .deleteSmartScheduleData(data.smartschedule_id!);

        await flutterLocalNotificationsPlugin!.cancel(data.smartschedule_id!);
      }
    }

    _smartScheduleList = _smartScheduleList.toSet().toList();

    _smartScheduleList.sort((a,b) => a.smartschedule_time!.compareTo(b.smartschedule_time!));

    if (_smartScheduleList.isNotEmpty) {
      setState(() {
        _showList = true;
        _showNewReminder = false;
        _showCalendarIcon = false;
      });
    } else {
      setState(() {
        _showCalendarIcon = true;
        _showList = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSmartSchedule();
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;

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
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DashBoard())),
              ),
              title: const Text(MyConstants.smartScheduling),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _showNewReminder = true;
                        _showCalendarIcon = false;
                        _showList = false;
                        _selectedTimeController.value = TextEditingValue.empty;
                        _tittleController.value = TextEditingValue.empty;
                        _descriptionController.value = TextEditingValue.empty;
                      });
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 35,
                    ))
              ],
              backgroundColor: Color(int.parse("0xfff" "507a7d")),
            ),
            body: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 0,
                      child: Container(
                          color: Colors.white,
                          height: MediaQuery.of(context).size.height / 4,
                          child: TableCalendar(
                            calendarFormat: CalendarFormat.week,
                            calendarStyle: const CalendarStyle(
                                todayTextStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22.0,
                                    color: Colors.white)),
                            headerStyle: HeaderStyle(
                              titleCentered: true,
                              formatButtonDecoration: BoxDecoration(
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(22.0),
                              ),
                              formatButtonTextStyle:
                                  const TextStyle(color: Colors.white),
                              formatButtonShowsNext: false,
                            ),
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            onDaySelected: (date, events) async {
                              //change date in calendar
                              setState(() {
                                _selectedDate = date;
                                _day = date.day;
                                _month = date.month;
                                _year = date.year;

                                _selectedDateController.value =
                                    TextEditingValue(
                                        text: DateFormat("dd-MM-yyyy")
                                            .format(_selectedDate!));
                              });

                              final database = await $FloorAppDatabase
                                  .databaseBuilder('floor_database.db')
                                  .build();
                              var smartScheduleDataDao =
                                  database.smartScheduleDataDao;
                              var smartScheduleList = await smartScheduleDataDao
                                  .findSmartScheduleDataByDate(
                                      DateFormat("dd-MM-yyyy")
                                          .format(_selectedDate!));

                              smartScheduleList =
                                  smartScheduleList.toSet().toList();

                              //checking if any record available for selected date
                              if (smartScheduleList.isNotEmpty) {
                                setState(() {
                                  _buttonText =
                                      MyConstants.addEventButton;
                                  _year = _selectedDate!.year;
                                  _month = _selectedDate!.month;
                                  _day = _selectedDate!.day;
                                  _selectedDateController.value =
                                      TextEditingValue(
                                          text: DateFormat("dd-MM-yyyy")
                                              .format(_selectedDate!));
                                });

                                _smartScheduleList.clear();

                                for (var data in smartScheduleList) {
                                  String? scheduledTime;
                                  DateTime? checkDateTime;
                                  if (data.smartschedule_time!.endsWith("AM")) {
                                    scheduledTime = data.smartschedule_time!
                                        .replaceAll(" AM", '');
                                    checkDateTime = DateTime(
                                        _year!,
                                        _month!,
                                        _day!,
                                        int.parse(
                                            scheduledTime.split(":")[0].trim()),
                                        int.parse(scheduledTime
                                            .split(":")[1]
                                            .trim()));
                                  } else if (data.smartschedule_time!
                                      .endsWith("PM")) {
                                    scheduledTime = data.smartschedule_time!
                                        .replaceAll(" PM", '');
                                    checkDateTime = DateTime(
                                        _year!,
                                        _month!,
                                        _day!,
                                        int.parse(scheduledTime
                                                .split(":")[0]
                                                .trim()) +
                                            12,
                                        int.parse(scheduledTime
                                            .split(":")[1]
                                            .trim()));
                                  }

                                  if (checkDateTime!.millisecondsSinceEpoch >=
                                      DateTime.now().millisecondsSinceEpoch) {
                                    _smartScheduleList.add(data);
                                  } else {
                                    await smartScheduleDataDao
                                        .deleteSmartScheduleData(
                                            data.smartschedule_id!);

                                    await flutterLocalNotificationsPlugin!
                                        .cancel(data.smartschedule_id!);
                                  }
                                }

                                _smartScheduleList =
                                    _smartScheduleList.toSet().toList();

                                if (_smartScheduleList.isNotEmpty) {
                                  setState(() {
                                    _showList = true;
                                    _showNewReminder = false;
                                    _showCalendarIcon = false;
                                  });
                                } else {
                                  setState(() {
                                    _showCalendarIcon = true;
                                    _showList = false;
                                  });
                                }
                              } else {
                                ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                        title:
                                            MyConstants.appTittle,
                                        text: MyConstants.noRecord,
                                        showCancelBtn: true,
                                        confirmButtonText:
                                            MyConstants.yesButton,
                                        cancelButtonText:
                                            MyConstants.noButton,
                                        onConfirm: () {
                                          setState(() {
                                            _showNewReminder = true;
                                            _showCalendarIcon = false;
                                            _showList = false;
                                            _selectedTimeController.value =
                                                const TextEditingValue(
                                                    text:
                                                        MyConstants
                                                            .empty);
                                            _tittleController.value =
                                                const TextEditingValue(
                                                    text:
                                                        MyConstants
                                                            .empty);
                                            _descriptionController.value =
                                                const TextEditingValue(
                                                    text:
                                                        MyConstants
                                                            .empty);
                                          });
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                        },
                                        onCancel: () => Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(),
                                        cancelButtonColor: Color(
                                            int.parse("0xfff" "C5C5C5")),
                                        confirmButtonColor: Color(
                                            int.parse("0xfff" "507a7d"))));
                              }
                            },
                            selectedDayPredicate: (day) =>
                                isSameDay(day, _selectedDate),
                            calendarBuilders: CalendarBuilders(
                              selectedBuilder: (context, date, events) =>
                                  Container(
                                      margin: const EdgeInsets.all(5.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: Text(
                                        date.day.toString(),
                                        style: const TextStyle(color: Colors.white),
                                      )),
                              todayBuilder: (context, date, events) =>
                                  Container(
                                      margin: const EdgeInsets.all(5.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: Text(
                                        date.day.toString(),
                                        style: const TextStyle(color: Colors.white),
                                      )),
                            ),
                            firstDay: DateTime.now(),
                            focusedDay: _selectedDate!,
                            lastDay: DateTime.now().add(const Duration(days: 365)),
                          ))),
                  Visibility(
                      visible: _showCalendarIcon!,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Expanded(
                                  flex: 0,
                                  child: Image.asset(
                                      "assets/images/calendar.png")),
                              const SizedBox(
                                height: 10.0,
                              ),
                              const Expanded(
                                  flex: 0,
                                  child:
                                      Text(MyConstants.noPlanning)),
                            ],
                          ),
                        ),
                      )),
                  Visibility(
                      visible: _showNewReminder!,
                      child: Expanded(
                        flex: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(children: [
                            Expanded(
                              flex: 0,
                              child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Color(
                                          int.parse("0xfff" "5C7E7F")),
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(10.0),
                                          topLeft: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight:
                                              Radius.circular(10.0))),
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          const Text(
                                            MyConstants.reminder,
                                            style: TextStyle(
                                                color: Colors.white),
                                          ),
                                          IconButton(
                                              onPressed: () async {
                                                setState(() {
                                                  _showNewReminder = false;
                                                  if (_smartScheduleList.isNotEmpty) {
                                                    _showList = true;
                                                    _showCalendarIcon = false;
                                                  } else {
                                                    _showList = false;
                                                    _showCalendarIcon = true;
                                                  }
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.clear,
                                                color: Colors.white,
                                              ))
                                        ],
                                      ))),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Expanded(
                              flex: 0,
                              child: TextFormField(
                                enabled: false,
                                showCursor: false,
                                controller: _selectedDateController,
                                decoration: const InputDecoration(
                                    labelText:
                                        MyConstants.selectedDate,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Expanded(
                              flex: 0,
                              child: GestureDetector(
                                onTap: () => _selectTime(context),
                                child: TextFormField(
                                  showCursor: false,
                                  enabled: false,
                                  controller: _selectedTimeController,
                                  decoration: const InputDecoration(
                                      labelText: MyConstants
                                          .selectedTime,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 0),
                                      border: OutlineInputBorder()),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Expanded(
                              flex: 0,
                              child: TextFormField(
                                controller: _tittleController,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                    labelText: MyConstants.tittle,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Expanded(
                              flex: 0,
                              child: TextFormField(
                                controller: _descriptionController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: const InputDecoration(
                                    labelText:
                                        MyConstants.description,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Expanded(
                              flex: 0,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () => _buttonText ==
                                            MyConstants
                                                .addEventButton
                                        ? addEvent()
                                        : submitUpdateEvent(_notificationId),
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    10.0)), backgroundColor: Color(
                                            int.parse("0xfff" "5C7E7F"))),
                                    child: Text(_buttonText!,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      )),
                  Visibility(
                      visible: _showList!,
                      child: Expanded(
                        flex: 0,
                        child: ListView.builder(
                            itemCount: _smartScheduleList.length,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.all(10.0),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  ArtSweetAlert.show(
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                          title:
                                              MyConstants.appTittle,
                                          text: MyConstants
                                              .editSchedule,
                                          showCancelBtn: true,
                                          confirmButtonText:
                                              MyConstants.yesButton,
                                          cancelButtonText:
                                              MyConstants.noButton,
                                          onConfirm: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                            setState(() {
                                              _showNewReminder = true;
                                              _showList = false;
                                            });
                                            updateEvent(
                                                _smartScheduleList[index]
                                                    .smartschedule_tittle,
                                                _smartScheduleList[index]
                                                    .smartschedule_time,
                                                _smartScheduleList[index]
                                                    .smartschedule_desc,
                                                _smartScheduleList[index]
                                                    .smartschedule_id);
                                          },
                                          onCancel: () => Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop(),
                                          cancelButtonColor: Color(
                                              int.parse("0xfff" "C5C5C5")),
                                          confirmButtonColor: Color(
                                              int.parse("0xfff" "507a7d"))));
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: Card(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            flex: 0,
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.only(top: 0),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      const SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Expanded(
                                                        flex: 0,
                                                        child: Row(
                                                          children: [
                                                            const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                            .all(
                                                                        5.0)),
                                                            Expanded(
                                                              flex: 0,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: const <
                                                                    Widget>[
                                                                  Text(
                                                                      "${MyConstants
                                                                              .tittle}             :  ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w600)),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                10.0),
                                                                    child: Text(
                                                                        _smartScheduleList[index]
                                                                            .smartschedule_tittle!,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15)),
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
                                                                padding:
                                                                    EdgeInsets
                                                                            .all(
                                                                        5.0)),
                                                            Expanded(
                                                              flex: 0,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: const <
                                                                    Widget>[
                                                                  Text(
                                                                      "${MyConstants
                                                                              .time}              :  ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w600)),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                10.0),
                                                                    child: Text(
                                                                        _smartScheduleList[index]
                                                                            .smartschedule_time!,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15)),
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
                                                                padding:
                                                                    EdgeInsets
                                                                            .all(
                                                                        5.0)),
                                                            Expanded(
                                                              flex: 0,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: const <
                                                                    Widget>[
                                                                  Text(
                                                                      "${MyConstants
                                                                              .description}  :  ",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w600)),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                10.0),
                                                                    child: Text(
                                                                        capitalize(_smartScheduleList[index]
                                                                            .smartschedule_desc!),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15)),
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
                                                    ])),
                                          )
                                        ]),
                                  ),
                                ),
                              );
                            }),
                      ))
                ],
              ),
            ),
            floatingActionButton: showFab
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
          ),
        ),
      ),
    );
  }

  bool? validateAddEvent() {
    bool? validate = true;

    if (_selectedDateController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.dateError);
    } else if (_selectedTimeController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.selectTime);
    } else if (_tittleController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.ssTittleError);
    } else if (_descriptionController.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.descriptionError);
    }

    return validate;
  }

  addEvent() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    var smartScheduleDataDao = database.smartScheduleDataDao;
    var list = await smartScheduleDataDao.findAllSmartScheduleData();

    if (validateAddEvent()!) {
      int? value;
      if (list.isEmpty) {
        value = 0;
      } else {
        value = list.last.smartschedule_id! + 1;
      }

      SmartScheduleDataTable smartScheduleDataTable = SmartScheduleDataTable(
          smartschedule_id: value,
          smartschedule_date: _selectedDateController.text.trim(),
          smartschedule_time: _selectedTimeController.text.trim(),
          smartschedule_tittle: _tittleController.text.trim(),
          smartschedule_desc: _descriptionController.text.trim(),
          smartschedule_update: false);

      smartScheduleDataDao.insertSmartScheduleData(smartScheduleDataTable);

      getSmartSchedule();

      scheduleAlarm(value);
    }
  }

  void updateEvent(String? smartscheduleTittle, String? smartscheduleTime,
      String? smartscheduleDesc, int? id) async {
    setState(() {
      _tittleController.value = TextEditingValue(text: smartscheduleTittle!);
      _selectedTimeController.value =
          TextEditingValue(text: smartscheduleTime!);
      _descriptionController.value =
          TextEditingValue(text: smartscheduleDesc!);
      _buttonText = MyConstants.updateEventButton;
      _notificationId = id;
      _scheduledTime = smartscheduleTime;
    });
  }

  submitUpdateEvent(int? id) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    var smartScheduleDataDao = database.smartScheduleDataDao;

    if (validateAddEvent()!) {
      await smartScheduleDataDao.updateSmartScheduleData(
          _tittleController.text.trim(),
          _selectedTimeController.text.trim(),
          _descriptionController.text.trim(),
          id!);

      getSmartSchedule();

      updateAlarm(id);
    }
  }

  void scheduleAlarm(int? value) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      channelDescription: 'Channel for Alarm notification',
      icon: 'logo',
      largeIcon: DrawableResourceAndroidBitmap('logo'),
    );

    var iOSPlatformChannelSpecifics = const IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin!.schedule(
        value!,
        _tittleController.text.trim(),
        _descriptionController.text.trim(),
        _saveDateTime!,
        platformChannelSpecifics,
        payload: 'Default_Sound');
  }

  void updateAlarm(int? id) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      channelDescription: 'Channel for Alarm notification',
      icon: 'logo',
      largeIcon: DrawableResourceAndroidBitmap('logo'),
    );

    var iOSPlatformChannelSpecifics = const IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    if (_selectedTimeController.text.trim() == _scheduledTime) {
      if (_scheduledTime!.endsWith("AM")) {
        _scheduledTime = _scheduledTime!.replaceAll(" AM", '');
        _saveDateTime = DateTime(
            _year!,
            _month!,
            _day!,
            int.parse(_scheduledTime!.split(":")[0].trim()),
            int.parse(_scheduledTime!.split(":")[1].trim()));
      } else if (_scheduledTime!.endsWith("PM")) {
        _scheduledTime = _scheduledTime!.replaceAll(" PM", '');
        _saveDateTime = DateTime(
            _year!,
            _month!,
            _day!,
            int.parse(_scheduledTime!.split(":")[0].trim()) + 12,
            int.parse(_scheduledTime!.split(":")[1].trim()));
      }
    }

    await flutterLocalNotificationsPlugin!.cancel(id!);

    await flutterLocalNotificationsPlugin!.schedule(
        id,
        _tittleController.text.trim(),
        _descriptionController.text.trim(),
        _saveDateTime!,
        platformChannelSpecifics,
        payload: 'Default_Sound');
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime!,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _saveDateTime =
            DateTime(_year!, _month!, _day!, picked.hour, picked.minute);
        if (DateTime(_year!, _month!, _day!, picked.hour, picked.minute)
                .millisecondsSinceEpoch >=
            DateTime.now()
                .subtract(const Duration(seconds: 60))
                .millisecondsSinceEpoch) {
          _hour = picked.hour.toString();
          _minute = picked.minute.toString();
          _selectedTimeController.text = DateFormat.jm()
              .format(DateFormat("hh:mm").parse("$_hour:$_minute"));
        } else {
          setToastMessage(context, MyConstants.selectedTimeError);
        }
      });
    }
  }
}
