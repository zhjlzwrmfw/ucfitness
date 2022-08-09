import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:my_bluetooth_plugin/my_bluetooth_plugin.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/saveData.dart';
import 'package:flutter/foundation.dart';
import 'blueUuid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlueToothChannel{

  MethodChannel platform = const MethodChannel('my.flutter.io/bluetooth'); //定义与底层操作系统的方法调用通道
  EventChannel eventChannelPlugin = const EventChannel('my.flutter.event/bluetooth'); //定义接收底层操作系统主动发来的消息通道
  bool isOpen = true;

  //连接设备
  void connectDevice(String sportDeviceName, int duration){
    Future<void>.delayed(Duration(seconds: duration),(){
      SaveData.deviceName = sportDeviceName;
      final Map<String, Object> data = <String, Object>{};
      data['deviceName'] = sportDeviceName;
      data['scanDuring'] = 3;
      data['notifyUuid'] = defaultTargetPlatform == TargetPlatform.android ? [if (sportDeviceName.substring(0, 4) == 'HEAD') BlueUuid.androidHeadNotifyUuid else BlueUuid.androidSportNotifyUuid, BlueUuid.androidOtaNotifyUuid]
          : [BlueUuid.iosSportNotifyUuid, BlueUuid.iosHeadNotifyUuid, BlueUuid.iosFasciaGunNotifyUUid, BlueUuid.iosOtaNotifyUuid];
      data['notify_d'] = defaultTargetPlatform == TargetPlatform.android ? BlueUuid.androidNotify_d : null;
      data['deviceUuid'] = null;
      data['uuidDataType'] = 0;
      data['connectType'] = 2;
      data['connectTimeout'] = 5;
      data['passUuid'] = null;
      data['intervalNotifyTime'] = defaultTargetPlatform == TargetPlatform.android ? 1 : null;
      MyBluetoothPlugin.connectDevice(data);
    });
  }
  //断开连接
  void disConnect(){
    MyBluetoothPlugin.disConnectDevice(SaveData.deviceName);
  }
//检查定位、蓝牙权限
  Future<bool> checkWhatPermission(BuildContext context) async {
    final List permissonList = await MyBluetoothPlugin.androidCheckBlueLackWhat();
    if(permissonList.isNotEmpty){
      switch(permissonList[0] as int){
        case 0:
          Method.customDialog(context, 'tips'.tr, 'localPermission'.tr, localPermissionConfirm);
          return false;
        case 1:
          Method.customDialog(context, 'tips'.tr, 'localService'.tr, localServiceConfirm);
          return false;
        case 2:
          Method.customDialog(context, 'tips'.tr, 'blueService'.tr, blueServiceConfirm);
          return false;
        default :
          return false;
      }
    }else{
      return true;
    }
  }

  void localPermissionConfirm(){
    MyBluetoothPlugin.androidApplyLocationPermission();
  }

  void localServiceConfirm(){
    MyBluetoothPlugin.androidOpenLocationService();
  }

  void blueServiceConfirm(){
    MyBluetoothPlugin.androidOpenBluetoothService();
  }

  void customOrder(String order){
    final int length = order.length ~/ 2;
    final Uint8List data = Uint8List(length);
    for(int i = 0; i < length; i++){
      data[i] = int.parse('0x' + order.substring(2 * i, 2 * (i + 1)));
    }
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendData(dataMap);
  }
