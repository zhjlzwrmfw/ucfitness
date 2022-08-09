import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/model/medal.dart';
import 'package:running_app/model/newMedal.dart';
import 'package:running_app/routes/userRoutes/userPicture.dart';
import '../../common/encapMethod.dart';
import '../../common/saveData.dart';
import 'package:get/get.dart';

class SportInfoPage extends StatefulWidget{
  final int id;//运动记录id
  final bool isRealSport;//区分实时运动页面和统计页
  SportInfoPage({this.id, this.isRealSport});

  @override
  SportInfoPageState createState() => SportInfoPageState();

}
class SportInfoPageState extends State<SportInfoPage>{

  static String deviceName;
  List totalBmpList = [];
  List totalBmpTimeList = [];
  int minBmp = 60;
  int maxBmp = 200;
  static double intensity;
  int bmpLength;
  List splitBmpString = [];
  List splitBmpTimeString = [];
  int realMaxBmp;
  int realMinBmp;
  int length;
  var _futureBuilderFuture;//避免重复请求刷新
  int totalBmp = 0;//累加总心率
  int avgLength;
  final BlueToothChannel blueToothChannel = new BlueToothChannel();
  StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息
  NewMedal newMedal;

  @override
  void initState() {
    super.initState();
    _streamSubscription = blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
    if(!widget.isRealSport){
      if(SaveData.userId != null){
        _futureBuilderFuture = _getNetData();
      }else{
        _getLocalData();
        if(deviceName == '跳绳'){
          SaveData.sportPosture = sportPosture(1, SaveData.sportMode);
        }else if(deviceName == '拉力绳'){
          SaveData.sportPosture = sportPosture(2, SaveData.sportMode);
        }else if(deviceName == '蝴蝶绳'){
          SaveData.sportPosture = sportPosture(4, SaveData.sportMode);
        }else if(deviceName == '哑铃'){
          SaveData.sportPosture = sportPosture(3, SaveData.sportMode);
        }else if(deviceName == '健腹轮'){
          SaveData.sportPosture = sportPosture(5, SaveData.sportMode);
        }
      }
    }else{
      if(SaveData.userId != null && !SaveData.hasPopupMedalDialog){
        getNewMedal();
      }
      _getLocalData();
      if(SaveData.userId != null && SaveData.netSaveDataList.isNotEmpty){
        Future<void>.delayed(Duration.zero,(){
          Method.customDialog(context, 'tips'.tr, 'reSendData'.tr, confirm, cancel: cancel);
        });
      }
    }
  }

  void confirm(){
    Method.checkNetwork(context).then((bool value){
      if(value){
        reSendData();
      }
    });
  }

