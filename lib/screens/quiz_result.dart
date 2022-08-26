import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../network/db/app_database.dart';
import '../utility/store_strings.dart';
import 'training.dart';

class QuizResult extends StatefulWidget {
  final int? score, assessmentId, threshold;

  const QuizResult(
      {Key? key,
      required this.score,
      required this.assessmentId,
      required this.threshold})
      : super(key: key);

  @override
  _QuizResultState createState() => _QuizResultState();
}

class _QuizResultState extends State<QuizResult> {
  bool? _isLoading = true, _correctAnswer;
  final _questionController = <TextEditingController>[];
  final _correctAnswerController = <TextEditingController>[];
  final _yourAnswerController = <TextEditingController>[];
  final _checkAnswer = <bool?>[];
  String? _quizResult;

  getQuizResult() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    var assessmentQuizDataDao = database.assessmentQuizDataDao;
    var assessmentQuizList = await assessmentQuizDataDao
        .findAssessmentQuizDataByAssessmentId(widget.assessmentId!);

    _questionController.clear();
    _correctAnswerController.clear();
    _yourAnswerController.clear();
    _checkAnswer.clear();

    if (widget.threshold == widget.score ||
        widget.threshold! <= widget.score!) {
      _correctAnswer = true;
      _quizResult = MyConstants.quizComplete;
    } else {
      _correctAnswer = false;
      _quizResult = MyConstants.quizInComplete;
    }

    if (assessmentQuizList.isNotEmpty) {
      setState(() {
        for (int i = 0; i < assessmentQuizList.length; i++) {

          _questionController.add(TextEditingController());
          _questionController[i].value = TextEditingValue(
              text: "${i + 1}.${MyConstants.space}${assessmentQuizList[i].quation!}");
          _correctAnswerController.add(TextEditingController());
          _correctAnswerController[i].value = TextEditingValue(
              text: "${MyConstants.correctAnswer} : ${assessmentQuizList[i].correctAnswer!}");
          _yourAnswerController.add(TextEditingController());
          _yourAnswerController[i].value = TextEditingValue(
              text: "${MyConstants.yourAnswer} : ${assessmentQuizList[i].your_answer!}");
          if (assessmentQuizList[i].correctAnswer ==
              assessmentQuizList[i].your_answer) {
            _checkAnswer.add(true);
          } else {
            _checkAnswer.add(false);
          }
        }
      });
    }

    setState(() {
      _isLoading = !_isLoading!;
    });
  }

  @override
  void initState() {
    super.initState();
    getQuizResult();
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const Training(selectedIndex: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
     //   pushPage(context);
        return false;
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
                        builder: (context) => const Training(selectedIndex: 1))),
              ),
              title: const Text(MyConstants.appTittle),
              backgroundColor: Color(int.parse("0xfff" "507a7d")),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: _isLoading == true
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[400]!,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Text("Congratulations! You have cleared the quiz"),
                            const SizedBox(
                              height: 20.0,
                            ),
                            const Text("Your Score : 5"),
                            Expanded(
                                flex: 0,
                                child: ListView.builder(
                                    itemCount: 3,
                                    physics: const ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(5.0),
                                    itemBuilder: (context, index) {
                                      return Container(
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
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 0,
                                              child: TextFormField(
                                                enabled: false,
                                                autofocus: false,
                                                decoration: const InputDecoration(
                                                    labelText:
                                                        MyConstants
                                                            .question,
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            10, 10, 10, 0),
                                                    border:
                                                        OutlineInputBorder()),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 0,
                                              child: TextFormField(
                                                enabled: false,
                                                autofocus: false,
                                                decoration: const InputDecoration(
                                                    labelText:
                                                        MyConstants
                                                            .question,
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            10, 10, 10, 0),
                                                    border:
                                                        OutlineInputBorder()),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 0,
                                              child: TextFormField(
                                                enabled: false,
                                                autofocus: false,
                                                decoration: const InputDecoration(
                                                    labelText:
                                                        MyConstants
                                                            .question,
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            10, 10, 10, 0),
                                                    border:
                                                        OutlineInputBorder()),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })),
                          ],
                        ))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            _quizResult!,
                            style: TextStyle(
                                color: _correctAnswer == true
                                    ? Colors.green
                                    : Colors.red),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(MyConstants.yourScore +
                              widget.score!.toString()),
                          Expanded(
                              flex: 0,
                              child: ListView.builder(
                                  itemCount: _questionController.length,
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(5.0),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10.0),
                                            bottomLeft: Radius.circular(10.0),
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 0,
                                            child: TextFormField(
                                              enabled: false,
                                              autofocus: false,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: null,
                                              controller:
                                                  _questionController[index],
                                              decoration: const InputDecoration(
                                                  labelText:
                                                      MyConstants
                                                          .question,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          10, 10, 10, 0),
                                                  border: OutlineInputBorder()),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: TextFormField(
                                              enabled: false,
                                              autofocus: false,
                                              controller:
                                                  _correctAnswerController[
                                                      index],
                                              style: TextStyle(
                                                  color: _checkAnswer[index] ==
                                                          true
                                                      ? Colors.green
                                                      : Colors.red),
                                              decoration: const InputDecoration(
                                                  labelText:
                                                      MyConstants
                                                          .correctAnswer,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          10, 10, 10, 0),
                                                  border: OutlineInputBorder()),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: TextFormField(
                                              enabled: false,
                                              autofocus: false,
                                              controller:
                                                  _yourAnswerController[index],
                                              style: TextStyle(
                                                  color: _checkAnswer[index] ==
                                                          true
                                                      ? Colors.green
                                                      : Colors.red),
                                              decoration: const InputDecoration(
                                                  labelText:
                                                      MyConstants
                                                          .yourAnswer,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          10, 10, 10, 0),
                                                  border: OutlineInputBorder()),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
