import 'package:flutter/cupertino.dart';

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xff000000)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset(15, 15) & const Size(15, 15), paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}