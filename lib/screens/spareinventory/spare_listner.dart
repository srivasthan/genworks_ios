import 'package:flutter/material.dart';

import '../../network/db/app_database.dart';
import '../../network/db/spare_request_data.dart';
import '../../utility/store_strings.dart';
import '../../utility/validator.dart';
import '../field_return_material.dart';
import '../spare_request.dart';
import '../work_in_progress.dart';
import 'spare_cart.dart';
import 'spare_inventory.dart';

class SpareListener extends StatefulWidget {
  final String? status, ticketId;

  const SpareListener(this.status, this.ticketId, {super.key});

  @override
  _SpareListenerState createState() => _SpareListenerState();
}

class _SpareListenerState extends State<SpareListener> {
  var _spareCartRequestData = <SpareRequestDataTable?>[];
  bool _listVisible = false;

  Future<void> spareCartDataList() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final spareRequestDataDao = database.spareRequestDataDao;
    var result = await spareRequestDataDao.updateSpareRequestData(true);
    _spareCartRequestData = result;
    if (_spareCartRequestData.isNotEmpty) {
      setState(() {
        _listVisible = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    spareCartDataList();
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return  Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
            SpareCart(widget.status!, widget.ticketId!)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        pushPage(context);
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text(MyConstants.appName,
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color(int.parse("0xfff" "507a7d")),
            leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SpareCart(widget.status!, widget.ticketId!)));
                },
                icon: const Icon(Icons.arrow_back_ios_outlined)),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: SizedBox(
                            child: Container(
                              height: 40,
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
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0)),
                              ),
                              child: Center(
                                child: GestureDetector(
                                  child: const Text(
                                      MyConstants.selectedSpareList,
                                      style: TextStyle(
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Visibility(
                    visible: _listVisible,
                    child: ListView.builder(
                        itemCount: _spareCartRequestData.length,
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                color: Colors.white,
                              ),
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Column(children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                        width: 85,
                                        height: 85,
                                        margin: const EdgeInsets.only(right: 13.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          // _spareCartRequestData[index]!
                                          //   .spareName != null
                                          // Image.network(
                                          //   widget.image!,
                                          //   fit: BoxFit.fill,
                                          //   loadingBuilder: (BuildContext context, Widget child,
                                          //       ImageChunkEvent? loadingProgress) {
                                          //     if (loadingProgress == null) return child;
                                          //     return Center(
                                          //       child: CircularProgressIndicator(
                                          //         value: loadingProgress.expectedTotalBytes != null
                                          //             ? loadingProgress.cumulativeBytesLoaded /
                                          //             loadingProgress.expectedTotalBytes!
                                          //             : null,
                                          //       ),
                                          //     );
                                          //   },
                                          // )
                                          child: Image.asset(
                                            'assets/images/user_image.png',
                                          ),
                                        )),
                                    Expanded(
                                      flex: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text(
                                              "${MyConstants.spareCode}      :",
                                              style: TextStyle(fontSize: 13)),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: const <Widget>[
                                              Text(
                                                  "${MyConstants
                                                          .spareName}     :",
                                                  style: TextStyle(fontSize: 13)),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: const <Widget>[
                                              Text(
                                                  "${MyConstants
                                                          .quantity}            :",
                                                  style: TextStyle(fontSize: 13)),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          // mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                                _spareCartRequestData[index]!
                                                    .spareCode,
                                                style: const TextStyle(fontSize: 13)),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                    _spareCartRequestData[index]!
                                                        .spareName,
                                                    style:
                                                        const TextStyle(fontSize: 13)),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                    "${_spareCartRequestData[index]!
                                                            .updateQuantity}  ${MyConstants
                                                            .bar}  ${_spareCartRequestData[
                                                                index]!
                                                            .quantity}",
                                                    style:
                                                        const TextStyle(fontSize: 13)),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  border: Border.all(
                                                    width: 1,
                                                  )),
                                              child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      addQuantity(index);
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 14,
                                                  ))),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              border: Border.all(
                                                width: 1,
                                              )),
                                          child: IconButton(
                                              onPressed: () {
                                                subtractQuantity(index);
                                              },
                                              icon: const Icon(
                                                Icons.remove,
                                                size: 14,
                                              )))
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          );
                        })),
              ),
              Expanded(
                flex: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.status == MyConstants.complete) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FieldReturnMaterial(
                                          ticketUpdate: widget.status,
                                        )));
                          } else if (widget.status ==
                              MyConstants.spareRequest) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SpareRequest(
                                          status: widget.status,
                                        )));
                          } else if(widget.status == MyConstants.workInProgressAlert){
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WorkInProgress(
                                        widget.status!, widget.ticketId!, false)));
                          } else {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SpareInventory(1, MyConstants.backButton)));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                        child: const Text(MyConstants.submitButton,
                            style: TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addQuantity(int index) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final spareRequestDataDao = database.spareRequestDataDao;
    var result = await spareRequestDataDao.updateSpareRequestData(true);
    int updateQuantity = result[index]!.updateQuantity + 1;
    int quantity = result[index]!.quantity;
    if (updateQuantity > quantity) {
      setToastMessage(context, MyConstants.maximumQuantity);
    } else {
      spareRequestDataDao.updateQuantity(
          updateQuantity, result[index]!.spareId);
    }
    spareCartDataList();
  }

  Future<void> subtractQuantity(int index) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final spareRequestDataDao = database.spareRequestDataDao;
    var result = await spareRequestDataDao.updateSpareRequestData(true);
    _spareCartRequestData = result;
    int updateQuantity = _spareCartRequestData[index]!.updateQuantity - 1;
    if (updateQuantity < 1) {
      setToastMessage(context, MyConstants.minimumQuantity);
    } else {
      spareRequestDataDao.updateQuantity(
          updateQuantity, _spareCartRequestData[index]!.spareId);
    }
    spareCartDataList();
  }
}
