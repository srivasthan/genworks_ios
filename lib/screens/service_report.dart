import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';

import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/technician_punch.dart';
import '../utility/validator.dart';
import 'dashboard.dart';
import 'file_directory.dart';

class ServiceReport extends StatefulWidget {
  final int? selectedIndex;

  const ServiceReport({Key? key, required this.selectedIndex})
      : super(key: key);

  @override
  _ServiceReportState createState() => _ServiceReportState();
}

class _ServiceReportState extends State<ServiceReport> {
  final Map<int, Widget> _children = {
    0: const Padding(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      child: Text(
        "Today",
        style: TextStyle(fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    ),
    1: const Padding(
      padding: EdgeInsets.only(left: 5.0, right: 10.0),
      child: Text(
        "Period",
        style: TextStyle(fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    ),
  };
  int _currentSelection = 0;
  bool? _isLoading = true,
      _noDataAvailable = false,
      _todayFragment = false,
      _periodFragment = false;
  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  var pdfFile;

  Future<void> getToday(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
      _todayFragment = true;
      _periodFragment = false;
      _fromDateController.text = MyConstants.empty;
      _toDateController.text = MyConstants.empty;
      _selectedFromDate = DateTime.now();
      _selectedToDate = DateTime.now();
      PreferenceUtils.setString(MyConstants.technicianStatus, MyConstants.free);
    });

    if (widget.selectedIndex == 0) {
      _currentSelection = 0;
    }

    if (await checkInternetConnection() == true) {
      Map<String, String> getTravelDetailsData = {
        'technician_code':
            PreferenceUtils.getString(MyConstants.technicianCode),
        'from_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'to_date': DateFormat('yyyy-MM-dd').format(DateTime.now())
      };

      final Response<String> result = await Dio().request(
          'https://genworks.kaspontech.com/djadmin/servicereport_web_view/',
          options: Options(
              method: 'POST',
              headers: {'Content-Type': 'application/json'},
              extra: <String, dynamic>{}),
          data: getTravelDetailsData);

      final value = result.data;

      int idx = value!.indexOf(",");
      var cut = value.substring(1, idx).trim();
      int status = int.parse(cut.split(":")[1].trim());

      switch (status) {
        case 1:
          {
            var idx = value.split(",");
            var cut = idx.sublist(1).join(",");
            var idx1 = cut.split(":");
            var cut1 = idx1.sublist(1).join(":");
            String convertedData = cut1.replaceAll('"', '').replaceAll('}', '');

            setState(() {
              pdfFile = convertedData;
              _fromDateController.value = TextEditingValue(
                  text: DateFormat('yyyy-MM-dd')
                      .format(DateTime.now())
                      .toString());
              _toDateController.value = TextEditingValue(
                  text: DateFormat('yyyy-MM-dd')
                      .format(DateTime.now())
                      .toString());
            });

            _isLoading = !_isLoading!;

            break;
          }
        case 0:
          {
            setState(() {
              pdfFile = null;
              _noDataAvailable = true;
              _isLoading = !_isLoading!;
              setToastMessage(context, MyConstants.todayError);
            });
          }
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> getPeriod() async {
    setState(() {
      _isLoading = true;
      _noDataAvailable = false;
    });

    if (widget.selectedIndex == 1) {
      _currentSelection = 1;
    }

    if (await checkInternetConnection() == true) {
      if (_fromDateController.text.trim().isNotEmpty) {
        if (_toDateController.text.trim().isEmpty) {
          setToastMessage(context, MyConstants.toDateError);
        } else {
          setState(() => _isLoading = true);

          /* post travel claim details to server*/
          Map<String, String> getTravelDetailsData = {
            'technician_code':
                PreferenceUtils.getString(MyConstants.technicianCode),
            'from_date': DateFormat('yyyy-MM-dd').format(_selectedFromDate),
            'to_date': DateFormat('yyyy-MM-dd').format(_selectedToDate)
          };

          final Response<String> result = await Dio().request(
              'https://genworks.kaspontech.com/djadmin/servicereport_web_view/',
              options: Options(
                  method: 'POST',
                  headers: {'Content-Type': 'application/json'},
                  extra: <String, dynamic>{}),
              data: getTravelDetailsData);

          final value = result.data;

          int idx = value!.indexOf(",");
          var cut = value.substring(1, idx).trim();
          int status = int.parse(cut.split(":")[1].trim());

          switch (status) {
            case 1:
              {
                var idx = value.split(",");
                var cut = idx.sublist(1).join(",");
                var idx1 = cut.split(":");
                var cut1 = idx1.sublist(1).join(":");
                String convertedData =
                    cut1.replaceAll('"', '').replaceAll('}', '');

                setState(() {
                  pdfFile = convertedData;
                });

                _isLoading = !_isLoading!;

                break;
              }
            case 0:
              {
                setState(() {
                  pdfFile = null;
                  _noDataAvailable = true;
                  _isLoading = !_isLoading!;
                  setToastMessage(context, MyConstants.noClaimsFoundError);
                });

                break;
              }
          }
        }
      } else {
        setToastMessage(context, MyConstants.fromDateError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getToday(context);
    });
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
        return true;
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashBoard())),
            ),
            title: const Text(MyConstants.appName),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: MaterialSegmentedControl(
                            children: _children,
                            selectionIndex: _currentSelection,
                            borderColor: Colors.grey,
                            selectedColor:
                                Color(int.parse("0xfff" "507a7d")),
                            unselectedColor: Colors.white,
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
                                    getToday(context);
                                  } else if (index == 1) {
                                    _periodFragment = true;
                                    _todayFragment = false;
                                    pdfFile = null;
                                    _fromDateController.text =
                                        MyConstants.empty;
                                    _toDateController.text =
                                        MyConstants.empty;
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ]),
              ),
              Visibility(
                visible: _todayFragment!,
                child: todayScreen(),
              ),
              Visibility(
                visible: _periodFragment!,
                child: periodScreen(),
              ),
            ],
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
        ),
      ),
    );
  }

  Widget todayScreen() {
    return _isLoading == true
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
                                  const Padding(padding: EdgeInsets.all(5.0)),
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
            ? Column(mainAxisSize: MainAxisSize.max, children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  color: Colors.white,
                  child: pdfFile != null
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Html(
                            shrinkWrap: true,
                            data: pdfFile,
                            style: {
                              "table": Style(
                                backgroundColor:
                                    const Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                              ),
                              "tr": Style(
                                border: const Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              "th": Style(
                                padding: const EdgeInsets.all(6),
                                backgroundColor: Colors.grey,
                              ),
                              "td": Style(
                                padding: const EdgeInsets.all(6),
                                alignment: Alignment.topLeft,
                              ),
                              'h5': Style(
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis),
                            },
                            customRender: {
                              "table": (context, child) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: (context.tree as TableLayoutElement)
                                      .toWidget(context),
                                );
                              },
                              "bird": (RenderContext context, Widget child) {
                                return const TextSpan(text: "🐦");
                              },
                              "flutter": (RenderContext context, Widget child) {
                                return FlutterLogo(
                                  style: (context.tree.element!
                                              .attributes['horizontal'] !=
                                          null)
                                      ? FlutterLogoStyle.horizontal
                                      : FlutterLogoStyle.markOnly,
                                  textColor: context.style.color!,
                                  size: context.style.fontSize!.size! * 5,
                                );
                              },
                            },
                            onLinkTap: (url, _, __, ___) {
                            },
                            onImageTap: (src, _, __, ___) {
                            },
                            onImageError: (exception, stackTrace) {
                            },
                            onCssParseError: (css, messages) {
                              return null;
                            },
                          ),
                        )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () => saveAsPDF(),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "507a7d"))),
                      child: const Text(MyConstants.downloadButton,
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                  ),
                )
              ])
            : Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  child: const Center(
                    child: Text(MyConstants.noDataAvailable),
                  ),
                ),
              );
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

  Widget periodScreen() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: GestureDetector(
                  onTap: () => selectFromDate(context),
                  child: TextFormField(
                    showCursor: false,
                    enabled: false,
                    controller: _fromDateController,
                    decoration: const InputDecoration(
                        labelText: MyConstants.fromDate,
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        border: OutlineInputBorder()),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: GestureDetector(
                  onTap: () => selectToDate(context),
                  child: TextFormField(
                    showCursor: false,
                    enabled: false,
                    controller: _toDateController,
                    decoration: const InputDecoration(
                        labelText: MyConstants.toDate,
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        border: OutlineInputBorder()),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height / 2.5,
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
                          height: 50,
                          padding: const EdgeInsets.only(top: 10),
                          child: const Card(child: null));
                    }),
              )
            : pdfFile != null
                ? SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Html(
                      shrinkWrap: true,
                      data: pdfFile,
                      style: {
                        "table": Style(
                          backgroundColor:
                              const Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                        ),
                        "tr": Style(
                          border:
                              const Border(bottom: BorderSide(color: Colors.grey)),
                        ),
                        "th": Style(
                          padding: const EdgeInsets.all(6),
                          backgroundColor: Colors.grey,
                        ),
                        "td": Style(
                          padding: const EdgeInsets.all(6),
                          alignment: Alignment.topLeft,
                        ),
                        'h5': Style(
                            maxLines: 2, textOverflow: TextOverflow.ellipsis),
                      },
                      customRender: {
                        "table": (context, child) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: (context.tree as TableLayoutElement)
                                .toWidget(context),
                          );
                        },
                        "bird": (RenderContext context, Widget child) {
                          return const TextSpan(text: "🐦");
                        },
                        "flutter": (RenderContext context, Widget child) {
                          return FlutterLogo(
                            style: (context.tree.element!
                                        .attributes['horizontal'] !=
                                    null)
                                ? FlutterLogoStyle.horizontal
                                : FlutterLogoStyle.markOnly,
                            textColor: context.style.color!,
                            size: context.style.fontSize!.size! * 5,
                          );
                        },
                      },
                      onLinkTap: (url, _, __, ___) {
                      },
                      onImageTap: (src, _, __, ___) {
                      },
                      onImageError: (exception, stackTrace) {
                      },
                      onCssParseError: (css, messages) {
                        return null;
                      },
                    ),
                  )
                : null,
      ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 140.0,
              child: ElevatedButton(
                onPressed: () => saveAsPDF(),
                style: ElevatedButton.styleFrom(
                    shape:
                    RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                            10.0)), backgroundColor: Color(int.parse(
                        "0xfff" "5C7E7F"))),
                child: const Text(
                    MyConstants.downloadButton,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white)),
              ),
            ),
            SizedBox(
              width: 140.0,
              child: ElevatedButton(
                onPressed: () => getPeriod(),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "507a7d"))),
                child: const Text(MyConstants.viewButton,
                    style: TextStyle(fontSize: 15, color: Colors.white)),
              ),
            )
          ],
        ),
      )
    ]);
  }

  Future<void> selectFromDate(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedFromDate,
          firstDate: DateTime.now().subtract(const Duration(days: 730)),
          lastDate: DateTime.now());
      if (picked != null && picked != _selectedFromDate) {
        setState(() {
          _selectedFromDate = picked;
          _fromDateController.value = TextEditingValue(
              text: DateFormat('dd-MM-yyyy').format(_selectedFromDate));
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    if (await checkInternetConnection() == true) {
      if (_fromDateController.text.trim().isNotEmpty) {
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedToDate,
            firstDate: DateTime.now().subtract(const Duration(days: 730)),
            lastDate: DateTime.now());
        if (picked != null && picked != _selectedToDate) {
          setState(() {
            if (_selectedFromDate.compareTo(picked) <= 0) {
              _selectedToDate = picked;
              _toDateController.value = TextEditingValue(
                  text: DateFormat('dd-MM-yyyy').format(_selectedToDate));
            } else {
              setToastMessage(context, MyConstants.selectedDateError);
            }
          });
        }
      } else {
        setToastMessage(context, MyConstants.fromDateError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void saveAsPDF() async {
    if (await checkInternetConnection() == true) {
      if (_fromDateController.text.trim().isNotEmpty) {
        if (_toDateController.text.trim().isEmpty) {
          setToastMessage(context, MyConstants.toDateError);
        } else {
          String? downloadedPdf;
          downloadingDialog(context);

          /* post travel claim details to server*/
          Map<String, String> getTravelDetailsData = {
            'technician_code':
                PreferenceUtils.getString(MyConstants.technicianCode),
            'from_date': DateFormat('yyyy-MM-dd').format(_selectedFromDate),
            'to_date': DateFormat('yyyy-MM-dd').format(_selectedToDate)
          };

          final Response<String> result = await Dio().request(
              'https://genworks.kaspontech.com/djadmin/servicereport_web_view/',
              options: Options(
                  method: 'POST',
                  headers: {'Content-Type': 'application/json'},
                  extra: <String, dynamic>{}),
              data: getTravelDetailsData);

          final value = result.data;

          int idx = value!.indexOf(",");
          var cut = value.substring(1, idx).trim();
          int status = int.parse(cut.split(":")[1].trim());

          switch (status) {
            case 1:
              {
                var idx = value.split(",");
                var cut = idx.sublist(1).join(",");
                var idx1 = cut.split(":");
                var cut1 = idx1.sublist(1).join(":");
                String convertedData =
                    cut1.replaceAll('"', '').replaceAll('}', '');

                setState(() {
                  downloadedPdf = convertedData;
                });

                if (Platform.isAndroid) {
                  final FileDirectory fileDirectory =
                      FileDirectory(context, MyConstants.imageFolder);
                  Directory? getDirectory;
                  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
                  await _requestPermission(Permission.storage);

                  if (androidInfo.version.sdkInt >=
                      int.parse(MyConstants.osVersion)) {
                    Directory appDocDir =
                        await getApplicationDocumentsDirectory();
                    var generatedPdfFile =
                        await FlutterHtmlToPdf.convertFromHtmlContent(
                            downloadedPdf!, appDocDir.path, timestamp());
                    Navigator.of(context, rootNavigator: true).pop();
                    OpenFilex.open(generatedPdfFile.path);
                  } else {
                    fileDirectory.createFolder().then((value) async {
                      getDirectory = value;
                      if (!await getDirectory!.exists()) {
                        await getDirectory!.create(recursive: true);
                      }

                      var generatedPdfFile =
                          await FlutterHtmlToPdf.convertFromHtmlContent(
                              downloadedPdf!,
                              getDirectory!.path,
                              timestamp());
                      Navigator.of(context, rootNavigator: true).pop();
                      OpenFilex.open(generatedPdfFile.path);
                    });
                  }
                } else if (Platform.isIOS) {
                  var status = await Permission.storage.request();
                  Directory? directory = await getApplicationSupportDirectory();

                  setToastMessage(context, "Downloading please wait");

                  if (status == PermissionStatus.granted) {
                    var generatedPdfFile =
                        await FlutterHtmlToPdf.convertFromHtmlContent(
                            downloadedPdf!,
                            directory.path,
                            timestamp());
                    Navigator.of(context, rootNavigator: true).pop();
                    OpenFilex.open(generatedPdfFile.path);
                  } else if (status == PermissionStatus.denied) {
                    saveAsPDF();
                  } else if (status == PermissionStatus.permanentlyDenied) {
                    openAppSettings();
                  }
                }

                break;
              }
            case 0:
              {
                Navigator.of(context, rootNavigator: true).pop();
                setToastMessage(context, MyConstants.noClaimsFoundError);

                break;
              }
          }
        }
      } else {
        setToastMessage(context, MyConstants.fromDateError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
}
