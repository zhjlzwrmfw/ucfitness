import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../common/saveData.dart';
import 'mainSport.dart';
import 'package:get/get.dart';

class UpdateCardPage extends StatefulWidget{

  @override
  UpdateCardPageState createState() => UpdateCardPageState();

}

class UpdateCardPageState extends State<UpdateCardPage>{

  bool showCard = true;//显示卡片标志位
  static List<int> items = [0, 1, 2, 3, 4, 5];
  List<Widget> cardList = new List();
  List<String> itemList = new List(6);
  bool isEndSport = false;
  final BlueToothChannel blueToothChannel = new BlueToothChannel();
  StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息

  @override
  void initState() {
    super.initState();
    _streamSubscription = blueToothChannel.eventChannelPlugin
        .receiveBroadcastStream()
        .listen(_onToDart, onError: _onToDartError);

    SharedPreferences.getInstance().then((value){
      if(value.getStringList("itemList") != null){
        itemList = value.getStringList("itemList");
        for(int i = 0; i < itemList.length; i++){
          items[i] = int.parse(itemList[i]);
        }
      }
      setState(() {
        showCard = value.getBool('showCard');
      });
    });
  }

  void _onToDart(dynamic message) {
    switch (message['code']) {
      case '80005':
        Uint8List data = message['data'];
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
    titleItems = [
      'count'.tr, 'Duration'.tr,
      'Height'.tr, 'Weight'.tr,
      'BMI', 'Top coach'.tr
    ];
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
                  if(isEndSport){
                    Navigator.of(context).pop(1);
                  }else{
                    Navigator.of(context).pop(0);
                  }
                },
              ),
              title: Text(
                'Edit'.tr,
                style: TextStyle(
                    fontSize: 42.sp, color: Colors.white),
              ),
            ),
            body: Stack(
              children: <Widget>[
                Positioned(
                    top: 48.h,
                    child: Container(
                      width: 1080.w,
                      height: 120.h,
                      padding: EdgeInsets.only(
                          left: 72.w,
                          right: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Show'.tr,
                            style: TextStyle(
                                fontSize: 42.sp,
                                fontWeight: FontWeight.normal,
                                color: Color.fromRGBO(0, 0, 0, 0.87)),
                          ),
                          Container(
                            // width: ScreenUtil().setWidth(34),
                            // color: Colors.blue,
                            child: Switch(
                              activeColor: const Color.fromRGBO(249, 122, 53, 1),
                              value: showCard,
                              onChanged: (bool value) {
                                setState(() {
                                  showCard = value;
                                  SharedPreferences.getInstance().then((value) {
                                    value.setBool('showCard', showCard);
                                  });
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    )),
                if(showCard)
                  Positioned(
                    top: 216.h,
                    child: Container(
                      width: 1080.w,
                      height: 1200.h,
                      child: ReorderableListView(
                        header:Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: 72.w,),
                            Text('Hold and drag to change the order'.tr, style: TextStyle(fontWeight: FontWeight.normal,fontSize: 30.sp, color: Color.fromRGBO(0, 0, 0, 0.5)),)
                          ],
                        ),
                        children: <Widget>[
                          for (int item in items)
                            buildListData(titleItems[item], leadingItems[item], item)
                        ],
                        onReorder: (int oldIndex, int newIndex) {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          var child = items.removeAt(oldIndex);
                          items.insert(newIndex, child);
                          setState(() {});
                          SaveData.setCard = true;
                          SharedPreferences.getInstance().then((value){
                            for(int i = 0; i < items.length; i++){
                              itemList[i] = items[i].toString();
                            }
                            value.setStringList("itemList", itemList);
                          });
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
//卡片数据来源
  List<String> titleItems = [
    '运动次数','运动时长','身高','体重','BMI','金牌教练'
  ];
//卡片数据来源
  List<String> leadingItems = [
    'images/cishu .png','images/shichang.png',
    'images/shengao.png','images/tizhong.png',
    'images/bmi.png','images/jiaolian.png'
  ];
//自定义卡片组件
  Widget buildListData(String titleItems, String leading, int item){
    return Container(
      key: ValueKey(item),
      height: 140.h,
      width: 1080.w,
      color: Color.fromRGBO(250, 250, 250, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 72.w,right: 32.w),
            child: Image.asset(leading, width: 48.w, height: 48.h),
          ),
          Container(
            width: 804.w,
            child: Text(titleItems,style: TextStyle(fontSize: 42.sp,color: Color.fromRGBO(0, 0, 0, 0.87)),),
          ),
          Image.asset('images/shunxu.png',width: 44.w,height: 44.h),
        ],
      ),
    );
  }
}