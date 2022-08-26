// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
//
// class LineChartSample7 extends StatelessWidget {
//   List<Color> gradientColors = [
//     const Color(0xff23b6e6),
//     const Color(0xff02d39a),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 190 / 150,
//       child: Padding(
//         padding: EdgeInsets.only(left: 28, right: 18),
//         child: LineChart(
//           LineChartData(
//             lineBarsData: [
//               LineChartBarData(
//                 spots: [
//                   FlSpot(1, 10),
//                   // FlSpot(2, 0),
//                   FlSpot(3, 60),
//                   // FlSpot(4, 40),
//                   FlSpot(5, 50),
//                   // FlSpot(6, 36),
//                   FlSpot(7, 70),
//                   // FlSpot(8, 80),
//                   FlSpot(9, 90),
//                   // FlSpot(10, 100),
//                   FlSpot(11, 110),
//                   // FlSpot(12, 120),
//                   FlSpot(13, 130),
//                 ],
//                 isCurved: true,
//                 belowBarData: BarAreaData(show: true, colors: [
//                   ColorTween(begin: gradientColors[0], end: gradientColors[1])
//                       .lerp(0.2)!
//                       .withOpacity(0.1),
//                   ColorTween(begin: gradientColors[0], end: gradientColors[1])
//                       .lerp(0.2)!
//                       .withOpacity(0.1),
//                 ]),
//                 barWidth: 1,
//                 colors: [
//                   Colors.black,
//                 ],
//               ),
//             ],
//             minY: 0,
//             titlesData: FlTitlesData(
//               bottomTitles: SideTitles(
//                   showTitles: true,
//                   interval: 2,
//                   getTextStyles: (context, value) => const TextStyle(
//                       fontSize: 10,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold),
//                   getTitles: (value) {
//                     switch (value.toInt()) {
//                       case 0:
//                         return '-1';
//                       case 1:
//                         return '';
//                       case 2:
//                         return '1';
//                       case 3:
//                         return '2';
//                       case 4:
//                         return '3';
//                       case 5:
//                         return '4';
//                       case 6:
//                         return '5';
//                       case 7:
//                         return '6';
//                       case 8:
//                         return '7';
//                       case 9:
//                         return '8';
//                       case 10:
//                         return '9';
//                       case 11:
//                         return '10';
//                       case 12:
//                         return '11';
//                       case 13:
//                         return '12';
//                       default:
//                         return '';
//                     }
//                   }),
//               topTitles: SideTitles(
//                   showTitles: true,
//                   interval: 2,
//                   getTextStyles: (context, value) => const TextStyle(
//                       fontSize: 10,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold),
//                   getTitles: (value) {
//                     switch (value.toInt()) {
//                       case 0:
//                         return '-1';
//                       case 1:
//                         return '';
//                       case 2:
//                         return '1';
//                       case 3:
//                         return '2';
//                       case 4:
//                         return '3';
//                       case 5:
//                         return '4';
//                       case 6:
//                         return '5';
//                       case 7:
//                         return '6';
//                       case 8:
//                         return '7';
//                       case 9:
//                         return '8';
//                       case 10:
//                         return '9';
//                       case 11:
//                         return '10';
//                       case 12:
//                         return '11';
//                       case 13:
//                         return '12';
//                       case 14:
//                         return '13';
//                       case 15:
//                         return '14';
//                       default:
//                         return '';
//                     }
//                   }),
//             ),
//             gridData: FlGridData(
//                 show: true, drawVerticalLine: true, drawHorizontalLine: true),
//           ),
//         ),
//       ),
//     );
//   }
// }
