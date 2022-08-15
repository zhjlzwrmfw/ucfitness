import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/model/historyData.dart';
import 'package:running_app/routes/sportData/sportInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/saveData.dart';
import 'package:get/get.dart';

class TotalRecordPage extends StatefulWidget {
  @override
  TotalRecordPageState createState() => TotalRecordPageState();
}

class TotalRecordPageState extends State<TotalRecordPage> {
  // bool skippingDevice = false; //跳绳数据选择判断值
  // bool pullDevice = false; //拉力绳数据选择判断值
  // bool butterflyDevice = false; //蝴蝶绳数据选择判断值
  // bool dumbbellDevice = false; //哑铃数据选择判断值
  // bool abRoundDevice = false; //健腹轮数据选择判断值
  // bool choseDataTypeList[0] = true; //全部设备数据选择判断值
  List<bool> choseDataTypeList = [true, false, false, false, false, false, false];
  List<String> deviceControllerPicList = <String>['All data'.tr, 'images/tiaosheng.png',
    'images/lalisheng.png', 'images/hudiesheng .png', 'images/yaling.png', 'images/jianfulun.png'
    ,'images/wolihuan.png'];
  List<bool> valueList = new List();
  bool onclickDelete = false;
  bool totalDelete = false;
  String choseDevice; //用于点击选择设备标志
  List<String> choseDeviceList = ['全部', '跳绳','拉力绳','蝴蝶绳','哑铃','健腹轮','握力环'];
  //存储设备丹茨运动秒数
  Map<String, Object> _map = new Map();
  List<Map<String, Object>> _mapList = new List();
  List<String> _list = new List();
  // int choseCount = 0; //判断是否有选中的数据可删除
  String sportDurations;
  List _delItemsList = new List();
  HistoryData historyData;
  var _futureBuilderFuture; //避免重复请求刷新
  String jsonStr;
  int length = 0;//选中设备类型总长度
  List deleteValue = new List();


  @override
  void initState() {
    super.initState();
    if (SaveData.userId != null) {
      _futureBuilderFuture = _getSportData();
    } else {
      SharedPreferences.getInstance().then((value) {
        setState(() {
          _list = value.getStringList('sportData');
          int length = _list.length;
          for (int i = 0; i < length; i++) {
            //将拿到的字符串数组转换成map类型的数组
            _map = jsonDecode(_list[i]);
            _mapList.add(_map);
          }
          // print('_list:$_list');
          // print('_listLength:${_list.length}');
          valueList.length = _list.length;
          valueList.fillRange(0, _list.length, false);
        });
      });
    }
  }

  Future _getSportData() async {
    await Future.delayed(Duration(milliseconds: 500),(){
      _mapList.clear();
    });
    return DioUtil()
        .get(RequestUrl.historySportDataUrl,
        queryParameters: <String, Object>{
          'equipmentType': 0,
          'page': 0,
          'userId': SaveData.userId,
          'zone': DateTime.now().timeZoneOffset.inHours
        },
        options: Options(
          headers: <String, Object>{
            'access_token': SaveData.accessToken,
            'app_pass': RequestUrl.appPass
          },
          sendTimeout: 5000,
          receiveTimeout: 10000,
        )).then((value) {
      historyData = HistoryData.fromJson(value);
      print(value);
      if (historyData.code == "200") {
        int length = historyData.data.totalElements;
        print(length);
        for (int i = 0; i < length; i++) {
          _mapList.add(historyData.data.dataList[i].toJson());
          _getDeviceType(historyData.data.dataList[i].equipmentType, i);
          // print(historyData.data.dataList[length - 1 - i]);
        }
        _mapList.sort((a, b){
          return int.parse(a['id'].toString()) - int.parse(b['id'].toString());
        });
        valueList.length = _mapList.length;
        valueList.fillRange(0, _mapList.length, false);
        print(_mapList);
      }
    });
  }

