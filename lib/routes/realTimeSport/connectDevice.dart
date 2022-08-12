import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_bluetooth_plugin/my_bluetooth_plugin.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/routes/course/video_player_slider.dart';
import 'package:running_app/routes/fasicaGun/fasicaGunMain.dart';
import 'package:running_app/widgets/waterRipple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import '../../common/blueUuid.dart';
import 'mainSport.dart';
import 'package:get/get.dart';

class ConnectDevicePage extends StatefulWidget{

  final int courseType;
  ConnectDevicePage({this.courseType});

  @override
  ConnectDevicePageState createState() => ConnectDevicePageState();

}

class ConnectDevicePageState extends State<ConnectDevicePage> with SingleTickerProviderStateMixin{

  String deviceSubString;//截取扫描到的设备名的特定字符串
  Set<String> deviceSet = new Set();//扫描到的设备名去重
  List<String> devicePictureList = [];//添加设备图列表
  List<String> deviceNameList = [];//用于连接设备需要的广播名
  Set<String> deviceNameSet = new Set();//去除重复的广播名
  List<int> deviceTypeName = [];//用于在课程连接设备时区分连接哪种设备
  bool findDevice = false;//扫描设备标志位
  List<String> deviceList = [];//扫描到的设备列表
  bool firstFind = true;//用于扫描不到
  bool firstScan = false;//用于出现水波纹扫描
//用于防止设备图重复添加至设备图列表
  Map<String, Object> dataMap = {
    'scanDuring': 3,
    'passUuid': null,
    'passUuidDataType': defaultTargetPlatform == TargetPlatform.android ? 3 : 0
  };
  BlueToothChannel blueToothChannel = BlueToothChannel();
  StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息

  bool scanning = false;
  static bool hasPicture = false;

  List<String> hasConnectDeviceName = <String>[];//已经连接过的设备名
  List<String> hasConnectDeviceBroadcast = <String>[];//已经连接过的设备广播名
  List<String> hasConnectDevicePicture = <String>[];//已经连接过的设备图片
  int connectIndex;//标志连接哪个设备

  @override
  void initState() {
    super.initState();
    if(SaveData.openedApp){
      SaveData.openedApp = false;
    }
    SharedPreferences.getInstance().then((value){
      if(value.getStringList('hasConnectDeviceBroadcast') != null){
        hasConnectDevicePicture = value.getStringList('hasConnectDevicePicture');
        hasConnectDeviceName = value.getStringList('hasConnectDeviceName');
        hasConnectDeviceBroadcast = value.getStringList('hasConnectDeviceBroadcast');
      }
    });
    _streamSubscription = blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
    MyBluetoothPlugin.scanDevice(dataMap);
    delayScan();
  }

