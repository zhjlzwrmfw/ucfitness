import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../common/saveData.dart';
import '../realTimeSport/mainSport.dart';

class SportSettingPage extends StatefulWidget {
  @override
  SportSettingPageState createState() => SportSettingPageState();
}

class SportSettingPageState extends State<SportSettingPage> {

  bool isMediaPlay = true;//是否播报语音
  bool isCourse = false;//课程优先
  FixedExtentScrollController scrollController1;//更改语音播报次数对应
  bool isEndSport = false;
  double volume = 19;
  int pos;

  final BlueToothChannel blueToothChannel = new BlueToothChannel();
  StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息

  @override
  void initState() {
    super.initState();
    _streamSubscription = blueToothChannel.eventChannelPlugin
        .receiveBroadcastStream()
        .listen(_onToDart, onError: _onToDartError);
    SharedPreferences.getInstance().then((value){
      setState(() {
        if(value.getBool('openMedia') != null){
          isMediaPlay = value.getBool('openMedia');
        }
        if(value.getInt('sportPlayRate') != null){
          SaveData.sportPlayRate = value.getInt('sportPlayRate');
          if(value.getInt('sportPlayRate') == 10){
            scrollController1 = FixedExtentScrollController(initialItem: 0);
          }else if(value.getInt('sportPlayRate') == 20){
            scrollController1 = FixedExtentScrollController(initialItem: 1);
          }else if(value.getInt('sportPlayRate') == 50){
            scrollController1 = FixedExtentScrollController(initialItem: 2);
          }else if(value.getInt('sportPlayRate') == 100){
            scrollController1 = FixedExtentScrollController(initialItem: 3);
          }
        }
      });
    });
  }

  void _onToDart(dynamic message) {
    switch (message['code'] as String) {
      case '80005':
        Uint8List data = message['data'] as Uint8List;
        if(data[0] == 0x04 && data[1] == 0x01){
          MainSportPageState.second = data[2] + data[3] * 16 * 16;
          MainSportPageState.dynamicSecond = (data[2] + data[3] * 16 * 16) % 60;
          MainSportPageState.minute = MainSportPageState.second ~/ 60;
          if(SaveData.choseType == 100){
            if(SaveData.choseNumber == (data[2] + data[3] * 16 * 16) ~/ 60){
              isEndSport = true;
            }
          }else if(SaveData.choseType == 200){
            if(SaveData.choseNumber == data[5] * 16 * 16 + data[4]){
              isEndSport = true;
            }
          }
          MainSportPageState.sportCount = data[5] * 16 * 16 + data[4];
          MainSportPageState.kcalCount = data[13] * 16 * 16 + data[12] + 0.0;
        }else if(data[1] == 0x41 && data[2] == 0x08){
          MainSportPageState.sportCount = data[4] + data[3] * 16 * 16;
          MainSportPageState.bmpCount = data[7];
          if(data[7] != 0){
            MainSportPageState.count = MainSportPageState.count + 1;
            MainSportPageState.totalBmp = MainSportPageState.totalBmp + data[7];
          }
          if(data[8] * 16 * 16 + data[9] >= 100){
            MainSportPageState.kcalCount = data[8] * 16 * 16 + data[9] + 0.0;
          }else{
            MainSportPageState.kcalCount = data[8] * 16 * 16 + data[9] + data[10] / 100;
          }
          if(MainSportPageState.totalBmpData.isNotEmpty || data[7] != 0){//记录实时心率和运动时间
            MainSportPageState.totalBmpData = MainSportPageState.totalBmpData + data[7].toString() + '-';
            DateTime bmpTime = DateTime.now();
            MainSportPageState.totalBmpTime = MainSportPageState.totalBmpTime + bmpTime.toString().substring(11, 16) + '-';
          }
          if(SaveData.choseType == 100){
            if(SaveData.choseNumber == MainSportPageState.minute){
              isEndSport = true;
            }
          }else if(SaveData.choseType == 200){
            if(SaveData.choseNumber == data[4] + data[3] * 16 * 16){
              isEndSport = true;
            }
          }
        }
    }
  }

