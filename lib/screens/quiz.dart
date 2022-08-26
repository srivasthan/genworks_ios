import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart' as dio;

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/db/assessment_quiz_data.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'content_details.dart';
import 'quiz_result.dart';
import 'training.dart';

class Quiz extends StatefulWidget {
  final int? assessmentId, threshold;

  const Quiz({Key? key, required this.assessmentId, required this.threshold})
      : super(key: key);

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  var assessmentQuizData = <AssessmentQuizDataTable>[];
  int? i = 0, yourAnswer = 0, score = 0;
  String? _buttonName;
  final TextEditingController _questionController = TextEditingController();
  bool? optionA = false,
      optionB = false,
      optionC = false,
      optionD = false,
      _isLoading = true;

  getQuizData() async {
    setState(() {
      _isLoading = true;
    });

    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    var assessmentQuizDataDao = database.assessmentQuizDataDao;
    assessmentQuizData = await assessmentQuizDataDao
        .findAssessmentQuizDataByAssessmentId(widget.assessmentId!);

    if (assessmentQuizData.isNotEmpty) {
      if (i == assessmentQuizData.length - 1) {
        _buttonName = MyConstants.submitButton;
      } else {
        _buttonName = MyConstants.nextButton;
      }

      setState(() {
        _isLoading = !_isLoading!;
        _questionController.value =
            TextEditingValue(text: assessmentQuizData[i!].quation!);
      });
    } else {
      setToastMessage(context, MyConstants.noQuestionsAvailable);
    }
  }

