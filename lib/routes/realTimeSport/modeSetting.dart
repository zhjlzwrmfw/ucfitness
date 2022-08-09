import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/common/encapMethod.dart';
import '../../common/blueUuid.dart';
import '../../common/saveData.dart';
import 'mainSport.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ModeSettingPage extends StatefulWidget{

  @override
  ModeSettingPageState createState() => ModeSettingPageState();

}

class ModeSettingPageState extends State<ModeSettingPage>{

  List<bool> userChoseMode = [true, false, false, false, false, false];
  List<bool> userChoseTrain = [true, false, false];
  List<String> modeName = new List();
  List<String> modePicture = new List();
  // List<String> modeNameEn = ['Mode one', 'Mode two', 'Mode three', 'Mode four', 'Mode five', 'Mode six'];
  List<String> modeNameEn = new List();
  bool choseDevice = true;//用于判断选择哪种设备
  bool skipDevice = false;//选择跳绳
  int connectDevice;
  int choseDeviceMode;
  bool minute1 = true;
  bool minute2 = false;
  bool minute5 = false;
  bool minute10 = false;
  bool minute30 = false;
  bool customMinute = false;
  String inputNumber;
  TextEditingController _controller = new TextEditingController();
  final BlueToothChannel blueToothChannel = new BlueToothChannel();
  StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息

  @override
  void initState() {
    super.initState();
    initDataMode();
    _streamSubscription = blueToothChannel.eventChannelPlugin
        .receiveBroadcastStream()
        .listen(_onToDart, onError: _onToDartError);
  }

  void initDataMode(){
    if(MainSportPageState.deviceName == '蝴蝶绳'){
      modeName..add('向上弯举')..add('仰卧划船')..add('坐姿弯举')..add('坐姿划船');
      modeNameEn..add('Standard\nbicep curls')..add('Supine\nposition rowing')..add('Seated\npreacher curl')..add('Seated\nband row');
      modePicture..add('images/hudiesheng1.gif')..add('images/hudiesheng2.gif')
        ..add('images/hudiesheng3.gif')..add('images/hudiesheng4.gif');
      connectDevice = 4;
    }else if(MainSportPageState.deviceName == '拉力绳'){
      modeName..add('站姿划船')..add('侧平举')..add('向上弯举')..add('过顶屈伸')..add('背部舒展')..add('扩胸运动');
      modeNameEn..add('Resistance\nband rows')..add('Lateral raise')..add('Standard\nbicep curls')..add('Overhead tricep\nextensions')..add('Back stretch')..add('Chest pull');
      modePicture..add('images/lalisheng1.gif')..add('images/lalisheng2.gif')
        ..add('images/lalisheng3.gif')..add('images/lalisheng4.gif')..add('images/lalisheng5.gif')..add('images/lalisheng6.gif');
      connectDevice = 2;
    }else if(MainSportPageState.deviceName == '哑铃'){
      modeName..add('哑铃弯举')..add('俯身臂屈伸')..add('颈后臂屈伸')..add('俯身划船');
      modeNameEn..add('Bicep curls')..add('Bent over tricep\nextension')..add('Overhead tricep\nextensions')..add('Bent over rows');
      modePicture..add('images/yaling1.gif')..add('images/yaling2.gif')
        ..add('images/yaling3.gif')..add('images/yaling4.gif');
      connectDevice = 3;
    }else if(MainSportPageState.deviceName == '健腹轮'){
      modeName..add('跪姿卷腹')..add('站姿卷腹');
      modeNameEn..add('Keenling rollout')..add('Standing rollout');
      modePicture..add('images/jianfulun1.gif')..add('images/jianfulun2.gif');
      choseDevice = false;
      connectDevice = 5;
    }else if(MainSportPageState.deviceName == '跳绳'){
      modeName.add('自由跳绳');
      modeNameEn.add('Jump rope\nworkouts');
      modePicture.add('images/tiaosheng.gif');
      choseDevice = false;
      skipDevice = true;
      userChoseMode[0] = true;
      connectDevice = 1;
    }
    SaveData.sportPosture = SaveData.english ? modeNameEn[0] : modeName[0];
  }

