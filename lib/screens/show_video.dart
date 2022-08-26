import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class ShowVideo extends StatefulWidget {
  final File? video;
  final String? videoPath;

  ShowVideo({Key? key, @required this.video, @required this.videoPath})
      : super(key: key);

  @override
  _ShowVideState createState() => _ShowVideState();
}

class _ShowVideState extends State<ShowVideo> {
  VideoPlayerController? _videoPlayerController1;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1!.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    if(widget.video != null)
      _videoPlayerController1 = VideoPlayerController.file(widget.video!);
    else
      _videoPlayerController1 = VideoPlayerController.network(widget.videoPath!);
    await Future.wait([
      _videoPlayerController1!.initialize(),
    ]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1!,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        deviceOrientationsOnEnterFullScreen: [DeviceOrientation.landscapeLeft]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              backgroundColor: Color(int.parse("0xfff" + "507a7d")),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: false).pop(),
              ),
              title: Text("Show Video")),
          body: Center(
            child: _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(
                    controller: _chewieController!,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Loading'),
                    ],
                  ),
          )),
    );
  }
}
