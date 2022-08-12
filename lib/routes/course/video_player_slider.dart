
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/fileImageEx.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/model/courseList.dart';
import 'package:running_app/routes/course/courseDetailPage.dart';
import 'package:running_app/routes/fasicaGun/fasicaGunMain.dart';
import 'package:running_app/routes/realTimeSport/connectDevice.dart';
import 'package:running_app/routes/userRoutes/userPicture.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import '../../common/blueUuid.dart';
import 'package:get/get.dart';

class PkPage extends StatefulWidget{

  @override
  PkPageState createState() => PkPageState();

}

bool hasNetwork = false;
CourseList courseList;
bool getCourseSuccess = false;

class PkPageState extends State<PkPage> with SingleTickerProviderStateMixin{

  final BlueToothChannel blueToothChannel = BlueToothChannel();
  StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息
  bool scanning = false;
  static bool hasPicture = false;
  bool hasDevice  = false;
  List<String> devicePictureList = [];//添加设备图列表
  List<String> deviceNameList = [];//用于连接设备需要的广播名
  List<String> deviceList = [];//扫描到的设备列表
  List<String> items = [];
  int functionFlag;
  String deviceName;
  List<bool> connect = <bool>[false, false];

  @override
  void initState() {
    super.initState();
    if(SaveData.openedApp){
      SaveData.openedApp = false;
    }
    getDeviceInfo();
    if(hasPicture){
      getTemporaryDirectory().then((value){
        setState(() {
          final File file = File(value.path + '/userImage.png');
          print(file.existsSync());
          if(file.existsSync()){
            getApplicationSupportDirectory().then((value){
              SaveData.pictureUrl = value.path + '/userImage.png';
              file.copy(SaveData.pictureUrl).then((value){
                SharedPreferences.getInstance().then((value){
                  value.setString('pictureUrl', SaveData.pictureUrl);
                });
                file.deleteSync();
              });
            });
          }else{
            getApplicationSupportDirectory().then((value){
              SaveData.pictureUrl = value.path + '/userImage.png';
              print(SaveData.pictureUrl);
              SharedPreferences.getInstance().then((value){
                value.setString('pictureUrl', SaveData.pictureUrl);
              });
            });
          }
        });
      });
    }
    _streamSubscription = blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
  }

  void getDeviceInfo(){
    SharedPreferences.getInstance().then((value){
      if(value.getBool('isCourse') != null){
        SaveData.isCourse = value.getBool('isCourse');
      }
      if(value.getStringList('hasConnectDeviceBroadcast') != null && value.getStringList('hasConnectDeviceBroadcast').isNotEmpty){
        if(mounted){
          setState(() {
            hasDevice = true;
            devicePictureList = value.getStringList('hasConnectDevicePicture');
            deviceList = value.getStringList('hasConnectDeviceName');
            deviceNameList = value.getStringList('hasConnectDeviceBroadcast');
          });
        }
      }
    }).whenComplete((){
      items = List<String>.generate(deviceList.length, (i) => 'Item ${i + 1}');
    });
  }

  @override
  void dispose() {
    super.dispose();
    if(_streamSubscription != null){
      _streamSubscription.cancel();
      _streamSubscription = null;
    }
  }

  void _onToDart(dynamic message) {
    switch (message['code']) {
      case '80001':
        break;
      case '8000A':
        getPermission();
        break;
      case '8000D':
        getPermission();
        break;
      case '8000E':
        getPermission();
        break;
    }
  }

