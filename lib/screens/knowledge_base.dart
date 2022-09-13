import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as pl;
import 'package:dio/dio.dart' as dio;
import 'package:path/path.dart' as path;
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_compress/video_compress.dart';

import '../network/api_services.dart';
import '../network/model/kb_subproduct_model.dart';
import '../network/model/product.dart';
import '../network/model/refer_solution_model.dart';
import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/technician_punch.dart';
import '../utility/validator.dart';
import 'dashboard.dart';
import 'file_directory.dart';
import 'show_image.dart';
import 'show_video.dart';

class KnowledgeBase extends StatefulWidget {
  @override
  _KnowledgeState createState() => _KnowledgeState();
}

class _KnowledgeState extends State<KnowledgeBase> {
  final formKey = GlobalKey<FormState>();
  late bool _isLoading = true,
      _isReferSolutionList = true,
      _noDataAvailable = false,
      _referSolutionView = false,
      _enterSolutionFragment = false,
      _referSolutionFragment = false,
      _es_productVisible = false,
      _rs_productVisisble = false;
  ProductModel? _es_productModel, _rs_productModel;
  KBSubProductModel? _kb_es_SubProductModel, _kb_rs_SubProductModel;
  int? count = 0;
  String? _es_selectedDropdownValue,
      _rs_selectedDropdownValue,
      _es_productId,
      _rs_productId,
      _es_productSubId,
      _rs_productSubId;
  double? latitude, longitude;
  List<ProductModel> productList = <ProductModel>[];
  List<KBSubProductModel> subProductList = <KBSubProductModel>[];
  final _referSolutionList = <ReferSolutionModel>[];
  bool _showTick = false, _showVideoTick = false;
  String? _videoPath;
  bool _rs_showImageTick = false, _rs_showVideoTick = false;
  File? image,
      capturedImage,
      signatureImage,
      _capturedVideo,
      _convertedVideo,
      _showVideo;
  pl.Location location = pl.Location();
  final TextEditingController _problemDescription = TextEditingController();
  final TextEditingController _enterSolution = TextEditingController();
  final TextEditingController _rs_problemDescription = TextEditingController();
  final TextEditingController _rs_subProductController = TextEditingController();
  final TextEditingController _rs_bs_problemDescription = TextEditingController();
  final TextEditingController _rs_SolutionController = TextEditingController();
  final Map<int, Widget> _children = {
    0: const Padding(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      child: Text(
        "Enter Solution",
        style: TextStyle(fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    ),
    1: const Padding(
      padding: EdgeInsets.only(left: 5.0, right: 10.0),
      child: Text(
        "Refer Solution",
        style: TextStyle(fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
    ),
  };
  int _currentSelection = 0;

  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    getProductDetails();
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
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashBoard())),
          ),
          title: const Text(MyConstants.knowledgeBase),
          backgroundColor: Color(int.parse("0xfff" "507a7d")),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: MaterialSegmentedControl(
                children: _children,
                selectionIndex: _currentSelection,
                borderColor: Colors.grey,
                selectedColor: Color(int.parse("0xfff" "507a7d")),
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
                        _enterSolutionFragment = true;
                        _referSolutionFragment = false;
                        _es_selectedDropdownValue = null;
                        _es_productVisible = false;
                        _es_productModel = null;
                        _kb_es_SubProductModel = null;
                        _showVideo = null;
                        getProductDetails();
                      } else if (index == 1) {
                        _rs_selectedDropdownValue = null;
                        _rs_productVisisble = false;
                        _rs_problemDescription.value =
                            TextEditingValue.empty;
                        _referSolutionView = false;
                        _referSolutionFragment = true;
                        _enterSolutionFragment = false;
                        count = 0;
                        _es_productModel = null;
                        _rs_productModel = null;
                        _kb_es_SubProductModel = null;
                        _kb_rs_SubProductModel = null;
                        _problemDescription.text = MyConstants.empty;
                        _enterSolution.text = MyConstants.empty;
                        _showTick = false;
                        _showVideoTick = false;
                        _showVideo = null;
                        getProductDetails();
                      }
                    }
                  });
                },
              ),
            ),
                ),
              ]),
            Visibility(
                visible: _enterSolutionFragment, child: enterSolution(context)),
            const SizedBox(
              height: 10.0,
            ),
            Visibility(
                visible: _referSolutionFragment, child: referSolution(context)),
            const SizedBox(
              height: 10.0,
            ),
          ]),
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
                      if (PreferenceUtils.getInteger(MyConstants.punchStatus) ==
                          1) {
                        dashBoardBottomSheet(context, true);
                      } else {
                        dashBoardBottomSheet(context, false);
                      }
                    },
                  )
                : null,
      ),
    );
  }

  Widget enterSolution(BuildContext context) {
    return _isLoading == true
        ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[400]!,
            child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Problem Description',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Expanded(
                      flex: 0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select knowledge type",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Select Knowledge type',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Expanded(
                      flex: 0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select product category",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Select product category',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Expanded(
                      flex: 0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select sub product category",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Select sub product category',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Enter Solution',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                        flex: 0,
                        child: Row(
                          children: [
                            const Padding(padding: EdgeInsets.all(5.0)),
                            Expanded(
                              flex: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(MyConstants.attachment,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return imageBottomSheet(context);
                                            });
                                      },
                                      child: const Text(MyConstants.attachmentString,
                                          style: TextStyle(
                                              color: Colors.lightBlue,
                                              fontSize: 15)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return imageBottomSheet(context);
                                      });
                                },
                                icon: Image.asset(
                                  'assets/images/photo.png',
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Visibility(
                                visible: _showTick,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ShowImage(
                                                image: "",
                                                capturedImage: capturedImage)));
                                  },
                                  icon: Image.asset(
                                    'assets/images/check.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                    Expanded(
                        flex: 0,
                        child: Row(
                          children: [
                            const Padding(padding: EdgeInsets.all(5.0)),
                            Expanded(
                              flex: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(MyConstants.video,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: const Text(MyConstants.attachmentString,
                                          style: TextStyle(
                                              color: Colors.lightBlue,
                                              fontSize: 15)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: IconButton(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/images/photo.png',
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Visibility(
                                visible: _showVideoTick,
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Image.asset(
                                    'assets/images/check.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      flex: 0,
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                            child: const Text('SUBMIT',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                )))
        : Container(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Expanded(
                  flex: 0,
                  child: TextFormField(
                    autofocus: false,
                    validator: (value) => value!.isEmpty
                        ? 'Please enter problem description'
                        : null,
                    controller: _problemDescription,
                    decoration: const InputDecoration(
                      labelText: 'Problem Description',
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Expanded(
                  flex: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select knowledge type",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    height: 50,
                    color: Color(int.parse("0xfff" "778899")),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        contentPadding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                      ),
                      child: DropdownButtonFormField<String?>(
                        isExpanded: true,
                        iconEnabledColor: Colors.white,
                        dropdownColor: Color(int.parse("0xfff" "778899")),
                        value: _es_selectedDropdownValue,
                        hint: const Text(
                          "Select knowledge type",
                          style: TextStyle(color: Colors.white),
                        ),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(int.parse("0xfff" "778899")))),
                          contentPadding: const EdgeInsets.all(5),
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            _es_selectedDropdownValue = value!;
                            if (value == MyConstants.product) {
                              _es_productVisible = true;
                            } else {
                              _es_productVisible = false;
                              _es_productModel = null;
                              _kb_es_SubProductModel = null;
                            }
                          });
                        },
                        items: <String?>[
                          MyConstants.product,
                          MyConstants.generic,
                          MyConstants.technology
                        ].map((String? value) {
                          return DropdownMenuItem<String?>(
                            value: value,
                            child: Text(
                              value!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: _es_productVisible,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Expanded(
                          flex: 0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Select product category",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Expanded(
                          flex: 0,
                          child: Container(
                            height: 50,
                            color: Color(int.parse("0xfff" "778899")),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              ),
                              child: DropdownButtonFormField<ProductModel>(
                                isExpanded: true,
                                menuMaxHeight:
                                    MediaQuery.of(context).size.height / 3,
                                value: _es_productModel,
                                iconEnabledColor: Colors.white,
                                dropdownColor:
                                    Color(int.parse("0xfff" "778899")),
                                hint: const Text(
                                  "Select product category",
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              int.parse("0xfff" "778899")))),
                                  contentPadding: const EdgeInsets.all(5),
                                ),
                                onChanged: (ProductModel? data) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    _es_productModel = data;
                                    _es_productId = data!.productId.toString();
                                    _kb_es_SubProductModel = null;
                                    getSubProductDetails(data.productId);
                                  });
                                },
                                items: productList.map((ProductModel value) {
                                  return DropdownMenuItem<ProductModel>(
                                    value: value,
                                    child: Text(
                                      value.productName!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Visibility(
                    visible: _es_productVisible,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Expanded(
                          flex: 0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Select sub product category",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Expanded(
                          flex: 0,
                          child: Container(
                            height: 50,
                            color: Color(int.parse("0xfff" "778899")),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              ),
                              child:
                                  DropdownButtonFormField<KBSubProductModel?>(
                                isExpanded: true,
                                menuMaxHeight:
                                    MediaQuery.of(context).size.height / 3,
                                value: _kb_es_SubProductModel,
                                iconEnabledColor: Colors.white,
                                dropdownColor:
                                    Color(int.parse("0xfff" "778899")),
                                hint: const Text(
                                  "Select sub product category",
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              int.parse("0xfff" "778899")))),
                                ),
                                onChanged: (KBSubProductModel? data) {
                                  setState(() {
                                    _kb_es_SubProductModel = data;
                                    _es_productSubId =
                                        data!.productSubId.toString();
                                  });
                                },
                                items: subProductList
                                    .map((KBSubProductModel? value) {
                                  return DropdownMenuItem<KBSubProductModel?>(
                                    value: value,
                                    child: Text(
                                      value!.productSubName!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  flex: 0,
                  child: TextFormField(
                    autofocus: false,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter solution' : null,
                    controller: _enterSolution,
                    decoration: const InputDecoration(
                      labelText: 'Enter Solution',
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(
                    flex: 0,
                    child: Row(
                      children: [
                        const Padding(padding: EdgeInsets.all(5.0)),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const <Widget>[
                              Text(MyConstants.attachment,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return imageBottomSheet(context);
                                        });
                                  },
                                  child: const Text(MyConstants.attachmentString,
                                      style: TextStyle(
                                          color: Colors.lightBlue,
                                          fontSize: 15)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return imageBottomSheet(context);
                                  });
                            },
                            icon: Image.asset(
                              'assets/images/photo.png',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Visibility(
                            visible: _showTick,
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ShowImage(
                                            image: "",
                                            capturedImage: capturedImage)));
                              },
                              icon: Image.asset(
                                'assets/images/check.png',
                                width: 25,
                                height: 25,
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
                Expanded(
                    flex: 0,
                    child: Row(
                      children: [
                        const Padding(padding: EdgeInsets.all(5.0)),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const <Widget>[
                              Text(MyConstants.video,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: GestureDetector(
                                  onTap: () => captureVideo(),
                                  child: const Text(MyConstants.attachmentString,
                                      style: TextStyle(
                                          color: Colors.lightBlue,
                                          fontSize: 15)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: IconButton(
                            onPressed: () => captureVideo(),
                            icon: Image.asset(
                              'assets/images/photo.png',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Visibility(
                            visible: _showVideoTick,
                            child: IconButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowVideo(
                                            video: _showVideo,
                                            videoPath: MyConstants.empty,
                                          ))),
                              icon: Image.asset(
                                'assets/images/check.png',
                                width: 25,
                                height: 25,
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  flex: 0,
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () => submitKnowledgeBaseEnterSolution(),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                        child: const Text('SUBMIT',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  Widget referSolution(BuildContext context) {
    return _isLoading == true
        ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[400]!,
            child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Problem Description',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Expanded(
                      flex: 0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select knowledge type",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Select Knowledge type',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Expanded(
                      flex: 0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select product category",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Select product category',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Expanded(
                      flex: 0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select sub product category",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Select sub product category',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Expanded(
                      flex: 0,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Enter Solution',
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                        flex: 0,
                        child: Row(
                          children: [
                            const Padding(padding: EdgeInsets.all(5.0)),
                            Expanded(
                              flex: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(MyConstants.attachment,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return imageBottomSheet(context);
                                            });
                                      },
                                      child: const Text(MyConstants.attachmentString,
                                          style: TextStyle(
                                              color: Colors.lightBlue,
                                              fontSize: 15)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return imageBottomSheet(context);
                                      });
                                },
                                icon: Image.asset(
                                  'assets/images/photo.png',
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Visibility(
                                visible: _showTick,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ShowImage(
                                                image: "",
                                                capturedImage: capturedImage)));
                                  },
                                  icon: Image.asset(
                                    'assets/images/check.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                    Expanded(
                        flex: 0,
                        child: Row(
                          children: [
                            const Padding(padding: EdgeInsets.all(5.0)),
                            Expanded(
                              flex: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text(MyConstants.video,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: const Text(MyConstants.attachmentString,
                                          style: TextStyle(
                                              color: Colors.lightBlue,
                                              fontSize: 15)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: IconButton(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/images/photo.png',
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Visibility(
                                visible: _showVideoTick,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (MyConstants.videoPath !=
                                          MyConstants.clear) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ShowVideo(
                                                      video: capturedImage,
                                                      videoPath:
                                                          MyConstants.empty,
                                                    )));
                                      } else {
                                        setToastMessage(
                                            context, MyConstants.videoError);
                                      }
                                    });
                                  },
                                  icon: Image.asset(
                                    'assets/images/check.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      flex: 0,
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                            child: const Text('SUBMIT',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                )))
        : Container(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
            child: Column(
              children: [
                const Expanded(
                  flex: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select knowledge type",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    height: 48,
                    color: Color(int.parse("0xfff" "778899")),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        contentPadding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      ),
                      child: DropdownButtonFormField<String?>(
                        isExpanded: true,
                        iconEnabledColor: Colors.white,
                        dropdownColor: Color(int.parse("0xfff" "778899")),
                        value: _rs_selectedDropdownValue,
                        hint: const Text(
                          "Select knowledge type",
                          style: TextStyle(color: Colors.white),
                        ),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(int.parse("0xfff" "778899")))),
                          contentPadding: const EdgeInsets.all(5),
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            _rs_selectedDropdownValue = value!;
                            if (value == MyConstants.product) {
                              _rs_productVisisble = true;
                            } else {
                              _rs_productVisisble = false;
                              _rs_productModel = null;
                              _kb_rs_SubProductModel = null;
                              _rs_problemDescription.value =
                                  TextEditingValue.empty;
                              _referSolutionView = false;
                            }
                          });
                        },
                        items: <String?>[
                          MyConstants.product,
                          MyConstants.generic,
                          MyConstants.technology
                        ].map((String? value) {
                          return DropdownMenuItem<String?>(
                            value: value,
                            child: Text(
                              value!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: _rs_productVisisble,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Expanded(
                          flex: 0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Select product category",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Expanded(
                          flex: 0,
                          child: Container(
                            height: 48,
                            color: Color(int.parse("0xfff" "778899")),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              ),
                              child: DropdownButtonFormField<ProductModel>(
                                isExpanded: true,
                                value: _rs_productModel,
                                iconEnabledColor: Colors.white,
                                dropdownColor:
                                    Color(int.parse("0xfff" "778899")),
                                hint: const Text(
                                  "Select product category",
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              int.parse("0xfff" "778899")))),
                                  contentPadding: const EdgeInsets.all(5),
                                ),
                                onChanged: (ProductModel? data) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    _rs_productModel = data;
                                    _rs_productId = data!.productId.toString();
                                    _kb_rs_SubProductModel = null;
                                    getSubProductDetails(data.productId);
                                  });
                                },
                                items: productList.map((ProductModel value) {
                                  return DropdownMenuItem<ProductModel>(
                                    value: value,
                                    child: Text(
                                      value.productName!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Visibility(
                    visible: _rs_productVisisble,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Expanded(
                          flex: 0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Select sub product category",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Expanded(
                          flex: 0,
                          child: Container(
                            height: 48,
                            color: Color(int.parse("0xfff" "778899")),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                contentPadding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              ),
                              child:
                                  DropdownButtonFormField<KBSubProductModel?>(
                                isExpanded: true,
                                value: _kb_rs_SubProductModel,
                                iconEnabledColor: Colors.white,
                                dropdownColor:
                                    Color(int.parse("0xfff" "778899")),
                                hint: const Text(
                                  "Select sub product category",
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              int.parse("0xfff" "778899")))),
                                ),
                                onChanged: (KBSubProductModel? data) {
                                  setState(() {
                                    _kb_rs_SubProductModel = data;
                                    _rs_productSubId =
                                        data!.productSubId.toString();
                                  });
                                },
                                items: subProductList
                                    .map((KBSubProductModel? value) {
                                  return DropdownMenuItem<KBSubProductModel?>(
                                    value: value,
                                    child: Text(
                                      value!.productSubName!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  flex: 0,
                  child: Row(children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _rs_problemDescription,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                            labelText: MyConstants.search,
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder()),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: ElevatedButton(
                          onPressed: () => submitKnowledgeBaseReferSolution(),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "2a9d8f"))),
                          child: const Text(MyConstants.submitButton,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white)),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Visibility(
                    visible: _referSolutionView, child: referSolutionList())
              ],
            ));
  }

  Future<void> captureImage(String? option) async {
    XFile? photo;

    if (Platform.isAndroid) {
      PermissionStatus? status;

      if (option == MyConstants.camera) {
        status = await Permission.camera.request();
      } else if (option == MyConstants.gallery) {
        status = await Permission.storage.request();
      }

      if (status == PermissionStatus.granted) {
        Future.delayed(const Duration(seconds: 1), () {
          showImageDialog(context);
        });

        if (option == MyConstants.camera) {
          photo = await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 50);
        } else if (option == MyConstants.gallery) {
          photo = await ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 50);
        }

        if (photo != null) {
          setState(() {
            image = File(photo!.path);
          });
          final FileDirectory fileDirectory =
              FileDirectory(context, MyConstants.imageFolder);
          Directory? getDirectory;
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

          if (androidInfo.version.sdkInt >=
              int.parse(MyConstants.osVersion)) {
            capturedImage = File(photo.path);
          } else {
            fileDirectory.createFolder().then((value) async {
              getDirectory = value;
              if (!await getDirectory!.exists()) {
                await getDirectory!.create(recursive: true);
                capturedImage = await image!
                    .copy('${getDirectory!.path}/${timestamp()}.png');
              } else {
                capturedImage = await image!
                    .copy('${getDirectory!.path}/${timestamp()}.png');
              }
            });
          }
        } else {
          Navigator.of(context).pop();
          if (option == MyConstants.camera) {
            setToastMessage(context, MyConstants.captureImageError);
          } else {
            setToastMessage(context, MyConstants.selectImageError);
          }
        }
      }
      else if (status == PermissionStatus.denied) {
        captureImage(option);
      }
      else if (status == PermissionStatus.permanentlyDenied) {
        openAppSettings();
      }
    } else if (Platform.isIOS) {
      PermissionStatus? status;

      if (option == MyConstants.camera) {
        status = await Permission.camera.request();
      } else if (option == MyConstants.gallery) {
        status = await Permission.storage.request();
      }
      Directory? directory = await getApplicationSupportDirectory();

      if (status == PermissionStatus.granted) {
        Future.delayed(const Duration(seconds: 1), () {
          showImageDialog(context);
        });

        if (option == MyConstants.camera) {
          photo = await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 50);
        } else if (option == MyConstants.gallery) {
          photo = await ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 50);
        }

        if (photo != null) {
          setState(() {
            image = File(photo!.path);
          });

          capturedImage =
              await image!.copy('${directory.path}/${timestamp()}.png');
        } else {
          Navigator.of(context).pop();
          if (option == MyConstants.camera) {
            setToastMessage(context, MyConstants.captureImageError);
          } else {
            setToastMessage(context, MyConstants.selectImageError);
          }
        }
      } else if (status == PermissionStatus.denied) {
        captureImage(option);
      } else if (status == PermissionStatus.permanentlyDenied) {
        openAppSettings();
      }
    }

    setState(() {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: false).pop();
        _showTick = true;
        if(photo != null) {
          Navigator.of(context).pop();
        }
        FocusScope.of(context).requestFocus(FocusNode());
      });
    });
  }

  Future<void> captureVideo() async {
    MediaInfo? info;
    var photo = await ImagePicker().pickVideo(
        preferredCameraDevice: CameraDevice.rear,
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 1));

    if (photo != null) {
      setState(() {
        _capturedVideo = File(photo.path);
      });

      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        final FileDirectory fileDirectory =
            FileDirectory(context, MyConstants.imageFolder);
        Directory? getDirectory;

        await _requestPermission(Permission.storage);

        if (androidInfo.version.sdkInt >=
            int.parse(MyConstants.osVersion)) {
          showVideoDialog(context);

          _convertedVideo = File(photo.path);

          _videoPath = _convertedVideo!.path;

          info = await VideoCompress.compressVideo(
            _videoPath!,
            quality: VideoQuality.LowQuality,
            deleteOrigin: false, // default(false)
          );

          _showVideo = await File(info!.path!).copy(_videoPath!);
          Navigator.of(context, rootNavigator: true).pop();

          setState(() {
            _showVideoTick = true;
            FocusScope.of(context).requestFocus(FocusNode());
          });
        } else {
          fileDirectory.createFolder().then((value) async {
            getDirectory = value;
            if (!await getDirectory!.exists()) {
              await getDirectory!.create(recursive: true);
            }

            showVideoDialog(context);

            _convertedVideo = await _capturedVideo!
                .copy('${getDirectory!.path}/${timestamp()}.mp4');
            _videoPath = _convertedVideo!.path;

            info = await VideoCompress.compressVideo(
              _videoPath!,
              quality: VideoQuality.LowQuality,
              deleteOrigin: false, // default(false)
            );

            _showVideo = await File(info!.path!).copy(_videoPath!);
            Navigator.of(context, rootNavigator: true).pop();

            setState(() {
              _showVideoTick = true;
              FocusScope.of(context).requestFocus(FocusNode());
            });
          });
        }
      } else if (Platform.isIOS) {
        Directory? directory = await getTemporaryDirectory();

        if (await _requestPermission(Permission.photos)) {
          showVideoDialog(context);

          _convertedVideo = await _capturedVideo!
              .copy('${directory.path}/${timestamp()}.mp4');
          _videoPath = _convertedVideo!.path;

          info = await VideoCompress.compressVideo(
            _videoPath!,
            quality: VideoQuality.LowQuality,
            deleteOrigin: false, // default(false)
          );

          _showVideo = await File(info!.path!).copy(_videoPath!);
          Navigator.of(context, rootNavigator: true).pop();

          setState(() {
            _showVideoTick = true;
            FocusScope.of(context).requestFocus(FocusNode());
          });
        }
      }

      PreferenceUtils.setString(MyConstants.videoPath, _showVideo!.path);
    } else {
      setToastMessage(context, MyConstants.videoError);
    }
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

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Widget imageBottomSheet(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(children: [
        Container(
            height: 40,
            decoration: BoxDecoration(
                color: Color(int.parse("0xfff" "5C7E7F")),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0))),
            child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      MyConstants.imageBottomSheetOption,
                      style: TextStyle(color: Colors.white),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.white,
                        ))
                  ],
                ))),
        SizedBox(
          height: 65,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: IconButton(
                              onPressed: () => captureImage(MyConstants.camera),
                              icon: const Icon(Icons.camera))),
                      const Text(MyConstants.camera, style: TextStyle(fontSize: 15))
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 50,
              ),
              Center(
                child: Column(
                  children: [
                    Expanded(
                        child: IconButton(
                            onPressed: () => captureImage(MyConstants.gallery),
                            icon: const Icon(Icons.photo))),
                    const Text(MyConstants.gallery, style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  void getProductDetails() async {
    var status = await Permission.storage.request();

    if (status == PermissionStatus.granted) {
      setState(() {
        _isLoading = true;
        if (count == 0) {
          count = count! + 1;
        } else {
          _es_productModel = null;
          _rs_productModel = null;
          _kb_es_SubProductModel = null;
          _kb_rs_SubProductModel = null;
          _problemDescription.text = MyConstants.empty;
          _enterSolution.text = MyConstants.empty;
          _showTick = false;
          _showVideoTick = false;
          PreferenceUtils.setString(
              MyConstants.technicianStatus, MyConstants.free);
        }
        productList.clear();
        if (_currentSelection == 0) {
          _enterSolutionFragment = true;
        } else {
          _referSolutionFragment = true;
        }
      });
      if (await checkInternetConnection() == true) {
        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.getProducts();
        if (response.productEntity!.responseCode == MyConstants.response200) {
          setState(() {
            for (int i = 0; i < response.productEntity!.data!.length; i++) {
              productList.add(ProductModel(
                  productId: response.productEntity!.data![i]!.productId,
                  productName: response.productEntity!.data![i]!.productName,
                  productImage: response.productEntity!.data![i]!.productImage,
                  productDescription:
                  response.productEntity!.data![i]!.productDescription,
                  productModel: response.productEntity!.data![i]!.productModel));
            }
            _isLoading = !_isLoading;
          });
        } else if (response.productEntity!.responseCode ==
            MyConstants.response400 ||
            response.productEntity!.responseCode == MyConstants.response500) {
          setState(() {
            _isLoading = !_isLoading;
          });
        }
      } else {
        setToastMessage(context, MyConstants.internetConnection);
      }
    }
    else if (status == PermissionStatus.denied) {
      getProductDetails();
    }
    else if (status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  void getSubProductDetails(int? productId) async {
    if (await checkInternetConnection() == true) {
      subProductList.clear();

      showAlertDialog(context);

      ApiService apiService = ApiService(dio.Dio());
      final response =
          await apiService.getKnowledgeBaseSubProductList(productId);
      if (response.kBSubProductEntity!.responseCode ==
          MyConstants.response200) {
        setState(() {
          for (int i = 0; i < response.kBSubProductEntity!.data!.length; i++) {
            subProductList.add(KBSubProductModel(
                productId: response.kBSubProductEntity!.data![i]!.productId,
                productName: response.kBSubProductEntity!.data![i]!.productName,
                productSubId:
                    response.kBSubProductEntity!.data![i]!.productSubId,
                productSubDescription: response
                    .kBSubProductEntity!.data![i]!.productSubDescription,
                productSubName:
                    response.kBSubProductEntity!.data![i]!.productSubName,
                productSubModel:
                    response.kBSubProductEntity!.data![i]!.productSubModel));
          }
          Navigator.of(context, rootNavigator: true).pop();
        });
      } else if (response.kBSubProductEntity!.responseCode ==
              MyConstants.response400 ||
          response.kBSubProductEntity!.responseCode ==
              MyConstants.response500) {
        setState(() {
          Navigator.of(context, rootNavigator: true).pop();
        });
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  bool? validation() {
    bool? validate = true;

    if (_problemDescription.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.problemDescriptionError);
    } else if (_es_selectedDropdownValue == null) {
      validate = false;
      setToastMessage(context, MyConstants.knowledgeTypeError);
    } else if (_enterSolution.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.enterSolutionError);
    } else if (_es_productVisible == true) {
      if (_es_productModel == null) {
        validate = false;
        setToastMessage(context, MyConstants.productError);
      } else if (_kb_es_SubProductModel == null) {
        validate = false;
        setToastMessage(context, MyConstants.subProductError);
      }
    }

    return validate;
  }

  void submitKnowledgeBaseEnterSolution() async {
    if (await checkInternetConnection() == true) {
      if (validation()!) {
        FocusScope.of(context).requestFocus(FocusNode());

        showAlertDialog(context); //setting loader

        //convert data to form data
        dio.FormData enterSolutionData = dio.FormData.fromMap({
          "technician_code":
              PreferenceUtils.getString(MyConstants.technicianCode),
          "knowledge_type": _es_selectedDropdownValue,
          "problem_desc": _problemDescription.text.trim(),
          "product_id":
              _es_productVisible == true ? _es_productId : MyConstants.empty,
          "product_sub_id":
              _es_productVisible == true ? _es_productSubId : MyConstants.empty,
          "solution": _enterSolution.text.trim(),
          "upload_image": capturedImage != null
              ? await dio.MultipartFile.fromFile(capturedImage!.path,
                  filename: path.basename(capturedImage!.path))
              : "",
          "upload_video": _showVideo != null
              ? await dio.MultipartFile.fromFile(_showVideo!.path,
                  filename: path.basename(_showVideo!.path))
              : "",
        });

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.enterSolution(
            PreferenceUtils.getString(MyConstants.token), enterSolutionData);

        if (response.addTransferEntity != null) {
          if (response.addTransferEntity!.responseCode ==
              MyConstants.response200) {
            if (capturedImage != null) {
              if (await capturedImage!.exists()) await capturedImage!.delete();
            }
            if (PreferenceUtils.getString(MyConstants.videoPath) !=
                MyConstants.clear) {
              if (await File(PreferenceUtils.getString(MyConstants.videoPath))
                  .exists()) {
                await File(PreferenceUtils.getString(MyConstants.videoPath))
                    .delete();
              }
            }

            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              PreferenceUtils.setString(
                  MyConstants.token, response.addTransferEntity!.token!);
              setToastMessage(context, response.addTransferEntity!.message!);
              PreferenceUtils.setString(
                  MyConstants.videoPath, MyConstants.clear);

              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DashBoard()));
              });
            });
          } else if (response.addTransferEntity!.responseCode ==
              MyConstants.response400) {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              PreferenceUtils.setString(
                  MyConstants.token, response.addTransferEntity!.token!);
              setToastMessage(context, response.addTransferEntity!.message!);
            });
          } else if (response.addTransferEntity!.responseCode ==
              MyConstants.response500) {
            Navigator.of(context, rootNavigator: true).pop();
            setToastMessage(context, response.addTransferEntity!.message!);
          }
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          setToastMessage(context, MyConstants.internalServerError);
        }
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  bool? referSolutionValidation() {
    bool? validate = true;

    if (_rs_selectedDropdownValue == null) {
      validate = false;
      setToastMessage(context, MyConstants.knowledgeTypeError);
    } else if (_rs_productVisisble == true) {
      if (_rs_productModel == null) {
        validate = false;
        setToastMessage(context, MyConstants.productError);
      } else if (_kb_rs_SubProductModel == null) {
        validate = false;
        setToastMessage(context, MyConstants.subProductError);
      }
    } else if (_rs_problemDescription.text.trim().isEmpty) {
      validate = false;
      setToastMessage(context, MyConstants.problemDescriptionError);
    }

    return validate;
  }

  void submitKnowledgeBaseReferSolution() async {
    if (await checkInternetConnection() == true) {
      if (referSolutionValidation()!) {
        setState(() {
          _isReferSolutionList = true;
          _noDataAvailable = false;
          _referSolutionList.clear();
        });

        FocusScope.of(context).requestFocus(FocusNode());

        //convert data to form data
        Map<String, dynamic> referSolutionData = {
          "technician_code":
              PreferenceUtils.getString(MyConstants.technicianCode),
          "problem_desc": _rs_problemDescription.text.trim(),
          "product_id": _rs_productVisisble == true
              ? _rs_productId
              : MyConstants.chargeable,
          "product_sub_id": _rs_productVisisble == true
              ? _rs_productSubId
              : MyConstants.chargeable
        };

        ApiService apiService = ApiService(dio.Dio());
        final response = await apiService.referKnowledgeBaseSolution(
            PreferenceUtils.getString(MyConstants.token), referSolutionData);

        if (response.referSolutionEntity != null) {
          if (response.referSolutionEntity!.responseCode ==
              MyConstants.response200) {
            setState(() {
              PreferenceUtils.setString(
                  MyConstants.token, response.referSolutionEntity!.token!);

              for (int i = 0;
                  i < response.referSolutionEntity!.data!.length;
                  i++) {
                _referSolutionList.add(ReferSolutionModel(
                    category: response.referSolutionEntity!.data![i]!.category,
                    problemDesc:
                        response.referSolutionEntity!.data![i]!.problemDesc,
                    productCategory:
                        response.referSolutionEntity!.data![i]!.productCategory,
                    solution: response.referSolutionEntity!.data![i]!.solution,
                    uploadImage:
                        response.referSolutionEntity!.data![i]!.uploadImage,
                    uploadVideo:
                        response.referSolutionEntity!.data![i]!.uploadVideo));
              }

              _isReferSolutionList = !_isReferSolutionList;
              _referSolutionView = true;
            });
          } else if (response.referSolutionEntity!.responseCode ==
              MyConstants.response400) {
            setState(() {
              _isReferSolutionList = !_isReferSolutionList;
              PreferenceUtils.setString(
                  MyConstants.token, response.referSolutionEntity!.token!);
              _noDataAvailable = true;
              _referSolutionView = false;
            });
          } else if (response.referSolutionEntity!.responseCode ==
              MyConstants.response500) {
            setState(() {
              _isReferSolutionList = !_isReferSolutionList;
            });
          }
        } else {
          setState(() {
            _isReferSolutionList = !_isReferSolutionList;
          });
          setToastMessage(context, MyConstants.internalServerError);
        }
      }
    } else {
      setToastMessage(context, MyConstants.internetConnection);
    }
  }

  Future<void> refreshReferSolution() async {
    await Future.delayed(const Duration(seconds: 0));
    setState(() {
      submitKnowledgeBaseReferSolution();
    });

    return;
  }

  Widget referSolutionList() {
    return RefreshIndicator(
      onRefresh: refreshReferSolution,
      child: _isReferSolutionList == true
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
          : _noDataAvailable == false
              ? ListView.builder(
                  itemCount: _referSolutionList.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  itemBuilder: (context, index) {
                    return Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return referSolutionBottomSheet(
                                      _referSolutionList[index].uploadImage ??
                                          "",
                                      _referSolutionList[index].uploadVideo ??
                                          "",
                                      _referSolutionList[index]
                                          .productCategory!,
                                      _referSolutionList[index].category!,
                                      _referSolutionList[index].problemDesc!,
                                      _referSolutionList[index].solution!);
                                });
                          },
                          child: Card(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                Container(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            children: [
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.all(5.0)),
                                              Expanded(
                                                flex: 0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const <Widget>[
                                                    Text(
                                                        "${MyConstants.product}                        :",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          left: 10.0),
                                                      child: Text(
                                                          _referSolutionList[
                                                                  index]
                                                              .productCategory!,
                                                          style: const TextStyle(
                                                              fontSize: 13)),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            children: [
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.all(5.0)),
                                              Expanded(
                                                flex: 0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const <Widget>[
                                                    Text(
                                                        "${MyConstants.subProduct}                :",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          left: 10.0),
                                                      child: Text(
                                                          _referSolutionList[
                                                                  index]
                                                              .category!,
                                                          style: const TextStyle(
                                                              fontSize: 13)),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            children: [
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.all(5.0)),
                                              Expanded(
                                                flex: 0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const <Widget>[
                                                    Text(
                                                        "${MyConstants
                                                                .problemDescription}  :",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          left: 10.0),
                                                      child: Text(
                                                          _referSolutionList[
                                                                  index]
                                                              .problemDesc!,
                                                          style: const TextStyle(
                                                              fontSize: 13)),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            children: [
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.all(5.0)),
                                              Expanded(
                                                flex: 0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const <Widget>[
                                                    Text(
                                                        "${MyConstants.solution}                       :",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          left: 10.0),
                                                      child: Text(
                                                          _referSolutionList[
                                                                  index]
                                                              .solution!,
                                                          style: const TextStyle(
                                                              fontSize: 13)),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          )
                                        ]))
                              ])),
                        ));
                  })
              : const SizedBox(
                  height: 100,
                  child: Center(child: Text(MyConstants.noDataAvailable)),
                ),
    );
  }

  Widget referSolutionBottomSheet(String? uploadImage, String? uploadVideo,
      String? product, String? subProduct, String? problem, String? solution) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
      mystate(() {
        _rs_subProductController.text = product!;
        _rs_bs_problemDescription.text = problem!;
        _rs_SolutionController.text = solution!;
        if (uploadImage != MyConstants.empty) {
          _rs_showImageTick = true;
        } else {
          _rs_showImageTick = false;
        }
        if (uploadVideo != MyConstants.empty) {
          _rs_showVideoTick = true;
        } else {
          _rs_showVideoTick = false;
        }
      });
      return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Expanded(
              flex: 0,
              child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color(int.parse("0xfff" "5C7E7F")),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0))),
                  child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            MyConstants.problemDescription,
                            style: TextStyle(color: Colors.white),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ))
                        ],
                      ))),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Expanded(
              flex: 0,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, right: 15.0, left: 15.0),
                child: TextFormField(
                  controller: _rs_subProductController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      labelText: MyConstants.subProduct,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      border: OutlineInputBorder()),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Expanded(
              flex: 0,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, right: 15.0, left: 15.0),
                child: TextFormField(
                  controller: _rs_bs_problemDescription,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      labelText: MyConstants.problemDescription,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      border: OutlineInputBorder()),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Expanded(
              flex: 0,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, right: 15.0, left: 15.0),
                child: TextFormField(
                  controller: _rs_SolutionController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      labelText: MyConstants.solution,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      border: OutlineInputBorder()),
                ),
              ),
            ),
            Expanded(
                flex: 0,
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.all(5.0)),
                    Expanded(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(MyConstants.attachment,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text(MyConstants.attachmentString,
                                style: TextStyle(
                                    color: Colors.lightBlue, fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/images/photo.png',
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Visibility(
                        visible: _rs_showImageTick,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShowImage(
                                        image: MyConstants.baseurl +
                                            uploadImage!,
                                        capturedImage: null)));
                          },
                          icon: Image.asset(
                            'assets/images/check.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                    )
                  ],
                )),
            Expanded(
                flex: 0,
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.all(5.0)),
                    Expanded(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(MyConstants.video,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(MyConstants.attachmentString,
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/images/photo.png',
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Visibility(
                        visible: _rs_showVideoTick,
                        child: IconButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShowVideo(
                                        video: null,
                                        videoPath: MyConstants.baseurl +
                                            uploadVideo!,
                                      ))),
                          icon: Image.asset(
                            'assets/images/check.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                    )
                  ],
                )),
            const SizedBox(
              height: 10.0,
            ),
          ]));
    });
  }
}
