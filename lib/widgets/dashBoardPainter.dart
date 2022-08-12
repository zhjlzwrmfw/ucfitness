import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/blueUuid.dart';
import 'package:running_app/common/saveData.dart';

class sportDataPainter extends CustomPainter {

  int second;
  double kcalCount;
  int bmpCount;
  int dataFlag;

  sportDataPainter({this.second, this.kcalCount, this.bmpCount, this.dataFlag});

  @override
  void paint(Canvas canvas, Size size) {
    if(dataFlag == 0){
      bmpPaint(canvas, size);
    }else if(dataFlag == 1){
      kcalPaint(canvas, size);
    }else if(dataFlag == 2){
      minPaint(canvas, size);
    }
  }

  void minPaint(Canvas canvas, Size size){
    Paint timePaint = Paint()
      ..isAntiAlias = true
      ..color = Color.fromRGBO(10, 185, 150, 0.24)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.8
      ..style = PaintingStyle.stroke;
    Paint time1Paint = Paint()
      ..isAntiAlias = true
      ..color = Color.fromRGBO(10, 185, 150, 0.54)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.8
      ..style = PaintingStyle.stroke;

    canvas.drawArc(ui.Rect.fromCircle(center: ui.Offset(size.width / 2, size.height / 2), radius: size.width / 2), -pi / 3, pi * 5 / 3, false, timePaint);
    if(SaveData.choseType == 100){
      canvas.drawArc(ui.Rect.fromCircle(center: ui.Offset(size.width / 2, size.height / 2), radius: size.width / 2), -pi / 3, pi * 5 / 3 * ((60 - second) / 60), false, time1Paint);
    }else{
      canvas.drawArc(ui.Rect.fromCircle(center: ui.Offset(size.width / 2, size.height / 2), radius: size.width / 2), -pi / 3, pi * 5 / 3 * (second / 60), false, time1Paint);
    }
  }

  void kcalPaint(Canvas canvas, Size size){
    Paint caloriesPaint = Paint()
      ..isAntiAlias = true
      ..color = Color.fromRGBO(255, 165, 0, 0.24)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.8
      ..style = PaintingStyle.stroke;
    canvas.drawArc(ui.Rect.fromCircle(center: ui.Offset(size.width / 2, size.height / 2), radius: size.width / 2), -pi / 3, pi * 5 / 3 , false, caloriesPaint);
  }

