import 'package:flutter/material.dart';

import '../../network/db/app_database.dart';
import '../../network/db/consumed_spare_request_data.dart';
import '../../network/db/selected_onhand_spare.dart';
import '../../utility/shared_preferences.dart';
import '../../utility/store_strings.dart';
import '../../utility/validator.dart';
import '../submit_complete.dart';
import 'on_hand_spare.dart';
import 'spare_inventory.dart';

class ConsumedSpareListener extends StatefulWidget {
  final String? status, ticketId;

  const ConsumedSpareListener(this.status, this.ticketId, {super.key});

  @override
  _ConsumedSpareListenerState createState() => _ConsumedSpareListenerState();
}

class _ConsumedSpareListenerState extends State<ConsumedSpareListener> {
  var consumedSpareRequestData = <ConsumedSpareRequestDataTable?>[];
  bool _listVisible = false;

  Future<void> consumedSpareRequestDataList() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
    var result = await consumedSpareRequestDataDao.updateSpareCart(true);
    consumedSpareRequestData = result;
    if (consumedSpareRequestData.isNotEmpty) {
      setState(() {
        _listVisible = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    consumedSpareRequestDataList();
  }

  Future<T?> pushPage<T>(BuildContext context) {
    return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                OnHandSpare(widget.status, widget.ticketId)));
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
                              OnHandSpare(widget.status, widget.ticketId)));
                },
                icon: const Icon(Icons.arrow_back_ios_outlined)),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
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
                                child: const Text(MyConstants.selectedSpareList,
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
              Expanded(
                child: Visibility(
                    visible: _listVisible,
                    child: ListView.builder(
                        itemCount: consumedSpareRequestData.length,
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                      width: 85,
                                      height: 85,
                                      margin: const EdgeInsets.only(right: 13.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
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
                                        const Text("${MyConstants.spareCode}      :",
                                            style: TextStyle(fontSize: 13)),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: const <Widget>[
                                            Text(
                                                "${MyConstants.spareName}     :",
                                                style: TextStyle(fontSize: 13)),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: const <Widget>[
                                            Text(
                                                "${MyConstants.quantity}            :",
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
                                              consumedSpareRequestData[index]!
                                                  .spareCode,
                                              style: const TextStyle(fontSize: 13)),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                  consumedSpareRequestData[
                                                          index]!
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
                                                  "${consumedSpareRequestData[
                                                              index]!
                                                          .updateQuantity}  ${MyConstants.bar}  ${consumedSpareRequestData[
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
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
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
                                                  setState(() {
                                                    addQuantity(index);
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 14,
                                                ))),
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
                                ],
                              ),
                            ),
                          );
                        })),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, bottom: 10.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (widget.status == MyConstants.selectedOnHand) {
                            final database = await $FloorAppDatabase
                                .databaseBuilder('floor_database.db')
                                .build();
                            final consumedSpareRequestDataDao =
                                database.consumedSpareRequestDataDao;
                            final selectedOnHandSpareDao =
                                database.selectedOnHandSpareDao;
                            await selectedOnHandSpareDao
                                .deleteSelectedSpareByTicketId(
                                    true, widget.ticketId!);
                            List<ConsumedSpareRequestDataTable?>
                                consumedSpareRequestData =
                                await consumedSpareRequestDataDao
                                    .updateSpareCart(true);
                            for (var selectedOnHandSpareList
                                in consumedSpareRequestData) {

                              PreferenceUtils.setBool(MyConstants.mapKey, true);

                              SelectedOnHandSpareDataTable
                                  selectedOnHandSpareDataTable =
                                  SelectedOnHandSpareDataTable(
                                      ticketId: widget.ticketId,
                                      isSelectedSpare: true,
                                      location:
                                          selectedOnHandSpareList!.location,
                                      locationId: selectedOnHandSpareList
                                          .spareLocationId,
                                      price: selectedOnHandSpareList.price
                                          .toDouble(),
                                      quantity:
                                          selectedOnHandSpareList.updateQuantity,
                                      spareCode:
                                          selectedOnHandSpareList.spareCode,
                                      spareId: selectedOnHandSpareList.spareId,
                                      spareName:
                                          selectedOnHandSpareList.spareName);
                              selectedOnHandSpareDao
                                  .insertSpare(selectedOnHandSpareDataTable);
                            }

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SubmitComplete(
                                          ticketId: widget.ticketId,
                                          status: MyConstants.submitComplete,
                                        )));
                          } else {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SpareInventory(
                                        2, MyConstants.backButton)));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)), backgroundColor: Color(int.parse("0xfff" "5C7E7F"))),
                        child: const Text(MyConstants.submitButton,
                            style:
                                TextStyle(fontSize: 15, color: Colors.white)),
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
    final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
    var result = await consumedSpareRequestDataDao.updateSpareCart(true);
    int updateQuantity = result[index]!.updateQuantity + 1;
    int quantity = result[index]!.quantity;
    if (updateQuantity > quantity) {
      setToastMessage(context, MyConstants.maximumQuantity);
    } else {
      consumedSpareRequestDataDao.updateQuantity(
          updateQuantity, result[index]!.spareId);
    }
    consumedSpareRequestDataList();
  }

  Future<void> subtractQuantity(int index) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('floor_database.db').build();
    final consumedSpareRequestDataDao = database.consumedSpareRequestDataDao;
    var result = await consumedSpareRequestDataDao.updateSpareCart(true);
    consumedSpareRequestData = result;
    int updateQuantity = consumedSpareRequestData[index]!.updateQuantity - 1;
    if (updateQuantity < 1) {
      setToastMessage(context, MyConstants.minimumQuantity);
    } else {
      consumedSpareRequestDataDao.updateQuantity(
          updateQuantity, consumedSpareRequestData[index]!.spareId);
    }
    consumedSpareRequestDataList();
  }
}