  @override
  void initState() {
    super.initState();
    getQuizData();
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ContentDetail(
                  assessmentId: widget.assessmentId!,
                  threshold: widget.threshold,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // pushPage(context);
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ContentDetail(
                          threshold: widget.threshold,
                          assessmentId: widget.assessmentId!))),
            ),
            title: const Text(MyConstants.quizButton),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: assessmentQuizData.isNotEmpty ? _isLoading == true
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[400]!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 0,
                          child: TextFormField(
                            enabled: false,
                            autofocus: false,
                            controller: _questionController,
                            decoration: const InputDecoration(
                                labelText: MyConstants.question,
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 0),
                                border: OutlineInputBorder()),
                          ),
                        ),
                        Expanded(
                            flex: 0,
                            child: Column(children: [
                              Expanded(
                                flex: 0,
                                child: Row(
                                  children: [
                                    Transform.scale(
                                      scale: 1.0,
                                      child: Checkbox(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: optionA,
                                          onChanged: (bool? value) {},
                                          activeColor:
                                              Theme.of(context).primaryColor),
                                    ),
                                    const Text(
                                      "Option A",
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 0,
                                child: Row(
                                  children: [
                                    Transform.scale(
                                      scale: 1.0,
                                      child: Checkbox(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: optionB,
                                          onChanged: (bool? value) {},
                                          activeColor:
                                              Theme.of(context).primaryColor),
                                    ),
                                    const Text(
                                      "Option B",
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 0,
                                child: Row(
                                  children: [
                                    Transform.scale(
                                      scale: 1.0,
                                      child: Checkbox(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: optionC,
                                          onChanged: (bool? value) {},
                                          activeColor:
                                              Theme.of(context).primaryColor),
                                    ),
                                    const Text(
                                      "Option C",
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 0,
                                child: Row(
                                  children: [
                                    Transform.scale(
                                      scale: 1.0,
                                      child: Checkbox(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: optionD,
                                          onChanged: (bool? value) {},
                                          activeColor:
                                              Theme.of(context).primaryColor),
                                    ),
                                    const Text(
                                      "Option D",
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              )
                            ])),
                        Expanded(
                            child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
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
                          ),
                        )),
                      ],
                    ))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 0,
                        child: TextFormField(
                          enabled: false,
                          autofocus: false,
                          controller: _questionController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: MyConstants.question,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 0),
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Expanded(
                          flex: 0,
                          child: Column(children: [
                            Expanded(
                              flex: 0,
                              child: Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.0,
                                    child: Checkbox(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: optionA,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            optionA = value!;
                                            optionB = false;
                                            optionC = false;
                                            optionD = false;
                                            optionAClicked();
                                          });
                                        },
                                        activeColor:
                                            Theme.of(context).primaryColor),
                                  ),
                                  Text(
                                    assessmentQuizData[i!].optionA!,
                                    style: const TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.0,
                                    child: Checkbox(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: optionB,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            optionB = value!;
                                            optionA = false;
                                            optionC = false;
                                            optionD = false;
                                            optionBClicked();
                                          });
                                        },
                                        activeColor:
                                            Theme.of(context).primaryColor),
                                  ),
                                  Text(
                                    assessmentQuizData[i!].optionB!,
                                    style: const TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.0,
                                    child: Checkbox(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: optionC,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            optionC = value!;
                                            optionA = false;
                                            optionB = false;
                                            optionD = false;
                                            optionCClicked();
                                          });
                                        },
                                        activeColor:
                                            Theme.of(context).primaryColor),
                                  ),
                                  Text(
                                    assessmentQuizData[i!].optionC!,
                                    style: const TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.0,
                                    child: Checkbox(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: optionD,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            optionD = value!;
                                            optionA = false;
                                            optionB = false;
                                            optionC = false;
                                            optionDClicked();
                                          });
                                        },
                                        activeColor:
                                            Theme.of(context).primaryColor),
                                  ),
                                  Text(
                                    assessmentQuizData[i!].optionD!,
                                    style: const TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                            )
                          ])),
                      Expanded(
                          child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_buttonName == MyConstants.nextButton) {
                                nextButtonClicked();
                              } else if (_buttonName ==
                                  MyConstants.submitButton) {
                                submitButtonClicked();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                            child: Text(
                                _buttonName == MyConstants.nextButton
                                    ? MyConstants.nextButton
                                    : MyConstants.submitButton,
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.white)),
                          ),
                        ),
                      )),
                    ],
                  ) : const Center(
              child: Text(MyConstants.noQuestionsAvailable),
            ),
          ),
        ),
      ),
    );
  }

  optionAClicked() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    var assessmentQuizDataDao = database.assessmentQuizDataDao;

    if (optionA == true) {
      if (_buttonName == MyConstants.submitButton) {
        assessmentQuizDataDao.updatessessmentQuizData(
            true, false, false, false, assessmentQuizData[i!].quationId!);
        assessmentQuizDataDao.updateAssessmentQuizDataByYourAnswerANDQuationId(
            assessmentQuizData[i!].optionA!, assessmentQuizData[i!].quationId!);
      } else {
        assessmentQuizDataDao.updatessessmentQuizData(
            true, false, false, false, assessmentQuizData[i!].quationId!);
      }
    } else {
      assessmentQuizDataDao.updatessessmentQuizData(
          false, false, false, false, assessmentQuizData[i!].quationId!);
    }
  }

  optionBClicked() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    var assessmentQuizDataDao = database.assessmentQuizDataDao;

    if (optionB == true) {
      if (_buttonName == MyConstants.submitButton) {
        assessmentQuizDataDao.updatessessmentQuizData(
            false, true, false, false, assessmentQuizData[i!].quationId!);
        assessmentQuizDataDao.updateAssessmentQuizDataByYourAnswerANDQuationId(
            assessmentQuizData[i!].optionB!, assessmentQuizData[i!].quationId!);
      } else {
        assessmentQuizDataDao.updatessessmentQuizData(
            false, true, false, false, assessmentQuizData[i!].quationId!);
      }
    } else {
      assessmentQuizDataDao.updatessessmentQuizData(
          false, false, false, false, assessmentQuizData[i!].quationId!);
    }
  }

  optionCClicked() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    var assessmentQuizDataDao = database.assessmentQuizDataDao;

    if (optionC == true) {
      if (_buttonName == MyConstants.submitButton) {
        assessmentQuizDataDao.updatessessmentQuizData(
            false, false, true, false, assessmentQuizData[i!].quationId!);
        assessmentQuizDataDao.updateAssessmentQuizDataByYourAnswerANDQuationId(
            assessmentQuizData[i!].optionC!, assessmentQuizData[i!].quationId!);
      } else {
        assessmentQuizDataDao.updatessessmentQuizData(
            false, false, true, false, assessmentQuizData[i!].quationId!);
      }
    } else {
      assessmentQuizDataDao.updatessessmentQuizData(
          false, false, false, false, assessmentQuizData[i!].quationId!);
    }
  }

  optionDClicked() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    var assessmentQuizDataDao = database.assessmentQuizDataDao;

    if (optionD == true) {
      if (_buttonName == MyConstants.submitButton) {
        assessmentQuizDataDao.updatessessmentQuizData(
            false, false, false, true, assessmentQuizData[i!].quationId!);
        assessmentQuizDataDao.updateAssessmentQuizDataByYourAnswerANDQuationId(
            assessmentQuizData[i!].optionD!, assessmentQuizData[i!].quationId!);
      } else {
        assessmentQuizDataDao.updatessessmentQuizData(
            false, false, false, true, assessmentQuizData[i!].quationId!);
      }
    } else {
      assessmentQuizDataDao.updatessessmentQuizData(
          false, false, false, false, assessmentQuizData[i!].quationId!);
    }
  }

  nextButtonClicked() async {
    if (optionA == false &&
        optionB == false &&
        optionC == false &&
        optionD == false) {
      setToastMessage(context, MyConstants.selectAnswer);
    } else {
      if (assessmentQuizData.isNotEmpty) {
        if (i == assessmentQuizData.length - 1) {
          setState(() {
            _buttonName = MyConstants.submitButton;
            optionA = false;
            optionB = false;
            optionC = false;
            optionD = false;
            _questionController.value =
                TextEditingValue(text: assessmentQuizData[i!].quation!);
          });
        } else {
          final database = await $FloorAppDatabase
              .databaseBuilder('floor_database.db')
              .build();
          var assessmentQuizDataDao = database.assessmentQuizDataDao;

          if (optionA == true) {
            assessmentQuizDataDao
                .updateAssessmentQuizDataByYourAnswerANDQuationId(
                    assessmentQuizData[i!].optionA!,
                    assessmentQuizData[i!].quationId!);
          } else if (optionB == true) {
            assessmentQuizDataDao
                .updateAssessmentQuizDataByYourAnswerANDQuationId(
                    assessmentQuizData[i!].optionB!,
                    assessmentQuizData[i!].quationId!);
          } else if (optionC == true) {
            assessmentQuizDataDao
                .updateAssessmentQuizDataByYourAnswerANDQuationId(
                    assessmentQuizData[i!].optionC!,
                    assessmentQuizData[i!].quationId!);
          } else if (optionD == true) {
            assessmentQuizDataDao
                .updateAssessmentQuizDataByYourAnswerANDQuationId(
                    assessmentQuizData[i!].optionD!,
                    assessmentQuizData[i!].quationId!);
          }

          setState(() {
            i = i! + 1;
            optionA = false;
            optionB = false;
            optionC = false;
            optionD = false;
            _questionController.value =
                TextEditingValue(text: assessmentQuizData[i!].quation!);
          });
        }
      }
    }
  }

  submitButtonClicked() async {
    if (optionA == false &&
        optionB == false &&
        optionC == false &&
        optionD == false) {
      setToastMessage(context, MyConstants.selectAnswer);
    } else {
      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      var assessmentQuizDataDao = database.assessmentQuizDataDao;
      var assessmentQuizData =
          await assessmentQuizDataDao.findAllAssessmentQuizData();

      for (var quizData in assessmentQuizData) {
        if (quizData.correctAnswer == quizData.your_answer) {
          yourAnswer = yourAnswer! + 1;
          score = score! + 1;
        }
      }

      callSubmitQuizData();
    }
  }

  callSubmitQuizData() async {
    if (await checkInternetConnection() == true) {
      int? status = 0;

      showAlertDialog(context);

      if (widget.threshold == yourAnswer) {
        status = MyConstants.updateQuantity;
      } else if (widget.threshold! <= yourAnswer!) {
        status = MyConstants.updateQuantity;
      } else {
        status = MyConstants.chargeable;
      }

      Map<String, dynamic> quizData = {
        "technician_code":
            PreferenceUtils.getString(MyConstants.technicianCode),
        "certificate_id": widget.assessmentId!,
        "score": score,
        "status": status
      };

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.submitQuizDataAssessment(
          PreferenceUtils.getString(MyConstants.token), quizData);

      if (response.addTransferEntity != null) {
        if (response.addTransferEntity!.responseCode ==
            MyConstants.response200) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            PreferenceUtils.setString(
                MyConstants.token, response.addTransferEntity!.token!);
            if (response.addTransferEntity!.token != null) {
              setToastMessage(context, response.addTransferEntity!.message!);
            }
            if (widget.threshold == score || widget.threshold! <= score!) {
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      title: MyConstants.appTittle,
                      text: MyConstants.quizComplete,
                      showCancelBtn: true,
                      confirmButtonText: MyConstants.yesButton,
                      cancelButtonText: MyConstants.viewButton,
                      onConfirm: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Training(
                                      selectedIndex: 1,
                                    )));
                      },
                      onCancel: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuizResult(
                                    score: score,
                                    threshold: widget.threshold,
                                    assessmentId: widget.assessmentId)));
                      },
                      cancelButtonColor: Color(int.parse("0xfff" "C5C5C5")),
                      confirmButtonColor:
                          Color(int.parse("0xfff" "507a7d"))));
            } else {
              ArtSweetAlert.show(
                  context: context,
                  artDialogArgs: ArtDialogArgs(
                      title: MyConstants.appTittle,
                      text: MyConstants.quizInComplete,
                      showCancelBtn: true,
                      confirmButtonText: MyConstants.yesButton,
                      cancelButtonText: MyConstants.viewButton,
                      onConfirm: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Training(
                                      selectedIndex: 1,
                                    )));
                      },
                      onCancel: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuizResult(
                                    score: score,
                                    threshold: widget.threshold,
                                    assessmentId: widget.assessmentId)));
                      },
                      cancelButtonColor: Color(int.parse("0xfff" "C5C5C5")),
                      confirmButtonColor:
                          Color(int.parse("0xfff" "507a7d"))));
            }
          });
        } else if (response.addTransferEntity!.responseCode ==
            MyConstants.response400) {
          setState(() {
            Navigator.of(context, rootNavigator: true).pop();
            PreferenceUtils.setString(
                MyConstants.token, response.addTransferEntity!.token!);
            if (response.addTransferEntity!.token != null) {
              setToastMessage(context, response.addTransferEntity!.message!);
            }
          });
        } else if (response.addTransferEntity!.responseCode ==
            MyConstants.response500) {
          setState(() {
            Navigator.of(context, rootNavigator: true).pop();
            if (response.addTransferEntity!.token != null) {
              setToastMessage(context, response.addTransferEntity!.message!);
            }
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