  void bmpPaint(Canvas canvas, Size size){
    Paint bmpPaint = Paint()
      ..isAntiAlias = true
      ..color = Color.fromRGBO(237, 82, 84, 0.24)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.8
      ..style = PaintingStyle.stroke;
    canvas.drawArc(ui.Rect.fromCircle(center: ui.Offset(size.width / 2, size.height / 2), radius: size.width / 2), -pi / 3, pi * 5 / 3 , false, bmpPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}

class DashBoardPainter extends CustomPainter {
  int sportCount;
  int bmpCount;
  double kcalCount;
  String startSport;
  bool sporting;//用于标志是否正在进行运动
  int minCount;
  int sportNum1;
  int sportNum2;
  String kcalNum;
  int choseType;
  int second;

  DashBoardPainter({this.sportCount, this.kcalCount, this.bmpCount, this.startSport, this.sporting, this.minCount,this.choseType, this.second});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    //1.绘制背景。
    _drawBg(canvas, paint, size);
    //2.绘制内容。
    _drawArc(canvas, paint, size);
  }

  void _drawBg(Canvas canvas, Paint paint, Size size) {
    paint..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawArc(Canvas canvas, Paint paint, Size size) {
    final double width = size.width;
    final double height = size.height;
    canvas.save();
    // canvas.translate(0, 0);

    final double arcX = 0.w;//刻度盘距离画布边距
    final double arcWidth = 20.w;//刻度盘粗细

    //绘制刻度的100条横线，已经跨过的部分是黄色，否则为浅色。
    int threadHold;
    if(sportCount == null){
      threadHold = 0;
    }else{
      threadHold = sportCount % 100;
    }

    for (int i = 0; i <= 100; i++) {
      canvas.save();
      i < threadHold ? paint.strokeWidth = 16.w : paint.strokeWidth = 1.w;
      paint.color = i < threadHold ? const Color.fromRGBO(249, 122, 53, 1) : const Color.fromRGBO(143, 151, 169, 1);
      canvas.translate(width/2, height/2);
      canvas.rotate(7 * pi * i / 600 - pi / 12.8);
      canvas.translate(-width / 2, -height / 2);
      i < threadHold ? canvas.drawLine(Offset(arcX, height / 2), Offset(arcX+arcWidth, height / 2), paint)
          : canvas.drawLine(Offset(arcX, height / 2 + 8.w), Offset(arcX+arcWidth, height/2 + 8.w), paint);
      canvas.restore();
    }

    //绘制文字。
    // canvas.save();
    TextSpan motivatedTips1 = TextSpan(
        style: TextStyle(
            color: Color.fromRGBO(41, 51, 75, 1),
            fontSize: 42.sp
        ),
        text: sportCount == null ? SaveData.english ? "let's start exercising!" : '开始运动吧!' : SaveData.english ? 'In motion...' : '正在运动,'
    );
    TextPainter motivatedTipsPainter1 = TextPainter(
        text: motivatedTips1,
        textDirection: TextDirection.ltr
    );
    motivatedTipsPainter1.layout();
    motivatedTipsPainter1.paint(canvas, Offset(width / 50, 0));
    canvas.restore();

    canvas.save();
    TextSpan motivatedTips2 = TextSpan(
        style: TextStyle(
            color: Color.fromRGBO(41, 51, 75, 1),
            fontSize: 60.sp
        ),
        text: SaveData.english ? 'Come on!' : '加油哦！'
    );
    TextPainter motivatedTipsPainter2 = TextPainter(
        text: motivatedTips2,
        textDirection: TextDirection.ltr
    );
    motivatedTipsPainter2.layout();
    motivatedTipsPainter2.paint(canvas, Offset(width / 50, height * 21 / 506));
    canvas.restore();

    if(sportCount == null){
      sportNum1 = 0;
      sportNum2 = 100;
    }else{
      sportNum1 = sportCount - sportCount % 100;
      sportNum2 = sportNum1 + 100;
    }
    canvas.save();
    TextSpan leftTextSpan = TextSpan(
        style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.4),
            fontSize: 42.sp
        ),
        text: sportNum1.toString()
    );
    TextPainter leftTextPainter = TextPainter(
        text: leftTextSpan,
        textAlign: ui.TextAlign.center,
        textDirection: TextDirection.ltr
    );
    leftTextPainter.layout();
    leftTextPainter.paint(canvas, Offset(sportNum1 == 0 ? width / 36 : sportNum1 >= 1000 ?  width / 124 : width / 79, height / 1.62));
    canvas.restore();

    canvas.save();
    TextSpan rightTextSpan = TextSpan(
        style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.4),
            fontSize: 42.sp
        ),
        text: sportNum2.toString()
    );
    TextPainter rightTextPainter = TextPainter(
        text: rightTextSpan,
        textDirection: TextDirection.ltr
    );
    rightTextPainter.layout();
    rightTextPainter.paint(canvas, Offset(sportNum2 >= 1000 ? width / 1.09 : width / 1.08, height / 1.62));
    canvas.restore();
  }

  @override
  bool shouldRepaint(DashBoardPainter oldDelegate){
    return true;
  }

}

class TestStatelessWidget extends StatelessWidget {


  const TestStatelessWidget({
    Key key,
    this.kcalCount,
    this.bmpCount,
    this.minute,
    this.choseType,
    this.sporting,
    this.second,
    this.startSport,
    this.sportCount,})
      : super(key: key);