  void _getDeviceType(int type, int i) {
    if (type == 6) {
      _mapList[i]['deviceName'] = '握力环';
      _mapList[i]['devicePicture'] = 'images/equip06.png';
    } else if (type == 5) {
      _mapList[i]['deviceName'] = '健腹轮';
      _mapList[i]['devicePicture'] = 'images/equip05.png';
    } else if (type == 4) {
      _mapList[i]['deviceName'] = '蝴蝶绳';
      _mapList[i]['devicePicture'] = 'images/equip03.png';
    } else if (type == 3) {
      _mapList[i]['deviceName'] = '哑铃';
      _mapList[i]['devicePicture'] = 'images/equip04.png';
    } else if (type == 2) {
      _mapList[i]['deviceName'] = '拉力绳';
      _mapList[i]['devicePicture'] = 'images/equip02.png';
    } else if (type == 1) {
      _mapList[i]['deviceName'] = '跳绳';
      _mapList[i]['devicePicture'] = 'images/equip01.png';
    }
    _mapList[i]['sportCount'] = historyData.data.dataList[i].count;
    _mapList[i]['sportKCal'] = historyData.data.dataList[i].calories;
    _mapList[i]['sportDuration'] = historyData.data.dataList[i].duringTime;
    _mapList[i]['sportMD'] =
        historyData.data.dataList[i].startTime.substring(5, 7) +
            '/' +
            historyData.data.dataList[i].startTime.substring(8, 10);
  }

