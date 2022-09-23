import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../utility/shared_preferences.dart';
import '../utility/store_strings.dart';
import '../utility/validator.dart';
import 'amc_details.dart';
import 'dashboard.dart';
import 'knowledge_base.dart';
import 'reimbursement.dart';
import 'service_report.dart';
import 'smart_scheduling.dart';
import 'spareinventory/spare_inventory.dart';
import 'ticket_list.dart';
import 'training.dart';

class DashBoardMenu extends StatefulWidget {
  @override
  _DashBoardMenuState createState() => _DashBoardMenuState();
}

class _DashBoardMenuState extends State<DashBoardMenu> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  bool status = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          constraints:
          BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/menu_bg_drawable.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 3, right: 3, top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: SizedBox(
                            height: 40,
                            width: 40,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/user_image.png',
                                fit: BoxFit.cover,
                              ),
                            )),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              "Sumitha Nesamani",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: RatingBar.builder(
                                itemSize: 26,
                                initialRating: 3,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: FlutterSwitch(
                          activeColor: Color(int.parse("0xfff" "4a777c")),
                          value: status,
                          borderRadius: 30.0,
                          showOnOff: true,
                          onToggle: (val) {},
                        ),
                      ),
                      // new MyHomePage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color = Colors.white,
  }) : super(listenable: controller!);

  /// The PageController that this DotsIndicator is representing.
  final PageController? controller;

  /// The number of items managed by the PageController
  final int? itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int>? onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 8.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 2.0;

  // The distance between the center of each dot
  static const double _kDotSpacing = 25.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller!.page ?? controller!.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return SizedBox(
      width: _kDotSpacing,
      child: Center(
        child: Material(
          color: color,
          type: MaterialType.circle,
          child: SizedBox(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: InkWell(
              onTap: () => onPageSelected!(index),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount!, _buildDot),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String? title;
  final ImageIcon? icon;
}

const List<Choice> choices = [
  Choice(
      title: 'Home', icon: ImageIcon(AssetImage("assets/images/home.png"), color: Colors.white)),
  Choice(
      title: 'Ticket list',
      icon: ImageIcon(AssetImage("assets/images/ticket_list.png"), color: Colors.white)),
  Choice(
      title: 'Service report',
      icon: ImageIcon(AssetImage("assets/images/service_report.png"), color: Colors.white)),
  Choice(
      title: 'Spare Inventory',
      icon: ImageIcon(AssetImage("assets/images/si.png"), color: Colors.white)),
  Choice(
      title: 'Training', icon: ImageIcon(AssetImage("assets/images/training.png"), color: Colors.white)),
  Choice(
      title: 'Knowledge base',
      icon: ImageIcon(AssetImage("assets/images/knowledge_base.png"), color: Colors.white)),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key? key, required this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          PreferenceUtils.init();
          if (PreferenceUtils.getInteger(MyConstants.punchStatus) ==
              0) {
            setToastMessage(context, MyConstants.punchIn);
          } else {
            if (choice.title == MyConstants.home) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DashBoard()));
            } else if (choice.title == MyConstants.ticketList) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const TicketList(0)));
            } else if (choice.title == MyConstants.serviceReport) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ServiceReport(
                        selectedIndex: 0,
                      )));
            } else if (choice.title == MyConstants.knowledgeBase) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KnowledgeBase()));
            } else if (choice.title == MyConstants.spareInventory) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const SpareInventory(0, MyConstants.bar)));
            } else if (choice.title == MyConstants.training) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Training(
                        selectedIndex: 0,
                      )));
            } else if (choice.title == MyConstants.amcHints) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const AMC()));
            } else if (choice.title == MyConstants.reimbursement) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Reimbursement(
                          selectedIndex: 0,
                          backButton: MyConstants.empty)));
            } else if (choice.title == MyConstants.smartScheduling) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SmartScheduling()));
            }
          }
        },
        child: Column(children: [
          IconButton(
            onPressed: () {
              PreferenceUtils.init();
              if (PreferenceUtils.getInteger(
                  MyConstants.punchStatus) ==
                  0) {
                setToastMessage(context, MyConstants.punchIn);
              } else {
                if (choice.title == MyConstants.home) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashBoard()));
                } else if (choice.title == MyConstants.ticketList) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TicketList(0)));
                } else if (choice.title ==
                    MyConstants.serviceReport) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ServiceReport(
                            selectedIndex: 0,
                          )));
                } else if (choice.title ==
                    MyConstants.knowledgeBase) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => KnowledgeBase()));
                } else if (choice.title ==
                    MyConstants.spareInventory) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SpareInventory(
                              0, MyConstants.bar)));
                } else if (choice.title == MyConstants.training) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Training(
                            selectedIndex: 0,
                          )));
                } else if (choice.title == MyConstants.amcHints) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const AMC()));
                } else if (choice.title ==
                    MyConstants.reimbursement) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Reimbursement(
                              selectedIndex: 0,
                              backButton: MyConstants.empty)));
                } else if (choice.title ==
                    MyConstants.smartScheduling) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SmartScheduling()));
                }
              }
            },
            icon: SizedBox(
              height: 36,
              width: 36,
              child: choice.icon,
            ),
          ),
          Text(choice.title!,
              style: const TextStyle(fontSize: 13.0, color: Colors.white))
        ])
    );
  }
}

const List<Choice> choices1 = [
  Choice(
      title: 'Amc Contracts',
      icon: ImageIcon(AssetImage(
        "assets/images/planning.png",
      ), color: Colors.white)),
  Choice(
      title: 'Reimbursement',
      icon: ImageIcon(AssetImage("assets/images/reimbursement.png"), color: Colors.white)),
  Choice(
      title: 'Smart Scheduling',
      icon: ImageIcon(AssetImage("assets/images/schedule.png"), color: Colors.white)),
];