  void _onToDartError(dynamic error) {
    switch (error.code as String) {
      case '90002':
        Method.showToast('Device disconnected'.tr, context, second: 2);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => WillPopScope(
          onWillPop: () async {
            if(isEndSport){
              Navigator.of(context).pop(1);
            }else{
              Navigator.of(context).pop(0);
            }
            return true;
          },
          child: Material(
              child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: const Color.fromRGBO(249, 122, 53, 1),
                    titleSpacing: 4,
                    elevation: 0,
                    centerTitle: false,
                    leading: FlatButton(
                      splashColor: Colors.transparent,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 42.w,
                      ),
                      onPressed: () {
                        if(isEndSport){
                          Navigator.of(context).pop(1);
                        }else{
                          Navigator.of(context).pop(0);
                        }
                      },
                    ),
                    title: Text(
                      'Setting'.tr,
                      style: TextStyle(
                          fontSize: 42.sp, color: Colors.white),
                    ),
                  ),
                  body: Stack(children: <Widget>[
                    Positioned(
                      top: 72.h,
                      left: 72.w,
                      child: Text(
                        'Speak'.tr,
                        style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.normal,
                            color: Color.fromRGBO(0, 0, 0, 0.5)),
                      ),
                    ),
                    Positioned(
                        top: 126.h,
                        child: Container(
                          width: 1080.w,
                          height: 120.h,
                          padding: EdgeInsets.only(left: 72.w,right: 24.w),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'speak count of exercise'.tr,
                                  style: TextStyle(
                                      fontSize: 42.sp,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromRGBO(0, 0, 0, 0.87)),
                                ),
                                Container(
                                  // width: ScreenUtil().setWidth(34),
                                  child: Switch(
                                    activeColor: Color.fromRGBO(249, 122, 53, 1),
                                    value: isMediaPlay,
                                    onChanged: (value) {
                                      setState(() {
                                        isMediaPlay = value;
                                        SaveData.openMedia = value;
                                        SharedPreferences.getInstance().then((value) {
                                          value.setBool('openMedia', SaveData.openMedia);
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ]),
                        )),
                    if (isMediaPlay)
                      Positioned(
                          top: 270.h,
                          child: Container(
                            width: 1080.w,
                            height: 120.h,
                            child: FlatButton(
                              padding: EdgeInsets.only(left: 72.w,right: 72.w),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'frequency'.tr,
                                      style: TextStyle(
                                          fontSize: 42.sp,
                                          fontWeight: FontWeight.normal,
                                          color: Color.fromRGBO(0, 0, 0, 0.87)),
                                    ),
                                    Text(
                                      (SaveData.sportPlayRate).toString() + 'singleCount'.tr,
                                      style: TextStyle(
                                          fontSize: 42.sp,
                                          fontWeight: FontWeight.normal,
                                          color: Color.fromRGBO(0, 0, 0, 0.7)),
                                    ),
                                  ]),
                              onPressed: _getPlayRate,
                            ),
                          )),
                    // if(isMediaPlay && MainSportPageState.eleAmount != null && SaveData.broadcastType == 1)
                    //   Positioned(
                    //       top: ScreenUtil().setHeight(138),
                    //       left: 24.w,
                    //       child: Row(
                    //         children: <Widget>[
                    //           Text(
                    //               '硬件设备音量调节',
                    //               style: TextStyle(
                    //                   fontSize: 14.sp,
                    //                   fontWeight: FontWeight.normal,
                    //                   color: Color.fromRGBO(0, 0, 0, 0.87))
                    //           ),
                    //           SizedBox(
                    //             width: 24.w,
                    //           ),
                    //           Slider(
                    //             min: 1,
                    //             max: 56,
                    //             value: volume,
                    //             activeColor: Color.fromRGBO(249, 122, 53, 1),
                    //             inactiveColor: Colors.grey,
                    //             onChanged: (value){
                    //               setState(() {
                    //                 volume = value;
                    //                 BlueToothChannel().changeVoice(56 - value.toInt());
                    //               });
                    //             },
                    //           ),
                    //         ],
                    //       )
                    //   ),
                    // Positioned(
                    //   top: ScreenUtil().setHeight(isMediaPlay ? 158 : 98).toDouble(),
                    //   left: 24.w.toDouble(),
                    //   child: Text(
                    //     '一碰连',
                    //     style: TextStyle(
                    //         fontSize: ScreenUtil().setSp(10).toDouble(),
                    //         fontWeight: FontWeight.normal,
                    //         color: const Color.fromRGBO(0, 0, 0, 0.5)),),
                    // ),
                    // Positioned(
                    //   top: ScreenUtil().setHeight(isMediaPlay ? 178 : 118).toDouble(),
                    //   child: Row(
                    //     children: <Widget>[
                    //       Container(
                    //         width: 360.w,
                    //         height: 40.h,
                    //         padding: EdgeInsets.only(left: 24.w,right: 12.w),
                    //         child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: [
                    //               Text(
                    //                 '课程优先',
                    //                 style: TextStyle(
                    //                     fontSize: 14.sp,
                    //                     fontWeight: FontWeight.normal,
                    //                     color: Color.fromRGBO(0, 0, 0, 0.87)),
                    //               ),
                    //               Container(
                    //                 // width: ScreenUtil().setWidth(34),
                    //                 child: Switch(
                    //                   activeColor: Color.fromRGBO(249, 122, 53, 1),
                    //                   value: isCourse,
                    //                   onChanged: (bool value) {
                    //                     if(SaveData.userId != null){
                    //                       setState(() {
                    //                         isCourse = value;
                    //                         SaveData.isCourse = value;
                    //                         SharedPreferences.getInstance().then((SharedPreferences value) {
                    //                           value.setBool('isCourse', SaveData.isCourse);
                    //                         });
                    //                       });
                    //                     }else{
                    //                       Method.showToast('没有注册登录账号，无法进行设置', context);
                    //                     }
                    //                   },
                    //                 ),
                    //               ),
                    //             ]),
                    //       )
                    //     ],
                    //   ),
                    // ),
                  ])))),
    );
  }

  void _getPlayRate() {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          return ScreenUtilInit(
            designSize: const Size(1080, 1920),
            builder: () => Material(
                child: Container(
                  width: 1080.w,
                  height: 750.h,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          width: 1080.w,
                          height: 126.h,
                          color: const Color.fromRGBO(244, 245, 249, 1),
                        ),
                      ),
                      Positioned(
                        top: 36.h,
                        right: 54.w,
                        child: GestureDetector(
                          child: Text('Finish'.tr),
                          onTap: () {
                            setState(() {
                              if (pos == 0) {
                                SaveData.sportPlayRate = 10;
                              } else if (pos == 1) {
                                SaveData.sportPlayRate = 20;
                              } else if (pos == 2) {
                                SaveData.sportPlayRate = 50;
                              } else if (pos == 3) {
                                SaveData.sportPlayRate = 100;
                              }
                              SharedPreferences.getInstance().then((value) {
                                value.setInt(
                                    'sportPlayRate', SaveData.sportPlayRate);
                                value.setBool('openMedia', SaveData.openMedia);
                              });
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Positioned(
                        top: 126.h,
                        child: Container(
                          width: 1080.w,
                          height: 612.h,
                          child: CupertinoPicker(
                            itemExtent: 40,
                            diameterRatio: 5,
                            squeeze: 1,
                            onSelectedItemChanged: (position) {
                              pos = position;
                              scrollController1 = FixedExtentScrollController(initialItem: position);
                            },
                            scrollController: scrollController1,
                            children: <Widget>[
                              Center(
                                child: Text("10 " + 'singleCount'.tr),
                              ),
                              Center(
                                child: Text("20 " + 'singleCount'.tr),
                              ),
                              Center(
                                child: Text("50 " + 'singleCount'.tr),
                              ),
                              Center(
                                child: Text("100 " + 'singleCount'.tr),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          );
        });
  }
}
