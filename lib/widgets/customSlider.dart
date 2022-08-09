// import 'dart:math';
// import 'dart:ui';
// import 'package:flutter/material.dart';
//
// /// *
// /// 自定义滑块
// class SliderPaint extends CustomPainter {
//   final double position;
//
//   SliderPaint(this.position);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (size.height - 24 <= position && position <= size.height) {
//       canvas.drawPath(
//           Path()
//             ..arcTo(
//                 Rect.fromCircle(
//                     center: Offset(size.width - 24, size.height - 24),
//                     radius: 24),
//                 pi / 2 - (size.height - position) / 24 * pi / 2,
//                 (size.height - position) / 24 * pi / 2,
//                 false)
//             ..arcTo(
//                 Rect.fromCircle(
//                     center: Offset(24, size.height - 24), radius: 24),
//                 pi / 2,
//                 (size.height - position) / 24 * pi / 2,
//                 false),
//           Paint()
//             ..color = Color.fromRGBO(249, 122, 53, 1)
//             ..style = PaintingStyle.fill);
//     } else if (24 <= position && position <= size.height - 24) {
//       canvas.drawRRect(
//           RRect.fromRectAndCorners(
//               Rect.fromLTRB(0, position, size.width, size.height),
//               topLeft: Radius.circular(0),
//               topRight: Radius.circular(0),
//               bottomLeft: Radius.circular(24),
//               bottomRight: Radius.circular(24)),
//           Paint()
//             ..color = Color.fromRGBO(249, 122, 53, 1)
//             ..style = PaintingStyle.fill);
//     } else {
//       canvas.drawRRect(
//           RRect.fromRectAndCorners(
//               Rect.fromLTRB(0, 23, size.width, size.height),
//               topLeft: Radius.circular(0),
//               topRight: Radius.circular(0),
//               bottomLeft: Radius.circular(24),
//               bottomRight: Radius.circular(24)),
//           Paint()
//             ..color = Color.fromRGBO(249, 122, 53, 1)
//             ..style = PaintingStyle.fill);
//       canvas.drawPath(
//           Path()
//             ..arcTo(
//                 Rect.fromCircle(
//                     center: Offset(size.width - 24, 24), radius: 24),
//                 (position - 24) / 24 * pi / 2,
//                 pi / 2,
//                 false)
//             ..arcTo(Rect.fromCircle(center: Offset(24, 24), radius: 24), pi,
//                 (24 - position) / 24 * pi / 2, false),
//           Paint()
//             ..color = Color.fromRGBO(249, 122, 53, 1)
//             ..style = PaintingStyle.fill);
//     }
//     //自定义矩形
//     canvas.drawRRect(
//         RRect.fromRectXY(
//             Rect.fromCircle(
//                 center: Offset(size.width / 2, position), radius: 14.5),
//             6.72,
//             6.72),
//         Paint()
//           ..color = Colors.white
//           ..strokeWidth = 4.0
//           ..style = PaintingStyle.fill);
//     canvas.drawLine(
//         Offset(size.width / 2 - ScreenUtil().setWidth(8.4), position + 5),
//         Offset(size.width / 2 + ScreenUtil().setWidth(8.4), position + 5),
//         Paint()
//           ..color = Color.fromRGBO(0, 0, 0, 0.12)
//           ..strokeWidth = 3);
//     canvas.drawLine(
//         Offset(size.width / 2 - ScreenUtil().setWidth(8.4), position - 5),
//         Offset(size.width / 2 + ScreenUtil().setWidth(8.4), position - 5),
//         Paint()
//           ..color = Color.fromRGBO(0, 0, 0, 0.12)
//           ..strokeWidth = 3);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }