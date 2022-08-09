import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///五维图
/// 设置五维图的半径，根据分5等分来计算
/// 绘制一个正五边形，一个顶点在y轴上，半径为r，顺势正依次是（0，r）（r*c18，r*s18）
/// （r*c54，-r*s54）（-r*c54，-r*s54）(-r*c18,r*s18)
///
class SportBean{
  double score;
  String name;

  SportBean(this.score, this.name);

}
// ignore: must_be_immutable
class SportIndexWidget extends StatefulWidget {
  ///半径
  double r = 80.0;

  ///正五边形个数 目前只支持五边形
  int n = 5;

  ///文字和图像的间距
  double padding;

  ///最下面两个的间距
  double bottomPadding = 8;
  Paint  zeroToPointPaint;
  Paint pentagonPaint;
  Paint contentPaint;


  ///当前的分数 ///对应的文案
  List<SportBean> score;


  SportIndexWidget(this.score,
      {this.r = 80.0,
        this.padding = 10,
        this.bottomPadding = 8,
        this.zeroToPointPaint,
        this.pentagonPaint,
        this.contentPaint}){
    // ///原点到5个定点的连线
    // zeroToPointPaint = Paint()
    //   ..style = PaintingStyle.stroke
    //   ..color = Colors.black12
    //   ..strokeWidth = 0.5;
    //
    // ///5层五边形画笔
    // pentagonPaint = Paint()
    //   ..color = Colors.black12
    //   ..strokeWidth = 1
    //   ..style = PaintingStyle.fill;
    //
    // ///覆盖内容颜色
    // contentPaint = Paint()
    //   ..color = Colors.blueAccent
    //   ..strokeWidth = 2
    //   ..style = PaintingStyle.fill;
  }

  @override
  State<StatefulWidget> createState() {
    return SportIndexWidgetState();
  }
}

class SportIndexWidgetState extends State<SportIndexWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        painter: SportIndexPainter(
            widget.score,
            r: widget.r,
            n: widget.n,
            padding: widget.padding,
            bottomPadding: widget.bottomPadding,
            zeroToPointPaint: widget.zeroToPointPaint,
            pentagonPaint: widget.pentagonPaint,
            contentPaint: widget.contentPaint),
      ),
    );
  }
}

class SportIndexPainter extends CustomPainter {
  double r;
  int n;
  double padding;
  double bottomPadding;
  Paint zeroToPointPaint;
  Paint pentagonPaint;
  Paint contentPaint;
  List<SportBean> score;

  SportIndexPainter(this.score,
      {this.r = 80.0,
        this.n = 5,
        this.padding = 10,
        this.bottomPadding = 8,
        this.zeroToPointPaint,
        this.pentagonPaint,
        this.contentPaint}) {
    zeroToPointPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.8)
      ..strokeWidth = 0.5;

    ///5层五边形画笔
    pentagonPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    ///覆盖内容颜色
    contentPaint = Paint()
      ..color = Color.fromRGBO(249, 122, 53, 1).withOpacity(0.24)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
  }


  @override
  void paint(Canvas canvas, Size size) {
    List<Offset> points = [
      Offset(0, -r),
      Offset(r * cos(angleToRadian(18)), -r * sin(angleToRadian(18))),
      Offset(r * cos(angleToRadian(54)), r * sin(angleToRadian(54))),
      Offset(-r * cos(angleToRadian(54)), r * sin(angleToRadian(54))),
      Offset(-r * cos(angleToRadian(18)), r * -sin(angleToRadian(18))),
    ];

    // canvas.translate(size.width / 2, r+padding);
    canvas.save();
    canvas.translate(size.width / 2, size.height/2);
    canvas.drawPoints(
        PointMode.points,
        [Offset(0, 0)],
        Paint()
          ..color = Colors.green
          ..strokeWidth = 2);

    ///画n个五边形
    for (int i = 0; i < n; i++) {
      List<Offset> points = [
        Offset(0, -r * (i + 1) / n),
        Offset(r * (i + 1) / n * cos(angleToRadian(18)),
            -r * (i + 1) / n * sin(angleToRadian(18))),
        Offset(r * (i + 1) / n * cos(angleToRadian(54)),
            r * (i + 1) / n * sin(angleToRadian(54))),
        Offset(-r * (i + 1) / n * cos(angleToRadian(54)),
            r * (i + 1) / n * sin(angleToRadian(54))),
        Offset(-r * (i + 1) / n * cos(angleToRadian(18)),
            r * (i + 1) / n * -sin(angleToRadian(18))),
      ];
      drawPentagon(points, canvas, pentagonPaint);
    }

    ///连接最外层的五个定点
    drawZeroToPoint(points, canvas);

    ///修改成对应的分数，绘制覆盖内容
    List<Offset> list = converPoint(points, score);
    drawPentagon(list, canvas, contentPaint);

    ///根据位置绘制文字
    for (int i = 0; i < points.length; i++) {
      int type = 0;
      switch (i) {
        case 0:
          type = 1;
          points[i] -= Offset(0, padding * 2);
          break;
        case 1:
          type = 0;
          points[i] += Offset(padding, -padding);
          break;
        case 2:
          type = 1;
          points[i] += Offset(bottomPadding, padding);
          break;
        case 3:
          type = 1;
          points[i] += Offset(-bottomPadding, padding);
          break;
        case 4:
          type = 2;
          points[i] -= Offset(padding, padding);
          break;
        default:
      }
      drawText(canvas, points[i], score[i].name,
          TextStyle(fontSize: 14, color: Colors.black54), type);
    }
    canvas.restore();
  }

  /// 右边的文字不需要移动   有的文字要移动一半居中  左边的文字需要左移动整个距离
  ///type 0 1 2
  void drawText(Canvas canvas, Offset offset, String text, TextStyle style,
      int type) {
    var textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl);
    textPainter.layout();
    Size size = textPainter.size;
    Offset offsetResult;
    switch (type) {
      case 1:
        offsetResult = Offset(offset.dx - size.width / 2, offset.dy);
        break;
      case 2:
        offsetResult = Offset(offset.dx - size.width, offset.dy);
        break;
      default:
        offsetResult = offset;
    }
    textPainter.paint(canvas, offsetResult);
  }

  List<Offset> converPoint(List<Offset> points, List<SportBean> score) {
    List<Offset> list = [];
    for (int i = 0; i < points.length; i++) {
      list.add(points[i].scale(score[i].score / 100, score[i].score / 100));
    }
    return list;
  }

  void drawZeroToPoint(List<Offset> points, Canvas canvas) {
    points.forEach((element) {
      canvas.drawLine(
        Offset.zero,
        element,
        zeroToPointPaint,
      );
    });
  }

  ///画五边形
  void drawPentagon(List<Offset> points, Canvas canvas, Paint paint) {
    Path path = Path();
    Paint _paint = new Paint();
    _paint..strokeWidth = 4..color = Colors.green;
    path.moveTo(0, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
    if(paint.color == Colors.greenAccent.withOpacity(0.5)){
      canvas.drawPoints(PointMode.points, points, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  ///转换角度  18/180.0 *pi
  double angleToRadian(double angle) {
    return angle / 180.0 * pi;
  }
}