//五件套事件同步指令
  void synTime(DateTime syncTime){
    final Uint8List data = Uint8List(10);
    data[0] = 0xFE;
    data[1] = 0xA4;
    data[2] = 0x07;
    data[3] = syncTime.year - 2010;
    data[4] = syncTime.month;
    data[5] = syncTime.day;
    data[6] = syncTime.hour;
    data[7] = syncTime.minute;
    data[8] = syncTime.second;
    data[9] = syncTime.weekday;
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendData(dataMap);
  }
  //海德方形跳绳计时计数自由跳
  void headStartSport(String setNumber){
    final Uint8List data = Uint8List(4);
    data[0] = 0x03;
    data[1] = SaveData.choseType == 0 ? 0x01 : SaveData.choseType == 100 ? 0x02 : 0x03;
    data[2] = SaveData.choseType == 0 ? 0 : int.parse('0x' + setNumber.substring(2,4));
    data[3] = SaveData.choseType == 0 ? 0 : int.parse('0x' + setNumber.substring(0,2));
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendData(dataMap);
  }
  //海德方形跳绳时间同步指令
  void headSyncTime(String hexSecondStr){
    final Uint8List data = Uint8List(6);
    data[0] = 0x01;
    data[1] = 0x00;
    data[2] = int.parse('0x' + hexSecondStr.substring(6,8));
    data[3] = int.parse('0x' + hexSecondStr.substring(4,6));
    data[4] = int.parse('0x' + hexSecondStr.substring(2,4));
    data[5] = int.parse('0x' + hexSecondStr.substring(0,2));
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendData(dataMap);
  }
  //设置运动模式
  void setMode(int mode, int connectDevice){
    final Uint8List data = Uint8List(5);
    data[0] = 0xFE;
    data[1] = 0xA0;
    data[2] = 0x02;
    data[3] = connectDevice;
    data[4] = mode;
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendData(dataMap);
  }
  //马达测试
  void motorTest(){
    if(isOpen){
      isOpen = false;
    }else{
      isOpen = true;
    }
    final Uint8List data = Uint8List(7);
    data[0] = 0xFE;
    data[1] = 0x54;
    data[2] = 0x45;
    data[3] = 0x53;
    data[4] = 0x54;
    data[5] = 0x32;
    data[6] = isOpen ? 0x00 : 0x01;
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendData(dataMap);
}
  //筋膜枪等级调节
  void updateFasciaNumber(int number){
    final Uint8List data = Uint8List(4);
    data[0] = 0xFE;
    data[1] = 0xA2;
    data[2] = 0x01;
    data[3] = number;
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendFascia(dataMap);
  }
  //筋膜枪开关
  void openFascia(bool isOpen){
    final Uint8List data = Uint8List(4);
    data[0] = 0xFE;
    data[1] = 0xA1;
    data[2] = 0x01;
    data[3] = isOpen ? 0x01 : 0x00;
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendFascia(dataMap);
  }
  //筋膜枪模式
  void changeFasciaMode(int mode){
    final Uint8List data = Uint8List(4);
    data[0] = 0xFE;
    data[1] = 0xA3;
    data[2] = 0x01;
    data[3] = mode;
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendFascia(dataMap);
  }
  //获取筋膜枪电量
  void getFasciaEleAmount(){
    final Uint8List data = Uint8List(4);
    data[0] = 0xFE;
    data[1] = 0xA4;
    data[2] = 0x01;
    data[3] = 0x01;
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendFascia(dataMap);
  }
  void openData(){
    final Uint8List data = Uint8List(4);
    data[0] = 0xFE;
    data[1] = 0xAB;
    data[2] = 0x01;
    data[3] = 0x01;
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendData(dataMap);
  }

  void closeData(){
    final Uint8List data = Uint8List(4);
    data[0] = 0xFE;
    data[1] = 0xAB;
    data[2] = 0x01;
    data[3] = 0x00;
    final Map<String, Object> dataMap = <String, Object>{'data': data};
    _callPlatformToSendData(dataMap);
  }
  //设备广播名判断
  bool deviceType(String deviceStr){
    if(deviceStr.substring(0, 4) == BlueUuid.HeadSkipBroadcast
        || deviceStr.substring(0, 5) == BlueUuid.sj300Broadcast
        || deviceStr.substring(0, 10) == BlueUuid.SmartGripBroadcast
        || deviceStr.substring(0, 12) == BlueUuid.HuaweiGripBroadcast
        || deviceStr.substring(0, 13) == BlueUuid.sj500Broadcast
        || deviceStr.substring(0, 16) == BlueUuid.HeadSkipBroadcast
    ){
      return true;
    }else{
      return false;
    }
  }

  //向底层操作系统发送消息去给蓝牙设备
  void _callPlatformToSendData(Map<String, Object> dataMap) {
    dataMap['deviceName'] = SaveData.deviceName;
    dataMap['serviceUuid'] = defaultTargetPlatform == TargetPlatform.android
        ?  deviceType(SaveData.deviceName) ? BlueUuid.androidHeadServiceUuid : BlueUuid.androidSportServiceUuid
        : deviceType(SaveData.deviceName) ? BlueUuid.iosHeadServiceUuid : BlueUuid.iosSportServiceUuid;
    dataMap['writeUuid'] = defaultTargetPlatform == TargetPlatform.android
        ? deviceType(SaveData.deviceName) ? BlueUuid.androidHeadWriteUuid : BlueUuid.androidSportWriteUuid
        : deviceType(SaveData.deviceName) ? BlueUuid.iosHeadWriteUuid : BlueUuid.iosSportWriteUuid;
    dataMap['notifyUuid'] = defaultTargetPlatform == TargetPlatform.android
        ? deviceType(SaveData.deviceName) ? BlueUuid.androidHeadNotifyUuid : BlueUuid.androidSportNotifyUuid
        : deviceType(SaveData.deviceName) ? BlueUuid.iosHeadNotifyUuid : BlueUuid.iosSportNotifyUuid;
    dataMap['isWithResult'] = true;
    MyBluetoothPlugin.sendData(dataMap); //调用底层去向蓝牙设备发送消息
  }
  //筋膜枪
  void _callPlatformToSendFascia(Map<String, Object> dataMap){
    dataMap['deviceName'] = SaveData.deviceName;
    dataMap['serviceUuid'] = defaultTargetPlatform == TargetPlatform.android ? BlueUuid.androidFasciaGunServiceUUid : BlueUuid.iosFasciaGunServiceUUid;
    dataMap['writeUuid'] = defaultTargetPlatform == TargetPlatform.android ? BlueUuid.androidFasciaGunWriteUUid : BlueUuid.iosFasciaGunWriteUUid;
    dataMap['notifyUuid'] = defaultTargetPlatform == TargetPlatform.android ? BlueUuid.androidFasciaGunNotifyUUid : BlueUuid.iosFasciaGunNotifyUUid;
    dataMap['isWithResult'] = true;
    MyBluetoothPlugin.sendData(dataMap); //调用底层去向蓝牙设备发送消息
  }

}