  void delayScan(){
    Future.delayed(const Duration(seconds: 4),(){
      if(mounted){
        setState(() {
          firstScan = true;
          if(deviceList.isEmpty){//如果扫描不到设备
            findDevice = false;
            firstFind = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    MyBluetoothPlugin.stopScan();
  }

  void _onToDart(dynamic message) {
    switch (message['code']) {
      case "80006": //如果是扫描到一个设备
        print('扫描到广播名为:' + message['deviceName']);
        deviceSubString = message['deviceName'] as String;
        if(deviceSubString.length > 14){
          if(deviceSubString.substring(0, 10) == BlueUuid.SmartGripBroadcast || deviceSubString.substring(0, 12) == BlueUuid.HuaweiGripBroadcast){
            deviceNameSet.add(message['deviceName'].toString());
            deviceSet.add('grip'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
          }else if(deviceSubString.substring(0,4) == BlueUuid.HeadSkipBroadcast){
            if(deviceSubString.substring(0,10) == 'HEAD-SR105'){
              deviceNameSet.add(message['deviceName'] as String);
              deviceSet.add('head-SR105'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
            }else if(deviceSubString.substring(0,10) == 'HEAD-SR900'){
              deviceNameSet.add(message['deviceName'] as String);
              deviceSet.add('headJumpRpoeSR900'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
            }else{
              deviceNameSet.add(message['deviceName'] as String);
              deviceSet.add('headJumpRpoe'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
            }
          }else if(deviceSubString.substring(0,12) == BlueUuid.HuaWeiSkipBroadcast && deviceSubString.substring(12, 16) == 'GOD0'){
            deviceNameSet.add(message['deviceName'] as String);
            deviceSet.add('jumpRope200'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
          }else if (deviceSubString.substring(0,12) == BlueUuid.TergasySkipBroadcast) {
            deviceNameSet.add(message['deviceName'] as String);
            deviceSet.add('jumpRope'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
          }else if(deviceSubString.substring(0,13) == BlueUuid.TergasyRopeABroadcast){
            deviceNameSet.add(message['deviceName'] as String);
            deviceSet.add('resistanceBand'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
          }else if(deviceSubString.substring(0,13) == BlueUuid.TergasyROPEBBroadcast){
            deviceNameSet.add(message['deviceName'] as String);
            deviceSet.add('spiderBand'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
          }else if(deviceSubString.substring(0,13) == BlueUuid.TergasyROUNDBroadcast){
            deviceNameSet.add(message['deviceName'] as String);
            deviceSet.add('abWheel'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
          }else if (deviceSubString.substring(0,12) == BlueUuid.TergasyDUMBBroadcast) {
            deviceNameSet.add(message['deviceName'] as String);
            deviceSet.add('dumbBell'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
          }else if(deviceSubString.substring(0,13) == BlueUuid.sj500Broadcast){
            deviceNameSet.add(message['deviceName'] as String);
            deviceSet.add('SJ500'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
          }else if(deviceSubString.substring(0,5) == BlueUuid.sj300Broadcast){
            deviceNameSet.add(message['deviceName'] as String);
            deviceSet.add('SJ300'.tr + ' - ' + deviceSubString.substring(deviceSubString.length - 4));
          }
          if(deviceList.isNotEmpty){//如果扫到设备
            firstFind = true;
          }
        }
        break;
      case '80007': //如果是扫描结束
        if(mounted){
          setState(() {
            if(deviceNameSet.isNotEmpty){
              deviceTypeName.clear();
              deviceList = deviceSet.toList();
              deviceNameList = deviceNameSet.toList();
              print(deviceNameList);
              for(int i = 0; i < deviceNameList.length; i++){
                if(deviceNameList[i].substring(0, 4) == BlueUuid.HeadSkipBroadcast
                    || deviceNameList[i].substring(0, 12) == BlueUuid.HuaWeiSkipBroadcast
                    || deviceNameList[i].substring(0, 5) == BlueUuid.sj300Broadcast
                    || deviceNameList[i].substring(0, 13) == BlueUuid.sj500Broadcast){
                  devicePictureList.add('images/tiaosheng.png');
                  deviceTypeName.add(1);
                }else if(deviceNameList[i].substring(0, 10) == 'Smart-Grip' || deviceNameList[i].substring(0, 12) == BlueUuid.HuaweiGripBroadcast){
                  devicePictureList.add('images/wolihuan.png');
                  deviceTypeName.add(6);
                }else if(deviceNameList[i].substring(0, 13) == BlueUuid.TergasyRopeABroadcast){
                  devicePictureList.add('images/lalisheng.png');
                  deviceTypeName.add(2);
                }else if(deviceNameList[i].substring(0, 13) == BlueUuid.TergasyROPEBBroadcast){
                  devicePictureList.add('images/hudiesheng .png');
                  deviceTypeName.add(4);
                }else if(deviceNameList[i].substring(0, 13) == BlueUuid.TergasyROUNDBroadcast){
                  devicePictureList.add('images/jianfulun.png');
                  deviceTypeName.add(5);
                }else if(deviceNameList[i].substring(0, 12) == BlueUuid.TergasyDUMBBroadcast){
                  devicePictureList.add('images/yaling.png');
                  deviceTypeName.add(3);
                }
              }
              print(deviceTypeName);
            }
            firstScan = true;
            scanning = false;
            if(deviceList.isEmpty){//如果扫描不到设备
              findDevice = false;
              firstFind = false;
            }else{
              findDevice = true;
            }
          });

        }
        break;
      case '80001':
        disconnect = false;
        Future<void>.delayed(const Duration(milliseconds: 3000), () {
          if(!disconnect){
            if(Navigator.canPop(context)){
              Navigator.of(context).pop();
            }
            addDevice();
            if(widget.courseType == null){
              Navigator.push<Object>(context, MaterialPageRoute(builder: (BuildContext context) {
                return MainSportPage();
              })).then((Object value){
                _streamSubscription = blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
              });
            }else{
              Navigator.of(context).pop(true);
            }
          }
        });
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

  void confirm(){}

  void addDevice(){
    if(!hasConnectDeviceBroadcast.contains(deviceNameList[connectIndex])){
      SaveData.changeState = true;
      SaveData.onclickPage.clear();
      hasConnectDeviceBroadcast.add(deviceNameList[connectIndex]);
      hasConnectDeviceName.add(deviceList[connectIndex]);
      hasConnectDevicePicture.add(devicePictureList[connectIndex]);
      SharedPreferences.getInstance().then((value){
        value.setStringList('hasConnectDeviceBroadcast', hasConnectDeviceBroadcast);
        value.setStringList('hasConnectDeviceName', hasConnectDeviceName);
        value.setStringList('hasConnectDevicePicture', hasConnectDevicePicture);
      });
    }
  }

  bool disconnect = false;

  void _onToDartError(dynamic error) {
    switch (error.code) {
      case '90001':
        _canPopRoutes();
        disconnect = true;
        Method.showToast('Connect failed'.tr, context);
        break;
      case '90002':
        _canPopRoutes();
        disconnect = true;
        Method.showToast('Connect failed'.tr, context);
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

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => Scaffold(
        appBar: AppBar(
          leading: FlatButton(
            child: Icon(Icons.arrow_back_ios, color: Colors.white,),
            onPressed: (){
              MyBluetoothPlugin.stopScan();
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: const Color.fromRGBO(249, 122, 53, 1),
          actions: <Widget>[
            if(findDevice)
              FlatButton.icon(
                  padding: EdgeInsets.all(0),
                  textTheme: ButtonTextTheme.normal,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onPressed: scanning ? null : (){
                    setState(() {
                      scanning = true;
                      //List清空是为了重新放进设备信息
                      deviceList.clear();
                      deviceSet.clear();
                      devicePictureList.clear();
                      deviceNameList.clear();
                      deviceNameSet.clear();
                      firstScan = false;
                      functionFlag = 1;
                      if(defaultTargetPlatform == TargetPlatform.android){
                        blueToothChannel.checkWhatPermission(context).then((bool value){
                          if(value){
                            MyBluetoothPlugin.scanDevice(dataMap);
                          }
                        });
                      }else{
                        MyBluetoothPlugin.scanDevice(dataMap);
                      }
                      delayScan();
                    });
                  },
                  icon: Icon(Icons.add,size: 56.w,color: Colors.white,),
                  label: Text('Search devices'.tr, style: TextStyle(fontSize: 42.sp, fontWeight: FontWeight.normal, color: Colors.white),)),
            SizedBox(
              width: 72.w,
            )
          ],
        ),
        body: firstScan ? RefreshIndicator(
          child: Container(
            width: 1080.w,
            height: 1716.h,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 72.h,
                    ),
                    if(!findDevice)
                      SizedBox(
                        height: 376.h,
                      ),
                    if(!findDevice)
                      Image.asset(firstFind ? "images/home_finding.png" : "images/home_notfound.png",width: 374.h,height: 374.h,),
                    if(!findDevice)
                      SizedBox(
                        height: 57.2.h,
                      ),
                    if(!findDevice)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // SizedBox(width: ScreenUtil().setWidth(167),),
                          Text('Not Device'.tr, style: TextStyle(color: const Color.fromRGBO(145, 148, 160, 1),fontSize: 42.sp),),
                        ],
                      ),
                    if(!findDevice)
                      SizedBox(
                        height: 50.h,
                      ),
                    if(!findDevice)
                      Container(
                        width: 374.w,
                        height: 124.h,
                        margin: EdgeInsets.only(left: 353.w,right: 353.w),
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(9)),
                            color: firstFind ? const Color.fromRGBO(111, 122, 135, 1) : const Color.fromRGBO(255, 227, 211, 1),
                            border: firstFind ? null : Border.all(color: const Color.fromRGBO(255, 189, 153, 1),width: 2.7.w)
                        ),
                        child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: firstFind ? const Color.fromRGBO(62, 72, 83, 1):const Color.fromRGBO(255, 138, 101, 0.52),
                          padding: EdgeInsets.zero,
                          child: Text(
                            firstFind ? 'Search devices'.tr : 'Retry'.tr,
                            style: TextStyle(
                                color: firstFind ? Colors.white : const Color.fromRGBO(249, 122, 53, 1),
                                fontSize: 42.sp,
                                fontWeight: FontWeight.normal
                            ),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.sp)),
                          onPressed: (){
                            setState(() {
                              deviceList.clear();
                              deviceSet.clear();
                              devicePictureList.clear();
                              firstScan = false;
                              functionFlag = 1;
                              if(defaultTargetPlatform == TargetPlatform.android){
                                blueToothChannel.checkWhatPermission(context).then((bool value){
                                  if(value){
                                    MyBluetoothPlugin.scanDevice(dataMap);
                                  }
                                });
                              }else{
                                MyBluetoothPlugin.scanDevice(dataMap);
                              }
                              Future.delayed(const Duration(seconds: 4),(){
                                if(mounted){
                                  setState(() {
                                    firstScan = true;
                                    if(deviceList.isEmpty){//如果扫描不到设备
                                      findDevice = false;
                                      firstFind = false;
                                    }
                                  });
                                }
                              });
                            });
                          },
                        ),
                      ),
                    if(findDevice)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 72.w,
                          ),
                          Text('Available devices'.tr, style: TextStyle(fontSize: 42.sp,color: const Color.fromRGBO(182, 184, 189, 1)),)
                        ],
                      ),
                    if(findDevice)
                      for(int i = 0; i < deviceList.length; i++)
                        buildScanDevice(i),
                    SizedBox(
                      height: 160.h,
                    )
                  ]
              ),
            ),
          ),
          onRefresh: _doRefresh,
          color: const Color.fromRGBO(249, 122, 53, 1),
        )
            :
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 360.w,
                height: 360.h,
                child: const WaterRipple(),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text('Searching'.tr, style: TextStyle(fontSize: 48.sp),)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doRefresh() async {
    scanning = true;
    deviceList.clear();
    deviceSet.clear();
    devicePictureList.clear();
    deviceNameList.clear();
    deviceNameSet.clear();
    blueToothChannel.checkWhatPermission(context).then((bool value){
      if(value){
        MyBluetoothPlugin.scanDevice(dataMap);
      }
    });
  }

  int functionFlag;
  String deviceName;

  void getPermission() {
    blueToothChannel.checkWhatPermission(context).then((bool value){
      if(value){
        if(functionFlag == 1){
          MyBluetoothPlugin.scanDevice(dataMap);
        }else if(functionFlag == 2){
          Method.showLessLoading(context, 'Connecting'.tr);
          blueToothChannel.connectDevice(deviceName, 0);
        }
      }
    });
  }

  Widget buildScanDevice(int i) {
    return Container(
        height: 200.h,
        margin: EdgeInsets.only(
            right: 72.w, top: 48.w,left: 72.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(48.w),
          color: Color.fromRGBO(246, 247, 249, 1),
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
            trailing: Icon(Icons.add),
            onTap: (){
              functionFlag = 2;
              deviceName = deviceNameList[i];
              connectIndex = i;
              if(defaultTargetPlatform == TargetPlatform.android){
                blueToothChannel.checkWhatPermission(context).then((bool value){
                  if(value){
                    connectDeviceType(i);
                  }
                });
              }else{
                connectDeviceType(i);
              }
            },
          ),
        )
    );
  }

  void connectDeviceType(int i){
    print('deviceTypeName: ${deviceTypeName[i]}');
    print('courseType: ${widget.courseType}');
    if(widget.courseType != null && deviceTypeName[i] != widget.courseType){
      Method.customDialog(context, 'wrong device type'.tr, 'deviceTypeError'.tr, confirm, isCancel: false);
    }else{
      Method.showLessLoading(context, 'Connecting'.tr);
      blueToothChannel.connectDevice(deviceNameList[i], 0);
    }
  }
}