  final int sportCount;
  final int bmpCount;
  final double kcalCount;
  final String startSport;
  final bool sporting;
  final int minute;
  final int choseType;
  final int second;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Positioned(
          top: 0,
          child: RepaintBoundary(
            child: Container(
              width: 880.w,
              height: 1016.w,
              child: CustomPaint(
                painter: DashBoardPainter(
                    second: second,
                    sportCount: sportCount,
                    bmpCount: bmpCount,
                    kcalCount: kcalCount,
                    sporting: sporting,
                    startSport: startSport,
                    minCount: minute,
                    choseType: choseType),
              ),
            ),
          ),
        ),
        if(sportCount != null && (SaveData.deviceName.substring(0, 10) != BlueUuid.SmartGripBroadcast && SaveData.deviceName.substring(0, 12) != BlueUuid.HuaweiGripBroadcast))
          Positioned(
              top: 488.w,
              // left: ScreenUtil().setWidth(185),
              child: RepaintBoundary(child: Image.asset(SaveData.devicePicture, width: 301.w,height: 177.w,))
          ),
        if(sporting)
          Positioned(
            top: sportCount == null ? 290.w : 220.w,
            child: Text(
              SaveData.english ? 'Set' : '个数',
              style: TextStyle(
                // fontWeight: ui.FontWeight.bold,
                  color: Color.fromRGBO(0, 0, 0, 0.53),
                  fontSize: 48.sp),
            ),
          ),
        if(sporting)
          Positioned(
            top: sportCount == null ? 350.w : 300.w,
            child: RepaintBoundary(
              child: Text(
                sportCount == null ? '-' : sportCount.toString(),
                style: TextStyle(
                    fontWeight: ui.FontWeight.bold,
                    color: Colors.black,
                    fontSize: 160.sp
                ),
              ),
            ),
          ),
        if(!sporting)
          Positioned(
            top: 308.w,
            child: Text(
              startSport,
              style: TextStyle(
                color: const Color.fromRGBO(38, 45, 68, 1),
                fontSize: 240.sp,
                // fontWeight: ui.FontWeight.bold
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 48.w,
          child: RepaintBoundary(
            child: Container(
              width: 220.w,
              height: 220.w,
              child: CustomPaint(
                painter: sportDataPainter(second: second, dataFlag: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    RepaintBoundary(child: Image.asset('images/clock.png',width: 48.w, height: 48.w,)),
                    SizedBox(
                      height: 16.h,
                    ),
                    Text(
                      minute == null ? '-' : SaveData.choseType == 100 && SaveData.choseNumber - minute >= 1 ? (SaveData.choseNumber - minute - 1).toString() : minute.toString(),
                      style: TextStyle(
                          color: Color.fromRGBO(41, 51, 75, 1),
                          fontSize: 60.sp
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      'Min',
                      style: TextStyle(
                          color: Color.fromRGBO(41, 51, 75, 0.5),
                          fontSize: 28.sp
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: RepaintBoundary(
            child: Container(
              width: 220.w,
              height: 220.w,
              child: CustomPaint(
                painter: sportDataPainter(dataFlag: 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    RepaintBoundary(child: Image.asset('images/calories.png',width: 48.w, height: 48.w,)),
                    SizedBox(
                      height: 16.h,
                    ),
                    Text(
                      kcalCount == null ? '-' : kcalCount >= 100 || kcalCount == 0 ? kcalCount.toStringAsFixed(0) : kcalCount.toStringAsFixed(2),
                      style: TextStyle(
                          color: Color.fromRGBO(41, 51, 75, 1),
                          fontSize: 60.sp
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      'Kcal',
                      style: TextStyle(
                          color: Color.fromRGBO(41, 51, 75, 0.5),
                          fontSize: 28.sp
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 48.w,
          child: RepaintBoundary(
            child: Container(
              width: 220.w,
              height: 220.w,
              child: CustomPaint(
                painter: sportDataPainter(dataFlag: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    RepaintBoundary(
                      child: Image.asset(bmpCount == 0 || bmpCount == null ? "images/heart_pink.png" : "images/heart.png",
                        width: 48.w, height: 48.w,),
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    Text(
                      bmpCount == null ? '-' : bmpCount == 0 ? '-' : bmpCount.toString(),
                      style: TextStyle(
                          color: Color.fromRGBO(41, 51, 75, 1),
                          fontSize: 60.sp
                      ),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      'Bpm',
                      style: TextStyle(
                          color: Color.fromRGBO(41, 51, 75, 0.5),
                          fontSize: 28.sp
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
