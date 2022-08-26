import 'dart:math';

import 'package:flutter/material.dart';

class CircularProgressView extends StatefulWidget {

  double progress = 0;
  CircularProgressView(this.progress);

  @override
  _CircularProgressViewState createState() => _CircularProgressViewState();
}

class _CircularProgressViewState extends State<CircularProgressView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        foregroundPainter: CircleProgressIndicator(widget.progress),
        child: Container(
          height: 80, width: 80,
          child: Center(
            child: Text( widget.progress.toInt().toString() + '%',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CircleProgressIndicator extends CustomPainter {

  double progress = 0;

  CircleProgressIndicator(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint outerCircle = Paint()
      ..strokeWidth = 10
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    Paint completeArc = Paint()
      ..strokeWidth = 10
      ..color = Color(
          int.parse("0xfff" + "3498DB"))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset offset = Offset(size.width/2, size.height/2);
    double radius = min(size.width/2, size.height/2);

    double angle = 2*pi*(progress/100);

    canvas.drawCircle(offset, radius, outerCircle);
    canvas.drawArc(Rect.fromCircle(center: offset, radius: radius), 0, angle, false, completeArc);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

}