  void getPermission() {
    blueToothChannel.checkWhatPermission(context).then((bool value){
      if(value){
        if(functionFlag == 1){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectDevicePage())).then((value){
            getDeviceInfo();
            _openStreamNotify();
          });
        }else if(functionFlag == 2){
          Method.showLessLoading(context, 'Connecting'.tr);
          blueToothChannel.connectDevice(deviceName, 0);
        }
      }
    });
  }

  static bool homePage = true;

  void _onToDartError(dynamic error) {
    switch (error.code) {
      case '90001':
        _canPopRoutes();
        print('90001');
        Method.showToast('Connect failed'.tr, context);
        homePage = true;
        break;
      case '90003':
        Method.showToast('Location permission required'.tr, context);
        _canPopRoutes();
        break;
      case '90004':
        Method.showToast('Enable Location services'.tr, context);
        _canPopRoutes();
        break;
      case '90005':
        Method.showToast('Enable Bluetooth'.tr, context);
        _canPopRoutes();
        break;
      case '90006':
        _canPopRoutes();
        break;
      case '90007':
        _canPopRoutes();
        break;
    }
  }

  void _canPopRoutes(){
    if(Navigator.of(context).canPop()){
      Navigator.of(context).pop();
    }
  }

  void _openStreamNotify() {
    _streamSubscription = blueToothChannel.eventChannelPlugin
        .receiveBroadcastStream()
        .listen(_onToDart, onError: _onToDartError); //注册消息回调函数
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => Material(
          color: const Color.fromRGBO(249, 122, 53, 1),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                left: 72.w,
                top: 168.h,
                child: Text('Welcome back'.tr, style: TextStyle(fontSize: 36.sp,color: Colors.white),),
              ),
              Positioned(
                left: 72.w,
                top: 216.h,
                child: Text("let's start exercising!".tr,style: TextStyle(fontSize: 60.sp,color: Colors.white),),
              ),
              Positioned(
                right: 72.w,
                top: 176.h,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserPicturePage(SaveData.pictureUrl))).then((value){
                      getDeviceInfo();
                      _openStreamNotify();
                    });
                  },
                  child: Container(
                      width: 114.h,
                      height: 114.h,
                      padding: EdgeInsets.all(0),
                      // color: Colors.yellow,
                      child: SaveData.pictureUrl == null ? Image.asset('images/home_user.png',width: 57.w,height: 57.h)
                          : ClipOval(
                        child: Image(image: FileImageEx(File(SaveData.pictureUrl)),),
                      )
                  ),
                ),
              ),
              Positioned(
                top: 372.h,
                child: Container(
                  width: 1080.w,
                  height: 1548.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(72.w),
                          topRight: Radius.circular(72.w)),
                      color: Colors.white),
                ),
              ),
              Positioned(
                top: 422.h,
                child: Text(
                  'Home'.tr,
                  style: TextStyle(fontSize: 42.sp),
                ),
              ),
              Positioned(
                left: 494.w,
                top: 501.h,
                child: Container(
                  width: 90.w,
                  height: 3.h,
                  decoration: BoxDecoration(color: Colors.black),
                ),
              ),
              Positioned(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        width: 200.w,
                        height: 200.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(100.w)
                        ),
                        child: !connect[0] ? Icon(Icons.add, color: Colors.black.withOpacity(0.7),) : SaveData.pictureUrl == null ? Image.asset('images/home_user.png')
                            : Image.file(File(SaveData.pictureUrl)),
                      ),
                      onTap: (){
                        // connectDevice();
                      },
                    ),
                    InkWell(
                      onTap: (){

                      },
                      child: Container(
                        width: 200.w,
                        height: 200.w,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(100.w)
                        ),
                        child: !connect[0] ? Icon(Icons.add, color: Colors.black.withOpacity(0.7)) : SaveData.pictureUrl == null ? Image.asset('images/home_user.png')
                            : Image.file(File(SaveData.pictureUrl)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }

  void connectDevice(String deviceName){
    if(defaultTargetPlatform == TargetPlatform.android){
      blueToothChannel.checkWhatPermission(context).then((bool value){
        if(value){
          Method.showLessLoading(context, 'Connecting'.tr);
          blueToothChannel.connectDevice(deviceName, 0);
        }
      });
    }else{
      Method.showLessLoading(context, 'Connecting'.tr);
      blueToothChannel.connectDevice(deviceName, 0);
    }
  }

  Widget buildConnectDevice(int i) {
    final item = items[i];
    return Dismissible(
      key: Key(item),
      child: Container(
          height: 200.h,
          margin: EdgeInsets.only(
              right: 72.w, top: 24.w,left: 72.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48.w),
            color: const Color.fromRGBO(246, 247, 249, 1),
          ),
          child: Center(
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 72.w, right: 72.w),
              leading: Image.asset(
                devicePictureList[i],
                height: 110.h,
              ),
              title: Text(
                deviceList[i],
                style: TextStyle(fontSize: 48.sp, height: 1),
              ),
              trailing: Icon(Icons.check_circle),
              onTap: (){
                functionFlag = 2;
                deviceName = deviceNameList[i];
                if(defaultTargetPlatform == TargetPlatform.android){
                  blueToothChannel.checkWhatPermission(context).then((bool value){
                    if(value){
                      Method.showLessLoading(context, 'Connecting'.tr);
                      blueToothChannel.connectDevice(deviceNameList[i], 0);
                    }
                  });
                }else{
                  Method.showLessLoading(context, 'Connecting'.tr);
                  blueToothChannel.connectDevice(deviceNameList[i], 0);
                }
              },
            ),
          )
      ),
      onDismissed: (DismissDirection direction){
        setState(() {
          items.removeAt(i);
          devicePictureList.removeAt(i);
          deviceList.removeAt(i);
          deviceNameList.removeAt(i);
          SharedPreferences.getInstance().then((value){
            value.setStringList('hasConnectDevicePicture', devicePictureList);
            value.setStringList('hasConnectDeviceName', deviceList);
            value.setStringList('hasConnectDeviceBroadcast', deviceNameList);
          });
          if(deviceList.isEmpty){
            hasDevice = false;
          }
        });
      },
    );
  }
}