import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/model/statisticsData.dart';
import 'package:running_app/routes/sportData/totalRecord.dart';
import 'package:running_app/routes/userRoutes/userPicture.dart';
import '../../common/fileImageEx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/historyData.dart';
import 'package:get/get.dart';

class RecordPage extends StatefulWidget{

  @override
  RecordPageState createState() => RecordPageState();

}

bool totalData = true;//判断用户点击选择日期
bool todayData = false;//判断用户点击选择日期
bool weekData = false;//判断用户点击选择日期
bool monthData = false;//判断用户点击选择日期
List<int> onclickCountList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];//避免重复刷新
///用户点击顶部设备选择判断列表
List<bool> deviceOnClickList = <bool>[true, false, false, false, false, false, false];
// bool skippingDevice = false;//跳绳数据选择判断值
// bool pullDevice = false;//拉力绳数据选择判断值
// bool butterflyDevice = false;//蝴蝶绳数据选择判断值
// bool dumbbellDevice = false;//哑铃数据选择判断值
// bool abRoundDevice = false;//健腹轮数据选择判断值
// bool totalDevice = true;//全部设备数据选择判断值
String sportDeviceName = 'total';//设备名传值
String choseWhichDay;//运动日历选择
String sportDevicePicture = 'images/alldevice.png';
List deviceTimeList = [0, 0];//状态值对应
String choseWhichDuration;//判断点击什么时间段
bool firstEnterRecord = true;

class RecordPageState extends State<RecordPage>{
  DateTime nowTime = DateTime.now();
  //新添加从这里开始
  DateTime now = DateTime.parse(DateTime.now().toString().substring(0, 10));//显示今天时间
  DateTime compareTime;//拿到设备运动日期
  var different;//天数差
  String sportMonth;
  int cardPosition = 0;//日历位置
  ///为了滑动时不重复拿运动日历
  bool firstCardPosition1 = true;
  bool firstCardPosition2 = true;
  bool lastCardPosition1 = true;
  bool lastCardPosition2 = true;
  // int bottomPosition = 1;
  List sportYearList = [];//运动年份
  List sportYMList = [];//运动年月
  int sportCount = 0;//运动次数
  int sportDuration = 0;//运动时长
  double sportKCal = 0;//运动卡路里
  double sportStrength = 0;//运动强度
  Set sportMDSet = new Set();//用于去除重复时间运动日历生成的小卡片
  List sportMDList = new List();//用于运动日历生成的小卡片
  Set sportYMSet = new Set();//记录年月并且去重
  Set sportYearSet = new Set();//记录是否存在跨年并且年份去重
  int sportYMLength = 0;//没有跨年，月的个数
  int sportYearLength = 0;//有跨年,年的个数
  ///总体运动数据
  List allSportCountList = new List();
  List allSportMinutesList = new List();
  List allSportKCalList = new List();
  ///今日运动数据
  List todaySportCountList = [0,0,0,0,0,0];
  List todaySportMinutesList = [0,0,0,0,0,0];
  List todaySportKCalList = [0,0,0,0,0,0];
  ///一周运动数据
  List weekSportCountList = [0,0,0,0,0,0,0];
  List weekSportMinutesList = [0,0,0,0,0,0,0];
  List weekSportKCalList = [0,0,0,0,0,0,0];
  ///一个月运动数据
  List monthSportCountList = new List(30);
  List monthSportMinutesList = new List(30);
  List monthSportKCalList = new List(30);
  Map<String, Object> _map = new Map();//方便数据展示
  List<Map<String, Object>> _mapList = new List();
  List<String> _list = new List();//从这里结束

  var _futureBuilderFuture;//避免重复请求刷新
  StatisticsData _statisticsData;
  HistoryData historyData;
  var connectivityResult;
  int length;//运动日历长度