  Widget deviceControllerBuild(){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: deviceControllerBox(),
      ),
    );
  }

  List<Widget> deviceControllerBox() => List<Widget>.generate(choseDataTypeList.length, (int index){
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
          width: index == 0 ? 138.w : 108.w,
          height: index == 0 ? 76.h : 62.h,
          margin: EdgeInsets.symmetric(horizontal: 22.w),
          child: FlatButton(
              splashColor: Colors.white10,
              highlightColor: Colors.white10,
              onPressed: (){
                setState(() {
                  choseDataTypeList.fillRange(0, choseDataTypeList.length, false);
                  choseDataTypeList[index] = true;
                  length = 0;
                  totalDelete = false;
                  choseDevice = choseDeviceList[index];
                  valueList.fillRange(0, valueList.length, false);
                  deleteValue.clear();
                });
              },
              padding: EdgeInsets.zero,
              child: index == 0 ? Text(
                'All data'.tr,
                style: TextStyle(
                  fontSize: 36.sp,
                  color: choseDataTypeList[index] ? const Color.fromRGBO(38, 45, 68, 1) : const Color.fromRGBO(182, 188, 203, 1),
                  fontWeight: FontWeight.normal,),
              ) : Image.asset(deviceControllerPicList[index], color: choseDataTypeList[index] ? const Color.fromRGBO(38, 45, 68, 1) : const Color.fromRGBO(182, 188, 203, 1),)
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

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => refreshBuild(),
    );
  }

  Widget buildRecord(int i) {
    length = length + 1;
    deleteValue.add(i);
    return Container(
      width: 1080.w,
      child: FlatButton(
        padding: EdgeInsets.only(left: 48.w, right: 48.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: <Widget>[
                RepaintBoundary(
                  child: Image(
                    image: AssetImage(_mapList[i]['devicePicture']),
                    width: 156.w,
                    height: 156.w,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 24.h),//top: ScreenUtil().setHeight(27),
                        child: Text(
                          SaveData.connectDeviceTypeStr(_mapList[i]['deviceName']) + '  ' + _mapList[i]['sportCount'].toString() + 'singleCount'.tr,
                          style: TextStyle(
                              fontSize: 42.sp,
                              fontWeight: FontWeight.normal,
                              color: Color.fromRGBO(38, 45, 68, 1)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RepaintBoundary(
                            child: Image.asset("images/recordtime.png",
                                width: 32.w,
                                height: 32.h),
                          ),
                          SizedBox(
                            width: 12.w,
                          ),
                          Text(
                            _getSportDuration(_mapList[i]['sportDuration'].toString()),
                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 1)),
                          ),
                          SizedBox(
                            width: 46.w,
                          ),
                          RepaintBoundary(
                            child: Image.asset("images/recordkcal.png",
                                width: 32.w,
                                height: 32.h),
                          ),
                          SizedBox(
                            width: 12.w,
                          ),
                          Text(
                            _mapList[i]['sportKCal'].toString() + "kcal",
                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  _mapList[i]['sportMD'].toString(),
                  style: TextStyle(fontWeight: FontWeight.normal,color: Color.fromRGBO(38, 45, 68, 0.45)),
                ),
                SizedBox(
                  width: 20.w,
                ),
                RepaintBoundary(
                  child: Image.asset("images/next.png",
                      width: 30.w,
                      height: 42.h),
                ),
              ],
            )
          ],
        ),
        splashColor: Colors.transparent,
        onPressed: () {
          if (SaveData.userId != null) {
            SportInfoPageState.deviceName = _mapList[i]['deviceName'];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SportInfoPage(
                      id: _mapList[i]["id"],
                      isRealSport: false,
                    )));
          } else {
            _getLocalData(i);
          }
        },
      ),
    );
  }

  void _getLocalData(int i) {
    SaveData.sportCount = _mapList[i]['sportCount'].toString();
    SaveData.broadcastType = _mapList[i]['broadcastType'];
    SaveData.kcalCount = _mapList[i]['sportKCal'];
    SaveData.avgBmp = _mapList[i]['avgBmp'];
    SaveData.totalBmp = _mapList[i]['totalBmpData'];
    SaveData.totalBmpTime = _mapList[i]['totalBmpTime'];
    if(SaveData.userId == null){
      if(_mapList[i]['trainMode'] == 1){
        SaveData.modeName = '自由模式';
      }else if(_mapList[i]['trainMode'] == 2){
        SaveData.modeName = '计时模式';
      }else if(_mapList[i]['trainMode'] == 3){
        SaveData.modeName = '计数模式';
      }
      SaveData.sportMode = _mapList[i]['mode'];
    }
    if (_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(0, 2) == '00' && _getSportDuration(_mapList[i]['sportDuration'].toString()).substring(3, 5) == '00') {
      SaveData.secondsCount = (int.parse(_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(6, 8))).toString();
      SaveData.avgCount = (int.parse(_mapList[i]['sportCount'].toString()) / int.parse(_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(6, 8)) * 60).toStringAsFixed(0);
      SaveData.minCount = null;
    } else {
      if (_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(0, 2) != '00') {
        SaveData.minCount = (int.parse(_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(0, 2)) * 60 + int.parse(_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(3, 5))).toString();
        SaveData.totalSeconds = (int.parse(_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(0, 2)) * 60 * 60
            + int.parse(_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(3, 5)) * 60 + int.parse(_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(6, 8))).toString();
        SaveData.avgCount = (int.parse(_mapList[i]['sportCount'].toString()) / int.parse(SaveData.totalSeconds) * 60).toStringAsFixed(0);
      } else {
        SaveData.minCount = (int.parse(_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(3, 5))).toString();
        SaveData.totalSeconds = (int.parse(_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(3, 5)) * 60 + int.parse(_getSportDuration(_mapList[i]['sportDuration'].toString()).substring(6, 8))).toString();
        SaveData.avgCount = (int.parse(_mapList[i]['sportCount'].toString()) / int.parse(SaveData.totalSeconds) * 60).toStringAsFixed(0);
      }
      SaveData.secondsCount = null;
    }
    SaveData.sportTime = _mapList[i]['sportYMDHM'];
    SportInfoPageState.deviceName = _mapList[i]['deviceName'];
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SportInfoPage(isRealSport: false)));
  }

  Widget deleteList(int i) {
    length = length + 1;
    deleteValue.add(i);
    return Container(
      width: 1080.w,
      // height: 100.h,
      child: FlatButton(
        padding: EdgeInsets.only(left: 48.w, right: 48.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: <Widget>[
                Image(
                  image: AssetImage(_mapList[i]['devicePicture']),
                  width: 156.w,
                  height: 156.w,
                ),
                Container(
                  padding: EdgeInsets.only(left: 24.w),
                  // width: ScreenUtil().setWidth(305),
                  // color: Colors.red,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 24.h),//top: ScreenUtil().setHeight(27),
                        child: Text(
                          SaveData.connectDeviceTypeStr(_mapList[i]['deviceName'])
                              + '  ' + _mapList[i]['sportCount'].toString() + 'singleCount'.tr,
                          style: TextStyle(fontSize: 42.sp, color: Color.fromRGBO(38, 45, 68, 1), fontWeight: FontWeight.normal),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset("images/recordtime.png",
                              width: 32.w,
                              height: 32.h),
                          SizedBox(
                            width: 12.w,
                          ),
                          Text(
                            _getSportDuration(_mapList[i]['sportDuration'].toString()),
                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 1)),
                          ),
                          SizedBox(
                            width: 46.w,
                          ),
                          Image.asset("images/recordkcal.png",
                              width: 32.w,
                              height: 32.h),
                          SizedBox(
                            width: 12.w,
                          ),
                          Text(
                            _mapList[i]['sportKCal'].toString() + "kcal",
                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 36.sp,color: Color.fromRGBO(38, 45, 68, 1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Icon(
              Icons.check_circle,
              size: 72.w,
              color: valueList[i] ? Color.fromRGBO(249, 122, 53, 1) : Colors.grey.withOpacity(0.4),
            )
          ],
        ),
        splashColor: Colors.transparent,
        onPressed: () {
          setState(() {
            length = 0;
            deleteValue.clear();
            if(valueList[i]){
              valueList[i] = false;
            }else{
              valueList[i] = true;
            }
            if (valueList.contains(false)) {
              totalDelete = false;
            } else {
              totalDelete = true;
            }
          });
        },
      ),
    );
  }

  //新添加从这里开始
  String _getSportDuration(String sportDuration) {
    String sportMinutes;
    String sportHours;
    String sportSeconds;
    if (int.parse(sportDuration) ~/ 60 >= 10) {
      sportMinutes = (int.parse(sportDuration) ~/ 60).toString();
    } else {
      sportMinutes = '0' + (int.parse(sportDuration) ~/ 60).toString();
    }
    if (int.parse(sportDuration) ~/ 3600 >= 10) {
      sportHours = (int.parse(sportDuration) ~/ 3600).toString();
    } else {
      sportHours = '0' + (int.parse(sportDuration) ~/ 3600).toString();
    }
    if (int.parse(sportDuration) % 60 >= 10) {
      sportSeconds = (int.parse(sportDuration) % 60).toString();
    } else {
      sportSeconds = '0' + (int.parse(sportDuration) % 60).toString();
    }
    sportDurations = sportHours + ':' + sportMinutes + ':' + sportSeconds;
    return sportDurations;
  }

  void _confirm() {
    SaveData.isDeleteData = true;
    // print('deleteValue:$deleteValue');
    for (int i = length - 1; i >= 0; i--) {
      if (valueList[deleteValue[length - 1 - i]]) {
        if (SaveData.userId == null) {
          _list.removeAt(deleteValue[length - 1 - i]);
        }
        if(SaveData.userId != null){
          _delItemsList.add(_mapList[deleteValue[length - 1 - i]]['id']);
        }
        _mapList.removeAt(deleteValue[length - 1 - i]);
      }
    }

    if (SaveData.userId != null) {
      DioUtil()
          .delete(RequestUrl.historySportDataUrl,
          data: _delItemsList,
          options: Options(headers: {
            'access_token': SaveData.accessToken,
            "app_pass": RequestUrl.appPass
          }))
          .then((value) {
        // print('value:$value');
      });
    }
    setState(() {
      valueList.fillRange(0, _mapList.length, false);
      onclickDelete = false;
      SharedPreferences.getInstance().then((value) {
        if (SaveData.userId == null) {
          print('删除后的list:$_list');
          value.setStringList('sportData', _list);
        }
      });
    });
  }

  Widget refreshBuild() {
    return Material(
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
              size: 42.w,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Exercise records'.tr,
            style: TextStyle(
                fontSize: 42.sp, color: Colors.white),
          ),
          actions: <Widget>[
            FlatButton(
              child: onclickDelete
                  ? Text(
                'Cancel'.tr,
                style: TextStyle(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
                textAlign: TextAlign.right,
              )
                  : Image.asset(
                "images/edit.png",
                width: 42.w,
                height: 42.w,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  if (onclickDelete) {
                    onclickDelete = false;
                    valueList.fillRange(0, valueList.length, false);
                    totalDelete = false;
                  } else {
                    onclickDelete = true;
                  }
                  length = 0;
                  deleteValue.clear();
                });
              },
            )
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top:0,
              child:Container(
                width: 1080.w,
                height: 187.h,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(249, 122, 53, 1)),
              ),
            ),
            /**选择器*/
            Positioned(
                top: 0,
                child: Container(
                  width: 932.w,
                  height: 187.h,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                      color: Color.fromRGBO(255, 255, 255, 1)),
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
                )),
            if (SaveData.userId != null)
              Positioned(
                top: 186.h,
                child: FutureBuilder(
                  future: _futureBuilderFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        print('waiting');
                        return Padding(
                          padding: EdgeInsets.only(top: 500.h),
                          child: Image.asset(
                            'images/tiger-animation-loop.gif',
                            width: 300.w,
                            height: 300.h,
                          ),
                        );
                      case ConnectionState.done:
                        print('done');
                        print(snapshot.error);
                        // print(_mapList);
                        return snapshot.hasError
                            ? Padding(
                          padding: EdgeInsets.only(
                              top: 760.h,
                              left: 200.w),
                          child: FlatButton(
                            child: Text(
                              'It seems that there is no internet'.tr,
                              style: TextStyle(
                                  fontSize: 60.sp,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey),
                            ),
                            onPressed: () {
                              setState(() {
                                _futureBuilderFuture = _getSportData();
                              });
                            },
                          ),
                        )
                            : Container(
                          width: 1080.w,
                          height: 1600.h,
                          child: Scrollbar(
                            child: ListView(
                              cacheExtent: 1920.h,
                              itemExtent: 200.h,
                              padding: EdgeInsets.only(top: 22.h),
                              children: <Widget>[
                                if (!onclickDelete)
                                  for (int i = _mapList.length - 1; i >= 0; i--)
                                    if (_mapList[i]['deviceName'] == choseDevice || choseDataTypeList[0])
                                      buildRecord(i),
                                if (onclickDelete)
                                  for (int i = _mapList.length - 1; i >= 0; i--)
                                    if (_mapList[i]['deviceName'] == choseDevice || choseDataTypeList[0])
                                      deleteList(i),
                                SizedBox(
                                  height: 150.h,
                                )
                              ],
                            ),
                          ),
                        );
                      default:
                        return null;
                    }
                  },
                ),
              ),
            if (SaveData.userId == null)
              Positioned(
                top: 186.h,
                child: Container(
                  width: 1080.w,
                  height: 1600.h,
                  child: ListView(
                    itemExtent: 200.h,
                    padding: EdgeInsets.only(top: 22.h),
                    children: <Widget>[
                      if (!onclickDelete)
                        for (int i = _mapList.length - 1; i >= 0; i--)
                          if (_mapList[i]['deviceName'] == choseDevice ||
                              choseDataTypeList[0])
                            buildRecord(i),
                      if (onclickDelete)
                        for (int i = _mapList.length - 1; i >= 0; i--)
                          if (_mapList[i]['deviceName'] == choseDevice ||
                              choseDataTypeList[0])
                            deleteList(i),
                      SizedBox(
                        height: 300.h,
                      )
                    ],
                  ),
                ),
              ),
            if (onclickDelete)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 1080.w,
                  height: 173.h,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 48.w,
                          ),
                          Checkbox(
                            value: totalDelete,
                            activeColor: Color.fromRGBO(249, 122, 53, 1),
                            onChanged: (value) {
                              setState(() {
                                totalDelete = value;
                                if (value) {
                                  for(int i = 0; i < length; i++){
                                    valueList[deleteValue[i]] = true;
                                  }
                                } else {
                                  for(int i = 0; i < length; i++){
                                    valueList[deleteValue[i]] = false;
                                  }
                                }
                                length = 0;
                                deleteValue.clear();
                              });
                            },
                          ),
                          Text(
                            'Select all'.tr,
                            style: TextStyle(fontSize: 42.sp),
                          ),
                        ],
                      ),
                      FlatButton.icon(
                        padding:
                        EdgeInsets.only(right: 72.w),
                        onPressed: valueList.contains(true) ? () {
                          Method.customDialog(
                            context,
                            'tips'.tr,
                            'deleteRecord'.tr,
                            _confirm,
                          );
                        } : null,
                        icon: Image.asset(
                          valueList.contains(true)?"images/delete.png":"images/delete_grey.png",
                          width: 60.w,
                          height: 60.h,
                        ),
                        label: Text(
                          'Delete'.tr,
                          style: TextStyle(
                              fontSize: 42.sp,
                              fontWeight: FontWeight.normal,
                              color: valueList.contains(true)?Color.fromRGBO(237, 82, 84, 1):Color.fromRGBO(213, 213, 213, 1)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
