import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utility/store_strings.dart';
import 'training_detail.dart';

class ShowTrainingDetails extends StatefulWidget {
  final String? appBarTittle, thumbnail, fileUrl, fileType;

  const ShowTrainingDetails(
      {Key? key,
      @required this.appBarTittle,
      @required this.thumbnail,
      @required this.fileUrl,
      @required this.fileType})
      : super(key: key);

  @override
  _ShowTrainingDetailsState createState() => _ShowTrainingDetailsState();
}

class _ShowTrainingDetailsState extends State<ShowTrainingDetails> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  Future<T?> pushPage<T>(BuildContext context, Widget? page) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page!));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // pushPage(
        //     context,
        //     new Training(
        //       selectedIndex: 0,
        //     ));
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
                      builder: (context) => TrainingDetail(
                          appBarTittle: widget.appBarTittle!,
                          thumbnail: widget.thumbnail!,
                          fileUrl: widget.fileUrl!,
                          screenType: MyConstants.training,
                          fileType: widget.fileType!))),
            ),
            title: Text(widget.appBarTittle!),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
          ),
          body: widget.fileType == MyConstants.link
              ? WebView(
                  initialUrl: widget.fileUrl!,
                  debuggingEnabled: true,
                  javascriptMode: JavascriptMode.unrestricted,
                )
              : null,
        ),
      ),
    );
  }
}
