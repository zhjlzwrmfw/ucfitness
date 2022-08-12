import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_bluetooth_plugin/my_bluetooth_plugin.dart';
import 'package:running_app/common/PopupMenuItemOverride.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/model/sportDataController.dart';
import 'package:running_app/routes/about/ota.dart';
import 'package:running_app/routes/about/sportSetting.dart';
import 'package:running_app/routes/fasicaGun/fasicaGunMain.dart';
import 'package:running_app/routes/realTimeSport/home.dart';
import 'package:running_app/routes/realTimeSport/updateCard.dart';
import 'package:running_app/routes/sportData/sportInfo.dart';
import 'package:running_app/widgets/dashBoardPainter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screen/screen.dart';
import '../../common/saveData.dart';
import '../../common/blueUuid.dart';
import 'modeSetting.dart';
import '../../model/historyData.dart';
import 'dart:math';

class MainSportPage extends StatefulWidget{

  @override
  MainSportPageState createState() => MainSportPageState();

}

class MainSportPageState extends State<MainSportPage> with SingleTickerProviderStateMixin{
  bool soundPlay = true;//是否播放声音的图标
  int listPosition = 0;//可滑动指示，判断listView是否有滑动，0代表没滑动，1有滑动
  bool firstListPosition1 = true;//避免重复接受滑动回调参数
  bool firstListPosition2 = true;//避免重复接受滑动回调参数
  List<Widget> cardList = List(6);//运动信息卡片List
  static bool screenMode = true;//设置屏幕睡眠模式
  static int eleAmount;//固件电池电量
  static int sportCount;//运动次数
  static int bmpCount;//心率值
  static double kcalCount;//消耗卡路里
  bool isSporting = true;//用于开始、停止运动图标的转换
  DateTime now;//用于进行时间同步的系统时间
  DateTime syncTime = DateTime.now();//用于刚连接成功时间校准
  static String deviceName;//左上角设备名
  String seconds;// 5 4 3 2 1 go
  bool sporting = true;//是否点击开始运动标志位
  DateTime _lastPressedAt;//记录点击返回键的时间
  static int second = 0;//计时器秒数
  static int minute;//计时器分数
  Timer _timer;//计时器
  String devicePicture;//记录设备图片，用于统计页设备图片传值
  List<String> itemStringList = List(6);//记录用于调换卡片位置传值，与updateCard.dart传值
  List<int> itemIntList = [0, 1, 2, 3, 4, 5];//记录用于调换卡片位置传值，与updateCard.dart传值
  String userBMI = '19.6';//用户BMI
  String userHeight = '180';//用户身高
  String userWeight = '70';//用户体重
  List<String> subtitleLeft = [
    '0','0', '180', '70', '19.6', ''
  ];//用于卡片赋值
  static int totalBmp = 0;//记录总的心率值
  static int count = 0;//用于计算平均心率
//离线数据
  int offlineSportCount;
  String offlineSportTime;
  int offlineSecond;
  int offlineKcal;
  String offLineYear;
  String offLineMonth;
  String offLineDay;
  String offLineHour;
  String offLineMinute;
  String offLineSecond;

  Map<String,Object> sportMap = {};//存放运动数据的map
  List<String> sportDataList = [];//存放运动数据的map用于转换成List
  int totalDeviceSportCount = 0;//复制卡片上总的运动次数
  int totalDeviceSportMinutes = 0;//复制卡片上总的运动时间
  static String totalBmpData = '';//记录一连串心率
  static String totalBmpTime = '';//记录一连串心率时间
  bool showCard  = true;//显示卡片
  List<Map<String, Object>> netSaveDataList = [];//用于将数据上传至网络
  Map<String, dynamic> _netSportMap;//向云端上传运动数据的map
  int _deviceType;//上传给云端的设备类型
  String setNumber;//计时计数
  static int dynamicSecond = 0;//实时显示秒数
  bool firstGetEle = true;//避免再次播报“设备已连接”语音
  bool isEndSport = false;//标志运动结束不再进入接受80005回传数据
  bool notStartPlay = true;//避免在开始运动倒数时再次点击按钮出现语音播报
  AudioCache player;
  AudioPlayer audioPlayer = AudioPlayer(playerId: DateTime.now().millisecondsSinceEpoch.toString());
  List<String> audioUrlList = SaveData.english ? [
    '01.wav', '02.wav', '03.wav', '04.wav',
    '05.wav', '06.wav', '07.wav', '08.wav', '09.wav',
    '010.wav', '020.wav', '030.wav', '040.wav',
    '050.wav', '060.wav', '070.wav', '080.wav', '090.wav',
    'Hundred.wav', 'Thousand.wav', 'And.wav', 'Go_for_it.wav',
    'Device_is_connect.wav', 'Go.wav'
  ]
      : [
    '0.wav', '1.wav', '2.wav', '3.wav', '4.wav',
    '5.wav', '6.wav', '7.wav', '8.wav', '9.wav',
    '10.wav', '个.wav','加油.wav', '千.wav',
    '百.wav', '设备已连接.wav', '开始运动.wav',
  ];

  // List<int> enAudioDuration = [
  //   463, 488, 662, 580, 565, 668, 630, 508, 416, //1-9
  //   371, 548, 607, 620, 669, 800, 847, 580, 600, //10-90
  //   664, 780, 362, 658,//100,1000,and,times
  // ];
  // List<int> audioDuration = [
  //   334, 286, 337, 391, 440, 384, 345, 370, 270,
  //   410, 453, 363, 373, 275,
  // ];
  bool startSportFlag = false;
  String otaNetVersion;
  int bigVersion;
  int smallVersion;
  bool hasNewVersion = false;
  final SportDataController c = Get.put(SportDataController());
  bool isOpen = true;
  StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息

  final BlueToothChannel _blueToothChannel = BlueToothChannel();

  String whichDevice;//用于ota升级连接的设备

  List headHardwareVersion;

  bool hasEnter = false;

  Stream<AudioPlayerState> playStateStream;

  @override
  void initState() {
    super.initState();
    player = AudioCache(fixedPlayer: audioPlayer);
    playStateStream = audioPlayer.onPlayerStateChanged;
    playStateStream.listen(playState);
    c.sportData.update((val) {
      val.second = 0;
    });
    String hexSecondStr = ((DateTime.now().millisecondsSinceEpoch - DateTime.parse('1970-01-01 08:00:00').millisecondsSinceEpoch) ~/ 1000).toRadixString(16);
    _streamSubscription = _blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
    if(SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast || SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast){
      SaveData.broadcastType = 1;
      _getDeviceData();
      _initData();
      Future<void>.delayed(const Duration(milliseconds: 150),(){
        _blueToothChannel.headSyncTime(hexSecondStr);
        Future<void>.delayed(const Duration(milliseconds: 150),(){
          _blueToothChannel.customOrder('0200');
        });
      });
    }else if(SaveData.deviceName.substring(0,4) == BlueUuid.HeadSkipBroadcast
        || SaveData.deviceName.substring(0,13) == BlueUuid.sj500Broadcast
        || SaveData.deviceName.substring(0,5) == BlueUuid.sj300Broadcast
        || SaveData.deviceName.substring(0,16) == (BlueUuid.HuaWeiSkipBroadcast + 'GOD0')){
      SaveData.broadcastType = 1;
      SportInfoPageState.deviceName = '跳绳';
      if(SaveData.deviceName.substring(0,10) == BlueUuid.HeadSkipBroadcast + 'SR105'){
        whichDevice = 'SR105';
      }else if(SaveData.deviceName.substring(0,10) == BlueUuid.HeadSkipBroadcast + 'SR900'){
        whichDevice = 'SR900';
      }else if(SaveData.deviceName.substring(0,4) == BlueUuid.HeadSkipBroadcast){
        whichDevice = 'NT930';
      }else if(SaveData.deviceName.substring(0,13) == BlueUuid.sj500Broadcast){
        whichDevice = 'SJ500';
      }else if(SaveData.deviceName.substring(0,5) == BlueUuid.sj300Broadcast){
        whichDevice = 'SJ300';
      }else if(SaveData.deviceName.substring(0,16) == (BlueUuid.HuaWeiSkipBroadcast + 'GOD0')){
        whichDevice = 'SJ300';
      }
      _blueToothChannel.headSyncTime(hexSecondStr);
      Future.delayed(const Duration(milliseconds: 100),(){
        _blueToothChannel.customOrder('0200');
      });
      deviceName = '跳绳';
      devicePicture = 'images/equip01.png';
      _deviceType = 1;
      _initData();
    }else{
      SaveData.broadcastType = 0;
      Future<void>.delayed(const Duration(milliseconds: 150),(){
        _blueToothChannel.synTime(syncTime);
      });
      //用户使用哪种设备
      _getDeviceData();
      _initData();
      Future<void>.delayed(const Duration(seconds: 1),(){
        if(eleAmount == null){
          _blueToothChannel.customOrder('fea60101');
        }
      });
    }
    Future<void>.delayed(const Duration(milliseconds: 200), (){
      if(mounted){
        setState(() {
          hasEnter = true;
        });
      }
    });
  }

  int playCount = 0;
  List<String> playAudioList = <String>[];
  bool playCompleted  = true;

  void playState(AudioPlayerState event){
    switch(event){
      case AudioPlayerState.COMPLETED:
        if(playCount > 0){
          playCount--;
          player.play(playAudioList[playCount], stayAwake: true);
        }else{
          playCompleted = true;
        }
        print('语音播放完成');
        break;
    }
  }