  void _onToDart(dynamic message) {
    switch (message['code']) {
      case '80005':
        break;
    }
  }

  void _onToDartError(dynamic error) {
    switch (error.code) {
      case '90002':
        Method.showToast('Device disconnected'.tr, context, second: 2);
        Navigator.popUntil(context, ModalRoute.withName('MyHomePage'));
        break;
      case '90003':
        Method.showToast('Device disconnected'.tr, context, second: 2);
        Navigator.popUntil(context, ModalRoute.withName('MyHomePage'));
        break;
      case '90004':
        Method.showToast('Device disconnected'.tr, context, second: 2);
        Navigator.popUntil(context, ModalRoute.withName('MyHomePage'));
        break;
      case '90005':
        Method.showToast('Device disconnected'.tr, context, second: 2);
        Navigator.popUntil(context, ModalRoute.withName('MyHomePage'));
        break;
      case '90006':
        Method.showToast('Device disconnected'.tr, context, second: 2);
        Navigator.popUntil(context, ModalRoute.withName('MyHomePage'));
        break;
      case '90007':
        Method.showToast('Device disconnected'.tr, context, second: 2);
        Navigator.popUntil(context, ModalRoute.withName('MyHomePage'));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => Scaffold(
        appBar: AppBar(
          title: Text('Select mode'.tr, style: TextStyle(fontSize: 42.sp,color: Colors.white)),
          centerTitle: false,
          backgroundColor: Color.fromRGBO(249, 122, 53, 1),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          width: 960.w,
          height: 140.h,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(9)),
              color: Color.fromRGBO(111, 122, 135, 1)
          ),
          child: FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Text('OK2'.tr,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 42.sp,color: Colors.white),),
            onPressed: (){
              if(MainSportPageState.deviceName == '跳绳'){
                blueToothChannel.setMode(0, connectDevice);
              }else{
                if(SaveData.deviceName.substring(0,4) != BlueUuid.HeadSkipBroadcast
                    && SaveData.deviceName.substring(0,5) != BlueUuid.HuaWeiSkipBroadcast
                    && SaveData.deviceName.substring(0,13) != BlueUuid.sj500Broadcast){
                  if(userChoseMode[0]){
                    blueToothChannel.setMode(1, connectDevice);
                  }else if(userChoseMode[1]){
                    blueToothChannel.setMode(2, connectDevice);
                  }else if(userChoseMode[2]){
                    blueToothChannel.setMode(3, connectDevice);
                  }else if(userChoseMode[3]){
                    blueToothChannel.setMode(4, connectDevice);
                  }else if(userChoseMode[4]){
                    blueToothChannel.setMode(3, connectDevice);
                  }else if(userChoseMode[5]){
                    blueToothChannel.setMode(4, connectDevice);
                  }
                }
              }
              choseMode();
              SaveData.choseMode = true;
              if(userChoseTrain[0]){
                SaveData.choseType = 0;
                SaveData.modeName = '自由模式';
              }else if(userChoseTrain[1]){
                SaveData.choseType = 100;
                SaveData.modeName = '计时模式';
              }else if(userChoseTrain[2]){
                SaveData.choseType = 200;
                SaveData.modeName = '计数模式';
              }
              Navigator.of(context).pop(1);
            },
          ),
        ),
        body: Material(
          child: ListView(
            padding: EdgeInsets.only(left: 72.w,right: 72.w),
            children: <Widget>[
              SizedBox(height: 72.h,),
              Text('select type'.tr, style: TextStyle(fontSize: 42.sp,fontWeight: FontWeight.bold),),
              SizedBox(height: 72.h,),
              Wrap(
                alignment: modeName.length == 1 ? WrapAlignment.center : WrapAlignment.start,
                spacing: 36.w,
                runSpacing : 36.w,
                children: modeBox(),
              ),
              SizedBox(height: 108.h,),
              Text('Train Mode'.tr, style: TextStyle(fontSize: 42.sp,fontWeight: FontWeight.bold),),
              SizedBox(height: 72.h,),
              Wrap(
                spacing: 34.w,
                children: trainBox(),
              ),
              SizedBox(
                height: 300.h,
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> modeBox() => List.generate(modeName.length, (index) {
    return modeSetting(index);
  });

  List<Widget> trainBox() => List.generate(3, (index) {
    return trainSetting(index);
  });

  Widget trainSetting(int index){
    return Container(
      width: 288.w,
      height: 134.h,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: userChoseTrain[index] ? const Color.fromRGBO(255, 189, 153, 1) : Colors.white10,
        border: Border.all(width: 3.w, color: const Color.fromRGBO(238, 240, 242, 1)),
      ),
      child: RepaintBoundary(
        child: FlatButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: index == 1 || index == 2 ? <Widget>[
              Text(index == 0 ? 'Free mode'.tr : index == 1 ? 'Time training'.tr : 'Count training'.tr,
                style: TextStyle(fontWeight: FontWeight.normal,fontSize: 36.sp,color: Color.fromRGBO(0, 0, 0, 0.87)),),
              if(inputNumber != null && userChoseTrain[index])
                Text(inputNumber  + (index == 1 ? 'minutes'.tr : ''), style: TextStyle(fontWeight: FontWeight.normal,fontSize: 32.sp,color: Color.fromRGBO(0, 0, 0, 0.87)),),
            ] : <Widget>[Text(index == 0 ? 'Free mode'.tr : index == 1 ? 'Time training'.tr : 'Count training'.tr,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 36.sp,color: Color.fromRGBO(0, 0, 0, 0.87)),),],
          ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          padding: EdgeInsets.zero,
          onPressed: (){
            setState(() {
              if(index == 0){
                userChoseTrain = [true, false, false];
                SaveData.modeName = '自由模式';
              }else if(index == 1){
                userChoseTrain = [false, true, false];
                inputNumber = null;
                minute1 = true;
                minute2 = false;
                minute5 = false;
                minute10 = false;
                minute30 = false;
                customMinute = false;
                showBottomSheet();
                SaveData.modeName = '计时模式';
              }else if(index == 2){
                userChoseTrain = [false, false, true];
                inputNumber = null;
                minute1 = true;
                minute2 = false;
                minute5 = false;
                minute10 = false;
                minute30 = false;
                customMinute = false;
                showBottomSheet();
                SaveData.modeName = '计数模式';
              }
            });
          },
        ),
      ),
    );
  }

  Widget modeSetting(int index){
    return GestureDetector(
      onTap: (){
        choseWhichMode(index);
      },
      child: Container(
        width: 447.w,
        height: 472.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: Border.all(width: 3.w,color: userChoseMode[index] ? Color.fromRGBO(255, 104, 0, 0.45):Color.fromRGBO(238, 240, 242, 1)),
          color: userChoseMode[index] ? Color.fromRGBO(255, 138, 101, 0.24) : Colors.white10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RepaintBoundary(child: Image.asset(modePicture[index], height: 282.h,)),
            Container(
              height: 16.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RepaintBoundary(
                  child: Image.asset(
                    userChoseMode[index]
                        ? 'images/selected.png'
                        : 'images/notselected.png',
                    width: 48.w,
                    height: 48.w,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left:14.w),
                  child: Text(
                    SaveData.english ? modeNameEn[index] : modeName[index],
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 42.sp,
                        height: 1.2,),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void choseWhichMode(int index) {
    setState(() {
      switch(index) {
        case 0 :
          userChoseMode = [true, false, false, false, false, false];
          SaveData.sportMode = 1;
          SaveData.sportPosture = SaveData.english ? modeNameEn[0] : modeName[0];
          break;
        case 1 :
          userChoseMode = [false, true, false, false, false, false];
          SaveData.sportMode = 2;
          SaveData.sportPosture = SaveData.english ? modeNameEn[1] : modeName[1];
          break;
        case 2 :
          userChoseMode = [false, false, true, false, false, false];
          SaveData.sportMode = 3;
          SaveData.sportPosture = SaveData.english ? modeNameEn[2] : modeName[2];
          break;
        case 3 :
          userChoseMode = [false, false, false, true, false, false];
          SaveData.sportMode = 4;
          SaveData.sportPosture = SaveData.english ? modeNameEn[3] : modeName[3];
          break;
        case 4 :
          userChoseMode = [false, false, false, false, true, false];
          SaveData.sportMode = 5;
          SaveData.sportPosture = SaveData.english ? modeNameEn[4] : modeName[4];
          break;
        case 5 :
          userChoseMode = [false, false, false, false, false, true];
          SaveData.sportMode = 6;
          SaveData.sportPosture = SaveData.english ? modeNameEn[5] : modeName[5];
          break;
      }
    });
  }

  void showBottomSheet() {
    _streamSubscription = blueToothChannel.eventChannelPlugin
        .receiveBroadcastStream()
        .listen(_onToDart, onError: _onToDartError); //注册消息回调函数
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        isDismissible: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, openState) {
            return ScreenUtilInit(
              designSize: const Size(1080, 1920),
              builder: () => Material(
                child: Container(
                  height: 640.h,
                  width: 1080.w,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          width: 1080.w,
                          height: 120.h,
                          color: Color.fromRGBO(244, 245, 249, 1),
                        ),
                      ),
                      Positioned(
                        top: 162.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                userChoseTrain[1] ? choseTimeBuild('1' + 'minutes'.tr, 0, minute1, openState) : choseTimeBuild('100', 0, minute1, openState),
                                userChoseTrain[1] ? choseTimeBuild('2' + 'minutes'.tr, 1, minute2, openState) : choseTimeBuild('200', 1, minute2, openState),
                                userChoseTrain[1] ? choseTimeBuild('5' + 'minutes'.tr, 2, minute5, openState) : choseTimeBuild('300', 2, minute5, openState),
                                userChoseTrain[1] ? choseTimeBuild('10' + 'minutes'.tr, 3, minute10, openState) : choseTimeBuild('400', 3, minute10, openState),
                              ],
                            ),
                            SizedBox(
                              height: 40.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                userChoseTrain[1] ? choseTimeBuild('30' + 'minutes'.tr, 4, minute30, openState) : choseTimeBuild('500', 4, minute30, openState),
                                choseTimeBuild('customize'.tr, 5, customMinute, openState),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 34.h,
                        right: 56.w,
                        child: GestureDetector(
                          child: Text('Finish'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                          onTap: inputNumber == null && customMinute ? null : (){
                            if(minute1 && userChoseTrain[1]){
                              SaveData.choseNumber = 1;
                            }else if(minute1 && userChoseTrain[2]){
                              SaveData.choseNumber = 100;
                            }
                            inputNumber = SaveData.choseNumber.toString();
                            // print("SaveData.choseNumber: ${SaveData.choseNumber}");
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Positioned(
                        top: 34.h,
                        left: 56.w,
                        child: GestureDetector(

                          child: Text('Cancel'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        }).then((value){
      setState(() {});
    });
  }

  Widget choseTimeBuild(String time, int index, bool minuteType, Function openState){
    return Container(
      width: 220.w,
      height: 200.h,
      margin: index == 0 || index == 4 ? EdgeInsets.only(right: 36.w,left: 24.w) : EdgeInsets.only(right: 36.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: minuteType ? Color.fromRGBO(255, 189, 153, 1) : Colors.white,
          border: Border.all(width: 3.w,color: Color.fromRGBO(238, 240, 242, 1))
      ),
      child: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))
        ),
        padding: EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(time, style: TextStyle(fontWeight: FontWeight.normal,fontSize: 40.sp)),
          ],
        ),
        onPressed: () async {
          if(index == 5){
            openState(() {
              customMinute = true;
              minute1 = false;
              minute2 = false;
              minute5 = false;
              minute10 = false;
              minute30 = false;
              _controller.clear();
            });
            customTime();
          }else if(index == 0){
            openState(() {
              customMinute = false;
              minute1 = true;
              minute2 = false;
              minute5 = false;
              minute10 = false;
              minute30 = false;
              _controller.clear();
              if(userChoseTrain[1]){
                SaveData.choseNumber = 1;
              }else if(userChoseTrain[2]){
                SaveData.choseNumber = 100;
              }
            });
          }else if(index == 1){
            openState(() {
              customMinute = false;
              minute1 = false;
              minute2 = true;
              minute5 = false;
              minute10 = false;
              minute30 = false;
              _controller.clear();
              if(userChoseTrain[1]){
                SaveData.choseNumber = 2;
              }else if(userChoseTrain[2]){
                SaveData.choseNumber = 200;
              }
            });
          }else if(index == 2){
            openState(() {
              customMinute = false;
              minute1 = false;
              minute2 = false;
              minute5 = true;
              minute10 = false;
              minute30 = false;
              _controller.clear();
              if(userChoseTrain[1]){
                SaveData.choseNumber = 5;
              }else if(userChoseTrain[2]){
                SaveData.choseNumber = 300;
              }
            });
          }else if(index == 3){
            openState(() {
              customMinute = false;
              minute1 = false;
              minute2 = false;
              minute5 = false;
              minute10 = true;
              minute30 = false;
              _controller.clear();
              if(userChoseTrain[1]){
                SaveData.choseNumber = 10;
              }else if(userChoseTrain[2]){
                SaveData.choseNumber = 400;
              }
            });
          }else if(index == 4){
            openState(() {
              customMinute = false;
              minute1 = false;
              minute2 = false;
              minute5 = false;
              minute10 = false;
              minute30 = true;
              _controller.clear();
              if(userChoseTrain[1]){
                SaveData.choseNumber = 30;
              }else if(userChoseTrain[2]){
                SaveData.choseNumber = 500;
              }
            });
          }
        },
      ),
    );
  }

  String sportMode(){
    return SaveData.sportMode == 1 ? modeName[0]
        : SaveData.sportMode == 2 ? modeName[1]
        : SaveData.sportMode == 3 ? modeName[2]
        : SaveData.sportMode == 4 ? modeName[3]
        : modeName[4];
  }

  void customTime(){
    showDialog<void>(
        context: context,
        builder: (context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Center(
              child: Text(userChoseTrain[1] ? 'Set time goal'.tr : 'Set count goal'.tr, style: TextStyle(fontSize: 56.sp),),
            ),
            content: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: userChoseTrain[1] ? 'Time goal'.tr +'(1-60)' : 'Count goal'.tr +'(1-9999)' ,
                hintStyle: TextStyle(fontSize: 16),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(234, 236, 243, 1),
                      width: 6.w,
                    )),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(249, 122, 53, 1),
                      width: 6.w,
                    )),
              ),
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              onChanged: (str){
                inputNumber = str;
                // print(inputNumber);
                // print(inputNumber != null);
              },
            ),
            actions: <Widget>[     //监听器
              FlatButton(              //确定监听
                child: Text('Cancel'.tr, style: TextStyle(fontWeight: FontWeight.normal,color: Color.fromRGBO(249, 122, 53, 1),),),
                onPressed: (){
                  inputNumber = null;
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(              //取消监听
                child: Text('OK2'.tr, style: TextStyle(fontWeight: FontWeight.normal,color: Color.fromRGBO(249, 122, 53, 1),),),
                onPressed: () {
                  if(inputNumber != null){
                    if (userChoseTrain[1]) {
                      if (int.parse(inputNumber) > 60 || int.parse(inputNumber) == 0) {
                        Method.showToast("Time must be between 1 and 60 minutes.".tr, context, position: 1);
                      } else {
                        SaveData.choseNumber = int.parse(inputNumber);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                    } else if (userChoseTrain[2]) {
                      if (int.parse(inputNumber) > 9999 || int.parse(inputNumber) == 0) {
                        Method.showToast('Count must be between 1 and 9999.'.tr, context, position: 1);
                      } else {
                        SaveData.choseNumber = int.parse(inputNumber);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                    }
                  }
                }
                ,
              )
            ],
          );
        }
    );
  }

  void choseMode(){
    if(userChoseMode[0]){
      SaveData.devicePicture = modePicture[0];
    }else if(userChoseMode[1]){
      SaveData.devicePicture = modePicture[1];
    }else if(userChoseMode[2]){
      SaveData.devicePicture = modePicture[2];
    }else if(userChoseMode[3]){
      SaveData.devicePicture = modePicture[3];
    }else if(userChoseMode[4]){
      SaveData.devicePicture = modePicture[4];
    }else if(userChoseMode[5]){
      SaveData.devicePicture = modePicture[5];
    }
  }
}