  @override
  void initState() {
    super.initState();
    monthSportKCalList.fillRange(0, 30, 0);
    monthSportMinutesList.fillRange(0, 30, 0);
    monthSportCountList.fillRange(0, 30, 0);
    SaveData.onclickPage.add('RecordPage');
    if(SaveData.onclickPage.contains('SportRankingRoute') && SaveData.onclickPage.contains('CoursePage')){
      SaveData.changeState = false;
    }
    if(SaveData.userId != null){
      if(choseWhichDay == null){
        _futureBuilderFuture = _getNetSportData(deviceTimeList[0], deviceTimeList[1]);
      }else{
        _futureBuilderFuture = _getWhichDevice();
      }
    }else{
      _getInitData();
    }
  }
  //清空数据，避免重复添加
  void _clearData(){
    allSportCountList.clear();
    allSportMinutesList.clear();
    allSportKCalList.clear();
    todaySportCountList = [0,0,0,0,0,0];
    todaySportMinutesList = [0,0,0,0,0,0];
    todaySportKCalList = [0,0,0,0,0,0];
    weekSportCountList = [0,0,0,0,0,0,0];
    weekSportMinutesList = [0,0,0,0,0,0,0];
    weekSportKCalList = [0,0,0,0,0,0,0];
    // monthSportCountList = [0,0,0,0,0,0];
    // monthSportMinutesList = [0,0,0,0,0,0];
    // monthSportKCalList = [0,0,0,0,0,0];
    monthSportKCalList.fillRange(0, 30, 0);
    monthSportMinutesList.fillRange(0, 30, 0);
    monthSportCountList.fillRange(0, 30, 0);
    sportYearList.clear();
    sportYMList.clear();
    sportCount = 0;
    sportKCal = 0;
    sportDuration = 0;
    sportStrength = 0;
  }
  //从云端获取历史数据
  Future _getNetSportData(int deviceType, int timeArea) async {
    if(historyData == null){
      sportMDSet.clear();
      await DioUtil().get(//为了拿到运动日历
        RequestUrl.historySportDataUrl,
        queryParameters: {"equipmentType": 0, "page": 0, "userId": SaveData.userId, "zone": DateTime.now().timeZoneOffset.inHours},
        options: Options(headers: {'access_token': SaveData.accessToken, "app_pass": RequestUrl.appPass}, sendTimeout: 10000, receiveTimeout: 10000,),
      ).then((value){
        print('value: $value');
        if(value != null){
          historyData = HistoryData.fromJson(value);
          if(historyData.code == '200'){
            int length = historyData.data.totalElements;
            for(int i = length - 1; i >= 0; i--){
              sportMDSet.add(historyData.data.dataList[i].startTime.substring(0,10));
            }
            sportMDList = sportMDSet.toList();
            print(sportMDList);
          }
        }else{
          if(Navigator.canPop(context)){
            Navigator.of(context).pop();
            Method.showToast('It seems that there is no internet'.tr, context);
          }
        }
      });
    }
    return DioUtil().get(
        RequestUrl.getStatisticsUrl,
        queryParameters: {"equipmentType": deviceType, 'timeArea': timeArea, 'userId': SaveData.userId},
        options: Options(headers: {'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass}, sendTimeout: 10000, receiveTimeout: 10000,)
    ).then((value){
      print('设备的数据: $value');
      if(value != null){
        _clearData();
        _statisticsData = StatisticsData.fromJson(value);
        if(_statisticsData.code == '200' && _statisticsData.data != null){
          for(int i = 0; i < _statisticsData.data.length; i++){
            sportCount = sportCount + _statisticsData.data[i].sportCount;
            sportDuration = sportDuration + _statisticsData.data[i].duringTime ~/ 60;
            sportKCal = sportKCal + _statisticsData.data[i].calorie;
            sportStrength = sportStrength + _statisticsData.data[i].sportStrength;
            if(timeArea == 0){
              if(_statisticsData.data[i].sportCount != 0){
                allSportCountList.add(_statisticsData.data[i].sportCount);
                allSportKCalList.add(_statisticsData.data[i].calorie);
                allSportMinutesList.add(_statisticsData.data[i].duringTime ~/ 60);
                if(_statisticsData.data[0].startTime.substring(0,4) == nowTime.year.toString()){
                  sportYMList.add(_statisticsData.data[i].startTime.substring(0,7));
                  sportYearList.length = 1;
                }else{
                  sportYearList.add(_statisticsData.data[i].startTime.substring(0,4));
                }
              }
            }else if(timeArea == 4){//改为4
              monthSportCountList[i] = _statisticsData.data[i].sportCount;
              monthSportKCalList[i] = _statisticsData.data[i].calorie;
              monthSportMinutesList[i] = _statisticsData.data[i].duringTime ~/ 60;
            }else if(timeArea == 2){
              weekSportCountList[DateTime.parse(_statisticsData.data[i].startTime).weekday - 1] = _statisticsData.data[i].sportCount;
              weekSportKCalList[DateTime.parse(_statisticsData.data[i].startTime).weekday - 1] = _statisticsData.data[i].calorie;
              weekSportMinutesList[DateTime.parse(_statisticsData.data[i].startTime).weekday - 1] = _statisticsData.data[i].duringTime ~/ 60;
            }else if(timeArea == 3){
              todaySportCountList[i] = _statisticsData.data[i].sportCount;
              todaySportKCalList[i] = _statisticsData.data[i].calorie;
              todaySportMinutesList[i] = _statisticsData.data[i].duringTime ~/ 60;
            }
          }
          sportYMLength = sportYMList.length;
          if(allSportCountList.isEmpty){
            allSportCountList.add(0);
            allSportMinutesList.add(0);
            allSportKCalList.add(0);
            sportYMList.add(nowTime.toString().substring(0, 7));
          }
          if(!firstEnterRecord){
            setState(() {});
            if(Navigator.canPop(context)){
              Navigator.of(context).pop();
            }
          }
          firstEnterRecord = false;
        }else if(_statisticsData.code == '200' && _statisticsData.data == null){
          if(Navigator.canPop(context)){
            Navigator.of(context).pop();
          }
        }
      }else{
        if(Navigator.canPop(context)){
          Navigator.of(context).pop();
          Method.showToast('It seems that there is no internet'.tr, context);
        }
      }
    });
  }



//初始化数据
  void _getInitData(){
    SharedPreferences.getInstance().then((value){
      Method.showLessLoading(context, 'Loading2'.tr);
      setState(() {
        // print(value.getStringList('sportData'));
        if(value.getStringList('sportData') != null){
          if(_mapList.isNotEmpty){//避免重复添加至_mapList中
            _mapList.clear();
          }
          _list = value.getStringList('sportData');
          int length = _list.length;
          for(int i = 0; i < length; i++){//将拿到的字符串数组转换成map类型的数组
            _map = jsonDecode(_list[i]);
            _mapList.add(_map);
          }
          for(int i = 0; i < length; i++){//统计全部设备的总体数据
            sportYearSet.add(_mapList[i]['sportYear']);
            sportYMSet.add(_mapList[i]['sportYM']);
            sportMDSet.add(_mapList[i]['sportYMD']);
            sportCount = sportCount + _mapList[i]['sportCount'];
            sportDuration = sportDuration + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
            sportKCal = sportKCal + double.parse(_mapList[i]['sportKCal']);
          }
          sportMDList = sportMDSet.toList();
          //冒泡排序
          _bubbleSort(sportMDList, sportMDList.length);
          _mapBubbleSort(_mapList, _mapList.length);
          sportYearList = sportYearSet.toList();
          sportYMList = sportYMSet.toList();
          if(sportYearSet.length == 1){
            allSportCountList.length = sportYMSet.length;
            allSportMinutesList.length = sportYMSet.length;
            allSportKCalList.length = sportYMSet.length;
            allSportCountList.fillRange(0, sportYMSet.length, 0);
            allSportMinutesList.fillRange(0, sportYMSet.length, 0);
            allSportKCalList.fillRange(0, sportYMSet.length, 0.0);
          }else{
            allSportCountList.length = sportYearSet.length;
            allSportMinutesList.length = sportYearSet.length;
            allSportKCalList.length = sportYearSet.length;
            allSportCountList.fillRange(0, sportYearSet.length, 0);
            allSportMinutesList.fillRange(0, sportYearSet.length, 0);
            allSportKCalList.fillRange(0, sportYearSet.length, 0.0);
          }
          // _getSportData('total', false, whichDate: 100000);
        }
      });
    }).then((value){
      if(choseWhichDay == null){
        if(totalData){
          _getSportData(sportDeviceName, false, whichDate: 100000);
        }else if(todayData){
          _getSportData(sportDeviceName, false, whichDate: 0);
        }else if(weekData){
          _getSportData(sportDeviceName, false, whichDate: 7);
        }else if(monthData){
          _getSportData(sportDeviceName, false, whichDate: 29);
        }
      }else{
        _getSportData(sportDeviceName, true);
      }
    }).whenComplete((){
      setState(() {
        Navigator.of(context).pop();
      });
    });//从这里结束
  }
//元素为字符串的冒泡排序
  void _bubbleSort(List a, int n){
    int i;
    int j;
    int flag = 1;
    String temp;
    for(i = 1; i < n && flag == 1; i++){
      flag = 0;
      for(j = 0; j < n - i; j++){
        DateTime b = DateTime.parse(a[j]);
        DateTime c = DateTime.parse((a[j + 1]));
        if(b.isAfter(c)){
          flag = 1;
          temp = a[j];
          a[j] = a[j + 1];
          a[j + 1] = temp;
        }
      }
    }
  }
//元素为map类型的冒泡排序
  void _mapBubbleSort(List a, int n){
    int i;
    int j;
    int flag = 1;
    Map<String, Object> temp;
    for(i = 1; i < n && flag == 1; i++){
      flag = 0;
      for(j = 0; j < n - i; j++){
        DateTime b = DateTime.parse(a[j]['sportYMD']);
        DateTime c = DateTime.parse((a[j + 1]['sportYMD']));
        if(b.isAfter(c)){
          flag = 1;
          temp = a[j];
          a[j] = a[j + 1];
          a[j + 1] = temp;
        }
      }
    }
  }

  //新添加从这里开始
  void _getSportData(String deviceName, bool isSportCalendar,{int whichDate = 0}){
    int dataLength = _mapList.length;
    sportYMLength = 0;
    sportCount = 0;
    sportKCal = 0;
    sportDuration = 0;
    todaySportCountList = [0,0,0,0,0,0];
    todaySportMinutesList = [0,0,0,0,0,0];
    todaySportKCalList = [0,0,0,0,0,0];
    weekSportCountList = [0,0,0,0,0,0,0];
    weekSportMinutesList = [0,0,0,0,0,0,0];
    weekSportKCalList = [0,0,0,0,0,0,0];
    monthSportKCalList.fillRange(0, 30, 0);
    monthSportMinutesList.fillRange(0, 30, 0);
    monthSportCountList.fillRange(0, 30, 0);
    if(sportYearList.length == 1){
      allSportCountList.fillRange(0, sportYMSet.length, 0);
      allSportMinutesList.fillRange(0, sportYMSet.length, 0);
      allSportKCalList.fillRange(0, sportYMSet.length, 0.0);
    }else{
      allSportCountList.fillRange(0, sportYearSet.length, 0);
      allSportMinutesList.fillRange(0, sportYearSet.length, 0);
      allSportKCalList.fillRange(0, sportYearSet.length, 0.0);
    }
    if(isSportCalendar){
      for(int i = 0; i < dataLength; i++){
        if(deviceName == 'total'){
          if(_mapList[i]['sportYMD'] == choseWhichDay){
            sportCount = sportCount + _mapList[i]['sportCount'];
            sportDuration = sportDuration + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
            sportKCal = sportKCal + double.parse(_mapList[i]['sportKCal']);
            todaySportCountList[int.parse(_mapList[i]['sportHour']) ~/ 4] = todaySportCountList[int.parse(_mapList[i]['sportHour']) ~/ 4] + _mapList[i]['sportCount'];
            todaySportMinutesList[int.parse(_mapList[i]['sportHour']) ~/ 4] = todaySportMinutesList[int.parse(_mapList[i]['sportHour']) ~/ 4] + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
            todaySportKCalList[int.parse(_mapList[i]['sportHour']) ~/ 4] = todaySportKCalList[int.parse(_mapList[i]['sportHour']) ~/ 4] + double.parse(_mapList[i]['sportKCal']);
          }
        }else{
          if(_mapList[i]['deviceName'] == deviceName){
            if(_mapList[i]['sportYMD'] == choseWhichDay){
              sportCount = sportCount + _mapList[i]['sportCount'];
              sportDuration = sportDuration + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
              sportKCal = sportKCal + double.parse(_mapList[i]['sportKCal']);
              todaySportCountList[int.parse(_mapList[i]['sportHour']) ~/ 4] = todaySportCountList[int.parse(_mapList[i]['sportHour']) ~/ 4] + _mapList[i]['sportCount'];
              todaySportMinutesList[int.parse(_mapList[i]['sportHour']) ~/ 4] = todaySportMinutesList[int.parse(_mapList[i]['sportHour']) ~/ 4] + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
              todaySportKCalList[int.parse(_mapList[i]['sportHour']) ~/ 4] = todaySportKCalList[int.parse(_mapList[i]['sportHour']) ~/ 4] + double.parse(_mapList[i]['sportKCal']);
            }
          }
        }
      }
      // print('todaySportCountList:$todaySportCountList');
    }else{
      if(deviceName == 'total'){
        for(int i = 0; i < dataLength; i++){
          compareTime = DateTime.parse(_mapList[i]['sportYMD']);
          different = now.difference(compareTime);
          if(different.inDays <= whichDate){
            sportCount = sportCount + _mapList[i]['sportCount'];
            sportDuration = sportDuration + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
            sportKCal = sportKCal + double.parse(_mapList[i]['sportKCal']);
            _getCurseData(i, dataLength);
          }
        }
      }else{
        for(int i = 0; i < dataLength; i++){
          if(_mapList[i]['deviceName'] == deviceName){
            compareTime = DateTime.parse(_mapList[i]['sportYMD']);
            different = now.difference(compareTime);
            if(different.inDays <= whichDate){
              sportCount = sportCount + _mapList[i]['sportCount'];
              sportDuration = sportDuration + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
              sportKCal = sportKCal + double.parse(_mapList[i]['sportKCal']);
              _getCurseData(i, dataLength);
            }
          }
        }
      }
    }
  }//从这里结束

  //新添加从这里开始
  void _getCurseData(int i, int dataLength){
    if(totalData){//全部数据
      if(sportYearSet.length == 1){//没跨年
        if(i < dataLength - 1){//防止超过可用数组长度
          if(_mapList[i]['sportYM'] == _mapList[i + 1]['sportYM']){//判断是否年月相同
            allSportCountList[sportYMLength] = allSportCountList[sportYMLength] + _mapList[i]['sportCount'];
            allSportMinutesList[sportYMLength] = allSportMinutesList[sportYMLength] + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
            allSportKCalList[sportYMLength] = allSportKCalList[sportYMLength] + double.parse(_mapList[i]['sportKCal']);
          }else{//不相同计算另一个年月的总和
            sportYMLength++;
          }
        }else{
          allSportCountList[sportYMLength] = allSportCountList[sportYMLength] + _mapList[i]['sportCount'];
          allSportMinutesList[sportYMLength] = allSportMinutesList[sportYMLength] + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
          allSportKCalList[sportYMLength] = allSportKCalList[sportYMLength] + double.parse(_mapList[i]['sportKCal']);
        }
      }else{
        if(i < dataLength - 1){//防止超过可用数组长度
          if(_mapList[i]['sportYear'] == _mapList[i + 1]['sportYear']){//判断是否年相同
            allSportCountList[sportYearLength] = allSportCountList[sportYearLength] + _mapList[i]['sportCount'];
            allSportMinutesList[sportYearLength] = allSportMinutesList[sportYearLength] + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
            allSportKCalList[sportYearLength] = allSportKCalList[sportYearLength] + double.parse(_mapList[i]['sportKCal']);
          }else{//不相同计算另一个年的总和
            sportYearLength++;
            print('sportYearLength: $sportYearLength');
            print('i: $i');
          }
        }else{
          allSportCountList[sportYearLength] = allSportCountList[sportYearLength] + _mapList[i]['sportCount'];
          allSportMinutesList[sportYearLength] = allSportMinutesList[sportYearLength] + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
          allSportKCalList[sportYearLength] = allSportKCalList[sportYearLength] + double.parse(_mapList[i]['sportKCal']);
        }
      }
    }else if(todayData){//今日数据
      todaySportCountList[int.parse(_mapList[i]['sportHour']) ~/ 4] = todaySportCountList[int.parse(_mapList[i]['sportHour']) ~/ 4] + _mapList[i]['sportCount'];
      todaySportMinutesList[int.parse(_mapList[i]['sportHour']) ~/ 4] = todaySportMinutesList[int.parse(_mapList[i]['sportHour']) ~/ 4] + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
      todaySportKCalList[int.parse(_mapList[i]['sportHour']) ~/ 4] = todaySportKCalList[int.parse(_mapList[i]['sportHour']) ~/ 4] + double.parse(_mapList[i]['sportKCal']);
    }else if(weekData){
      weekSportCountList[int.parse(_mapList[i]['sportWeek']) - 1] = weekSportCountList[int.parse(_mapList[i]['sportWeek']) - 1] + _mapList[i]['sportCount'];
      weekSportMinutesList[int.parse(_mapList[i]['sportWeek']) - 1] = weekSportMinutesList[int.parse(_mapList[i]['sportWeek']) - 1] + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
      weekSportKCalList[int.parse(_mapList[i]['sportWeek']) - 1] = weekSportKCalList[int.parse(_mapList[i]['sportWeek']) - 1] + double.parse(_mapList[i]['sportKCal']);
    }else if(monthData){
      monthSportCountList[29- different.inDays] = monthSportCountList[29- different.inDays] + _mapList[i]['sportCount'];
      monthSportMinutesList[29- different.inDays] = monthSportMinutesList[29- different.inDays] + int.parse(_mapList[i]['sportDuration'].toString()) ~/ 60;
      monthSportKCalList[29- different.inDays] = monthSportKCalList[29- different.inDays] + double.parse(_mapList[i]['sportKCal']);
    }
  }//从这里结束

  String languageTransfer(int i){
    switch(sportMDList[i].toString().split('-')[1]){
      case '01':
        sportMonth = 'Jan';
        break;
      case '02':
        sportMonth = 'Feb';
        break;
      case '03':
        sportMonth = 'Mar';
        break;
      case '04':
        sportMonth = 'Apr';
        break;
      case '05':
        sportMonth = 'May';
        break;
      case '06':
        sportMonth = 'Jun';
        break;
      case '07':
        sportMonth = 'Jul';
        break;
      case '08':
        sportMonth = 'Aug';
        break;
      case '09':
        sportMonth = 'Sept';
        break;
      case '10':
        sportMonth = 'Oct';
        break;
      case '11':
        sportMonth = 'Nov';
        break;
      case '12':
        sportMonth = 'Dec';
        break;
    }

    return sportMonth;

  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 选择查看的数据类型
  void _onclickWhichDevice(int deviceType) async {
    if(SaveData.userId != null){
      connectivityResult = await (Connectivity().checkConnectivity());
      if(connectivityResult == ConnectivityResult.none){
        Method.showToast('It seems that there is no internet'.tr, context);
      }else{
        Method.showLessLoading(context, 'Loading2'.tr);
        if(choseWhichDay == null){
          if(totalData){
            _getNetSportData(deviceType, 0);
            deviceTimeList = [deviceType, 0];
          }else if(todayData){
            _getNetSportData(deviceType, 3);
            deviceTimeList = [deviceType, 3];
          }else if(weekData){
            _getNetSportData(deviceType, 2);
            deviceTimeList = [deviceType, 2];
          }else if(monthData){
            _getNetSportData(deviceType, 4);
            deviceTimeList = [deviceType, 4];
          }
        }else{
          _getSomeDayData(deviceType);
        }
      }
    }else{
      if(choseWhichDay == null){
        if(totalData){
          sportYearLength = 0;
          sportYMLength = 0;
          _getSportData(sportDeviceName, false, whichDate: 100000);
        }else if(todayData){
          _getSportData(sportDeviceName, false, whichDate: 0);
        }else if(weekData){
          _getSportData(sportDeviceName, false, whichDate: 7);
        }else if(monthData){
          _getSportData(sportDeviceName, false, whichDate: 29);
        }
      }else{
        _getSportData(sportDeviceName, true);
      }
    }
  }

  void _onclickTimeData(int timeArea) async {
    if(SaveData.userId != null){
      connectivityResult = await (Connectivity().checkConnectivity());
      if(connectivityResult == ConnectivityResult.none){
        Method.showToast('It seems that there is no internet'.tr, context);
      }else{
        Method.showLessLoading(context, 'Loading2'.tr);
        if(sportDeviceName == 'total'){
          _getNetSportData(0, timeArea);
          deviceTimeList = [0, timeArea];
        }else if(sportDeviceName == '跳绳'){
          _getNetSportData(1, timeArea);
          deviceTimeList = [1, timeArea];
        }else if(sportDeviceName == '拉力绳'){
          _getNetSportData(2, timeArea);
          deviceTimeList = [2, timeArea];
        }else if(sportDeviceName == '哑铃'){
          _getNetSportData(3, timeArea);
          deviceTimeList = [3, timeArea];
        }else if(sportDeviceName == '蝴蝶绳'){
          _getNetSportData(4, timeArea);
          deviceTimeList = [4, timeArea];
        }else if(sportDeviceName == '健腹轮'){
          _getNetSportData(5, timeArea);
          deviceTimeList = [5, timeArea];
        }else if(sportDeviceName == '握力环'){
          _getNetSportData(6, timeArea);
          deviceTimeList = [6, timeArea];
        }
      }
    }else{
      setState(() {
        sportYearLength = 0;
        sportYMLength = 0;
        if(timeArea == 0){
          _getSportData(sportDeviceName, false, whichDate: 100000);
        }else if(timeArea == 4){
          _getSportData(sportDeviceName, false, whichDate: 29);
        }else if(timeArea == 2){
          _getSportData(sportDeviceName, false, whichDate: 7);
        }else if(timeArea == 3){
          _getSportData(sportDeviceName, false, whichDate: 0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => Material(
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 0,
                child: Container(
                  width: 1080.w,
                  height: 558.h,
                  color: Color.fromRGBO(249, 122, 53, 1),
                ),
              ),
              Positioned(
                  top: 168.h,
                  left: 72.w,
                  child: Text('Welcome back'.tr,style: TextStyle(fontSize: 36.sp,color: Colors.white),)
              ),
              Positioned(
                  top: 216.h,
                  left: 72.w,
                  child: Text('My data'.tr,style: TextStyle(fontSize: 60.sp,color: Colors.white),)
              ),
              Positioned(
                right: 72.w,
                top: 176.h,
                child: Container(
                    width: 114.h,
                    height: 114.h,
                    padding: EdgeInsets.all(0),
                    // color: Colors.yellow,
                    child: SaveData.pictureUrl == null ? Image.asset("images/home_user.png")
                        : ClipOval(child: Image(image: FileImageEx(File(SaveData.pictureUrl)),),
                    )
                ),
              ),
              Positioned(
                  right: 72.w,
                  top: 176.h,
                  child: Container(
                    width: 114.h,
                    height: 114.h,
                    padding: EdgeInsets.all(0),
                    // color: Colors.yellow,
                    child: FlatButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return UserPicturePage(SaveData.pictureUrl);
                        }));
                      },
                    ),
                  )
              ),
              Positioned(
                  top: 372.h,
                  left: 72.w,
                  child: Container(
                    width: 936.w,
                    height: 187.h,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        color: Color.fromRGBO(255, 255, 255, 1)
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: <Widget>[
                          deviceControllerBuild(),
                          Container(
                            child: Icon(Icons.navigate_next, color: Colors.black.withOpacity(0.4),),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0.85), Colors.white.withOpacity(1)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight
                              )
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          Positioned(
                            left: 0,
                            child: Container(
                              child: Icon(Icons.navigate_before, color: Colors.black.withOpacity(0.4),),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [Colors.white.withOpacity(0.85), Colors.white.withOpacity(1)],
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft
                                  )
                              ),
                            ),
                          )
                      ],),
                    ),
                  )
              ),
              if(SaveData.userId != null)
                Positioned(
                  top: 558.h,
                  child: _bodyBuild(),
                ),
              if(SaveData.userId == null && _list.isNotEmpty)
                Positioned(
                    top: 558.h,
                    child: _dataBuild()
                ),
              if(SaveData.userId == null && _list.isEmpty)
                Positioned(
                    top: 1040.h,
                    child: Center(
                      child: Text('No motion data'.tr,style: TextStyle(fontSize: 64.sp,color: Colors.grey)),
                    )
                )
            ],
          ),
        ),
      ),
    );
  }
  ///顶部设备图片选择列表
  List<String> deviceControllerPicList = <String>['All data'.tr, 'images/tiaosheng.png',
    'images/lalisheng.png', 'images/hudiesheng .png', 'images/yaling.png', 'images/jianfulun.png'
    ,'images/wolihuan.png'];
  ///顶部设备名选择列表
  List<String> sportDeviceNameList = <String>['total', '跳绳', '拉力绳', '蝴蝶绳', '哑铃', '健腹轮', '握力环'];
  ///设备总体数据显示列表
  List<String> sportDevicePictureList = <String>['images/alldevice.png', 'images/equip_shuju_01.png', 'images/equip_shuju_05.png',
    'images/equip_shuju_03.png', 'images/equip_shuju_04.png', 'images/equip_shuju_02.png', 'images/equip_shuju_06.png'];


  Widget deviceControllerBuild(){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: deviceControllerBox(),
      ),
    );
  }

  List<Widget> deviceControllerBox() => List<Widget>.generate(deviceControllerPicList.length, (int index){
    return singleDeviceBuild(index);
  });

  Widget singleDeviceBuild(int index){
    return Row(
      children: <Widget>[
        Offstage(
          offstage: index != 0,
          child: Container(
            width: 10,
          ),
        ),
        Container(
          width: index == 0 ? 138.w : 106.8.w,
          height: index == 0 ? 76.h :61.3.h,
          margin: EdgeInsets.symmetric(horizontal: 22.w),
          child: FlatButton(
              splashColor: Colors.white10,
              highlightColor: Colors.white10,
              onPressed: (){
                setState(() {
                  deviceOnClickList.fillRange(0, deviceOnClickList.length, false);
                  deviceOnClickList[index] = true;
                  sportDeviceName = sportDeviceNameList[index];
                  sportDevicePicture = sportDevicePictureList[index];
                  if(onclickCountList[index] == 0){
                    onclickCountList.fillRange(0, onclickCountList.length, 0);
                    onclickCountList[index] = 1;
                    if(index == 3){
                      index++;
                    }else if(index == 4){
                      index--;
                    }
                    _onclickWhichDevice(index);
                  }
                });
              },
              padding: EdgeInsets.zero,
              child: index == 0 ? Text(
                'All data'.tr,
                style: TextStyle(
                  fontSize: 36.sp,
                  color: deviceOnClickList[index] ? const Color.fromRGBO(38, 45, 68, 1) : const Color.fromRGBO(182, 188, 203, 1),
                  fontWeight: FontWeight.normal,),
              ) : Image.asset(deviceControllerPicList[index], color: deviceOnClickList[index] ? const Color.fromRGBO(38, 45, 68, 1) : const Color.fromRGBO(182, 188, 203, 1),)
          ),
        ),
        Offstage(
          offstage: index == deviceControllerPicList.length - 1,
          child: Container(
            width: 3.w,
            height: 30.h,
            color: const Color.fromRGBO(197, 196, 199, 0.43),
          ),
        ),
        Offstage(
          offstage: index != deviceControllerPicList.length - 1,
          child: Container(
            width: 10,
          ),
        )
      ],
    );
  }

  Widget _bodyBuild() {
    return FutureBuilder(
      future: _futureBuilderFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            // print('waiting');
            return Padding(
              padding: EdgeInsets.only(
                  top: 500.h),
              child: Image.asset(
                'images/tiger-animation-loop.gif',
                width: 300.w,
                height: 300.h,
              ),
            );
          case ConnectionState.done:
            print('done');
            print(snapshot.hasError);
            return snapshot.hasError || _statisticsData == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 360.h,
                  ),
                  FlatButton(
                    child: Image.asset('images/unconnected.png',width: 360.w,height: 360.w,),
                    onPressed: (){
                      setState(() {
                        firstEnterRecord = true;
                        setState(() {
                          _futureBuilderFuture = _getNetSportData(deviceTimeList[0], deviceTimeList[1]);
                        });
                      });
                    },
                  ),
                  FlatButton(
                    child: Text('It seems that there is no internet'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                    onPressed: (){
                      setState(() {
                        firstEnterRecord = true;
                        setState(() {
                          _futureBuilderFuture = _getNetSportData(deviceTimeList[0], deviceTimeList[1]);
                        });
                      });
                    },
                  ),
                ],
              ),
            )
                : _statisticsData != null && _statisticsData.data == null
                ? Padding(
              padding: EdgeInsets.only(
                // left: ScreenUtil().setWidth(145),
                top: 600.h,
              ),
              child: Text(
                'No motion data'.tr,
                style: TextStyle(fontSize: 60.sp),
              ),
            )
                : _dataBuild();
          default:
            return null;
        }
      },
    );
  }

  Widget _dataBuild(){
    return Container(
      width: 1080.w,
      height: 1476.h,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 62.h),
        child: Column(
            children: <Widget>[
              RepaintBoundary(
                child: Container(
                  width: 936.w,
                  height: 90.h,
                  margin: EdgeInsets.only(
                      left: 72.w,
                      // top: 31.h,
                      right: 72.w),
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(22.5)),
                      color: Color(0xFFEEEEEE)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 234.w,
                        height: totalData ? 90.h : 66.h,
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(22.5)),
                            color: totalData
                                ? Colors.white
                                : Color(0xFFEEEEEE)),
                        child: FlatButton(
                          splashColor: Colors.white10,
                          highlightColor: Colors.white10,
                          child: Text('All Time'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                          onPressed: () {
                            totalData = true;
                            todayData = false;
                            weekData = false;
                            monthData = false;
                            choseWhichDay = null;
                            choseWhichDuration = null;
                            if (onclickCountList[6] == 0) {
                              _onclickTimeData(0);
                              onclickCountList = [0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 234.w,
                        height: todayData ? 90.h : 66.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(todayData ? 22.5 : 0)),
                            color: todayData
                                ? Colors.white
                                : Color(0xFFEEEEEE)),
                        child: FlatButton(
                          splashColor: Colors.white10,
                          highlightColor: Colors.white10,
                          child: Text('Day'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                          onPressed: () {
                            todayData = true;
                            totalData = false;
                            weekData = false;
                            monthData = false;
                            choseWhichDuration = '今日';
                            choseWhichDay = null;
                            if (onclickCountList[7] == 0) {
                              _onclickTimeData(3);
                              onclickCountList = [0, 0, 0, 0, 0, 0, 0, 1, 0, 0];
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 234.w,
                        height: weekData ? 90.h : 66.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(weekData ? 22.5 : 0)),
                            color: weekData
                                ? Colors.white
                                : Color(0xFFEEEEEE)),
                        child: FlatButton(
                          splashColor: Colors.white10,
                          highlightColor: Colors.white10,
                          child: Text('Week'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                          onPressed: () {
                            totalData = false;
                            todayData = false;
                            weekData = true;
                            monthData = false;
                            //新添加的从这里开始
                            choseWhichDuration = '周';
                            choseWhichDay = null;
                            if (onclickCountList[8] == 0) {
                              _onclickTimeData(2);
                              onclickCountList = [0, 0, 0, 0, 0, 0, 0, 0, 1, 0];
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 234.w,
                        height: monthData ? 90.h : 66.h,
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(22.5)),
                            color: monthData
                                ? Colors.white
                                : Color(0xFFEEEEEE)),
                        child: FlatButton(
                          child: Text('Month'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                          splashColor: Colors.white10,
                          highlightColor: Colors.white10,
                          onPressed: () {
                            totalData = false;
                            todayData = false;
                            weekData = false;
                            monthData = true;
                            choseWhichDuration = '月';
                            choseWhichDay = null;
                            if (onclickCountList[9] == 0) {
                              _onclickTimeData(4);
                              onclickCountList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 78.h,
              ),
              Container(
                margin: EdgeInsets.only(
                    left: 72.w,
                    right: 72.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Exercise data'.tr,
                      style: TextStyle(
                          fontSize: 42.sp,
                          color: Color.fromRGBO(0, 0, 0, 0.87)),
                    ),
                    FlatButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TotalRecordPage()))
                              .then((value) {
                            if(SaveData.isDeleteData){
                              SaveData.isDeleteData = false;
                              sportMDSet.clear();
                              sportMDList.clear();
                              if(SaveData.userId != null){
                                firstEnterRecord = true;
                                if(choseWhichDay == null){
                                  _futureBuilderFuture = _getNetSportData(deviceTimeList[0], deviceTimeList[1]).then((value){
                                    setState(() {});
                                  });
                                }else{
                                  _futureBuilderFuture = _getWhichDevice().then((value){
                                    setState(() {});
                                  });
                                }
                              }else{
                                setState(() {
                                  _getInitData();
                                });
                              }
                            }
                          });
                        },
                        padding: EdgeInsets.all(0),
                        icon: Image.asset("images/quanbujilu .png",
                            width: 34.w,
                            height: 34.h),
                        label: Text(
                          'All history'.tr,
                          style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.normal,
                              color: Color.fromRGBO(0, 0, 0, 0.87)),
                        ))
                  ],
                ),
              ),
              RepaintBoundary(child: buildDetailData()),
              SizedBox(
                height: 140.h,
              ),
              Container(
                margin: EdgeInsets.only(
                    left: 72.w,
                    right: 72.w),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Sports calendar'.tr,
                      style: TextStyle(
                          fontSize: 42.sp,
                          color: Color.fromRGBO(0, 0, 0, 0.87)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 62.h,
              ),
              RepaintBoundary(
                child: Container(
                  width: 1080.w,
                  height: 180.h,
                  // padding: EdgeInsets.only(left: 36.w, right: 36.w),
                  child: Swiper(
                    index: sportMDList.length % 4 == 0
                        ? sportMDList.length ~/ 4 - 1
                        : sportMDList.length ~/ 4,
                    loop: sportMDList.length <= 4 ? false : true,
                    itemBuilder: _buildSwiper,
                    itemCount: sportMDList.length % 4 == 0
                        ? sportMDList.length ~/ 4
                        : sportMDList.length ~/ 4 + 1,
                    control: sportMDList.length <= 4
                        ? null
                        :
                    SwiperControl(
                        size: 60.w,
                        color: Color.fromRGBO(249, 122, 53, 1)),
                  ),
                ),
              ),
              SizedBox(
                height: 140.h,
              ),
              Container(
                margin: EdgeInsets.only(
                    left: 72.w,
                    right: 72.w),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Graph'.tr,
                      style: TextStyle(
                          fontSize: 42.sp,
                          color: Color.fromRGBO(0, 0, 0, 0.87)),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 22.h,
              ),
              Container(
                  margin: EdgeInsets.only(
                      left: 72.w,
                      right: 72.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Image.asset(
                            'images/cishu .png',
                            width: 36.w,
                            height: 36.h,
                          ),
                          SizedBox(
                            width: 24.w,
                          ),
                          Text(
                            'count'.tr,
                            style: TextStyle(
                                fontSize: 30.sp,
                                color: Color.fromRGBO(0, 0, 0, 0.6)),
                          ),
                        ],
                      ),
                      Text(
                        'Units'.tr + ':' + 'singleCount'.tr,
                        style: TextStyle(
                            fontSize: 30.sp,
                            color: Color.fromRGBO(0, 0, 0, 0.6)),
                      ),
                    ],
                  )),
              RepaintBoundary(
                child: Container(
                    width: 891.6.w,
                    height: 500.h,
                    margin: EdgeInsets.only(
                        top: 37.6.h,
                        right: 72.w,
                        left: 72.w),
                    child: _buildLineData(1)),
              ),
              SizedBox(
                height: 100.h,
              ),
              Container(
                  margin: EdgeInsets.only(
                      left: 72.w,
                      right: 72.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Image.asset(
                            'images/shichang.png',
                            width: 36.w,
                            height: 36.h,
                          ),
                          SizedBox(
                            width: 24.w,
                          ),
                          Text(
                            'Duration'.tr,
                            style: TextStyle(
                                fontSize: 30.sp,
                                color: Color.fromRGBO(0, 0, 0, 0.6)),
                          ),
                        ],
                      ),
                      Text(
                        'Units'.tr + ':' + 'minute'.tr,
                        style: TextStyle(
                            fontSize: 30.sp,
                            color: Color.fromRGBO(0, 0, 0, 0.6)),
                      ),
                    ],
                  )),
              RepaintBoundary(
                child: Container(
                    width: 891.6.w,
                    height: 500.h,
                    margin: EdgeInsets.only(
                        top: 37.6.h,
                        right: 72.w,
                        left: 72.w),
                    child: _buildLineData(2)),
              ),
              SizedBox(
                height: 100.h,
              ),
              Container(
                  margin: EdgeInsets.only(
                      left: 72.w,
                      right: 72.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Image.asset(
                            'images/Color.png',
                            width: 36.w,
                            height: 36.h,
                          ),
                          SizedBox(
                            width: 24.w,
                          ),
                          Text(
                            'Calories'.tr,
                            style: TextStyle(
                                fontSize: 30.sp,
                                color: Color.fromRGBO(0, 0, 0, 0.6)),
                          ),
                        ],
                      ),
                      Text(
                        'Units'.tr + ": Kcal",
                        style: TextStyle(
                            fontSize: 30.sp,
                            color: Color.fromRGBO(0, 0, 0, 0.6)),
                      ),
                    ],
                  )),
              RepaintBoundary(
                child: Container(
                    width: 891.6.w,
                    height: 500.h,
                    margin: EdgeInsets.only(
                        top: 37.6.h,
                        right: 72.w,
                        left: 72.w),
                    child: _buildLineData(3)),
              ),
              SizedBox(
                height: 150.h,
              ),
            ]
        ),
      ),
    );
  }
  int k;
  Widget _buildSwiper(BuildContext context, int i){//运动日历轮播图
    int j;//每个item展示的日历卡片数量
    if(i == 0 && sportMDList.length % 4 !=0){
      j = sportMDList.length % 4;
    }else{
      j = 4;
    }
    k = sportMDList.length % 4;//余数
    return Container(
      width: 1080.w,
      // height: ScreenUtil().setHeight(104),
      padding: EdgeInsets.only(left: 72.w, right: 72.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // if(0 < j)
          //   buildTimeData(j == 4 ? k + 4 * i : 0 , sportMDList[j == 4 ? k + 4 * i : 0]),
          // if(0 < j)
          //   SizedBox(width: 40.w,),
          // if(1 < j)
          //   buildTimeData(j == 4 ? k + 4 * i + 1 : 1, sportMDList[j == 4 ? k + 4 * i + 1 : 1]),
          // if(1 < j)
          //   SizedBox(width: 40.w,),
          // if(2 < j)
          //   buildTimeData(j == 4 ? k + 4 * i + 2 : 2, sportMDList[j == 4 ? k + 4 * i + 2: 2]),
          // if(2 < j)
          //   SizedBox(width: 40.w,),
          // if(3 < j)
          //   buildTimeData(j == 4 ? k + 4 * i + 3: 3, sportMDList[j == 4 ? k + 4 * i + 3 : 3]),
          if(j != 4)
            SizedBox(width: (254 * (4-j)).w,),
          if(0 < j)
            sportMDList.length % 4 !=0 ? buildTimeData(j == 4 ? k + 4 * (i - 1) : 0, sportMDList[j == 4 ? k + 4 * (i - 1) : 0]) : buildTimeData(j == 4 ? 4 * i : 0, sportMDList[j == 4 ? 4 * i : 0]),
          if(1 < j)
            SizedBox(width: 80.w,),
          if(1 < j)
            sportMDList.length % 4 !=0 ? buildTimeData(j == 4 ? k + 4 * (i - 1) + 1: 1, sportMDList[j == 4 ? k + 4 * (i - 1) + 1: 1]) : buildTimeData(j == 4 ? 4 * i + 1: 0, sportMDList[j == 4 ? 4 * i + 1: 1]),
          if(2 < j)
            SizedBox(width: 80.w,),
          if(2 < j)
            sportMDList.length % 4 !=0 ? buildTimeData(j == 4 ? k + 4 * (i - 1) + 2: 2, sportMDList[j == 4 ? k + 4 * (i - 1) + 2: 2]) : buildTimeData(j == 4 ? 4 * i + 2: 0, sportMDList[j == 4 ? 4 * i + 2: 2]),
          if(3 < j)
            SizedBox(width: 80.w,),
          if(3 < j)
            sportMDList.length % 4 !=0 ? buildTimeData(j == 4 ? k + 4 * (i - 1) + 3: 3, sportMDList[j == 4 ? k + 4 * (i - 1) + 3: 3]) : buildTimeData(j == 4 ? 4 * i + 3: 0, sportMDList[j == 4 ? 4 * i + 3: 3]),
        ],
      ),
    );
  }

  Widget _buildLineData(int i){
    return choseWhichDay != null ? LineChartSample2(totalSportCount: todaySportCountList, totalSeconds: todaySportMinutesList, totalKcal: todaySportKCalList, dataType: i,
        choseWhichDay: choseWhichDuration,isYear: sportYearList.length == 1 ? true : false,totalYear: sportYearList.length == 1 ? sportYMList : sportYearList)
        : totalData ? LineChartSample2(totalSportCount: allSportCountList, totalSeconds: allSportMinutesList, totalKcal: allSportKCalList, dataType: i,
        choseWhichDay: choseWhichDuration,isYear: sportYearList.length == 1 ? true : false,totalYear: sportYearList.length == 1 ? sportYMList : sportYearList)
        : todayData ? LineChartSample2(totalSportCount: todaySportCountList, totalSeconds: todaySportMinutesList, totalKcal: todaySportKCalList, dataType: i,
        choseWhichDay: choseWhichDuration,isYear: sportYearList.length == 1 ? true : false,totalYear: sportYearList.length == 1 ? sportYMList : sportYearList)
        : weekData ? LineChartSample2(totalSportCount: weekSportCountList, totalSeconds: weekSportMinutesList, totalKcal: weekSportKCalList, dataType: i,
        choseWhichDay: choseWhichDuration,isYear: sportYearList.length == 1 ? true : false,totalYear: sportYearList.length == 1 ? sportYMList : sportYearList)
        : LineChartSample2(totalSportCount: monthSportCountList, totalSeconds: monthSportMinutesList, totalKcal: monthSportKCalList, dataType: i,
        choseWhichDay: choseWhichDuration,isYear: sportYearList.length == 1 ? true : false,totalYear: sportYearList.length == 1 ? sportYMList : sportYearList);
  }
  //详细数据组件
  Widget buildDetailData(){
    return Container(
        width: 934.w,
        height: 648.h,
        margin: EdgeInsets.only(top: 62.h,left: 72.w,right: 72.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 10, //阴影范围
                spreadRadius: 1, //阴影浓度
                color: Color.fromRGBO(86, 89, 96, 0.08), //阴影颜色
              )
            ]
        ),
        child: FlatButton(
          padding: EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 324.h,
                width: 934.w,
                padding: EdgeInsets.only(left: 72.w,right: 72.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(sportDevicePicture,width: 90.w,height: 90.h,),
                        Container(
                          width: 320.w,
                          child:Text(
                            deviceOnClickList[0] ? 'All Device'.tr : sportDeviceName == '握力环' ? 'Grip'.tr
                                : sportDeviceName == '跳绳' ? 'Jump rope'.tr
                                : sportDeviceName == '拉力绳' ? 'Resistance Band'.tr
                                : sportDeviceName == '蝴蝶绳' ? 'Spider Resistance Band'.tr
                                : sportDeviceName == '哑铃' ? 'Dumbbell'.tr : 'AB Wheel'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 42.sp,color: Color.fromRGBO(38, 45, 68, 1), fontWeight: FontWeight.normal,),),
                        ),
                      ],
                    ),
                    Text.rich(
                        TextSpan(
                            children: [
                              TextSpan(//新添加从这里开始
                                  text: sportCount.toString(),//从这里结束
                                  style: TextStyle(
                                      fontSize: 96.sp,
                                      color: Color.fromRGBO(38, 45, 68, 1)
                                  )
                              ),
                              TextSpan(
                                  text: ' ' + 'singleCount'.tr,
                                  style: TextStyle(
                                      fontSize: 42.sp,
                                      color: Color.fromRGBO(0, 0, 0, 0.6)
                                  )
                              )
                            ]
                        )
                    )
                  ],
                ),
              ),
              Divider(
                height: 3.h,
                color: Color.fromRGBO(233, 236, 241, 1),
                indent: 76.w,
                endIndent: 58.w,
              ),
              SizedBox(
                height: 90.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[//新添加从这里开始
                      Text(sportDuration.toString()//从这里结束
                        ,style: TextStyle(fontSize: 72.sp,color: Color.fromRGBO(41, 51, 75, 1)),),
                      Text('Duration'.tr + "(Min)",style: TextStyle(fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 0.45)),),
                    ],
                  ),
                  Column(
                    children: <Widget>[//新添加从这里开始
                      Text(sportKCal.toStringAsFixed(0),//从这结束
                        style: TextStyle(fontSize: 72.sp,color: Color.fromRGBO(41, 51, 75, 1)),),
                      Text('Calories'.tr + "(Kcal)",style: TextStyle(fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 0.45)),),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(sportStrength.toStringAsFixed(0), style: TextStyle(fontSize: 72.sp,color: Color.fromRGBO(41, 51, 75, 1)),),
                      Text('Strength'.tr, style: TextStyle(fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 0.45)),)
                    ],
                  )
                ],
              ),
            ],
          ),
        )
    );
  }

  List<int> dayList = new List();
