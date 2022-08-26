import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:badges/badges.dart';
import 'package:fieldpro_genworks_healthcare/screens/training_detail.dart';
import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:location/location.dart' as pl;
import 'package:dio/dio.dart' as dio;
import 'package:shimmer/shimmer.dart';

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/db/assessment_question_data.dart';
import '../network/db/assessment_quiz_data.dart';
import '../network/model/assessment_model.dart';
import '../network/model/training_model.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/technician_punch.dart';
import '../utility/validator.dart';
import 'content_details.dart';
import 'dashboard.dart';

class Training extends StatefulWidget {
  final int? selectedIndex;

  const Training({Key? key, @required this.selectedIndex}) : super(key: key);

  @override
  _TrainingState createState() => _TrainingState();
}

class _TrainingState extends State<Training> {
  bool? _isLoading = true,
      _trainingFragment = false,
      _assessmentFragment = false;
  double? latitude, longitude;
  final TextEditingController _searchTrainingController =
      TextEditingController();
  final TextEditingController _searchAssessmentController =
      TextEditingController();
  pl.Location location = pl.Location();
  final _trainingList = <TrainingModel>[];
  var filteredTrainingList = <TrainingModel>[];
  final _assessmentList = <AssessmentModel>[];
  var filteredAssessmentList = <AssessmentModel>[];
  final _quizList = <DataQuizModel>[];

