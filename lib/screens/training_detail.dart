import 'dart:io';

import 'package:fieldpro_genworks_healthcare/screens/show_training_details.dart';
import 'package:fieldpro_genworks_healthcare/screens/show_video.dart';
import 'package:fieldpro_genworks_healthcare/screens/training.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'content_details.dart';

class TrainingDetail extends StatefulWidget {
  final String? appBarTittle, thumbnail, fileUrl, fileType, screenType;
  final int? threshold;

  const TrainingDetail(
      {Key? key,
      @required this.appBarTittle,
      @required this.thumbnail,
      @required this.fileUrl,
      @required this.fileType,
      this.threshold,
      this.screenType})
      : super(key: key);

  @override
  _TrainingDetailState createState() => _TrainingDetailState();
}

class _TrainingDetailState extends State<TrainingDetail> {
  Future<T?> pushPage<T>(BuildContext context, Widget? page) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page!));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // if (widget.screenType == MyConstants.training) {
        //   pushPage(
        //       context,
        //       new Training(
        //         selectedIndex: 0,
        //       ));
        // } else {
        //   pushPage(
        //       context,
        //       new ContentDetail(
        //         threshold: widget.threshold,
        //         assessmentId: PreferenceUtils.getInteger(
        //             MyConstants.assessment_id),
        //       ));
        // }
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                if (widget.screenType == MyConstants.training) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Training(
                                selectedIndex: 0,
                              )));
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContentDetail(
                                threshold: widget.threshold,
                                assessmentId: PreferenceUtils.getInteger(
                                    MyConstants.assessment_id),
                              )));
                }
              },
            ),
            title: Text(widget.appBarTittle!),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: Column(
            children: [
              Expanded(
                  flex: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2.5,
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0, bottom: 25.0),
                              child: Image.network(
                                MyConstants.baseurl +
                                    widget.thumbnail!,
                                fit: BoxFit.cover,
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                loadingBuilder: (BuildContext context,
                                    Widget? child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child!;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
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
                            ),
                          ),
                          Text(widget.appBarTittle!)
                        ],
                      ),
                    ),
                  )),
              Expanded(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: const [
                        Expanded(
                            flex: 1,
                            child: Divider(
                              thickness: 2.0,
                              color: Colors.black,
                            )),
                        Expanded(
                            flex: 2,
                            child: Text(
                              MyConstants.all,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.blue),
                            )),
                        Expanded(
                            flex: 1,
                            child: Divider(
                              thickness: 2.0,
                              color: Colors.black,
                            )),
                      ],
                    ),
                  )),
              Expanded(
                  flex: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
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
                                  child: const Text(MyConstants.fileType,
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
                                child: const Text(MyConstants.fileName,
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
                          padding: const EdgeInsets.only(right: 15.0),
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
                                  child: const Text(MyConstants.viewFile,
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
                  )),
              Expanded(
                  flex: 0,
                  child: GestureDetector(
                    onTap: () => getFileFromUrl(),
                    child: Container(
                        padding: const EdgeInsets.all(15.0),
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
                                    const Padding(padding: EdgeInsets.all(5.0)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            widget.fileType ==
                                                    MyConstants.pdf
                                                ? 'assets/images/pdf.png'
                                                : widget.fileType ==
                                                        MyConstants
                                                            .word
                                                    ? 'assets/images/word.png'
                                                    : widget.fileType ==
                                                            MyConstants
                                                                .link
                                                        ? 'assets/images/link.png'
                                                        : 'assets/images/folder.png',
                                            width: 25.0,
                                            height: 25.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(widget.appBarTittle!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/images/download.png',
                                            width: 25.0,
                                            height: 25.0,
                                          ),
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
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void getFileFromUrl() async {
    if (widget.fileType == MyConstants.pdf ||
        widget.fileType == MyConstants.word) {
      showAlertDialog(context);
      try {
        var data = await http
            .get(Uri.parse(MyConstants.baseurl + widget.fileUrl!));
        var bytes = data.bodyBytes;
        var dir = await getApplicationDocumentsDirectory();
        File file;
        if (widget.fileType == MyConstants.pdf) {
          file = File("${dir.path}/${widget.appBarTittle}.pdf");
        } else {
          file = File("${dir.path}/${widget.appBarTittle}.doc");
        }

        File urlFile = await file.writeAsBytes(bytes);

        Navigator.of(context, rootNavigator: true).pop();

        OpenFilex.open(urlFile.path);
      } catch (e) {
        throw Exception("Error opening url file");
      }
    } else if(widget.fileType == MyConstants.link) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ShowTrainingDetails(
                  appBarTittle: widget.appBarTittle,
                  thumbnail: widget.thumbnail,
                  fileUrl: widget.fileUrl!,
                  fileType: widget.fileType)));
    } else{

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShowVideo(
                video: null,
                videoPath: MyConstants.baseurl + widget.fileUrl!,
              )));
    }
  }
}