//日历数据组件
  Widget buildTimeData(int day, String ymd){
    return Container(
        width: 174.w,
        // height: ScreenUtil().setHeight(104),
        // margin: day == sportMDList.length - 1 ? EdgeInsets.only(left: ScreenUtil().setWidth(0)) : EdgeInsets.only(left: 40.w),
        decoration: BoxDecoration(
            borderRadius:  BorderRadius.all(Radius.circular(16)),
            border: Border.all(width: 2.7.w,color: Color.fromRGBO(255, 104, 0, 0.45)),
            color: choseWhichDay != sportMDList[day] ? Color.fromRGBO(255,104,0,0.45) : Color.fromRGBO(249, 122, 53, 1)
        ),
        child: FlatButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          padding: EdgeInsets.all(0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 48.h,),
              Text(sportMDList[day].toString().split('-')[2],
                  style: TextStyle(fontWeight: FontWeight.normal,fontSize: 60.sp, color: choseWhichDay == sportMDList[day] ? Color.fromRGBO(255, 255, 255, 1)
                      : Color.fromRGBO(38, 45, 68, 1))),
              Text(languageTransfer(day),
                  style: TextStyle(fontWeight: FontWeight.normal,fontSize: 25.sp, color: choseWhichDay == sportMDList[day] ? Color.fromRGBO(255, 255, 255, 0.5) : Color.fromRGBO(38, 45, 68, 1))),
              SizedBox(height: 6.h,),
              if(choseWhichDay == sportMDList[day])
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                      borderRadius:  BorderRadius.all(Radius.circular(6.w)),
                      color: Colors.white
                  ),
                )
            ],
          ),
          onPressed: (){
            if(choseWhichDay != sportMDList[day]){
              setState(() {
                choseWhichDuration = '今日';
                choseWhichDay = sportMDList[day];
                if(SaveData.userId != null){
                  Method.showLessLoading(context, 'Loading2'.tr);
                  _getWhichDevice();
                }else{
                  _getSportData(sportDeviceName, true);
                }
                todayData = false;
                totalData = false;
                weekData = false;
                monthData = false;
              });
            }
          },
        )
    );
  }

  Future _getWhichDevice(){
    onclickCountList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    if(deviceOnClickList[0]){
      return _getSomeDayData(0);
    }else if(deviceOnClickList[1]){
      return _getSomeDayData(1);
    }else if(deviceOnClickList[2]){
      return _getSomeDayData(2);
    }else if(deviceOnClickList[4]){
      return _getSomeDayData(3);
    }else if(deviceOnClickList[3]){
      return _getSomeDayData(4);
    }else if(deviceOnClickList[5]){
      return _getSomeDayData(5);
    }else if(deviceOnClickList[6]){
      return _getSomeDayData(6);
    }
  }
  //获取某天的运动数据
  Future _getSomeDayData(int deviceType) async {
    if(historyData == null){
      await DioUtil().get(//为了拿到运动日历
        RequestUrl.historySportDataUrl,
        queryParameters: {"equipmentType": 0, "page": 0, "userId": SaveData.userId, "zone": DateTime.now().timeZoneOffset.inHours},
        options: Options(headers: {'access_token': SaveData.accessToken, "app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,),
      ).then((value){
        // print('运动日历:$value');
        if(value != null){
          historyData = HistoryData.fromJson(value);
          if(historyData.code == "200"){
            int length = historyData.data.totalElements;
            for(int i = length - 1; i >= 0; i--){
              sportMDSet.add(historyData.data.dataList[i].startTime.substring(0,10));
            }
            sportMDList = sportMDSet.toList();
          }
        }else{
          if(Navigator.canPop(context)){
            Navigator.of(context).pop();
          }
          Method.showToast('It seems that there is no internet'.tr, context);
        }
      });
    }
    return DioUtil().get(
        RequestUrl.getStatisticsSpecialUrl,
        queryParameters: {"avgCount": 6, "endTime": choseWhichDay + " 23:59:59", "equipmentType": deviceType, "startTime": choseWhichDay + " 00:00:00", "userId": SaveData.userId, "zone": DateTime.now().timeZoneOffset.inHours},
        options: Options(headers: {'access_token': SaveData.accessToken, "app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      if(value != null){
        _statisticsData = StatisticsData.fromJson(value);
        _clearData();
        // print(value);
        if(_statisticsData.code == "200"){
          for(int i = 0; i < _statisticsData.data.length; i++){
            sportCount = sportCount + _statisticsData.data[i].sportCount;
            sportDuration = sportDuration + _statisticsData.data[i].duringTime ~/ 60;
            sportKCal = sportKCal + _statisticsData.data[i].calorie;
            sportStrength = sportStrength + _statisticsData.data[i].sportStrength;
            todaySportCountList[i] = _statisticsData.data[i].sportCount;
            todaySportKCalList[i] = _statisticsData.data[i].calorie;
            todaySportMinutesList[i] = _statisticsData.data[i].duringTime ~/ 60;
          }
          sportYMLength = sportYMList.length;
          if(allSportCountList.isEmpty){
            // print(allSportCountList);
            allSportCountList.add(0);
            allSportMinutesList.add(0);
            allSportKCalList.add(0);
            sportYMList.add(nowTime.toString().substring(0, 7));
          }
          if(Navigator.canPop(context)){
            Navigator.of(context).pop();
          }
          setState(() {});
        }else{
          Method.showToast('It seems that there is no internet'.tr, context);
        }
      }
    });
  }
}

class LineChartSample2 extends StatefulWidget {
  final List totalKcal;
  final List totalSeconds;
  final List totalSportCount;
  final int dataType;
  final String choseWhichDay;
  final bool isYear;
  final List totalYear;
  const LineChartSample2({this.totalKcal, this.totalSeconds, this.totalSportCount, this.dataType, this.choseWhichDay,this.isYear,this.totalYear});
  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  //新添加的从这里开始
  List totalSportCountList;
  List totalMinutesList;
  List totalKCalList;
  int maxSportCount;
  int maxSportMinutes;
  double maxSportKCal;//从这里结束
  String xLength;

  @override
  void initState() {
    super.initState();
    //新添加从这里开始
    _makeMaxData();//从这里结束
  }


  //新添加从这里开始
  void _makeMaxData(){
    xLength = widget.choseWhichDay;
    totalSportCountList = widget.totalSportCount;
    totalMinutesList = widget.totalSeconds;
    totalKCalList = widget.totalKcal;
    maxSportCount = totalSportCountList[0];
    maxSportMinutes = totalMinutesList[0];
    maxSportKCal = double.parse(totalKCalList[0].toString());
    for(int i = 1; i < totalSportCountList.length; i++){
      if(totalSportCountList[i] > maxSportCount){
        maxSportCount = totalSportCountList[i];
      }
      if(totalMinutesList[i] > maxSportMinutes){
        maxSportMinutes = totalMinutesList[i];
      }
      if(double.parse(totalKCalList[i].toString()) > maxSportKCal){
        maxSportKCal = double.parse(totalKCalList[i].toString());
      }
    }
    maxSportCount = 10 * (maxSportCount ~/ 10 + 1);
    maxSportMinutes = 10 * (maxSportMinutes ~/ 10 + 1);
    maxSportKCal = 10 * (maxSportKCal ~/ 10 + 1) + 0.0;
  }//从这里结束

  @override
  void didUpdateWidget(LineChartSample2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _makeMaxData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 250.h,
      // width: ScreenUtil().setWidth(500),
      padding: EdgeInsets.zero,
      child: LineChart(mainData()),
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
        horizontalInterval: widget.dataType == 1 ? maxSportCount / 5
            : widget.dataType == 2 ? maxSportMinutes / 5
            : maxSportKCal / 5,//y轴分几等分,用于画多少条y轴线
        show: true,//是否显示画的垂直线和水平线
        drawVerticalLine: totalSportCountList.length == 30 ? false : true,//是否显示画的每一条垂直线
        getDrawingHorizontalLine: (value) {//画水平线
          return FlLine(
            color: Color.fromRGBO(233, 235, 241, 1),//线的颜色
            strokeWidth: 1,//线的宽度
          );
        },
        getDrawingVerticalLine: (value) {//画垂直线
          return FlLine(
            color: Color.fromRGBO(233, 235, 241, 1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,//是否显示横坐标值和纵坐标值
        bottomTitles: SideTitles(
          showTitles: true,//是否显示横坐标值
          reservedSize: 22,
          getTextStyles: (value) =>//横坐标值的颜色和字体大小
          const TextStyle(color: Color.fromRGBO(0, 23, 55, 0.3), fontSize: 10),
          getTitles: widget.choseWhichDay == '今日' ? (value) {
            switch (value.toInt()){
              case 0:
                return '00:00';
              case 1:
                return '04:00';
              case 2:
                return '08:00';
              case 3:
                return '12:00';
              case 4:
                return '16:00';
              case 5:
                return '20:00';
              case 6:
                return '24:00';
            }
            return '';
          } : widget.choseWhichDay == '周' ? (value) {
            switch (value.toInt()){
              case 0:
                return 'monday'.tr;
              case 1:
                return 'tuesday'.tr;
              case 2:
                return 'wednesday'.tr;
              case 3:
                return 'thursday'.tr;
              case 4:
                return 'friday'.tr;
              case 5:
                return 'saturday'.tr;
              case 6:
                return 'sunday'.tr;
            }
            return '';
          } : widget.choseWhichDay == '月' ? (value) {
            switch (value.toInt()){
              case 0:
                return DateTime.now().subtract(const Duration(days: 29)).toString().substring(5,10);
              case 1:
                return '';
              case 2:
                return '';
              case 3:
                return '';
              case 4:
                return DateTime.now().subtract(const Duration(days: 25)).toString().substring(5,10);
              case 5:
                return '';
              case 6:
                return '';
              case 7:
                return '';
              case 8:
                return '';
              case 9:
                return DateTime.now().subtract(const Duration(days: 20)).toString().substring(5,10);
              case 10:
                return '';
              case 11:
                return '';
              case 12:
                return '';
              case 13:
                return '';
              case 14:
                return DateTime.now().subtract(Duration(days: 15)).toString().substring(5,10);
              case 15:
                return '';
              case 16:
                return '';
              case 17:
                return '';
              case 18:
                return '';
              case 19:
                return DateTime.now().subtract(Duration(days: 10)).toString().substring(5,10);
              case 20:
                return '';
              case 21:
                return '';
              case 22:
                return '';
              case 23:
                return '';
              case 24:
                return DateTime.now().subtract(Duration(days: 5)).toString().substring(5,10);
              case 25:
                return '';
              case 26:
                return '';
              case 27:
                return '';
              case 28:
                return '';
              case 29:
                return DateTime.now().toString().substring(5,10);
            }
            return '';
          } : widget.choseWhichDay == null && !widget.isYear && widget.totalYear.isNotEmpty ?  (value) {
            switch (value.toInt()){
              case 1:
                return widget.totalYear[0];
              case 2:
                return widget.totalYear.length > 1 ? widget.totalYear[1] : '';
              case 3:
                return widget.totalYear.length > 2 ? widget.totalYear[2] : '';
              case 4:
                return widget.totalYear.length > 3 ? widget.totalYear[3] : '';
              case 5:
                return widget.totalYear.length > 4 ? widget.totalYear[4] : '';
              case 6:
                return widget.totalYear.length > 5 ? widget.totalYear[5] : '';
            }
            return '';
          } : widget.totalYear.isNotEmpty ? (value) {
            switch (value.toInt()){
              case 1:
                return widget.totalYear[0];
              case 2:
                return widget.totalYear.length > 1 ? widget.totalYear[1] : '';
              case 3:
                return widget.totalYear.length > 2 ? widget.totalYear[2] : '';
              case 4:
                return widget.totalYear.length > 3 ? widget.totalYear[3] : '';
              case 5:
                return widget.totalYear.length > 4 ? widget.totalYear[4] : '';
              case 6:
                return widget.totalYear.length > 5 ? widget.totalYear[5] : '';
              case 7:
                return widget.totalYear.length > 6 ? widget.totalYear[6] : '';
              case 8:
                return widget.totalYear.length > 7 ? widget.totalYear[7] : '';
              case 9:
                return widget.totalYear.length > 8 ? widget.totalYear[8] : '';
              case 10:
                return widget.totalYear.length > 9 ? widget.totalYear[9] : '';
              case 11:
                return widget.totalYear.length > 10 ? widget.totalYear[10] : '';
              case 12:
                return widget.totalYear.length > 11 ? widget.totalYear[11] : '';
            }
            return '';
          } : (value){},
          margin: 6,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: widget.dataType == 1 ? maxSportCount / 5
              : widget.dataType == 2 ? maxSportMinutes / 5
              : maxSportKCal / 5,//分多少等分数据，用于左边显示的数据
          getTextStyles: (value) => const TextStyle(
            color: Color.fromRGBO(33, 37, 41, 0.3),
            // fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          reservedSize: 24,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: const Color.fromRGBO(233, 235, 241, 1), width: 1)),//是否显示顶部水平线和底部水平线
      minX: 0,
      maxX: widget.choseWhichDay == null ? totalSportCountList.length.toDouble() : totalSportCountList.length == 30 ? 29 : 6,
      minY: 0,
      maxY: widget.dataType ==1 ? maxSportCount.toDouble()
          : widget.dataType == 2 ? maxSportMinutes.toDouble()
          : maxSportKCal,
      //画出的曲线，接收一个数组类型，可用于创建多条曲线
      lineBarsData: [
        LineChartBarData(
          spots: widget.choseWhichDay == null ? [
            FlSpot(0, 0),
            if(widget.dataType == 1)
              for(int i = 0; i < totalSportCountList.length; i++)
                FlSpot((i + 1).toDouble(), double.parse(totalSportCountList[i].toString())),
            if(widget.dataType == 2)
              for(int i = 0; i < totalSportCountList.length; i++)
                FlSpot((i + 1).toDouble(), double.parse(totalMinutesList[i].toString())),
            if(widget.dataType == 3)
              for(int i = 0; i < totalSportCountList.length; i++)
                FlSpot((i + 1).toDouble(), double.parse(totalKCalList[i].toString()))
          ] : widget.choseWhichDay == '今日' ? [
            FlSpot(0, 0),
            if(widget.dataType == 1)
              for(int i = 0; i < 6; i++)
                FlSpot((i + 1).toDouble(), double.parse(totalSportCountList[i].toString())),
            if(widget.dataType == 2)
              for(int i = 0; i < 6; i++)
                FlSpot((i + 1).toDouble(), double.parse(totalMinutesList[i].toString())),
            if(widget.dataType == 3)
              for(int i = 0; i < 6; i++)
                FlSpot((i + 1).toDouble(), double.parse(totalKCalList[i].toString()))
          ] : widget.choseWhichDay == '月' ? [
                if(widget.dataType == 1)
                  for(int i = 0; i < 30; i++)
                    FlSpot(i.toDouble(), double.parse(totalSportCountList[i].toString())),
                if(widget.dataType == 2)
                  for(int i = 0; i < 30; i++)
                    FlSpot(i.toDouble(), double.parse(totalMinutesList[i].toString())),
                if(widget.dataType == 3)
                  for(int i = 0; i < 30; i++)
                    FlSpot(i.toDouble(), double.parse(totalKCalList[i].toString()))
    ]
        : [
            if(widget.dataType == 1)
              for(int i = 0; i < 7; i++)
                FlSpot(i.toDouble(), double.parse(totalSportCountList[i].toString())),
            if(widget.dataType == 2)
              for(int i = 0; i < 7; i++)
                FlSpot(i.toDouble(), double.parse(totalMinutesList[i].toString())),
            if(widget.dataType == 3)
              for(int i = 0; i < 7; i++)
                FlSpot(i.toDouble(), double.parse(totalKCalList[i].toString()))
          ],
          isCurved: false,
          colors: widget.dataType == 1 ? [Color.fromRGBO(39, 113, 235, 1)] : widget.dataType == 2 ? [Color.fromRGBO(10, 185, 150, 1)] : [Color.fromRGBO(255, 175, 64, 1)],
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: totalSportCountList.length == 30 ? false : true,
          ),
          belowBarData: BarAreaData(//曲线下的颜色
            show: true,
            colors: widget.dataType == 1 ? [Color.fromRGBO(39, 113, 235, 0.08)] : widget.dataType == 2 ? [Color.fromRGBO(10, 185, 150, 0.08)] : [Color.fromRGBO(255, 175, 64, 0.08)],
          ),
        ),
      ],
    );
  }
//运动次数、运动时长去掉小数点
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
        fontSize: 12,
      );
      return LineTooltipItem(widget.dataType == 1 ? touchedSpot.y.toStringAsFixed(0) + '\n' + DateTime.now().subtract(Duration(days: 29 - touchedSpot.x.toInt())).toString().substring(0, 10)
          : widget.dataType == 2 ? touchedSpot.y.toStringAsFixed(0) + '\n' + DateTime.now().subtract(Duration(days: 29 - touchedSpot.x.toInt())).toString().substring(0, 10)
          : touchedSpot.y.toStringAsFixed(2) + '\n' + DateTime.now().subtract(Duration(days: 29 - touchedSpot.x.toInt())).toString().substring(0, 10), textStyle);
    }).toList();
  }
}