  final Map<int, Widget> _children = {
    0: Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
      child: Row(
        children: [
          Image.asset('assets/images/train.png', width: 24, height: 24),
          const SizedBox(
            width: 15.0,
          ),
          const Text(
            'Training',
            style: TextStyle(fontSize: 12.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
    1: Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
      child: Row(
        children: [
          Image.asset('assets/images/assessment.png', width: 24, height: 24),
          const SizedBox(
            width: 15.0,
          ),
          const Text(
            'Assessment',
            style: TextStyle(fontSize: 12.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
  };
  int _currentSelection = 0;

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashBoard()));
  }

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    if (widget.selectedIndex == 0) getTrainingDetails();
    if (widget.selectedIndex == 1) getAssessmentList();
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;

    return WillPopScope(
      onWillPop: () async {
        //  pushPage(context);
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashBoard())),
            ),
            title: const Text(MyConstants.training),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Row(
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
                                    getTrainingDetails();
                                  } else if (index == 1) {
                                    getAssessmentList();
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ]),
                Visibility(
                    visible: _trainingFragment!,
                    child: _searchTrainingController.text.isEmpty ||
                            filteredTrainingList.isEmpty
                        ? trainingView(context)
                        : searchTrainingView(context)),
                Visibility(
                    visible: _assessmentFragment!,
                    child: _searchAssessmentController.text.isEmpty ||
                            filteredAssessmentList.isEmpty
                        ? assessmentView(context)
                        : searchAssessmentView(context)),
              ],
            ),
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

  Widget trainingView(BuildContext context) {
    return SingleChildScrollView(
        child: _isLoading == true
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[400]!,
                child: Column(
                  children: [
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: MyConstants.search,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 0,
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
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.all(5.0)),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const <Widget>[
                                                    Text(MyConstants.na,
                                                        style: TextStyle(
                                                            fontSize: 11)),
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
                            }))
                  ],
                ))
            : Container(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: TextFormField(
                          autofocus: false,
                          controller: _searchTrainingController,
                          onChanged: onSearchTextChanged,
                          decoration: const InputDecoration(
                            labelText: MyConstants.search,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 0,
                        child: RefreshIndicator(
                          onRefresh: () => refreshTraining(),
                          child: ListView.builder(
                              itemCount: _trainingList.length,
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(5.0),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TrainingDetail(
                                                appBarTittle:
                                                    _trainingList[index]
                                                        .trainingTitle,
                                                thumbnail: _trainingList[index]
                                                    .trainingThumbImage,
                                                screenType:
                                                    MyConstants.training,
                                                fileUrl: _trainingList[index]
                                                    .trainingContent,
                                                fileType: _trainingList[index]
                                                    .trainingContentType,
                                              ))),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      color: index % 2 == 1
                                          ? Colors.white
                                          : Colors.grey[100],
                                    ),
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Center(
                                          child: Container(
                                              width: 100,
                                              height: 80,
                                              margin:
                                                  const EdgeInsets.only(right: 25),
                                              child: Padding(
                                                padding: const EdgeInsets.all(6.0),
                                                child: Image.network(
                                                  MyConstants.baseurl +
                                                      _trainingList[index]
                                                          .trainingThumbImage!,
                                                  fit: BoxFit.cover,
                                                  width: 75.0,
                                                  height: 75.0,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget? child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return child!;
                                                    }
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                                    .toInt()
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )),
                                        ),
                                        Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                    _trainingList[index]
                                                        .trainingTitle!,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Row(children: <Widget>[
                                                  Expanded(
                                                      flex: 0,
                                                      child: Badge(
                                                        showBadge: _trainingList[
                                                                        index]
                                                                    .showPdfBadge ==
                                                                true
                                                            ? true
                                                            : false,
                                                        badgeContent: const Text(
                                                          MyConstants
                                                              .spareIdGetSpare,
                                                          style: TextStyle(
                                                              fontSize: 10.0,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        badgeColor: Colors.red,
                                                        animationType:
                                                            BadgeAnimationType
                                                                .scale,
                                                        animationDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                        shape:
                                                            BadgeShape.circle,
                                                        child: Image.asset(
                                                          'assets/images/pdf.png',
                                                          width: 25,
                                                          height: 25,
                                                        ),
                                                      )),
                                                  const SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      color: Colors.black45,
                                                      height: 30,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Expanded(
                                                      flex: 0,
                                                      child: Badge(
                                                        showBadge: _trainingList[
                                                                        index]
                                                                    .showWordBadge ==
                                                                true
                                                            ? true
                                                            : false,
                                                        badgeContent: const Text(
                                                          MyConstants
                                                              .spareIdGetSpare,
                                                          style: TextStyle(
                                                              fontSize: 10.0,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        badgeColor: Colors.red,
                                                        animationType:
                                                            BadgeAnimationType
                                                                .scale,
                                                        animationDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                        shape:
                                                            BadgeShape.circle,
                                                        child: Image.asset(
                                                          'assets/images/word.png',
                                                          width: 25,
                                                          height: 25,
                                                        ),
                                                      )),
                                                  const SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      color: Colors.black45,
                                                      height: 30,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Expanded(
                                                      flex: 0,
                                                      child: Badge(
                                                        showBadge: _trainingList[
                                                                        index]
                                                                    .showFileBadge ==
                                                                true
                                                            ? true
                                                            : false,
                                                        badgeContent: const Text(
                                                          MyConstants
                                                              .spareIdGetSpare,
                                                          style: TextStyle(
                                                              fontSize: 10.0,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        badgeColor: Colors.red,
                                                        animationType:
                                                            BadgeAnimationType
                                                                .scale,
                                                        animationDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                        shape:
                                                            BadgeShape.circle,
                                                        child: Image.asset(
                                                          'assets/images/folder.png',
                                                          width: 25,
                                                          height: 25,
                                                        ),
                                                      )),
                                                  const SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      color: Colors.black45,
                                                      height: 30,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Expanded(
                                                      flex: 0,
                                                      child: Badge(
                                                        showBadge: _trainingList[
                                                                        index]
                                                                    .showLinkBadge ==
                                                                true
                                                            ? true
                                                            : false,
                                                        badgeContent: const Text(
                                                          MyConstants
                                                              .spareIdGetSpare,
                                                          style: TextStyle(
                                                              fontSize: 10.0,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        badgeColor: Colors.red,
                                                        animationType:
                                                            BadgeAnimationType
                                                                .scale,
                                                        animationDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                        shape:
                                                            BadgeShape.circle,
                                                        child: Image.asset(
                                                          'assets/images/link.png',
                                                          width: 25,
                                                          height: 25,
                                                        ),
                                                      )),
                                                ])
                                              ]),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ))
                  ],
                ),
              ));
  }

  Widget assessmentView(BuildContext context) {
    return SingleChildScrollView(
        child: _isLoading == true
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[400]!,
                child: Column(
                  children: [
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: MyConstants.search,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 0,
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
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.all(5.0)),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const <Widget>[
                                                    Text(MyConstants.na,
                                                        style: TextStyle(
                                                            fontSize: 11)),
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
                            }))
                  ],
                ))
            : Container(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        autofocus: false,
                        controller: _searchAssessmentController,
                        onChanged: onAssessmentSearch,
                        decoration: const InputDecoration(
                          labelText: MyConstants.search,
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: SizedBox(
                                    child: Container(
                                      height: 25,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(
                                                int.parse("0xfff" "507a7d")),
                                            Color(int.parse("0xfff" "507a7d"))
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(8.0),
                                            topLeft: Radius.circular(8.0)),
                                      ),
                                      child: Center(
                                        child: GestureDetector(
                                          child: const Text(MyConstants.tittle,
                                              style: TextStyle(
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 1,
                              ),
                              Expanded(
                                child: SizedBox(
                                  child: Container(
                                    height: 25,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(int.parse("0xfff" "507a7d")),
                                          Color(int.parse("0xfff" "507a7d"))
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: GestureDetector(
                                        child: const Text(MyConstants.score,
                                            style: TextStyle(
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 1,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 0.0),
                                  child: SizedBox(
                                    child: Container(
                                      height: 25,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(
                                                int.parse("0xfff" "507a7d")),
                                            Color(int.parse("0xfff" "507a7d"))
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(8.0),
                                            bottomRight: Radius.circular(8.0)),
                                      ),
                                      child: Center(
                                        child: GestureDetector(
                                          child: const Text(MyConstants.status,
                                              style: TextStyle(
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )),
                    Expanded(
                        flex: 0,
                        child: RefreshIndicator(
                          onRefresh: () => refreshAssessment(),
                          child: ListView.builder(
                              itemCount: _assessmentList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_assessmentList[index].statusName ==
                                          capitalize(MyConstants.clear)) {
                                        setToastMessage(context,
                                            MyConstants.alreadyCleared);
                                      } else {
                                        ArtSweetAlert.show(
                                            context: context,
                                            artDialogArgs: ArtDialogArgs(
                                                title: MyConstants.appTittle,
                                                text: MyConstants.retakeQuiz,
                                                showCancelBtn: true,
                                                confirmButtonText:
                                                    MyConstants.yesButton,
                                                cancelButtonText:
                                                    MyConstants.noButton,
                                                onConfirm: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                  updateStatus(index);
                                                },
                                                onCancel: () => Navigator.of(
                                                        context,
                                                        rootNavigator: true)
                                                    .pop(),
                                                cancelButtonColor: Color(
                                                    int.parse(
                                                        "0xfff" "C5C5C5")),
                                                confirmButtonColor: Color(
                                                    int.parse(
                                                        "0xfff" "507a7d"))));
                                      }
                                    });
                                  },
                                  child: Card(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7.5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Padding(
                                              padding:
                                                  EdgeInsets.all(5.0)),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                    _assessmentList[index]
                                                                .assessmentName ==
                                                            null
                                                        ? MyConstants.na
                                                        : _assessmentList[
                                                                index]
                                                            .assessmentName!,
                                                    textAlign:
                                                        TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                    _assessmentList[index]
                                                                .score ==
                                                            null
                                                        ? MyConstants.na
                                                        : _assessmentList[
                                                                index]
                                                            .score!
                                                            .toString(),
                                                    textAlign:
                                                        TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                    _assessmentList[index]
                                                                .statusName ==
                                                            null
                                                        ? MyConstants.na
                                                        : _assessmentList[
                                                                index]
                                                            .statusName!,
                                                    textAlign:
                                                        TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                  ])),
                                );
                              }),
                        ))
                  ],
                ),
              ));
  }

  updateStatus(int? index) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database').build();
    var assessmentQuestionDataDao = database.assessmentQuestionDataDao;

    setState(() {
      assessmentQuestionDataDao
          .updateAssessmentQuestionDataByAssessmentStatusAndAssessmentId(
              true, 5);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ContentDetail(
                    threshold: _assessmentList[index!].threshold,
                    assessmentId: _assessmentList[index].assessmentId,
                  )));
    });
  }

  Widget searchTrainingView(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Expanded(
            flex: 0,
            child: TextFormField(
              autofocus: true,
              controller: _searchTrainingController,
              onChanged: onSearchTextChanged,
              decoration: const InputDecoration(
                labelText: MyConstants.search,
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
              flex: 0,
              child: RefreshIndicator(
                onRefresh: () => refreshTraining(),
                child: ListView.builder(
                    itemCount: filteredTrainingList.length,
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(0.0),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TrainingDetail(
                                      appBarTittle:
                                          _trainingList[index].trainingTitle,
                                      screenType: MyConstants.training,
                                      thumbnail: _trainingList[index]
                                          .trainingThumbImage,
                                      fileUrl:
                                          _trainingList[index].trainingContent,
                                      fileType: _trainingList[index]
                                          .trainingContentType,
                                    ))),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            color: index % 2 == 1
                                ? Colors.white
                                : Colors.grey[100],
                          ),
                          width: double.infinity,
                          margin:
                              const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          padding:
                              const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Container(
                                    width: 100,
                                    height: 80,
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Image.network(
                                        MyConstants.baseurl +
                                            filteredTrainingList[index]
                                                .trainingThumbImage!,
                                        fit: BoxFit.cover,
                                        width: 75.0,
                                        height: 75.0,
                                        loadingBuilder: (BuildContext context,
                                            Widget? child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child!;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                          .toInt()
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    )),
                              ),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                          filteredTrainingList[index]
                                              .trainingTitle!,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                            flex: 0,
                                            child: Badge(
                                              showBadge:
                                                  filteredTrainingList[index]
                                                              .showPdfBadge ==
                                                          true
                                                      ? true
                                                      : false,
                                              badgeContent: const Text(
                                                MyConstants.spareIdGetSpare,
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.white),
                                              ),
                                              badgeColor: Colors.red,
                                              animationType:
                                                  BadgeAnimationType.scale,
                                              animationDuration:
                                                  const Duration(milliseconds: 500),
                                              shape: BadgeShape.circle,
                                              child: Image.asset(
                                                'assets/images/pdf.png',
                                                width: 25,
                                                height: 25,
                                              ),
                                            )),
                                        const SizedBox(
                                          width: 20.0,
                                        ),
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                            color: Colors.black45,
                                            height: 30,
                                            width: 2,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                            flex: 0,
                                            child: Badge(
                                              showBadge:
                                                  filteredTrainingList[index]
                                                              .showWordBadge ==
                                                          true
                                                      ? true
                                                      : false,
                                              badgeContent: const Text(
                                                MyConstants.spareIdGetSpare,
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.white),
                                              ),
                                              badgeColor: Colors.red,
                                              animationType:
                                                  BadgeAnimationType.scale,
                                              animationDuration:
                                                  const Duration(milliseconds: 500),
                                              shape: BadgeShape.circle,
                                              child: Image.asset(
                                                'assets/images/word.png',
                                                width: 25,
                                                height: 25,
                                              ),
                                            )),
                                        const SizedBox(
                                          width: 20.0,
                                        ),
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                            color: Colors.black45,
                                            height: 30,
                                            width: 2,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                            flex: 0,
                                            child: Badge(
                                              showBadge:
                                                  filteredTrainingList[index]
                                                              .showFileBadge ==
                                                          true
                                                      ? true
                                                      : false,
                                              badgeContent: const Text(
                                                MyConstants.spareIdGetSpare,
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.white),
                                              ),
                                              badgeColor: Colors.red,
                                              animationType:
                                                  BadgeAnimationType.scale,
                                              animationDuration:
                                                  const Duration(milliseconds: 500),
                                              shape: BadgeShape.circle,
                                              child: Image.asset(
                                                'assets/images/folder.png',
                                                width: 25,
                                                height: 25,
                                              ),
                                            )),
                                        const SizedBox(
                                          width: 20.0,
                                        ),
                                        Expanded(
                                          flex: 0,
                                          child: Container(
                                            color: Colors.black45,
                                            height: 30,
                                            width: 2,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                            flex: 0,
                                            child: Badge(
                                              showBadge:
                                                  filteredTrainingList[index]
                                                              .showLinkBadge ==
                                                          true
                                                      ? true
                                                      : false,
                                              badgeContent: const Text(
                                                MyConstants.spareIdGetSpare,
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.white),
                                              ),
                                              badgeColor: Colors.red,
                                              animationType:
                                                  BadgeAnimationType.scale,
                                              animationDuration:
                                                  const Duration(milliseconds: 500),
                                              shape: BadgeShape.circle,
                                              child: Image.asset(
                                                'assets/images/link.png',
                                                width: 25,
                                                height: 25,
                                              ),
                                            )),
                                      ])
                                    ]),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              ))
        ],
      ),
    ));
  }

  Widget searchAssessmentView(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Expanded(
            flex: 0,
            child: TextFormField(
              autofocus: false,
              controller: _searchAssessmentController,
              onChanged: onAssessmentSearch,
              decoration: const InputDecoration(
                labelText: MyConstants.search,
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: SizedBox(
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(int.parse("0xfff" "507a7d")),
                                  Color(int.parse("0xfff" "507a7d"))
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8.0),
                                  topLeft: Radius.circular(8.0)),
                            ),
                            child: Center(
                              child: GestureDetector(
                                child: const Text(MyConstants.tittle,
                                    style: TextStyle(
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Container(
                          height: 25,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(int.parse("0xfff" "507a7d")),
                                Color(int.parse("0xfff" "507a7d"))
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: GestureDetector(
                              child: const Text(MyConstants.score,
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 0.0),
                        child: SizedBox(
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(int.parse("0xfff" "507a7d")),
                                  Color(int.parse("0xfff" "507a7d"))
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0)),
                            ),
                            child: Center(
                              child: GestureDetector(
                                child: const Text(MyConstants.status,
                                    style: TextStyle(
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )),
          Expanded(
              flex: 0,
              child: RefreshIndicator(
                onRefresh: () => refreshAssessment(),
                child: ListView.builder(
                    itemCount: filteredAssessmentList.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (filteredAssessmentList[index].statusName ==
                                capitalize(MyConstants.clear)) {
                              setToastMessage(
                                  context, MyConstants.alreadyCleared);
                            } else {
                              ArtSweetAlert.show(
                                  context: context,
                                  artDialogArgs: ArtDialogArgs(
                                      title: MyConstants.appTittle,
                                      text: MyConstants.retakeQuiz,
                                      showCancelBtn: true,
                                      confirmButtonText: MyConstants.yesButton,
                                      cancelButtonText: MyConstants.noButton,
                                      onConfirm: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ContentDetail(
                                                      threshold:
                                                          filteredAssessmentList[
                                                                  index]
                                                              .threshold,
                                                      assessmentId:
                                                          filteredAssessmentList[
                                                                  index]
                                                              .assessmentId,
                                                    )));
                                      },
                                      onCancel: () => Navigator.of(context,
                                              rootNavigator: true)
                                          .pop(),
                                      cancelButtonColor:
                                          Color(int.parse("0xfff" "C5C5C5")),
                                      confirmButtonColor: Color(
                                          int.parse("0xfff" "507a7d"))));
                            }
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.only(top: 10),
                            child: Card(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 7.5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Padding(
                                            padding: EdgeInsets.all(5.0)),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  filteredAssessmentList[index]
                                                              .assessmentName ==
                                                          null
                                                      ? MyConstants.na
                                                      : filteredAssessmentList[
                                                              index]
                                                          .assessmentName!,
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      const TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  filteredAssessmentList[index]
                                                              .score ==
                                                          null
                                                      ? MyConstants.na
                                                      : filteredAssessmentList[
                                                              index]
                                                          .score!
                                                          .toString(),
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      const TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  filteredAssessmentList[index]
                                                              .statusName ==
                                                          null
                                                      ? MyConstants.na
                                                      : filteredAssessmentList[
                                                              index]
                                                          .statusName!,
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      const TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                ]))),
                      );
                    }),
              ))
        ],
      ),
    ));
  }

  Future<void> refreshTraining() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getTrainingDetails();
    });

    return;
  }

  Future<void> refreshAssessment() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getAssessmentList();
    });

    return;
  }

  void getTrainingDetails() async {
    if (await checkInternetConnection() == true) {
      setState(() {
        _currentSelection = 0;
        _isLoading = true;
        _trainingFragment = true;
        _assessmentFragment = false;
        _searchTrainingController.value =
            const TextEditingValue(text: MyConstants.empty);
        _searchAssessmentController.value =
            const TextEditingValue(text: MyConstants.empty);
        PreferenceUtils.setString(
            MyConstants.technicianStatus, MyConstants.free);
      });

      _trainingList.clear();
      filteredTrainingList.clear();
      _assessmentList.clear();
      filteredAssessmentList.clear();

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.training(
          PreferenceUtils.getString(MyConstants.token),
          PreferenceUtils.getString(MyConstants.technicianCode));

      if (response.trainingEntity != null) {
        if (response.trainingEntity!.responseCode == MyConstants.response200) {
          setState(() {
            PreferenceUtils.setString(
                MyConstants.token, response.trainingEntity!.token!);

            for (int i = 0; i < response.trainingEntity!.data!.length; i++) {
              _trainingList.add(TrainingModel(
                  certificateId:
                      response.trainingEntity!.data![i]!.certificateId ?? "",
                  trainingContent:
                      response.trainingEntity!.data![i]!.trainingContent ?? "",
                  trainingContentType:
                      response.trainingEntity!.data![i]!.trainingContentType ??
                          "",
                  trainingId:
                      response.trainingEntity!.data![i]!.trainingId ?? "",
                  trainingThumbImage:
                      response.trainingEntity!.data![i]!.trainingThumbImage ??
                          "",
                  showPdfBadge: response.trainingEntity!.data![i]!.trainingContentType == MyConstants.pdf
                      ? true
                      : false,
                  showWordBadge: response.trainingEntity!.data![i]!.trainingContentType == MyConstants.word
                      ? true
                      : false,
                  showFileBadge: response.trainingEntity!.data![i]!.trainingContentType != MyConstants.pdf &&
                          response.trainingEntity!.data![i]!.trainingContentType != MyConstants.word &&
                          response.trainingEntity!.data![i]!.trainingContentType != MyConstants.link
                      ? true
                      : false,
                  showLinkBadge: response.trainingEntity!.data![i]!.trainingContentType == MyConstants.link ? true : false,
                  trainingTitle: response.trainingEntity!.data![i]!.trainingTitle ?? ""));
            }

            _isLoading = !_isLoading!;
          });
        } else if (response.trainingEntity!.responseCode ==
            MyConstants.response400) {
          setState(() {
            _isLoading = !_isLoading!;
            PreferenceUtils.setString(
                MyConstants.token, response.trainingEntity!.token!);
          });
        } else if (response.trainingEntity!.responseCode ==
            MyConstants.response500) {
          setState(() {
            _isLoading = !_isLoading!;
          });
        }
      } else {
        setToastMessage(context, MyConstants.internalServerError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  void getAssessmentList() async {
    if (await checkInternetConnection() == true) {
      setState(() {
        _currentSelection = 1;
        _isLoading = true;
        _trainingFragment = false;
        _assessmentFragment = true;
        PreferenceUtils.setString(
            MyConstants.technicianStatus, MyConstants.free);
        _searchTrainingController.value =
            const TextEditingValue(text: MyConstants.empty);
        _searchAssessmentController.value =
            const TextEditingValue(text: MyConstants.empty);
      });

      _trainingList.clear();
      filteredTrainingList.clear();
      _assessmentList.clear();
      filteredAssessmentList.clear();

      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final assessmentQuestionDataDao = database.assessmentQuestionDataDao;
      final assessmentQuizDataDao = database.assessmentQuizDataDao;

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.assessmentList(
          PreferenceUtils.getString(MyConstants.token),
          PreferenceUtils.getString(MyConstants.technicianCode));

      if (response.assessmentEntity != null) {
        if (response.assessmentEntity!.responseCode ==
            MyConstants.response200) {
          await assessmentQuestionDataDao.deleteAssessmentQuestionDataTable();
          await assessmentQuizDataDao.deleteAssessmentQuizDataTable();

          setState(() {
            PreferenceUtils.setString(
                MyConstants.token, response.assessmentEntity!.token!);

            for (int i = 0; i < response.assessmentEntity!.data!.length; i++) {
              _assessmentList.add(AssessmentModel(
                  assessmentId:
                      response.assessmentEntity!.data![i]!.assessmentId ?? 0,
                  assessmentName:
                      response.assessmentEntity!.data![i]!.assessmentName ?? "",
                  assessmentStatus:
                      response.assessmentEntity!.data![i]!.assessmentStatus ??
                          0,
                  trainingId:
                      response.assessmentEntity!.data![i]!.trainingId ?? "",
                  totalQuations:
                      response.assessmentEntity!.data![i]!.totalQuations ?? 0,
                  quationToAssessment: response
                          .assessmentEntity!.data![i]!.quationToAssessment ??
                      0,
                  threshold:
                      response.assessmentEntity!.data![i]!.threshold ?? 0,
                  score: response.assessmentEntity!.data![i]!.score ?? 0,
                  statusName:
                      response.assessmentEntity!.data![i]!.statusName ?? ""));

              AssessmentQuestionDataTable assessmentQuestionDataTable =
                  AssessmentQuestionDataTable(
                      id: i + 1,
                      assessmentId:
                          response.assessmentEntity!.data![i]!.assessmentId ??
                              0,
                      assessmentName:
                          response.assessmentEntity!.data![i]!.assessmentName ??
                              "",
                      totalQuations:
                          response.assessmentEntity!.data![i]!.totalQuations ??
                              0,
                      quationToAssessment: response.assessmentEntity!.data![i]!
                              .quationToAssessment ??
                          0,
                      score: response.assessmentEntity!.data![i]!.score ?? 0,
                      status:
                          response.assessmentEntity!.data![i]!.statusName ?? "",
                      trainingId:
                          response.assessmentEntity!.data![i]!.trainingId ?? "",
                      threshold:
                          response.assessmentEntity!.data![i]!.threshold ?? 0,
                      assessment_status: false);

              assessmentQuestionDataDao
                  .insertAssessmentQuestionData(assessmentQuestionDataTable);
            }

            if (response.assessmentEntity!.data!.isNotEmpty) {
              for (var data in response.assessmentEntity!.data!) {
                for (int j = 0; j < data!.quiz!.length; j++) {
                  _quizList.add(DataQuizModel(
                    quationId: data.quiz![j]!.quationId ?? 0,
                    quation: data.quiz![j]!.quation ?? "",
                    optionA: data.quiz![j]!.optionA ?? "",
                    optionB: data.quiz![j]!.optionB ?? "",
                    optionC: data.quiz![j]!.optionC ?? "",
                    optionD: data.quiz![j]!.optionD ?? "",
                    correctAnswer: data.quiz![j]!.correctAnswer ?? "",
                  ));

                  AssessmentQuizDataTable assessmentQuizDataTable =
                      AssessmentQuizDataTable(
                          quationId: data.quiz![j]!.quationId ?? 0,
                          assessment_id: data.assessmentId ?? 0,
                          quation: data.quiz![j]!.quation ?? "",
                          optionA: data.quiz![j]!.optionA ?? "",
                          optionB: data.quiz![j]!.optionB ?? "",
                          optionC: data.quiz![j]!.optionC ?? "",
                          optionD: data.quiz![j]!.optionD ?? "",
                          correctAnswer: data.quiz![j]!.correctAnswer ?? "",
                          updateAnswer_a: false,
                          updateAnswer_b: false,
                          updateAnswer_c: false,
                          updateAnswer_d: false,
                          your_answer: MyConstants.empty);

                  assessmentQuizDataDao
                      .insertAssessmentQuizData(assessmentQuizDataTable);
                }
              }
            }

            _isLoading = !_isLoading!;
          });
        } else if (response.assessmentEntity!.responseCode ==
            MyConstants.response400) {
          setState(() {
            _isLoading = !_isLoading!;
            PreferenceUtils.setString(
                MyConstants.token, response.assessmentEntity!.token!);
          });
        } else if (response.assessmentEntity!.responseCode ==
            MyConstants.response500) {
          setState(() {
            _isLoading = !_isLoading!;
          });
        }
      } else {
        setToastMessage(context, MyConstants.internalServerError);
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  onSearchTextChanged(String text) async {
    filteredTrainingList.clear();
    setState(() {
      if (text.isEmpty) {
        return;
      }

      for (var trainingDetail in _trainingList) {
        if (trainingDetail.trainingTitle!.toLowerCase().contains(text) ||
            trainingDetail.trainingTitle!.toLowerCase().contains(text)) {
          filteredTrainingList.add(trainingDetail);
        }
      }
    });
  }

  onAssessmentSearch(String text) async {
    filteredAssessmentList.clear();
    setState(() {
      if (text.isEmpty) {
        return;
      }

      for (var trainingDetail in _assessmentList) {
        if (trainingDetail.assessmentName!.toLowerCase().contains(text) ||
            trainingDetail.assessmentName!.toLowerCase().contains(text)) {
          filteredAssessmentList.add(trainingDetail);
        }
      }
    });
  }
}
