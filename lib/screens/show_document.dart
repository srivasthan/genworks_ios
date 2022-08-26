import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../utility/store_strings.dart';

class DocumentViewer extends StatefulWidget {
  final File? selectedFile;

  const DocumentViewer(this.selectedFile);

  @override
  _DocumentViewerState createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text(MyConstants.showDocument),
        backgroundColor: Color(int.parse("0xfff" + "507a7d")),
      ),
      body: SfPdfViewer.file(widget.selectedFile!,
          controller: _pdfViewerController, key: _pdfViewerStateKey),
    ));
  }
}
