import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ShowImage extends StatefulWidget {
  final String? image;
  final File? capturedImage;

  ShowImage({Key? key, @required this.image, @required this.capturedImage})
      : super(key: key);

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse("0xfff" + "507a7d")),
        title: Center(
          child: Text("Show Image"),
        ),
      ),
      body: Container(
        child: widget.capturedImage == null
            ? Center(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Image.network(
                  widget.image!,
                  fit: BoxFit.fill,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            )
            : Center(child: Padding(padding: EdgeInsets.all(15.0),child: Image.file(widget.capturedImage!))),
      ),
    );
  }
}
