import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shimmer/shimmer.dart';

import '../network/api_services.dart';
import '../network/db/app_database.dart';
import '../network/db/training_list_data.dart';
import '../network/model/training_reference_model.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'quiz.dart';
import 'training.dart';
import 'training_detail.dart';

class ContentDetail extends StatefulWidget {
  final int? assessmentId, threshold;

  const ContentDetail({Key? key, @required this.assessmentId, required this.threshold})
      : super(key: key);

  @override
  _ContentDetailState createState() => _ContentDetailState();
}

class _ContentDetailState extends State<ContentDetail> {
  final _trainingReferenceList = <TrainingReferenceModel>[];
  bool? _isLoading = true, noDataAvailable = false;
  String? _trainingTittle;

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const Training(selectedIndex: 1)));
  }

  getTrainingDetails() async {
    if (await checkInternetConnection() == true) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> referenceBody = {
        "assessment_id": widget.assessmentId!,
        "technician_code":
            PreferenceUtils.getString(MyConstants.technicianCode)
      };

      _trainingReferenceList.clear();

      final database =
          await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
      final trainingListDataDao = database.trainingListDataDao;

      ApiService apiService = ApiService(dio.Dio());
      final response = await apiService.trainingReferenceDetails(
          PreferenceUtils.getString(MyConstants.token),
          referenceBody);

      if (response.trainingReferenceEntity != null) {
        if (response.trainingReferenceEntity!.responseCode ==
            MyConstants.response200) {
          await trainingListDataDao.deleteTrainingListDataTable();
          setState(() {
            PreferenceUtils.setString(MyConstants.token,
                response.trainingReferenceEntity!.token!);
            for (var trainingReference
                in response.trainingReferenceEntity!.data!) {
              _trainingReferenceList.add(TrainingReferenceModel(
                  trainingId: trainingReference!.trainingId,
                  trainingTitle: trainingReference.trainingTitle,
                  trainingThumbImage: trainingReference.trainingThumbImage,
                  trainingContentType: trainingReference.trainingContentType,
                  trainingContent: trainingReference.trainingContent,
                  trainingDetailsId: trainingReference.trainingDetailsId,
                  showPdf: trainingReference.trainingContentType ==
                          MyConstants.pdf
                      ? true
                      : false,
                  showWord: trainingReference.trainingContentType ==
                          MyConstants.word
                      ? true
                      : false,
                  showFile: trainingReference.trainingContentType ==
                          MyConstants.file
                      ? true
                      : false,
                  showLink: trainingReference.trainingContentType ==
                          MyConstants.link
                      ? true
                      : false));

              _trainingTittle = trainingReference.trainingTitle;

              TrainingListDataTable trainingListDataTable = TrainingListDataTable(
                  assessment_id: widget.assessmentId!,
                  training_id: trainingReference.trainingId,
                  training_title: trainingReference.trainingTitle,
                  certificate_id:
                      trainingReference.trainingDetailsId.toString(),
                  training_thumb_image: trainingReference.trainingThumbImage,
                  training_content: trainingReference.trainingContent,
                  training_content_type: trainingReference.trainingContentType,
                  trainingPdfImage: trainingReference.trainingContentType ==
                          MyConstants.pdf
                      ? MyConstants.spareIdGetSpare
                      : null,
                  trainingWordImage: trainingReference.trainingContentType ==
                          MyConstants.word
                      ? MyConstants.spareIdGetSpare
                      : null,
                  trainingVideoImage: trainingReference.trainingContentType ==
                          MyConstants.file
                      ? MyConstants.spareIdGetSpare
                      : null,
                  trainingLinkImage: trainingReference.trainingContentType ==
                          MyConstants.link
                      ? MyConstants.spareIdGetSpare
                      : null,
                  pdfCount: trainingReference.trainingContentType == MyConstants.pdf
                      ? true
                      : false,
                  wordCount: trainingReference.trainingContentType ==
                          MyConstants.word
                      ? true
                      : false,
                  videoCount: trainingReference.trainingContentType == MyConstants.file ? true : false,
                  linkCount: trainingReference.trainingContentType == MyConstants.link ? true : false);

              trainingListDataDao.insertTrainingListData(trainingListDataTable);
            }
            _isLoading = !_isLoading!;
          });
        } else if (response.trainingReferenceEntity!.responseCode ==
            MyConstants.response400) {
          setState(() {
            PreferenceUtils.setString(MyConstants.token,
                response.trainingReferenceEntity!.token!);
            noDataAvailable = true;
            _isLoading = !_isLoading!;
          });
        } else if (response.trainingReferenceEntity!.responseCode ==
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

  @override
  void initState() {
    super.initState();
    getTrainingDetails();
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
                      builder: (context) => const Training(selectedIndex: 1))),
            ),
            title: const Text(MyConstants.appName),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _isLoading == true
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[400]!,
                    child: Column(
                      children: [
                        Expanded(
                            flex: 0,
                            child: Container(
                              color: Colors.white,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Image.asset(
                                          'assets/images/certificate.png')),
                                  const Expanded(
                                      flex: 0,
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          "Amazing",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 10.0,
                                  )
                                ],
                              ),
                            )),
                        Expanded(
                            flex: 0,
                            child: ListView.builder(
                                itemCount: 4,
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                itemBuilder: (context, index) {
                                  return Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Card(
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 7.5),
                                              child: Row(
                                                children: [
                                                  const Padding(
                                                      padding:
                                                          EdgeInsets.all(
                                                              5.0)),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: const <Widget>[
                                                        Text(
                                                            MyConstants
                                                                .na,
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
                                })),
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
                              child: const Text(MyConstants.quizButton,
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
                          child: Container(
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                        'assets/images/certificate.png')),
                                Expanded(
                                    flex: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        _trainingTittle != null
                                            ? _trainingTittle!
                                            : MyConstants.na,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    )),
                                const SizedBox(
                                  height: 10.0,
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 0,
                          child: noDataAvailable == false
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: RefreshIndicator(
                                    onRefresh: refreshTrainingContent,
                                    child: ListView.builder(
                                        itemCount:
                                            _trainingReferenceList.length,
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.all(0.0),
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              PreferenceUtils.setInteger(
                                                  MyConstants
                                                      .assessment_id,
                                                  widget.assessmentId!);
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TrainingDetail(
                                                            threshold: widget.threshold,
                                                            appBarTittle:
                                                                _trainingReferenceList[
                                                                        index]
                                                                    .trainingTitle,
                                                            thumbnail:
                                                                _trainingReferenceList[
                                                                        index]
                                                                    .trainingThumbImage,
                                                            screenType:
                                                                MyConstants
                                                                    .assessment,
                                                            fileUrl:
                                                                _trainingReferenceList[
                                                                        index]
                                                                    .trainingContent,
                                                            fileType:
                                                                _trainingReferenceList[
                                                                        index]
                                                                    .trainingContentType,
                                                          )));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10)),
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
                                                        margin: const EdgeInsets.only(
                                                            right: 10),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                  6.0),
                                                          child: Image.network(
                                                            MyConstants
                                                                    .baseurl +
                                                                _trainingReferenceList[
                                                                        index]
                                                                    .trainingThumbImage!,
                                                            fit: BoxFit.cover,
                                                            width: 75.0,
                                                            height: 75.0,
                                                            loadingBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget?
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
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
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                              _trainingReferenceList[
                                                                      index]
                                                                  .trainingTitle!,
                                                              style: const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                          Row(children: <
                                                              Widget>[
                                                            Expanded(
                                                                flex: 0,
                                                                child: Badge(
                                                                  showBadge:
                                                                      _trainingReferenceList[index].showPdf ==
                                                                              true
                                                                          ? true
                                                                          : false,
                                                                  badgeContent:
                                                                      const Text(
                                                                    MyConstants
                                                                        .spareIdGetSpare,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  badgeColor:
                                                                      Colors
                                                                          .red,
                                                                  animationType:
                                                                      BadgeAnimationType
                                                                          .scale,
                                                                  animationDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500),
                                                                  shape:
                                                                      BadgeShape
                                                                          .circle,
                                                                  child: Image
                                                                      .asset(
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
                                                                color: Colors
                                                                    .black45,
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
                                                                      _trainingReferenceList[index].showWord ==
                                                                              true
                                                                          ? true
                                                                          : false,
                                                                  badgeContent:
                                                                      const Text(
                                                                    MyConstants
                                                                        .spareIdGetSpare,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  badgeColor:
                                                                      Colors
                                                                          .red,
                                                                  animationType:
                                                                      BadgeAnimationType
                                                                          .scale,
                                                                  animationDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500),
                                                                  shape:
                                                                      BadgeShape
                                                                          .circle,
                                                                  child: Image
                                                                      .asset(
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
                                                                color: Colors
                                                                    .black45,
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
                                                                      _trainingReferenceList[index].showFile ==
                                                                              true
                                                                          ? true
                                                                          : false,
                                                                  badgeContent:
                                                                      const Text(
                                                                    MyConstants
                                                                        .spareIdGetSpare,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  badgeColor:
                                                                      Colors
                                                                          .red,
                                                                  animationType:
                                                                      BadgeAnimationType
                                                                          .scale,
                                                                  animationDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500),
                                                                  shape:
                                                                      BadgeShape
                                                                          .circle,
                                                                  child: Image
                                                                      .asset(
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
                                                                color: Colors
                                                                    .black45,
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
                                                                      _trainingReferenceList[index].showLink ==
                                                                              true
                                                                          ? true
                                                                          : false,
                                                                  badgeContent:
                                                                      const Text(
                                                                    MyConstants
                                                                        .spareIdGetSpare,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10.0,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  badgeColor:
                                                                      Colors
                                                                          .red,
                                                                  animationType:
                                                                      BadgeAnimationType
                                                                          .scale,
                                                                  animationDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500),
                                                                  shape:
                                                                      BadgeShape
                                                                          .circle,
                                                                  child: Image
                                                                      .asset(
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
                                  ),
                                )
                              : const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 50.0),
                                    child: Text(MyConstants
                                        .noDataAvailable),
                                  ),
                                )),
                      Expanded(
                          child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: () async {
                              final database = await $FloorAppDatabase
                                  .databaseBuilder('floor_database.db')
                                  .build();
                              final assessmentQuizDataDao =
                                  database.assessmentQuizDataDao;
                              var assessmentQuizData =
                                  await assessmentQuizDataDao
                                      .findAllAssessmentQuizData();
                              if (assessmentQuizData.isNotEmpty) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Quiz(
                                          threshold: widget.threshold,
                                            assessmentId:
                                                widget.assessmentId!)));
                              } else {
                                setToastMessage(
                                    context,
                                    MyConstants
                                        .noQuestionsAvailable);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                            child: const Text(MyConstants.quizButton,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white)),
                          ),
                        ),
                      )),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshTrainingContent() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      getTrainingDetails();
    });

    return;
  }
}