  void setInitData(){
    playCompleted = true;
    playCount = 0;
    playAudioList.clear();
    sportState = 1;
    sportCount = null;
    bmpCount = null;
    kcalCount = null;
    isSporting = true;
    second = 0;
    seconds = null;
    minute = null;
    sporting = true;
    totalBmp = 0;
    count = 0;
    totalBmpTime = '';
    totalBmpData = '';
    dynamicSecond = 0;
    isEndSport = false;
    SaveData.choseType = 0;
    SaveData.choseNumber = 1;
    SaveData.choseMode = false;
    now = null;
    c.sportData.update((sportData) {
      sportData.second = 0;
      sportData.minute = null;
      sportData.bmpCount = null;
      sportData.sportCount = null;
      sportData.kcalCount = null;
    });
    if(SaveData.deviceName.substring(0, 10) != BlueUuid.SmartGripBroadcast
        && SaveData.deviceName.substring(0, 12) != BlueUuid.HuaweiGripBroadcast
        && SaveData.deviceName.substring(0, 13) != BlueUuid.sj500Broadcast
        &&  (SaveData.deviceName.substring(0,4) != BlueUuid.HeadSkipBroadcast
        && SaveData.deviceName.substring(0,16) != BlueUuid.HuaWeiSkipBroadcast  + 'GOD0')){
      if(_timer != null){
        _timer.cancel();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if(audioPlayer != null){
      audioPlayer.dispose();
      audioPlayer = null;
      player.clearCache();
      player = null;
    }
    if(SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast
        || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast
        || SaveData.deviceName.substring(0, 13) == BlueUuid.sj500Broadcast
        || SaveData.deviceName.substring(0, 5) == BlueUuid.sj300Broadcast
        || SaveData.deviceName.substring(0,4) == BlueUuid.HeadSkipBroadcast
        || SaveData.deviceName.substring(0,16) == BlueUuid.HuaWeiSkipBroadcast  + 'GOD0'){
      if(second != 0){
        _blueToothChannel.customOrder('03060000');
      }
    }
    Future<void>.delayed(const Duration(milliseconds: 200),(){
      MyBluetoothPlugin.disConnectDevice(SaveData.deviceName);
    });
    setInitData();
    eleAmount = null;
  }

  void _getDeviceData(){
    if(SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast){
      deviceName = '握力环';
      devicePicture = 'images/equip06.png';
      _deviceType = 6;
      SportInfoPageState.deviceName = '握力环';
      whichDevice = 'Grip';
    }else if(SaveData.deviceName.substring(8,12) == 'SKIP'){
      deviceName = '跳绳';
      devicePicture = 'images/equip01.png';
      _deviceType = 1;
      SportInfoPageState.deviceName = '跳绳';
      whichDevice = 'tergasy-JumpRope';
    }else if(SaveData.deviceName.substring(8,13) == 'ROPEA'){
      deviceName = '拉力绳';
      devicePicture = 'images/equip02.png';
      _deviceType = 2;
      SportInfoPageState.deviceName = '拉力绳';
      whichDevice = 'tergasy-RopeA';
    }else if(SaveData.deviceName.substring(8,13) == 'ROPEB'){
      deviceName = '蝴蝶绳';
      devicePicture = 'images/equip03.png';
      _deviceType = 4;
      SportInfoPageState.deviceName = '蝴蝶绳';
      whichDevice = 'tergasy-RopeB';
    }else if(SaveData.deviceName.substring(8,13) == 'ROUND'){
      deviceName = '健腹轮';
      devicePicture = 'images/equip05.png';
      _deviceType = 5;
      SportInfoPageState.deviceName = '健腹轮';
      whichDevice = 'tergasy-ABRound';
    }else if(SaveData.deviceName.substring(8,12) == 'DUMB'){
      deviceName = '哑铃';
      devicePicture = 'images/equip04.png';
      _deviceType = 3;
      SportInfoPageState.deviceName = '哑铃';
      whichDevice = 'tergasy-Dumb';
    }
  }
//进入页面初始化数据
  void _initData(){
    sportMap['deviceName'] = deviceName;
    sportMap['devicePicture'] = devicePicture;//从这里结束
    SharedPreferences.getInstance().then((value){
      if(value.getBool('openMedia') != null){
        if(value.getBool('openMedia')){
          if(value.getInt('sportPlayRate') != null){
            SaveData.sportPlayRate = value.getInt('sportPlayRate');
          }
        }else{
          SaveData.openMedia = false;
        }
      }
      if(SaveData.userId != null){
        DioUtil().get(
          RequestUrl.historySportDataUrl,
          queryParameters: <String, dynamic>{"equipmentType": 0, "page": 0, "userId": SaveData.userId, "zone": DateTime.now().timeZoneOffset.inHours},
          options: Options(headers: <String, dynamic>{'access_token': SaveData.accessToken, "app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,),
        ).then((value){
          print(value);
          if(value != null){
            HistoryData historyData = HistoryData.fromJson(value);
            if(historyData.code == '200'){
              print('拿到全部数据');
              for(int i = 0; i < historyData.data.totalElements; i++){
                totalDeviceSportCount = totalDeviceSportCount + historyData.data.dataList[i].count;
                totalDeviceSportMinutes = totalDeviceSportMinutes + historyData.data.dataList[i].duringTime;
              }
              totalDeviceSportMinutes = (totalDeviceSportMinutes / 60).floor();
              if(mounted){
                setState(() {
                  subtitleLeft = [
                    totalDeviceSportCount.toString(), totalDeviceSportMinutes.toString(), userHeight, userWeight, userBMI, ''
                  ];
                });
              }
            }
          }
        });
      }else{
        if(value.getStringList('sportData') != null){
          sportDataList = value.getStringList('sportData');
          for(int i = 0; i < sportDataList.length; i++){
            totalDeviceSportCount = totalDeviceSportCount + jsonDecode(sportDataList[i])['sportCount'];
            totalDeviceSportMinutes = totalDeviceSportMinutes + (jsonDecode(sportDataList[i])['sportDuration'] / 60).floor();
          }
        }
      }
      if(value.getBool('showCard') == null){
        showCard = true;
        value.setBool('showCard', showCard);
      }else{
        showCard = value.getBool('showCard');
      }
      if(mounted){
        setState(() {
          if(value.getStringList("itemList") != null) {
            itemStringList = value.getStringList("itemList");
            for (int i = 0; i < itemStringList.length; i++){
              itemIntList[i] = int.parse(itemStringList[i]);
            }
          }
          if(value.getString("userHeight") != null){
            userHeight = value.getString("userHeight");
          }
          if(value.getString("userWeight") != null){
            userWeight = value.getString("userWeight");
            userBMI = (int.parse(userWeight) / int.parse(userHeight) / int.parse(userHeight) * 10000).toStringAsFixed(1);//取小数点后一位
          }
          subtitleLeft = [
            totalDeviceSportCount.toString(), totalDeviceSportMinutes.toString(), userHeight, userWeight, userBMI, ''
          ];
        });
      }
    });
  }

  void _openStreamNotify() {
    _streamSubscription = _blueToothChannel.eventChannelPlugin
        .receiveBroadcastStream()
        .listen(_onToDart, onError: _onToDartError); //注册消息回调函数
  }

  List<String> huangDataList = <String>[];
  bool onclickData = false;

  void getHuang(){
    if(huangDataList.length == 2){
      onclickData = false;
      showDialog<void>(
        context: context,
        builder: (BuildContext context){
          return SimpleDialog(
            title: const Text('设备数据'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(huangDataList[0]),
                onPressed: null,
              ),
              SimpleDialogOption(
                child: Text(huangDataList[1]),
                onPressed: null,
              ),
            ],
          );
        },
      );
    }
  }

  bool canUpdate = true;
  bool startSport = false;

  void _onToDart(dynamic message) {
    switch (message['code']) {
      case '80005':
        Uint8List data = message['data'];
        // if(data[0] == 0x20 && data[1] == 0x22 && data[2] == 0x02 && data[3] == 0x28){
        //   canUpdate = false;
        //   Navigator.of(context).pop();
        //   Method.showToast('已进行过OTA，版本已是最新', context);
        //   break;
        // }
        if(data[0] == 0x08 && onclickData){
          List<int> list = [];
          for(int i = 1; i < data.length; i++)
            list.add(data[i]);
          huangDataList.add(String.fromCharCodes(list));
          getHuang();
          break;
        }
        if(data[0] == 0x09 && onclickData){
          List<int> list = [];
          for(int i = 1; i < data.length; i++)
            list.add(data[i]);
          huangDataList.add(String.fromCharCodes(list));
          getHuang();
          break;
        }
        if(data[0] == 0x05 && data[1] != 0x00
            && (SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast)
            && data[9] < 40){//data[9] < 40是为了过滤个数大于10000个的运动次数
          offlineKcal = 0;
          offlineSportCount = data[8] + data[9] * 16 * 16;
          offlineSecond = data[6] + data[7] * 16 * 16;
          sportMap['sportYMDHM'] = DateTime.fromMillisecondsSinceEpoch((data[2] + data[3] * pow(16, 2) + data[4] * pow(16, 4)+ data[5] * pow(16, 6)) * 1000).toString().substring(0, 16);
          // print(DateTime.fromMillisecondsSinceEpoch((data[2] + data[3] * pow(16, 2) + data[4] * pow(16, 4)+ data[5] * pow(16, 6)) * 1000));
          sportMap['sportYMD'] = sportMap['sportYMDHM'].toString().substring(0,10);
          sportMap['sportYM'] = sportMap['sportYMD'].toString().substring(0,7);
          sportMap['sportMD'] = sportMap['sportYMD'].toString().substring(5,7) + '/' + sportMap['sportYMD'].toString().substring(8,10);
          sportMap['sportYear'] = sportMap['sportYMD'].toString().substring(0,4);
          sportMap['sportHour'] = sportMap['sportYMDHM'].toString().substring(11,13);
          sportMap['sportWeek'] = DateTime.parse(sportMap['sportYMD']).weekday.toString();
          sportMap['offline'] = true;
          sportMap['avgBmp'] = '--';
          sportMap['trainMode'] = 1;
          sportMap['sportKCal'] = offlineKcal.toString();
          sportMap['sportDuration'] = offlineSecond;
          sportMap['sportCount'] = offlineSportCount;
          sportMap['avgCount'] = (offlineSportCount / offlineSecond * 60).round().toString();
          sportMap['totalBmpData'] = '-';
          sportMap['mode'] = 1;
          String sportDataStr = jsonEncode(sportMap);
          if(sportMap['sportYMDHM'].toString().substring(0,10) != '2020-01-01'){
            print('拿到离线数据');
            print('sportDataStr: $sportDataStr');
            sportDataList.add(sportDataStr);
          }
          if(SaveData.userId != null && sportMap['sportYMDHM'].toString().substring(0,10) != '2020-01-01'){
            print('_deviceType:${_deviceType}');
            _netSportMap = <String, dynamic>{
              'calories': offlineKcal,
              'count': offlineSportCount,
              'duringTime': offlineSecond,
              'equipmentType': _deviceType,
              'heartRateProcess': [],
              'mode': 1,
              'trainMode': SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast ? 1
                  : data.length == 16 ? '1' : data[16] == 2 ? 3 : data[16] == 3 ? 2 : 1,
              'offline': true,
              'startTime': sportMap['sportYMDHM'].toString() + ':00',
              'timeZone': DateTime.now().timeZoneOffset.inHours,
              'userId': SaveData.userId,
            };
            netSaveDataList.add(_netSportMap);
            if(data[1] == 0x01){
              _blueToothChannel.customOrder('03080000');
              DioUtil().post(
                  RequestUrl.historySportDataUrl,
                  data: netSaveDataList,
                  options: Options(headers: {'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
              ).then((value){
                print(value);
                if(value != null){
                  if(value["code"] == "200"){
                    print('离线数据上传成功');
                    netSaveDataList.clear();
                  }else{
                    Method.showToast('It seems that there is no internet'.tr, context);
                  }
                }else{
                  Method.showToast('It seems that there is no internet'.tr, context);
                }
              });
            }
          }else{
            if(data[1] == 0x01){
              print('删除离线数据');
              _blueToothChannel.customOrder('03080000');
              saveOfflineData();
            }
          }
        }else if(data[0] == 0x05 && data[1] != 0x00
            && (SaveData.deviceName.substring(0, 10) != BlueUuid.SmartGripBroadcast && SaveData.deviceName.substring(0, 12) != BlueUuid.HuaweiGripBroadcast)
            && data[9] < 40){//data[9] < 40是为了过滤个数大于10000个的运动次数
          offlineKcal = data[14] + data[15] * 16 * 16;
          offlineSportCount = data[8] + data[9] * 16 * 16;
          offlineSecond = data[6] + data[7] * 16 * 16;
          sportMap['sportYMDHM'] = DateTime.fromMillisecondsSinceEpoch((data[2] + data[3] * pow(16, 2) + data[4] * pow(16, 4)+ data[5] * pow(16, 6)) * 1000).toString().substring(0, 16);
          // print(DateTime.fromMillisecondsSinceEpoch((data[2] + data[3] * pow(16, 2) + data[4] * pow(16, 4)+ data[5] * pow(16, 6)) * 1000));
          sportMap['sportYMD'] = sportMap['sportYMDHM'].toString().substring(0,10);
          sportMap['sportYM'] = sportMap['sportYMD'].toString().substring(0,7);
          sportMap['sportMD'] = sportMap['sportYMD'].toString().substring(5,7) + '/' + sportMap['sportYMD'].toString().substring(8,10);
          sportMap['sportYear'] = sportMap['sportYMD'].toString().substring(0,4);
          sportMap['sportHour'] = sportMap['sportYMDHM'].toString().substring(11,13);
          sportMap['sportWeek'] = DateTime.parse(sportMap['sportYMD']).weekday.toString();
          sportMap['offline'] = true;
          sportMap['avgBmp'] = '--';
          if(data.length == 16){
            sportMap['trainMode'] = 1;
          }else{
            sportMap['trainMode'] = data[16] == 2 ? 3 : data[16] == 3 ? 2 : 1;
          }
          sportMap['sportKCal'] = offlineKcal.toString();
          sportMap['sportDuration'] = offlineSecond;
          sportMap['sportCount'] = offlineSportCount;
          sportMap['avgCount'] = (offlineSportCount / offlineSecond * 60).round().toString();
          sportMap['totalBmpData'] = '-';
          sportMap['mode'] = 1;
          String sportDataStr = jsonEncode(sportMap);
          if(sportMap['sportYMDHM'].toString().substring(0,10) != '2020-01-01'){
            sportDataList.add(sportDataStr);
          }
          if(SaveData.userId != null && sportMap['sportYMDHM'].toString().substring(0,10) != '2020-01-01'){
            _netSportMap = <String, dynamic>{
              "calories": offlineKcal,
              "count": offlineSportCount,
              "duringTime": offlineSecond,
              "equipmentType": _deviceType,
              "heartRateProcess": [],
              "mode": 1,
              "trainMode": data.length == 16 ? "1" : data[16] == 2 ? 3 : data[16] == 3 ? 2 : 1,
              "offline": true,
              "startTime": sportMap['sportYMDHM'].toString() + ':00',
              "timeZone": DateTime.now().timeZoneOffset.inHours,
              "userId": SaveData.userId,
            };
            netSaveDataList.add(_netSportMap);
            if(data[1] == 0x01){
              _blueToothChannel.customOrder('03080000');
              DioUtil().post(
                  RequestUrl.historySportDataUrl,
                  data: netSaveDataList,
                  options: Options(headers: {'access_token': SaveData.accessToken, "app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
              ).then((value){
                // print(value);
                if(value != null){
                  if(value["code"] == "200"){
                    print('离线数据上传成功');
                    netSaveDataList.clear();
                  }else{
                    Method.showToast('It seems that there is no internet'.tr, context);
                  }
                }else{
                  Method.showToast('It seems that there is no internet'.tr, context);
                }
              });
            }
          }else{
            if(data[1] == 0x01){
              _blueToothChannel.customOrder('03080000');
              saveOfflineData();
            }
          }
        }else if(data[0] == 0x04 && data[1] == 0x01
            && SaveData.deviceName.substring(0, 10) != BlueUuid.SmartGripBroadcast
            && SaveData.deviceName.substring(0, 12) != BlueUuid.HuaweiGripBroadcast){
          if(!isEndSport){
            second = data[2] + data[3] * 16 * 16;//用于存储运动秒数数据
            dynamicSecond = (data[2] + data[3] * 16 * 16) % 60;//用于ui显示秒数
            minute = second ~/ 60;
            if(SaveData.choseType == 100){
              if(SaveData.choseNumber == minute){
                _streamSubscription.cancel();
                isEndSport = true;
                Method.showLessLoading(context, 'Loading2'.tr);
                saveSportData();
                break;
              }
            }else if(SaveData.choseType == 200){
              if(SaveData.choseNumber == data[5] * 16 * 16 + data[4]){
                _streamSubscription.cancel();
                sportCount = sportCount + 1;
                isEndSport = true;
                Method.showLessLoading(context, 'Loading2'.tr);
                saveSportData();
                break;
              }
            }
            if(SaveData.openMedia){
              if((data[4] + data[5] * 16 * 16) % (SaveData.sportPlayRate) == 0 && sportCount != data[4] + data[5] * 16 * 16 ){
                _futurePlay(data[4] + data[5] * 16 * 16);
              }
            }
            sportCount = data[5] * 16 * 16 + data[4];
            kcalCount = data[13] * 16 * 16 + data[12] + 0.0;
            c.sportData.update((sportData) {
              sportData.second = dynamicSecond;
              sportData.sportCount = sportCount;
              sportData.minute = minute;
              sportData.bmpCount = bmpCount;
              sportData.kcalCount = kcalCount;
            });
          }
        }else if(startSport && data[0] == 0x04 && data[1] == 0x01
            && (SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast)){
          second = data[2] + data[3] * 16 * 16;//用于存储运动秒数数据
          dynamicSecond = (data[2] + data[3] * 16 * 16) % 60;//用于ui显示秒数
          minute = second ~/ 60;
          if(SaveData.openMedia){
            if((data[4] + data[5] * 16 * 16) % (SaveData.sportPlayRate) == 0 && sportCount != data[4] + data[5] * 16 * 16 ){
              _futurePlay(data[4] + data[5] * 16 * 16);
            }
          }
          sportCount = data[5] * 16 * 16 + data[4];
          if(second != 0){
            kcalCount = (0.000024 * sportCount * 30 / second + 0.133 * 65 + 0.004 * 90 + 0.187) * second / 30;
          }
          c.sportData.update((sportData) {
            sportData.second = dynamicSecond;
            sportData.sportCount = sportCount;
            sportData.minute = minute;
            sportData.bmpCount = bmpCount;
            sportData.kcalCount = kcalCount;
          });
        }else if(data[0] == 0x02){
          if(mounted){
            setState(() {
              eleAmount = data[1];
            });
          }
          String hexSecondStr = ((DateTime.now().millisecondsSinceEpoch - DateTime.parse('1970-01-01 08:00:00').millisecondsSinceEpoch) ~/ 1000).toRadixString(16);
          _blueToothChannel.headSyncTime(hexSecondStr);
          Future<void>.delayed(const Duration(milliseconds: 150),(){
            _blueToothChannel.customOrder('03070000');
            Future<void>.delayed(const Duration(milliseconds: 300),(){
              _blueToothChannel.customOrder('0400');
            });
          });
          if(firstGetEle){
            if(SaveData.openMedia){
              player.loadAll(audioUrlList);
              if(SaveData.english){
                player.play('Device_is_connect.wav', stayAwake:  true);
              }else{
                player.play('设备已连接.wav', stayAwake: true);
              }
            }
            firstGetEle = false;
          }
        }else if(data[0] == 0x09){
          headHardwareVersion = data;
        }else if(data[0] == 0xFE && data[1] == 0x56) {
          if(mounted){
            setState(() {
              eleAmount = data[3];
            });
          }
          print('获取电量成功');
          Future<void>.delayed(const Duration(milliseconds: 150),(){
            _blueToothChannel.customOrder('fea10101');
          });
          // getHistoryData();
          if(firstGetEle){
            if(SaveData.openMedia){
              player.loadAll(audioUrlList);
              if(SaveData.english){
                player.play('Device_is_connect.wav', stayAwake:  true);
              }else{
                player.play('设备已连接.wav', stayAwake: true);
              }
            }
            firstGetEle = false;
          }
        }else if(data[1] == 0x41 && data[2] == 0x08){
          if(!isEndSport){
            if(sportCount != data[4] + data[3] * 16 * 16 || kcalCount != data[8] * 16 * 16 + data[9] + 0.0 || bmpCount != data[7]){
              if(SaveData.openMedia){
                if((sportCount + 1) % (SaveData.sportPlayRate) == 0 && sportCount != data[4] + data[3] * 16 * 16 ){
                  _futurePlay(sportCount + 1);
                }
              }
              sportCount = data[4] + data[3] * 16 * 16;
              bmpCount = data[7];
              if(data[7] != 0){
                count = count + 1;
                totalBmp = totalBmp + data[7];
              }
              if(data[8] * 16 * 16 + data[9] >= 100){
                kcalCount = data[8] * 16 * 16 + data[9] + 0.0;
              }else{
                kcalCount = data[8] * 16 * 16 + data[9] + data[10] / 100;
              }
              if(totalBmpData.isNotEmpty || data[7] != 0){//记录实时心率和运动时间
                totalBmpData = totalBmpData + data[7].toString() + '-';
                DateTime bmpTime = DateTime.now();
                totalBmpTime = totalBmpTime + bmpTime.toString().substring(11, 16) + '-';
              }
              if(SaveData.choseType == 100){
                if(SaveData.choseNumber == minute){
                  isEndSport = true;
                  Method.showLessLoading(context, 'Loading2'.tr);
                  saveSportData();
                  break;
                }
              }else if(SaveData.choseType == 200){
                if(SaveData.choseNumber == sportCount){
                  isEndSport = true;
                  Method.showLessLoading(context, 'Loading2'.tr);
                  saveSportData();
                  break;
                }
              }
            }
            c.sportData.update((sportData) {
              sportData.second = dynamicSecond;
              sportData.sportCount = sportCount;
              sportData.minute = minute;
              sportData.bmpCount = bmpCount;
              sportData.kcalCount = kcalCount;
            });
          }
        }else if(data[1] == 0x53){
          if(startSportFlag){
            startSportFlag = false;
            // startApp();
            _blueToothChannel.customOrder('fea90101');
          }
          // isStartSport = true;
        }else if(data[1] == 0x54){
          print("同步时间成功！");
          Future.delayed(const Duration(milliseconds: 150),(){
            _blueToothChannel.customOrder('fea60101');
          });
          // getEleAmount();
        }else if(data[1] == 0x59 && data[5] == 0x01 && data[4] != 0){
          _blueToothChannel.customOrder('fea30100');
          // stopSport();
          // _streamSubscription.cancel();
        }else if(data[1] == 0x40){
          for(int i = 0; i < (data[2] / 20).floor(); i++){
            if(data[16 + i * 20] < 40){//data[16 + i * 20] < 40是为了过滤个数大于10000个的运动次数
              offlineKcal = data[20 + i *20] * 16 * 16 + data[19 + i * 20];
              offlineSportCount = data[16 + i * 20] * 16 * 16 + data[15 + i * 20];
              offlineSecond = data[12 + i * 20] * 3600 - data[6 + i * 20] * 3600 + data[13 + i * 20] * 60 - data[7 + i * 20] * 60 + data[14 + i * 20] - data[8 + i * 20];
              sportMap['offline'] = true;
              sportMap['mode'] = 1;
              sportMap['trainMode'] = 1;
              sportMap['avgBmp'] = '--';
              _getOffLineTime(data[3], data[4], data[5], data[6], data[7], data[8]);
              sportMap['sportKCal'] = offlineKcal.toString();
              sportMap['sportDuration'] = offlineSecond;
              sportMap['sportCount'] = offlineSportCount;
              sportMap['avgCount'] = (offlineSportCount / offlineSecond * 60).round().toString();
              sportMap['totalBmpData'] = data[21].toString() + '-' + data[22].toString();
              String sportDataStr = jsonEncode(sportMap);
              sportDataList.add(sportDataStr);
              if(SaveData.userId != null){
                _netSportMap = <String, dynamic>{
                  'calories': offlineKcal,
                  'count': offlineSportCount,
                  'duringTime': offlineSecond,
                  'equipmentType': _deviceType,
                  'heartRateProcess': [],
                  'mode': 1,
                  'trainMode': 1,
                  'offline': true,
                  'startTime': offLineYear + '-' + offLineMonth + '-' + offLineDay + '\u0020' + offLineHour + ':' + offLineMinute + ':' + offLineSecond,
                  'timeZone': DateTime.now().timeZoneOffset.inHours,
                  'userId': SaveData.userId,
                };
                netSaveDataList.add(_netSportMap);
              }
            }
          }
        }else if(data[1] == 0x51){
          _blueToothChannel.customOrder('fea20101');
          // clearHistoryData();
        }else if(data[1] == 0x52){
          if(SaveData.userId != null && netSaveDataList.isNotEmpty){
            DioUtil().post(
                RequestUrl.historySportDataUrl,
                data: netSaveDataList,
                options: Options(headers: {'access_token': SaveData.accessToken, "app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
            ).then((value){
              // print(value);
              if(value['code'] == '200'){
                print('离线数据上传成功');
                netSaveDataList.clear();
              }else{
                Method.showToast('It seems that there is no internet'.tr, context);
              }
            });
          }
          if(data[3] == 0x01){
            print('数据清除成功');
          }else{
            print('数据清除失败');
          }
          SaveData.firstEnter = true;
          second = 0;
          // sportCount = null;
          kcalCount = null;
          saveOfflineData();
          _blueToothChannel.customOrder('fea70101');
        }else if(data[1] == 0x57){
          bigVersion = data[3];
          smallVersion = data[4];
          // getOtaVersion();
        }
        break;
    }
  }
//获取云端固件版本
  void getOtaVersion(){
    Method.checkNetwork(context).then((value){
      if(value){
        Method.showLessLoading(context, 'Loading2'.tr);
        DioUtil().get(RequestUrl.otaTergasyVersionUrl + whichDevice,).then((value){
          print(value);
          if(value != null){
            otaNetVersion = value['currentVersion'].toString();
            print('版本号获取成功');
            print(whichDevice);
            if(SaveData.broadcastType == 1){//海德跳绳OTA
              var listString = Utf8Encoder().convert(otaNetVersion);
              print(listString);
              if(listString[1] > headHardwareVersion[2] || listString[3] > headHardwareVersion[4] || listString[5] > headHardwareVersion[6]){
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => OtaPage(whichDevice: whichDevice,))).then((value){
                  _openStreamNotify();
                });
              }else{
                Navigator.of(context).pop();
                Method.showToast('Your version is up to date'.tr, context);
              }
            }else{
              Navigator.of(context).pop();
              List<String> splitList = <String>[];
              splitList = otaNetVersion.split('.');
              if((int.parse(splitList[0]) * 10 + int.parse(splitList[1])) > bigVersion * 10 + smallVersion){
                Navigator.push<Object>(context, MaterialPageRoute(builder: (context) => OtaPage(whichDevice: whichDevice,))).then((value){
                  _openStreamNotify();
                });
              }else{
                Method.showToast('Your version is up to date'.tr, context);
              }
            }
          }else{
            Navigator.of(context).pop();
            Method.showToast('otaVersionTip'.tr, context);
          }
        });
      }
    });
  }
//语音播报
  void _futurePlay(int sportCount){
    print('playCompleted:$playCompleted');
    if(sportCount < 10000 && playCompleted){
      if(!SaveData.english){
        cnAudioPlay(sportCount);
      }else{
        enAudioPlay(sportCount);
      }
    }
  }
  //中文语音播报
  void cnAudioPlay(int sportCount){
    playCompleted = false;
    playAudioList.clear();
    if(sportCount == 10){
      playCount = 1;
      player.play('10.wav', stayAwake: true);
      playAudioList.add('个.wav');
    }else if(sportCount > 10 && sportCount < 100){
      playCount = 2;
      player.play((sportCount ~/ 10).toString() + '.wav', stayAwake: true);
      if(sportCount == 50){
        playCount = 3;
        playAudioList..add('加油.wav')..add('个.wav')..add('10.wav');
      }else{
        playAudioList..add('个.wav')..add('10.wav');
      }
    }else if(sportCount % 100 == 0 && sportCount < 1000){
      playCount = 3;
      player.play((sportCount ~/ 100).toString() + '.wav', stayAwake: true);
      playAudioList..add('加油.wav')..add('个.wav')..add('百.wav');
    }else if(sportCount > 100 && sportCount < 1000){
      player.play((sportCount ~/ 100).toString() + '.wav', stayAwake: true);
      if(sportCount % 100 == 50){
        playCount = 5;
        playAudioList..add('加油.wav')..add('个.wav')..add('10.wav')..add(sportCount.toString().substring(1, 2) + '.wav')..add('百.wav');
      }else{
        playCount = 4;
        playAudioList..add('个.wav')..add('10.wav')..add(sportCount.toString().substring(1, 2) + '.wav')..add('百.wav');
      }
    }else if(sportCount % 1000 == 0){
      playCount = 3;
      player.play((sportCount ~/ 1000).toString() + '.wav', stayAwake: true);
      playAudioList..add('加油.wav')..add('个.wav')..add('千.wav');
    }else if(sportCount % 1000 == 50 && sportCount < 1100){
      playCount = 6;
      player.play('1.wav', stayAwake: true);
      playAudioList..add('加油.wav')..add('个.wav')..add('10.wav')..add('5.wav')..add('0.wav')..add('千.wav');
    }else if(sportCount > 1000  && sportCount < 1100){
      playCount = 5;
      player.play('1.wav', stayAwake: true);
      playAudioList..add('个.wav')..add('10.wav')..add(sportCount.toString().substring(2, 3) + '.wav')
        ..add('0.wav')..add('千.wav');
    }else if(sportCount % 100 == 50 && sportCount > 1100){
      if(sportCount.toString().substring(1, 2) == '0'){
        playCount = 6;
        player.play('${sportCount ~/ 1000}.wav', stayAwake: true);
        playAudioList..add('加油.wav')..add('个.wav')..add('10.wav')..add('5.wav')
          ..add(sportCount.toString().substring(1, 2) + '.wav')..add('千.wav');
      }else{
        playCount = 7;
        player.play('${sportCount ~/ 1000}.wav', stayAwake: true);
        playAudioList..add('加油.wav')..add('个.wav')..add('10.wav')..add('5.wav')
          ..add('百.wav')..add(sportCount.toString().substring(1, 2) + '.wav')..add('千.wav');
      }
    }else if(sportCount % 100 == 0){
      playCount = 5;
      player.play(sportCount.toString().substring(0, 1) + '.wav', stayAwake: true);
      playAudioList..add('加油.wav')..add('个.wav')..add('百.wav')
        ..add(sportCount.toString().substring(1, 2) + '.wav')..add('千.wav');
    }else{
      if(sportCount.toString().substring(1, 2) == '0'){
        playCount = 5;
        player.play(sportCount.toString().substring(0, 1) + '.wav', stayAwake: true);
        playAudioList..add('个.wav')..add('10.wav')..add(sportCount.toString().substring(2, 3) + '.wav')
          ..add('0.wav')..add('千.wav');
      }else{
        playCount = 6;
        player.play(sportCount.toString().substring(0, 1) + '.wav', stayAwake: true);
        playAudioList..add('个.wav')..add('10.wav')..add(sportCount.toString().substring(2, 3) + '.wav')
          ..add('百.wav')..add(sportCount.toString().substring(1, 2) + '.wav')..add('千.wav');
      }

    }
  }
  //英语语音播报
  void enAudioPlay(int sportCount){
    print('播报');
    playCompleted = false;
    playAudioList.clear();
    if(sportCount < 100){
      player.play('0' + sportCount.toString() + '.wav', stayAwake: true);
      if(sportCount == 50){
        playCount = 2;
        playAudioList..add('Go_for_it.wav')..add('Times.wav');
      }else{
        playCount = 1;
        playAudioList.add('Times.wav');
      }
    }else if(sportCount < 1000 && sportCount % 100 == 0){
      playCount = 3;
      player.play('0' + (sportCount ~/ 100).toString() + '.wav', stayAwake: true);
      playAudioList..add('Go_for_it.wav')..add('Times.wav')..add('Hundred.wav');
    }else if(sportCount > 100 && sportCount < 1000){
      player.play('0' + (sportCount ~/ 100).toString() + '.wav', stayAwake: true);
      if(sportCount % 100 == 50){
        playCount = 5;
        playAudioList..add('Go_for_it.wav')..add('Times.wav')
          ..add('0' + (sportCount % 100).toString() + '.wav')..add('And.wav')..add('Hundred.wav');
      }else{
        playCount = 4;
        playAudioList..add('Times.wav')..add('0' + (sportCount % 100).toString() + '.wav')
          ..add('And.wav')..add('Hundred.wav');
      }
    }else if(sportCount % 1000 == 0){
      playCount = 3;
      player.play('0' + (sportCount ~/ 1000).toString() + '.wav', stayAwake: true);
      playAudioList..add('Go_for_it.wav')..add('Times.wav')..add('Thousand.wav');
    }else if(sportCount > 1000 && sportCount < 1100){
      player.play('0' + (sportCount ~/ 1000).toString() + '.wav', stayAwake: true);
      if(sportCount % 100 == 50){
        playCount = 5;
        playAudioList..add('Go_for_it.wav')..add('Times.wav')
          ..add('0' + (sportCount % 100).toString() + '.wav')..add('And.wav')..add('Thousand.wav');
      }else{
        playCount = 4;
        playAudioList..add('Times.wav')..add('0' + (sportCount % 100).toString() + '.wav')
          ..add('And.wav')..add('Thousand.wav');
      }
    }else if(sportCount % 100 == 0){
      playCount = 5;
      player.play('0' + (sportCount ~/ 1000).toString() + '.wav', stayAwake: true);
      playAudioList..add('Go_for_it.wav')..add('Times.wav')
        ..add('Hundred.wav')..add('0' + (sportCount % 1000 ~/ 100).toString() + '.wav')..add('Thousand.wav');
    }else if(sportCount > 1100){
      player.play('0' + (sportCount ~/ 1000).toString() + '.wav', stayAwake: true);
      if(sportCount % 100 == 50){
        playCount = 7;
        playAudioList..add('Go_for_it.wav')..add('Times.wav')
          ..add('0' + (sportCount % 100).toString() + '.wav')..add('And.wav')..add('Hundred.wav')
          ..add('0' + (sportCount % 1000 ~/ 100).toString() + '.wav')..add('Thousand.wav');
      }else if(sportCount % 1000 < 100){
        if(sportCount % 1000 == 50){
          playCount = 5;
          playAudioList..add('Go_for_it.wav')..add('Times.wav')..add('0' + (sportCount % 100).toString() + '.wav')
            ..add('And.wav')..add('Thousand.wav');
        }else{
          playCount = 4;
          playAudioList..add('Times.wav')..add('0' + (sportCount % 100).toString() + '.wav')..add('And.wav')..add('Thousand.wav');
        }
      }else{
        playCount = 6;
        playAudioList..add('Times.wav')..add('0' + (sportCount % 100).toString() + '.wav')..add('And.wav')
          ..add('Hundred.wav')..add('0' + (sportCount % 1000 ~/ 100).toString() + '.wav')..add('Thousand.wav');
      }

    }
  }
//设置获取运动日期
  void _getOffLineTime(int year, int month, int day, int hour, int minute, int second){
    offLineYear = (2010 + year).toString();
    if(month < 10){
      offLineMonth = '0' + month.toString();
    }else{
      offLineMonth = month.toString();
    }
    if(day < 10){
      offLineDay = '0' + day.toString();
    }else{
      offLineDay = day.toString();
    }
    if(hour < 10){
      offLineHour = '0' + hour.toString();
    }else{
      offLineHour = hour.toString();
    }
    if(minute < 10){
      offLineMinute = '0' + minute.toString();
    }else{
      offLineMinute = minute.toString();
    }
    if(second < 10){
      offLineSecond = '0' + second.toString();
    }else{
      offLineSecond = second.toString();
    }
    sportMap['sportYMDHM'] = offLineYear + '-' + offLineMonth + '-' + offLineDay + '\u0020' + offLineHour + ':' + offLineMinute;
    sportMap['sportYMD'] = offLineYear + '-' + offLineMonth + '-' + offLineDay;
    sportMap['sportYM'] = offLineYear + '-' + offLineMonth;
    sportMap['sportMD'] = month.toString() + '/' + day.toString();
    sportMap['sportYear'] = offLineYear;
    sportMap['sportHour'] = offLineHour;
    sportMap['sportWeek'] = DateTime.parse(sportMap['sportYMD']).weekday.toString();
  }


  void _onToDartError(dynamic error) {
    switch (error.code) {
      case '90002':
        // HomePageState.homePage = false;
        disconnectToSaveData();
        Method.showToast('Device disconnected'.tr, context, second: 2);
        break;
      case '90003':
        disconnectToSaveData();
        break;
      case '90004':
        disconnectToSaveData();
        break;
      case '90005':
        disconnectToSaveData();
        break;
      case '90006':
        disconnectToSaveData();
        break;
      case '90007':
        disconnectToSaveData();
        break;
    }
  }

  void disconnectToSaveData(){
    setInitData();
    if(Navigator.canPop(context)){
      Navigator.of(context).pop();
      if(Navigator.canPop(context)){
        Navigator.of(context).pop();
      }
    }
    SaveData.choseMode = false;
  }

  @override
  Widget build(BuildContext context) {
    title = [
      'count'.tr, 'Duration'.tr, 'Height'.tr, 'Weight'.tr,
      'BMI', 'Top coach'.tr
    ];
    subtitleRight = [
      'singleCount'.tr, 'minute'.tr,
      'cm','kg','', 'Top coach'.tr
    ];
    print('Offset(${1080.w}, ${1920.h})');
    return hasEnter ? ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => WillPopScope(
        onWillPop: () async {
          if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
            //两次点击间隔超过1秒则重新计时
            _lastPressedAt = DateTime.now();
            Method.showToast('Press again to exit'.tr, context);
            return false;
          }else{
            Navigator.popUntil(context, ModalRoute.withName('MyHomePage'));
            return true;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Container(
              width: 80.w,
              height: 56.h,
              child: FlatButton(
                child: Icon(Icons.arrow_back_ios,size: 44.h,color: Colors.white,),
                onPressed: (){
                  Navigator.popUntil(context, ModalRoute.withName('MyHomePage'));
                },
              ),
            ),
            title: Container(
              child: Text(
                SaveData.connectDeviceTypeStr(deviceName),
                style: TextStyle(fontSize: 42.sp, color: Colors.white, ),
              ),
            ),
            backgroundColor: const Color.fromRGBO(249, 122, 53, 1),
            centerTitle: false,
            titleSpacing: 4,
            elevation: 0,
            actions: <Widget>[
              Container(
                width: 108.w,
                height: 68.h,
                child: FlatButton(
                  child: Icon(Icons.more_horiz,color: Colors.white,size: 56.w,),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    showMenu(
                        context: context,
                        position: const RelativeRect.fromLTRB(1000.0, 65, 0.0, 0.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        items: <PopupMenuEntry<String>>[
                          PopupMenuItemOverride<String>(
                            value: 'value01',
                            child: FlatButton.icon(
                              onPressed: (){
                                Navigator.of(context).pop();
                                getOtaVersion();
                              },
                              icon: Icon(Icons.file_download),
                              label: Text('OTA'.tr, style: TextStyle(fontWeight: FontWeight.normal)),
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuDivider(height: 1.0),
                          PopupMenuItemOverride<String>(
                            value: 'value02',
                            child: FlatButton.icon(
                              onPressed: (){
                                Navigator.of(context).pop();
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => SportSettingPage())).then((value){
                                  _openStreamNotify();
                                  if(mounted){
                                    setState(() {
                                      if(value == 1){
                                        Method.showLessLoading(context, 'Loading2'.tr);
                                        saveSportData();
                                      }
                                    });
                                  }
                                });
                              },
                              icon: Icon(Icons.audiotrack),
                              label: Text('Speak'.tr, style: TextStyle(fontWeight: FontWeight.normal),),
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          // const PopupMenuDivider(height: 1.0),
                          // PopupMenuItemOverride<String>(
                          //   value: 'value03',
                          //   child: FlatButton.icon(
                          //     onPressed: (){
                          //       Navigator.of(context).pop();
                          //       Navigator.push(context, MaterialPageRoute(
                          //           builder: (BuildContext context) => FasciaGunMainPage())).then((value){
                          //         _openStreamNotify();
                          //           });
                          //       // huangDataList.clear();
                          //       // onclickData = true;
                          //       // _blueToothChannel.customOrder('0400');
                          //       // Navigator.of(context).pop();
                          //     },
                          //     icon: Icon(Icons.data_usage),
                          //     label: Text('获取数据'),
                          //     highlightColor: Colors.transparent,
                          //     splashColor: Colors.transparent,
                          //     padding: const EdgeInsets.symmetric(horizontal: 0),
                          //   ),
                          // ),
                          // const PopupMenuDivider(height: 1.0),
                          // PopupMenuItemOverride<String>(
                          //   value: 'value04',
                          //   child: FlatButton.icon(
                          //     onPressed: (){
                          //       Navigator.of(context).pop();
                          //       showDialog<void>(
                          //         context: context,
                          //         builder: (BuildContext context){
                          //           return SimpleDialog(
                          //             title: const Text('校准方式'),
                          //             children: <Widget>[
                          //               SimpleDialogOption(
                          //                 child: const Text('重写offset'),
                          //                 onPressed: (){
                          //                   Navigator.of(context).pop();
                          //                   _blueToothChannel.customOrder('fead0101');
                          //                 },
                          //               ),
                          //               SimpleDialogOption(
                          //                 child: const Text('offset置零'),
                          //                 onPressed: (){
                          //                   Navigator.of(context).pop();
                          //                   _blueToothChannel.customOrder('fead0102');
                          //                 },
                          //               ),
                          //             ],
                          //           );
                          //         },
                          //       );
                          //     },
                          //     icon: Icon(Icons.vpn_key),
                          //     label: const Text('设备校准'),
                          //     highlightColor: Colors.transparent,
                          //     splashColor: Colors.transparent,
                          //     padding: const EdgeInsets.symmetric(horizontal: 0),
                          //   ),
                          // ),
                        ] );
                  },
                ),
              ),
              SizedBox(
                width: 48.w,
              )
            ],
          ),
          body: Material(
            child: Stack(
              children: <Widget>[
                Positioned(
                  // top: 0,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(top: 5),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            realTimeDataBuild(),
                            SizedBox(
                              height: 120.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 64.w,
                                    ),
                                    Text('Exercise data'.tr, style: TextStyle(fontSize: 42.sp,color: Color.fromRGBO(0, 0, 0, 0.87)),),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    FlatButton(
                                      padding: EdgeInsets.only(left: 42),
                                      splashColor: Colors.white10,
                                      highlightColor: Colors.white10,
                                      child: RepaintBoundary(
                                        child: Image.asset(
                                          "images/quanbujilu .png",
                                          width: 48.w,
                                          height: 48.h,
                                        ),
                                      ),
                                      onPressed: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateCardPage())).then((value){
                                          setState(() {
                                            _openStreamNotify();
                                            // if(!isStartSport){
                                            //   startSport();
                                            // }
                                            for(int i = 0; i < 6; i++){
                                              buildListData(title[UpdateCardPageState.items[i]], trailing[UpdateCardPageState.items[i]], subtitleLeft[UpdateCardPageState.items[i]], subtitleRight[UpdateCardPageState.items[i]]);
                                            }
                                            SharedPreferences.getInstance().then((value){
                                              showCard = value.getBool('showCard');
                                            });
                                            if(value == 1){
                                              Method.showLessLoading(context, 'Loading2'.tr);
                                              saveSportData();
                                            }
                                          });
                                        });
                                      },
                                    ),
                                    SizedBox(width: 40.w,),
                                  ],
                                )
                              ],
                            ),
                            RepaintBoundary(
                              child: Wrap(
                                spacing: 42.w,
                                runSpacing: 42.w,
                                alignment: WrapAlignment.center,
                                children: <Widget>[
                                  if(showCard)
                                    for(int i = 0; i < 6; i++)
                                      buildListData(SaveData.setCard ? title[UpdateCardPageState.items[i]] : title[itemIntList[i]],
                                          SaveData.setCard ? trailing[UpdateCardPageState.items[i]] : trailing[itemIntList[i]],
                                          SaveData.setCard ? subtitleLeft[UpdateCardPageState.items[i]] : subtitleLeft[itemIntList[i]],
                                          SaveData.setCard ? subtitleRight[UpdateCardPageState.items[i]] : subtitleRight[itemIntList[i]])
                                ],
                              ),
                            ),
                            SizedBox(height: 500.h,),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    child: Container(
                      width: 1080.w,
                      height: 468.h,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color.fromRGBO(255, 255, 255, 0),Color.fromRGBO(255, 255, 255, 1),Color.fromRGBO(255, 255, 255, 1)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter
                          )
                      ),
                    )
                ),
                Positioned(
                    bottom: 64.h,
                    left: 72.w,
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          if(screenMode){//如果屏幕睡眠模式开启
                            Screen.keepOn(true);
                            screenMode = false;
                          }else{//如果屏幕睡眠模式关闭
                            Screen.keepOn(false);
                            screenMode = true;
                          }
                        });
                      },
                      child: Container(
                        width: 280.w,
                        height: 160.h,
                        // color: Colors.red,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RepaintBoundary(child: Image.asset(screenMode ? "images/jiesuo.png" : "images/suoding.png",width: 67.2.w,height: 67.2.h,)),
                            Text(screenMode ? 'Unlock'.tr : 'lock'.tr,style: TextStyle(fontSize: 36.sp,color: Color.fromRGBO(41, 51, 75, 0.75)),)
                          ],
                        ),
                      ),
                    )
                ),
                Positioned(
                    bottom: isSporting ? 2.h : 56.h,
                    left: isSporting ? 347.w :417.w,
                    child: RepaintBoundary(
                      child: FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: RepaintBoundary(
                          child: Image.asset(isSporting ? 'images/button动效.gif' : sportState == 1 ? 'images/start.png' : 'images/pause.png' ,
                            width: isSporting ? 392.w : 190.w,height: isSporting ? 300.h : 190.h,),
                        ),
                        padding: EdgeInsets.all(0),
                        onPressed: notStartPlay ? (){
                          if(SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast){
                            setState(() {
                              newController();
                            });
                          }else{
                            sportState = 2;
                            if(SaveData.choseMode){
                              if(sportCount == null){
                                autoStartSport();
                              }else{
                                Method.customDialog(
                                    context,
                                    'tips'.tr,
                                    sportCount == null || sportCount == 0 ? 'notSaveRecord'.tr : 'isEndSport'.tr,
                                    _confirm,
                                    cancel: _cancel);
                              }
                            }else{
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => ModeSettingPage())).then((value){
                                _openStreamNotify();
                                getModePageBackData();
                                if(value == 1){
                                  autoStartSport();
                                }
                              });
                            }
                          }
                        } : null,
                        onLongPress: SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast
                            || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast ? (){
                          Method.customDialog(
                              context,
                              'tips'.tr,
                              sportCount == null || sportCount == 0 ? 'notSaveRecord'.tr : 'isEndSport'.tr,
                              _confirm,
                              cancel: _cancel);
                        } : null,
                      ),
                    )
                ),
                Positioned(
                    bottom: 64.h,
                    right: 72.w,
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          if(SaveData.openMedia){
                            SaveData.openMedia = false;
                          }else{
                            SaveData.openMedia = true;
                          }
                          SharedPreferences.getInstance().then((value){
                            value.setBool('openMedia', SaveData.openMedia);
                          });
                        });
                      },
                      child: Container(
                        width: 280.w,
                        height: 160.h,
                        // color: Colors.red,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RepaintBoundary(
                              child: Image.asset(SaveData.openMedia ? "images/sound.png" : "images/jingyin.png",width: 67.2.w,
                                height: 67.2.h,),
                            ),
                            Text(SaveData.openMedia ? 'Speaking'.tr : 'Silence'.tr,
                              style: TextStyle(fontSize: 36.sp,color: Color.fromRGBO(41, 51, 75, 0.75)),)
                          ],
                        ),
                      ),
                    )
                ),
                // if(listPosition == 0)
                //   Positioned(
                //     bottom: ScreenUtil().setHeight(145),
                //     left: ScreenUtil().setWidth(232),
                //     child: Image.asset('images/down arrow ani.gif',width: ScreenUtil().setWidth(78),height: ScreenUtil().setHeight(78),),
                //   ),
              ],
            ),
          ),
        ),
      ),
    ) : Container(color: Colors.white,);
  }

  void _cancel(){
    setState(() {
      _streamSubscription.resume();
    });
  }
  
  int sportState = 1;//1是暂停，2是恢复，3是停止

  void newController(){
    if(sportState == 1){
      sportState = 2;
    }else if(sportState == 2){
      sportState = 1;
    }
    if(sportCount == null){
      autoStartSport();
    }else if(sportState == 1){
      _blueToothChannel.customOrder('03040000');
    }else if(sportState == 2){
      _blueToothChannel.customOrder('03050000');
    }else if(sportState == 3){
      _blueToothChannel.customOrder('03060000');
    }
  }

  void getModePageBackData(){
    setNumber = SaveData.choseType == 100 ? (SaveData.choseNumber * 60).toRadixString(16) : SaveData.choseNumber.toRadixString(16);
    if(setNumber.length == 2){
      setNumber = '00' + setNumber;
    }else if(setNumber.length == 3){
      setNumber = '0' + setNumber;
    }else if(setNumber.length == 1){
      setNumber = '000' + setNumber;
    }
    // print('setNumber: $setNumber');
  }

  void autoStartSport(){
    if(isSporting){
      if(mounted){
        setState(() {
          notStartPlay = false;
          seconds = '5';
          sporting = false;
          if(SaveData.openMedia){
            if(SaveData.english){
              player.play('05.wav', stayAwake: true);
            }else{
              player.play('5.wav', stayAwake: true);

            }
          }
        });
      }
      for(int i = 0 ; i <= 4; i++){
        Future<void>.delayed(Duration(seconds: 5-i),(){
          if(mounted){
            setState(() {
              if(i == 0){
                seconds = 'GO';
                if(SaveData.openMedia){
                  if(SaveData.english){
                    player.play('Go.wav', stayAwake: true);
                  }else{
                    player.play('开始运动.wav', stayAwake: true);
                  }
                }
                minute = 0;
                bmpCount = 0;
                kcalCount = 0;
                Future.delayed(const Duration(seconds: 1), (){
                  setState(() {
                    notStartPlay = true;
                  });
                });
                if(SaveData.deviceName.substring(0, 10) != BlueUuid.SmartGripBroadcast
                    && SaveData.deviceName.substring(0, 12) != BlueUuid.HuaweiGripBroadcast
                    && SaveData.deviceName.substring(0, 13) != BlueUuid.sj500Broadcast
                    && SaveData.deviceName.substring(0,4) != BlueUuid.HeadSkipBroadcast
                    && SaveData.deviceName.substring(0,16) != BlueUuid.HuaWeiSkipBroadcast  + 'GOD0'){
                  _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
                    second = second + 1;
                    dynamicSecond = dynamicSecond + 1;
                    if(second % 60 == 0){
                      // second = 0;
                      dynamicSecond = 0;
                      minute = minute + 1;
                    }
                  });
                }
              }else{
                seconds = i.toString();
                if(SaveData.openMedia){
                  if(SaveData.english){
                    player.play('0' + seconds + '.wav', stayAwake: true);
                  }else{
                    player.play(seconds + '.wav', stayAwake: true);
                  }
                }
              }
            });
          }
        });
      }
      Future<void>.delayed(const Duration(seconds: 6),(){
        if(mounted){
          setState(() {
            sportCount = 0;
            sporting = true;
            if(SaveData.deviceName.substring(0, 10) != BlueUuid.SmartGripBroadcast
                && SaveData.deviceName.substring(0, 12) != BlueUuid.HuaweiGripBroadcast
                && (SaveData.deviceName.substring(0,4) == BlueUuid.HeadSkipBroadcast
                    || SaveData.deviceName.substring(0,13) == BlueUuid.sj500Broadcast
                    || SaveData.deviceName.substring(0,5) == BlueUuid.sj300Broadcast
                    || SaveData.deviceName.substring(0,16) == BlueUuid.HuaWeiSkipBroadcast  + 'GOD0')){
              _blueToothChannel.headStartSport(setNumber);
              _blueToothChannel.headStartSport(setNumber);
            }else if(SaveData.deviceName.substring(0, 10) != BlueUuid.SmartGripBroadcast
                && SaveData.deviceName.substring(0, 12) != BlueUuid.HuaweiGripBroadcast){
              _blueToothChannel.customOrder('fea30101');
              startSportFlag = true;
            }else if(SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast
                || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast){
              startSport = true;
              _blueToothChannel.customOrder('03010000');
            }
            isSporting = false;

          });
        }
      });
      now = DateTime.now();
      //从这里开始新添加
      sportMap['isOffLineData'] = false;
      sportMap['sportYMDHM'] = now.toString().substring(0,16);
      sportMap['sportYMD'] = now.toString().substring(0,10);
      if(now.month < 10){
        if(now.day < 10){
          sportMap['sportMD'] = '0' + now.month.toString() + '/' + '0' + now.day.toString();
        }else{
          sportMap['sportMD'] = '0' + now.month.toString() + '/' + now.day.toString();
        }
      }else{
        if(now.day < 10){
          sportMap['sportMD'] = now.month.toString() + '/' + '0' + now.day.toString();
        }else{
          sportMap['sportMD'] = now.month.toString() + '/' + now.day.toString();
        }
      }
      sportMap['sportYear'] = now.toString().substring(0,4);
      sportMap['sportYM'] = now.toString().substring(0,7);
      sportMap['sportHour'] = now.toString().substring(11,13);
      sportMap['sportWeek'] = now.weekday.toString();
      SaveData.sportTime = sportMap['sportYMDHM'];//从这里结束
    }else{
      Method.customDialog(
          context,
          'tips'.tr,
          sportCount == null || sportCount == 0 ? 'notSaveRecord'.tr : 'isEndSport'.tr,
          _confirm,
          cancel: _cancel);
    }
  }

  void _confirm(){
    if(sportCount == null || sportCount == 0){
      if(SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast
          || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast
          || SaveData.deviceName.substring(0, 13) == BlueUuid.sj500Broadcast
          || SaveData.deviceName.substring(0, 5) == BlueUuid.sj300Broadcast
          || SaveData.deviceName.substring(0,4) == BlueUuid.HeadSkipBroadcast
          || SaveData.deviceName.substring(0,16) == BlueUuid.HuaWeiSkipBroadcast  + 'GOD0'){
        _blueToothChannel.customOrder('03060000');
        // headStopSport();
      }
      SaveData.choseMode = false;
      Navigator.of(context)..pop..pop();
      MyBluetoothPlugin.disConnectDevice(SaveData.deviceName);
    }else{
      Method.showLessLoading(context, 'Loading2'.tr);
      saveSportData();
    }
  }
  //存储运动数据并跳转至运动详情页面
  void saveSportData(){
    if(SaveData.openMedia){
      if(SaveData.english){
        player.play('Exercise_has_ended.wav', stayAwake: true);
      }else{
        player.play('运动已结束.wav', stayAwake: true);
      }
    }
    SaveData.changeState = true;
    SaveData.onclickPage.clear();
    totalDeviceSportMinutes = totalDeviceSportMinutes + (second / 60).floor();
    totalDeviceSportCount = totalDeviceSportCount + sportCount;
    sportMap['offline'] = false;
    sportMap['sportCount'] = sportCount;
    sportMap['sportDuration'] = second;
    sportMap['sportKCal'] = kcalCount < 100 ? kcalCount.toStringAsFixed(2) : kcalCount.toStringAsFixed(0);
    sportMap['avgCount'] = (sportCount / second * 60).round().toString();
    sportMap['totalBmpData'] = totalBmpData;
    sportMap['totalBmpTime'] = totalBmpTime;
    sportMap['avgBmp'] = (totalBmp / count).toStringAsFixed(0);
    sportMap['mode'] = SaveData.sportMode;
    sportMap['trainMode'] = SaveData.modeName == null ? 1 : SaveData.modeName == '自由模式' ? 1 : SaveData.modeName == '计时模式' ? 2 : 3;
    SaveData.offline = false;
    SaveData.totalBmp = totalBmpData;
    SaveData.totalBmpTime = totalBmpTime;
    SaveData.sportCount = sportCount.toString();
    SaveData.avgCount = (sportCount / second * 60).round().toString();
    minute > 0 ? SaveData.minCount = minute.toString() : SaveData.secondsCount = second.toString();
    SaveData.choseMode = false;
    SaveData.firstEnter = true;
    isSporting = true;
    startSport = false;
    SaveData.avgBmp = sportMap['avgBmp'];
    String sportDataStr = jsonEncode(sportMap);
    sportDataList.add(sportDataStr);
    if(kcalCount == 0){
      SaveData.kcalCount = '0';
    }else if(kcalCount < 100){
      SaveData.kcalCount = kcalCount.toStringAsFixed(2);
    }else if(kcalCount >= 100){
      SaveData.kcalCount = kcalCount.toStringAsFixed(0);
    }
    setData();
  }

  void saveOfflineData(){
    SharedPreferences.getInstance().then((value){
      value.setStringList('sportData', sportDataList);//从这里结束
      value.setBool('downloadData', true);
    });
  }

  void setData(){
    if(SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast
        || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast
        || SaveData.deviceName.substring(0, 13) == BlueUuid.sj500Broadcast
        || SaveData.deviceName.substring(0, 5) == BlueUuid.sj300Broadcast
        || SaveData.deviceName.substring(0,4) == BlueUuid.HeadSkipBroadcast
        || SaveData.deviceName.substring(0,16) == BlueUuid.HuaWeiSkipBroadcast  + "GOD0"){
      _blueToothChannel.customOrder('03060000');
    }else{
      _blueToothChannel.customOrder('fea90100');
    }
    SharedPreferences.getInstance().then((value){
      value.setStringList('sportData', sportDataList);
      value.setBool('downloadData', true);
    }).then((value){
      if(SaveData.userId != null){
        int length = totalBmpData.split('-').length;
        int avgLength;
        if(length > 60){
          avgLength = length ~/ 60 + 1;
        }else{
          avgLength = 1;
        }
        final List<String> bmpData = totalBmpData.split('-');
        final List<String> bmpTimes = totalBmpTime.split('-');
        final List<Map<String, Object>> totalBmpList = [];
        for(int i = 0; i < length;){
          if(bmpData[i] != ''){
            totalBmpList.add(<String, Object>{
              'heartRate': int.parse(bmpData[i].toString()),
              'time': bmpTimes[i],
            });
          }
          i = i + avgLength;
        }
        _netSportMap = <String, dynamic>{
          'calories': SaveData.kcalCount,
          'count': sportCount,
          'duringTime': second,
          'equipmentType': _deviceType,
          'heartRateProcess': totalBmpList,
          'offline': false,
          'mode': SaveData.sportMode,
          'trainMode': SaveData.modeName == '自由模式' ? 1 : SaveData.modeName == '计时模式' ? 2 : 3,
          'startTime': now.toString().substring(0,19),
          'timeZone': DateTime.now().timeZoneOffset.inHours,
          'userId': SaveData.userId,
        };
        netSaveDataList.add(_netSportMap);
        SaveData.netSaveDataList = netSaveDataList;
        DioUtil().post(
            RequestUrl.historySportDataUrl,
            data: netSaveDataList,
            options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass,Headers.contentTypeHeader:ContentType.json}, sendTimeout: 5000, receiveTimeout: 10000,)
        ).then((value){
          print(value);
          if(value != null){
            if(value['code'] == '200'){
              netSaveDataList.clear();
              SaveData.netSaveDataList.clear();
              SportInfoPageState.intensity = value['data']['sportStrength'] as double;
            }else{
              Method.showToast('It seems that there is no internet'.tr, context);
            }
          }else{
            Method.showToast('It seems that there is no internet'.tr, context);
          }
          Navigator.of(context).pop();
          Navigator.push<Object>(context, MaterialPageRoute(
              builder: (BuildContext context) => SportInfoPage(isRealSport: true))).then((value){
            if(mounted){
              setState(() {
                setInitData();
                _openStreamNotify();
                subtitleLeft = [
                  totalDeviceSportCount.toString(), totalDeviceSportMinutes.toString(), userHeight, userWeight, userBMI, ''
                ];
              });
            }
          });
        });
      }
    }).then((value) => setInitData()).whenComplete((){
      if(SaveData.userId == null){
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => SportInfoPage(isRealSport: true))).then((value){
          if(mounted){
            setState(() {
              setInitData();
              _openStreamNotify();
              subtitleLeft = [
                totalDeviceSportCount.toString(), totalDeviceSportMinutes.toString(), userHeight, userWeight, userBMI, ''
              ];
            });
          }
        });
      }
    });
  }

  Widget realTimeDataBuild(){
    return Container(
      width: 960.w,
      height: 1296.w,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40.w)),
          boxShadow:[
            BoxShadow(
                color: const Color.fromRGBO(50, 51, 94, 0.1),
                offset: const Offset(0,0),
                blurRadius: 1532.8.w
            )
          ]
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 56.w,
            child: Container(
              height: 180.h,
              child: FlatButton(
                disabledTextColor: Colors.black,
                padding: EdgeInsets.only(right: 160.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(!SaveData.choseMode ? (SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast ? 'Free mode'.tr : 'Select mode'.tr)
                        : SaveData.modeName == '自由模式' ? SaveData.english ? 'Free Mode' : '自由模式'
                        : SaveData.modeName == '计数模式' ? SaveData.english ? 'Count training' : '定数计时'
                        : SaveData.english ? 'Time training' : '定时计数',
                      style: TextStyle(fontWeight: FontWeight.normal,fontSize: 48.sp),),
                    SizedBox(width: 10.w,),
                    if((SaveData.deviceName.substring(0, 10) != BlueUuid.SmartGripBroadcast && SaveData.deviceName.substring(0, 12) != BlueUuid.HuaweiGripBroadcast)
                        && sportCount == null)
                      RepaintBoundary(child: Image.asset('images/模式选择.png',width: 42.w,height: 42.h, alignment: Alignment.bottomLeft,)),
                  ],
                ),
                onPressed: sportCount != null || !notStartPlay  || SaveData.deviceName.substring(0, 10) == BlueUuid.SmartGripBroadcast || SaveData.deviceName.substring(0, 12) == BlueUuid.HuaweiGripBroadcast? null : (){
                  Navigator.push<Object>(context, MaterialPageRoute(
                      builder: (BuildContext context) => ModeSettingPage())).then((Object value){
                    if(mounted){
                      setState(() {
                        getModePageBackData();
                        _openStreamNotify();
                      });
                    }
                  });
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            right: 56.w,
            child: Container(
              height: 180.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RepaintBoundary(child: Image.asset('images/battery.png',width: 31.7.w, height: 51.9.h)),
                  SizedBox(width: 3.w,),
                  Text(eleAmount.toString() + '%',style: TextStyle(fontSize: 48.sp)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 196.w,
            child: RepaintBoundary(
              child: GetX<SportDataController>(
                builder: (SportDataController controller){
                  return Container(
                    height: 1100.w,
                    width: 960.w,
                    child: TestStatelessWidget(
                      second: controller.sportData.value.second,
                      sportCount: controller.sportData.value.sportCount,
                      bmpCount: controller.sportData.value.bmpCount,
                      kcalCount: controller.sportData.value.kcalCount,
                      startSport: seconds,
                      sporting: sporting,
                      minute: controller.sportData.value.minute,
                      choseType: SaveData.choseType,
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  List<String> title = ['运动次数','运动时长', '身高','体重', 'BMI','金牌教练'];

  List<String> trailing = [
    'images/cishu .png','images/shichang.png', 'images/shengao.png','images/tizhong.png', 'images/bmi.png','images/jiaolian.png'
  ];



  List<String> subtitleRight = [
    '次','分钟','cm','kg','kg/m²','你的健身管家'
  ];

  Widget buildListData(String title, String trailing, String subtitleLeft, String subtitleRight){
    return Container(
      width: 468.w,
      height: 216.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Color.fromRGBO(192, 192, 192, 0.24)
      ),
      padding: EdgeInsets.zero,
      child: ListTile(
          contentPadding: EdgeInsets.only(top: 30.h,left: 48.w,right: 48.w),
          title: Text(title, style: TextStyle(fontSize: 38.sp),),
          trailing: RepaintBoundary(child: Image.asset(trailing,width: 48.w,height: 48.h,)),
          subtitle: subtitleLeft.length == 0 ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 8.h,
              ),
              Text(subtitleRight,style: TextStyle(fontSize: 26.sp,color: Color.fromRGBO(0, 0, 0, 0.87)),)
            ],
          )
              :
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 16.h,
              ),
              Text.rich(
                  TextSpan(
                      children: [
                        TextSpan(
                            text: subtitleLeft.length >= 5 ? (int.parse(subtitleLeft) ~/ 10000).toString() + 'w+' : subtitleLeft,
                            style: TextStyle(
                                fontSize: 68.sp
                            )
                        ),
                        TextSpan(
                            text: ' ' + subtitleRight,
                            style: TextStyle(
                                fontSize: 32.sp,
                                color: Color.fromRGBO(0, 0, 0, 0.87)
                            )
                        )
                      ]
                  )
              )
            ],
          )
      ),
    );
  }
}