  void cancel(){
    SaveData.netSaveDataList.clear();
  }

//重新发送运动数据请求
  void reSendData(){
    DioUtil().post(
        RequestUrl.historySportDataUrl,
        data: SaveData.netSaveDataList,
        options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass,Headers.contentTypeHeader:ContentType.json}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      print(value);
      if(value != null){
        if(value['code'] == '200'){
          if(mounted){
            setState(() {
              SaveData.netSaveDataList.clear();
              SportInfoPageState.intensity = value["data"]['sportStrength'];
            });
          }
        }else{
          Method.showToast('It seems that there is no internet'.tr, context);
        }
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }

  void getNewMedal(){
    DioUtil().get(
      RequestUrl.getMedalNewUrl,
      queryParameters: <String, Object>{'lang': SaveData.english ? 'en' : 'zh', 'userId': SaveData.userId},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass':RequestUrl.appPass}),
    ).then((value){
      print(value);
      if(value != null){
        newMedal = NewMedal.fromJson(value);
        if(newMedal.code == '200'){
          if(newMedal.data.isNotEmpty){
            SaveData.hasNewMedal = true;
            SaveData.hasPopupMedalDialog = true;
            final double width = MediaQuery.of(context).size.width;
            Method.customMedalDialog(context, newMedal, width);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    SaveData.minCount = null;
    SaveData.secondsCount = null;
  }

  void _onToDart(dynamic message) {}

  void _onToDartError(dynamic error) {
    switch (error.code) {
      case '90002':
        Method.showToast('Device disconnected'.tr, context, second: 2);
        Navigator.popUntil(context, ModalRoute.withName('MyHomePage'));
        break;
    }
  }

  String sportPosture(int deviceType, int mode) {
    switch (deviceType) {
      case 1:
        return SaveData.english ? 'Free rope jumping' : '自由跳绳';
      case 2:
        return mode == 1
            ? SaveData.english ? 'Mode one' : '站姿划船'
            : mode == 2 ? SaveData.english ? 'Mode two' : '侧平举' : mode == 3 ? SaveData.english ? 'Mode three' : '向上弯举' : mode == 4 ? SaveData.english ? 'Mode four' : '过顶屈伸' : mode == 5 ? SaveData.english ? 'Mode five' : '背部舒展' : SaveData.english ? 'Mode six' : '扩胸运动';
      case 3:
        return mode == 1
            ? SaveData.english ? 'Mode one' : '哑铃弯举'
            : mode == 2 ? SaveData.english ? 'Mode two' : '俯身臂屈伸' : mode == 3 ? SaveData.english ? 'Mode three' : '颈后臂屈伸' : SaveData.english ? 'Mode four' : '附身划船';
      case 4:
        return mode == 1
            ? SaveData.english ? 'Mode one' : '向上弯举'
            : mode == 2 ? SaveData.english ? 'Mode two' : '仰卧划船' : mode == 3 ? SaveData.english ? 'Mode three' : '坐姿弯举' : SaveData.english ? 'Mode four' : '坐姿划船';
      case 5:
        return mode == 1 ? SaveData.english ? 'Mode one' : '跪姿卷腹' : SaveData.english ? 'Mode two' : '站姿卷腹';
      default:
        return '';
    }
  }

  Future _getNetData() async {
    totalBmp = 0;
    return DioUtil()
        .get(RequestUrl.getSportDataUrl,
        queryParameters: {"id": widget.id},
        options: Options(
          headers: {'access_token': SaveData.accessToken, "app_pass": RequestUrl.appPass},
          sendTimeout: 5000,
          receiveTimeout: 10000,
        )).then((value) {
      print(value);
      if (value["code"] == "200") {
        SaveData.sportCount = value["data"]["sportHistory"]["count"].toString();
        SaveData.kcalCount =
            value["data"]["sportHistory"]["calories"].toString();
        if (value["data"]["sportHistory"]["trainMode"] == 1) {
          SaveData.modeName = '自由模式';
        } else if (value["data"]["sportHistory"]["trainMode"] == 2) {
          SaveData.modeName = '计时模式';
        } else {
          SaveData.modeName = '计数模式';
        }
        SaveData.sportPosture = sportPosture(value["data"]["sportHistory"]["equipmentType"], value["data"]["sportHistory"]["mode"]);
        SaveData.sportTime = value["data"]["sportHistory"]["startTime"].toString().substring(0, 16);
        intensity = value["data"]["sportStrength"];
        if (value["data"]["sportHistory"]["duringTime"] < 60) {
          SaveData.secondsCount =
              value["data"]["sportHistory"]["duringTime"].toString();
          SaveData.avgCount = (value["data"]["sportHistory"]["count"] / value["data"]["sportHistory"]["duringTime"] * 60).round().toString();
          SaveData.minCount = null;
        } else {
          SaveData.minCount = (value["data"]["sportHistory"]["duringTime"] ~/ 60).toString();
          SaveData.avgCount = (value["data"]["sportHistory"]["count"] / value["data"]["sportHistory"]["duringTime"] * 60).round().toString();
          SaveData.secondsCount = null;
        }
        if (!value["data"]["sportHistory"]["offline"]) {
          SaveData.avgBmp = null;
          length = value["data"]["heartRateProcesses"].length;
          print('length:$length');
          if(length != 0){
            for (int i = 0; i < length; i++) {
              totalBmpList
                  .add(value["data"]["heartRateProcesses"][i]["heartRate"]);
              totalBmpTimeList
                  .add(value["data"]["heartRateProcesses"][i]["time"]);
              totalBmp = totalBmp +
                  value["data"]["heartRateProcesses"][i]["heartRate"];
            }
            SaveData.avgBmp = (totalBmp / length).round().toString();
            minBmp = totalBmpList[0];
            maxBmp = totalBmpList[0];
            for (int i = 0; i < totalBmpList.length; i++) {
              if (totalBmpList[i] > maxBmp) {
                maxBmp = totalBmpList[i];
              }
              if (totalBmpList[i] < minBmp) {
                minBmp = totalBmpList[i];
              }
            }
            realMaxBmp = maxBmp;
            realMinBmp = minBmp;
            maxBmp = 10 * ((maxBmp / 10).floor() + 1);
            if (minBmp != 0) {
              minBmp = pow(10, minBmp.toString().length - 1) *
                  (minBmp / pow(10, minBmp.toString().length - 1)).floor();
            }
          }else{
            totalBmpList.add('0');
          }
        } else {
          SaveData.avgBmp = '--';
        }
      }
    });
  }

  void _getLocalData(){
    if(SaveData.avgBmp != '--' ){
      bmpLength = SaveData.totalBmp.split('-').length;
      splitBmpString = SaveData.totalBmp.split('-');
      splitBmpTimeString = SaveData.totalBmpTime.split('-');
      if(bmpLength > 60){
        avgLength = bmpLength ~/ 60 + 1;
      }else{
        avgLength = 1;
      }
      for(int i = 0; i < bmpLength;){
        totalBmpList.add(splitBmpString[i]);
        totalBmpTimeList.add(splitBmpTimeString[i]);
        i = i + avgLength;
      }
      print(totalBmpList);
      if(totalBmpList.isNotEmpty){
        if(totalBmpList[totalBmpList.length - 1] == ''){
          totalBmpList.removeLast();
        }
      }
      if(totalBmpList.isNotEmpty){
        minBmp = int.parse(totalBmpList[0]);
        maxBmp = int.parse(totalBmpList[0]);
        for(int i = 0; i < totalBmpList.length; i++){
          if(int.parse(totalBmpList[i]) > maxBmp){
            maxBmp = int.parse(totalBmpList[i]);
          }
          if(int.parse(totalBmpList[i]) < minBmp){
            minBmp = int.parse(totalBmpList[i]);
          }
        }
        realMaxBmp = maxBmp;
        realMinBmp = minBmp;
        maxBmp = 10 * ((maxBmp / 10).floor() + 1);
        if(minBmp != 0){
          minBmp = pow(10, minBmp.toString().length - 1) * (minBmp / pow(10, minBmp.toString().length - 1)).floor();
        }
      }else{
        setState(() {
          totalBmpList.add('0');
          // minBmp = 0;
        });
      }
    }else{
      if(SaveData.broadcastType == 0){
        realMaxBmp = int.parse(SaveData.totalBmp.split('-')[0]);
        realMinBmp = int.parse(SaveData.totalBmp.split('-')[1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(540, 1186.5),
      builder: () => Material(
        color: Colors.white,
        child: SaveData.userId != null && !widget.isRealSport ? refreshBuild() : commonBuild(),
      ),
    );
  }

  Widget refreshBuild(){
    return FutureBuilder(
      future: _futureBuilderFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.waiting:
            print('waiting');
            return Scaffold(
              appBar: AppBar(
                title: Text(deviceName, style: TextStyle(color: Colors.white),),
                centerTitle: false,
                backgroundColor: Color.fromRGBO(249, 122, 53, 1),
              ),
              body: Container(
                color: Colors.white,
                child: Center(
                  // padding: EdgeInsets.only(top: ScreenUtil().setHeight(320),left: 200.w),
                  child: Image.asset('images/tiger-animation-loop.gif',width: 200.w,height: 200.h,),
                ),
              ),
            );
          case ConnectionState.done:
            print('done');
            print(snapshot.error);
            return snapshot.hasError ?
            Scaffold(
              appBar: AppBar(
                title: Text(deviceName,style: TextStyle(color: Colors.white),),
                centerTitle: false,
                backgroundColor: Color.fromRGBO(249, 122, 53, 1),
              ),
              body: Center(
                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      _futureBuilderFuture = _getNetData();
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('images/unconnected.png',width: 180.w,height: 180.w,),
                      Text('It seems that there is no internet'.tr)
                    ],
                  ),
                ),
              ),
            )
                : commonBuild();
          default:
            return null;
        }
      },
    );
  }

  Widget commonBuild(){
    return Material(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(249, 122, 53, 1),
          titleSpacing: 4,
          elevation: 0,
          centerTitle: false,
          leading: FlatButton(
            splashColor: Colors.transparent,
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 21.w,
            ),
            onPressed: () {
              SaveData.minCount = null;
              SaveData.secondsCount = null;
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            SaveData.connectDeviceTypeStr(deviceName),
            style: TextStyle(
                fontSize: 21.sp, color: Colors.white),
          ),
        ),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Positioned(
                right: 36.w,
                top: 50.5.h,
                child: Container(
                  width: 100.h,
                  height: 100.h,
                  child: SaveData.pictureUrl == null ? Image.asset("images/home_user.png", width: 88.w,height: 88.w,)
                      : ClipOval(child: Image.file(File(SaveData.pictureUrl), width: 88.w,height: 88.w)),
                )
            ),
            Positioned(
              right: 36.w,
              top: 57.5.h,
              child: Container(
                  width: 100.h,
                  height: 100.h,
                  padding: EdgeInsets.all(0),
                  child: FlatButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return UserPicturePage(SaveData.pictureUrl);
                      }));
                    },
                  )
              ),
            ),
            Positioned(
              top: 54.w,
              left: 36.w,
              child: Text(SaveData.username == null ? "Username" : SaveData.username,style: TextStyle(fontSize: 30.sp,color: Color.fromRGBO(38, 45, 68, 1)),),
            ),
            Positioned(
              top: 95.5.w,
              left: 36.w,
              child: Text(SaveData.sportTime,
                style: TextStyle(fontSize: 18.sp,color: Color.fromRGBO(145, 148, 160, 1)),),
            ),
            Positioned(
              top: 203.5.h,
              left: 36.w,
              child: Text('Count'.tr, style: TextStyle(fontSize: 18.sp,color: Color.fromRGBO(145, 148, 160, 1)),),
            ),
            Positioned(
              top: 231.5.h,
              left: 36.w,
              child: Text.rich(TextSpan(
                  children: [
                    TextSpan(
                      text: SaveData.sportCount,
                      style: TextStyle(fontSize: 60.sp,color: Color.fromRGBO(41, 51, 75, 1)),
                    ),
                    TextSpan(
                        text: 'singleCount'.tr,
                        style: TextStyle(fontSize: 18.sp,color: Color.fromRGBO(145, 148, 160, 1))
                    )
                  ]
              )
              ),
            ),
            if(deviceName != '握力环')
            Positioned(
                top: 203.5.h,
                right: 36.w,
                child: Column(
                  children: <Widget>[
                    if(SaveData.sportPosture != null)
                    FlatButton.icon(
                      disabledColor: Color.fromRGBO(251,210,186,1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.32.w)),
                      onPressed: null,
                      icon: Image.asset(deviceName == '跳绳' ? 'images/equip_recoid_01.png'
                          : deviceName == '拉力绳' ? 'images/equip_recoid_05.png'
                          : deviceName == '蝴蝶绳' ? 'images/equip_recoid_03.png'
                          : deviceName == '健腹轮' ? 'images/equip_recoid_02.png'
                          : 'images/equip_recoid_04.png',
                        width: 32.w, height: 32.w,),
                      label: Text(SaveData.sportPosture,
                        style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18.sp,color: Color.fromRGBO(249,122,53,1)),),),
                    FlatButton.icon(
                      disabledColor: Color.fromRGBO(226,228,231,1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.32.w)),
                      // padding: EdgeInsets.zero,
                      onPressed: null,
                      icon: Image.asset('images/freemode.png',width: 32.w, height: 32.w,),
                      label: Text(SaveData.modeName == null ? '自由模式' : SaveData.modeName == '自由模式' ? 'Free mode'.tr
                          : SaveData.modeName == '计数模式' ? 'Count training'.tr
                          : 'Time training'.tr,
                        style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18.sp,color: Color.fromRGBO(111,122,135,1)),),)
                  ],
                )
            ),
            Positioned(
              left: 36.w,
              top: 387.5.h,
              child: Text.rich(TextSpan(
                  children: [
                    TextSpan(
                      text: SaveData.kcalCount + '\n',
                      style: TextStyle(fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 1)),
                    ),
                    TextSpan(
                        text: 'Calories'.tr + '\n' + 'KCal',
                        style: TextStyle(fontSize: 18.sp,color: Color.fromRGBO(145, 148, 160, 1))
                    )
                  ]
              ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: 387.5.h,
              child: Text.rich(TextSpan(
                  children: [
                    TextSpan(
                      text: (SaveData.minCount == null ? SaveData.secondsCount : SaveData.minCount) + '\n',
                      style: TextStyle(fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 1)),
                    ),
                    TextSpan(
                        text: 'Duration'.tr + '\n' + (SaveData.minCount == null ? 'Sec' : 'Min'),
                        style: TextStyle(fontSize: 18.sp,color: Color.fromRGBO(145, 148, 160, 1))
                    )
                  ]
              ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: 387.5.h,
              right: 48.w,
              child: Text.rich(TextSpan(
                  children: [
                    TextSpan(
                      text: (intensity == null ? '--' : intensity >= 100 ? intensity.toStringAsFixed(0) : intensity.toString()) + '\n',
                      style: TextStyle(fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 1)),
                    ),
                    TextSpan(
                        text: 'Strength'.tr,
                        style: TextStyle(fontSize: 18.sp,color: Color.fromRGBO(145, 148, 160, 1))
                    )
                  ]
              ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              left: 36.w,
              top: 522.5.h,
              child: Text.rich(TextSpan(
                  children: [
                    TextSpan(
                      text: SaveData.avgCount + '\n',
                      style: TextStyle(fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 1)),
                    ),
                    TextSpan(
                        text: 'Average speed'.tr + '\n' + 'times/mn',
                        style: TextStyle(fontSize: 18.sp,color: Color.fromRGBO(145, 148, 160, 1))
                    )
                  ]
              ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
                top: 522.5.h,
                child: Text.rich(TextSpan(
                    children: [
                      TextSpan(
                        text: (realMaxBmp == null ? '--' : realMaxBmp.toString()) + '\n',
                        style: TextStyle(fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 1)),
                      ),
                      TextSpan(
                          text: 'Maximum heart rate'.tr + '\n' + 'bpm',
                          style: TextStyle(fontSize: 18.sp,color: Color.fromRGBO(145, 148, 160, 1))
                      )
                    ]
                ),
                  textAlign: TextAlign.center,
                )
            ),
            Positioned(
              top: 522.5.h,
              right: 36.w,
              child: Text.rich(TextSpan(
                  children: [
                    TextSpan(
                      text: (realMinBmp == null ? '--' : realMinBmp.toString()) + '\n',
                      style: TextStyle(fontSize: 36.sp,color: const Color.fromRGBO(38, 45, 68, 1)),
                    ),
                    TextSpan(
                        text: 'Minimum heart rate'.tr + '\n' + 'bpm',
                        style: TextStyle(fontSize: 18.sp,color: const Color.fromRGBO(145, 148, 160, 1))
                    )
                  ]
              ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              left: 182.w,
              top: 398.h,
              child: Container(
                width: 1.5.w,
                height: 24.h,
                color: Color.fromRGBO(238, 238, 238, 1),
              ),
            ),
            Positioned(
              left: 355.5.w,
              top: 398.h,
              child: Container(
                width: 1.5.w,
                height: 24.h,
                color: Color.fromRGBO(238, 238, 238, 1),
              ),
            ),
            Positioned(
              left: 355.5.w,
              top: 533.h,
              child: Container(
                width: 1.5.w,
                height: 24.h,
                color: Color.fromRGBO(238, 238, 238, 1),
              ),
            ),
            Positioned(
              left: 182.w,
              top: 533.h,
              child: Container(
                width: 1.5.w,
                height: 24.h,
                color: Color.fromRGBO(238, 238, 238, 1),
              ),
            ),
            Positioned(
                left: 29.w,
                top: 692.h,
                child: Text('Heart rate graph'.tr,style: TextStyle(fontSize: 21.sp,color: Color.fromRGBO(0, 0, 0, 0.87)),)
            ),
            Positioned(
                left: 29.w,
                top: 721.h,
                child: Text(
                  SaveData.avgBmp == '--'
                      ? 'Offline data has no real-time heart rate'.tr
                      : totalBmpList.isEmpty || totalBmpList[0] == '0'
                      ? 'No real-time heart rate this time'.tr
                      : 'Average heart rate'.tr + SaveData.avgBmp + 'singleCount'.tr + "/" + 'minute'.tr,
                  style: TextStyle(
                      fontSize: 18.sp,
                      color: Color.fromRGBO(145, 148, 160, 1)),
                )
            ),
            Positioned(
              top: 773.h,
              left: 29.w,
              child: Container(
                child: LineChartSample2(totalBmpList: totalBmpList, minBmp: minBmp, maxBmp: maxBmp, totalBmpTimeList: totalBmpTimeList,),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LineChartSample2 extends StatefulWidget {

  final List totalBmpList;
  final List totalBmpTimeList;
  final int minBmp;
  final int maxBmp;
  LineChartSample2({this.totalBmpList, this.minBmp, this.maxBmp, this.totalBmpTimeList});

  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 451.w,
          height: 249.h,
          child: LineChart(mainData()),
        ),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            getTooltipItems: customLineTooltipItem
        ),
      ),
      gridData: FlGridData(
        horizontalInterval: (widget.maxBmp - widget.minBmp) / 5,
        verticalInterval: widget.totalBmpList.length == 0 ? 100 : widget.totalBmpList.length.toDouble(),
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Color.fromRGBO(233, 235, 241, 1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Color.fromRGBO(233, 235, 241, 1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          interval: widget.totalBmpList.length == 0 ? 1 : widget.totalBmpList.length.toDouble(),
          showTitles: false,
          reservedSize: 22,
          getTextStyles: (value) =>
          const TextStyle(color: Color.fromRGBO(0, 23, 55, 0.3), fontSize: 13),
          margin: 6,
        ),
        leftTitles: SideTitles(
          interval: (widget.maxBmp - widget.minBmp) / 5,
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color.fromRGBO(33, 37, 41, 0.3),
            // fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          reservedSize: 22,
          margin: 6,
        ),
      ),
      borderData:
      FlBorderData(show: true, border: Border.all(color: Color.fromRGBO(233, 235, 241, 1), width: 1)),
      // minX: 0,
      // maxX: widget.totalBmpList.length / 4,
      minY: widget.minBmp.toDouble(),
      maxY: widget.maxBmp.toDouble(),
      lineBarsData: [
        if(SaveData.avgBmp != '--' && widget.totalBmpList.length != 0)
          LineChartBarData(
            spots: [
              for(int i = 0; i < widget.totalBmpList.length; i++)
                FlSpot((i).toDouble(),double.parse(widget.totalBmpList[i].toString()))
            ],//添加在曲线上的点数据
            isCurved: false,//是否为曲线
            // colors: [Color.fromRGBO(237, 82, 84, 1)],//曲线的颜色，数据类型是List
            colors: [Color.fromRGBO(249, 122, 53, 1)],//曲线的颜色，数据类型是List
            barWidth: 2.5,//曲线的宽度
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,//是否显示曲线上的数据点
            ),
            belowBarData: BarAreaData(
              show: true,//是否显示曲线下面的颜色
              // colors: [Color.fromRGBO(237, 82, 84, 0.07)],//曲线下面的颜色
              colors: [Color.fromRGBO(249, 122, 53, 0.07)],//曲线下面的颜色
            ),
          ),
      ],
    );
  }
  List<LineTooltipItem> customLineTooltipItem(List<LineBarSpot> touchedSpots) {
    if (touchedSpots == null) {
      return null;
    }

    return touchedSpots.map((LineBarSpot touchedSpot) {
      if (touchedSpot == null) {
        return null;
      }
      final TextStyle textStyle = TextStyle(
        color: touchedSpot.bar.colors[0],
        fontWeight: FontWeight.bold,
        fontSize: 12,
      );
      return LineTooltipItem('heartRate'.tr + ':' + touchedSpot.y.toStringAsFixed(0) + '\n' + widget.totalBmpTimeList[touchedSpot.x.toInt()], textStyle);
    }).toList();
  }
}