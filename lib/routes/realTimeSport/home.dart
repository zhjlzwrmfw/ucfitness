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
import 'package:running_app/routes/course/video_player_slider.dart';
import 'package:running_app/routes/fasicaGun/fasicaGunMain.dart';
import 'package:running_app/routes/realTimeSport/connectDevice.dart';
import 'package:running_app/routes/userRoutes/userPicture.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import '../../common/blueUuid.dart';
import 'mainSport.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget{

  @override
  HomePageState createState() => HomePageState();

}

  bool hasNetwork = false;
  CourseList courseList;
  bool getCourseSuccess = false;

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{

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

  @override
  void initState() {
    super.initState();
    if(SaveData.openedApp){
      SaveData.openedApp = false;
    }
    // Method.checkNetwork(context).then((value){
    //   if(mounted){
    //     setState(() {
    //       hasNetwork = value;
    //     });
    //   }
    //   if(SaveData.userId != null && value){
    //     getCourseList();
    //   }
    // });
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

  void getCourseList(){
    DioUtil().post(
      RequestUrl.getCourseListUrl,
      data: <String, Object>{'language': SaveData.english ? 1 : 0, 'page': 0, 'pageLimited': 0},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass':RequestUrl.appPass}),
    ).then((value){
      print(value);
      if(mounted){
        setState(() {
          if(value != null){
            courseList = CourseList.fromJson(value);
            if(courseList.code == '200'){
              getCourseSuccess = true;
            }else if(courseList.code == '409'){
              courseList = null;
              getCourseSuccess = false;
              getCourseList();
            }else{
              courseList = null;
              getCourseSuccess = false;
            }
          }else{
            getCourseSuccess = false;
            Method.showToast('It seems that there is no internet'.tr, context);
          }
        });
      }
    });
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

  bool disconnect = false;

  void _onToDart(dynamic message) {
    switch (message['code']) {
      case '80001':
        disconnect = false;
        Future.delayed(const Duration(milliseconds: 3000), () {
          if(!disconnect){
            if(Navigator.canPop(context)){
              Navigator.of(context).pop();
            }
            Navigator.push<Object>(context, MaterialPageRoute(builder: (BuildContext context) {
              return MainSportPage();
            })).then((Object value){
              _openStreamNotify();
            });
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
        disconnect = true;
        Method.showToast('Connect failed'.tr, context);
        // homePage = true;
        break;
      case '90002':
        _canPopRoutes();
        disconnect = true;
        Method.showToast('Connect failed'.tr, context);
        // homePage = true;
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PkPage())).then((value){
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
              if(hasDevice)
              Positioned(
                  top: 390.h,
                  right: 72.w,
                  child:FlatButton.icon(
                      padding: EdgeInsets.all(0),
                      textTheme: ButtonTextTheme.normal,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onPressed: (){
                        functionFlag = 1;
                        if(defaultTargetPlatform == TargetPlatform.android){
                          blueToothChannel.checkWhatPermission(context).then((bool value){
                            if(value){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectDevicePage())).then((value){
                                getDeviceInfo();
                                _openStreamNotify();
                              });
                            }
                          });
                        }else{
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectDevicePage())).then((value){
                            getDeviceInfo();
                            _openStreamNotify();
                          });
                        }
                      },
                      icon: Icon(Icons.add,size: 56.w,),
                      label: Text('Search devices'.tr, style: TextStyle(fontSize: 42.sp, fontWeight: FontWeight.normal),))
              ),
              Positioned(
                top: 505.h,
                child: RefreshIndicator(
                  onRefresh: _pullToRefresh,
                  color: const Color.fromRGBO(249, 122, 53, 1),
                  child: Container(
                    width: 1080.w,
                    height: 1396.h,
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 72.w,
                                    top: hasDevice ? 12.h : 36.h,
                                    right: 72.w),
                                child: Text(
                                  'Available devices'.tr,
                                  style: TextStyle(fontSize: 42.sp, fontWeight: FontWeight.normal, color: const Color.fromRGBO(25, 26, 26, 1)),
                                ),
                              ),
                            if(hasDevice)
                              for(int i = deviceList.length - 1; i >= 0; i--)
                                buildConnectDevice(i),
                            if(hasDevice && deviceList.length >= 5)
                              SizedBox(
                                height: 176.h,
                              ),
                            if(!hasDevice)
                              GestureDetector(
                                onTap: (){
                                  if(defaultTargetPlatform == TargetPlatform.iOS){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectDevicePage())).then((value){
                                      getDeviceInfo();
                                      _openStreamNotify();
                                    });
                                  }else{
                                    blueToothChannel.checkWhatPermission(context).then((bool value){
                                      if(value){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectDevicePage())).then((value){
                                          getDeviceInfo();
                                          _openStreamNotify();
                                        });
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  width: 936.w,
                                  height: 140.h,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(9)),
                                    color: Color.fromRGBO(247, 248, 250, 1),
                                  ),
                                  margin: EdgeInsets.only(left: 72.w, right: 72.w,top: 36.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(left: 32.w),
                                        child: Image.asset('images/添加设备.png', width: 80.w, height: 80.w, color: const Color.fromRGBO(186, 186, 186, 1),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 32.w),
                                        child: Text(
                                          'Search devices'.tr,
                                          style: TextStyle(
                                              color: const Color.fromRGBO(26, 19, 17, 1),
                                              fontSize: 36.sp,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            // if(SaveData.userId != null)
                            // Padding(
                            //   padding: EdgeInsets.only(left: 72.w, top: 96.h, bottom: 24.h),
                            //   child: Text(
                            //     '推荐课程',
                            //     style: TextStyle(fontSize: 42.sp, fontWeight: FontWeight.normal, color: const Color.fromRGBO(25, 26, 26, 1)),
                            //   ),
                            // ),
                            // if(courseList != null && SaveData.userId != null)
                            //   for(int i = 0; i < courseList.data.dataList.length; i++)
                            //     videoBuild(i: i),
                            // if(courseList == null && SaveData.userId != null)
                            //   videoBuild(),
                            const SizedBox(
                              height: 100,
                            )
                          ]
                      ),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Future _pullToRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    Method.checkNetwork(context).then((value){
      if(mounted){
        setState(() {
          if(value){
            hasNetwork = value;
            if(SaveData.userId != null){
              getCourseList();
            }else{
              Method.showToast('请先注册登录账号', context);
            }
          }
        });
      }
    });
  }

  Widget videoBuild({int i}){
    return RepaintBoundary(
      child: GestureDetector(
        child: Card(
          elevation: 1.3,
          margin: EdgeInsets.only(
              left: 72.w,
              right: 72.w,
              top: i == 0 ? 0 : 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 936.w,
                height: 480.h,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                    color: const Color.fromRGBO(229, 229, 228, 1),
                    // border: Border.all(color: const Color.fromRGBO(116, 117, 117, 1), width: ScreenUtil().setWidth(0.5).toDouble()),
                    image: hasNetwork && getCourseSuccess ? DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(
                            RequestUrl.getUserPictureUrl + courseList.data.dataList[i].cover,
                            headers: {'app_pass': RequestUrl.appPass})
                    ) : null
                ),
              ),
              SizedBox(
                height: 19.7.h,
              ),
              Container(
                width: 936.w,
                margin: EdgeInsets.only(
                    left: 18.w),
                child: Text(
                  hasNetwork && getCourseSuccess ? courseList.data.dataList[i].title : '',
                  style: TextStyle(fontSize: 42.sp, color: const Color.fromRGBO(52, 52, 52, 1), ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: 19.4.h,
              ),
              Container(
                width: 936.w,
                margin: EdgeInsets.only(
                    left: 18.w,
                    bottom: 18.w),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(6), bottomLeft: Radius.circular(6)),
                ),
                child: Text(
                  hasNetwork && getCourseSuccess ? (courseList.data.dataList[i].level == 1 ? '入门   ' : '进阶   ')
                  + (courseList.data.dataList[i].during ~/ 60).toString() + 'minutes'.tr
                  + '   ' + 'Calories'.tr + courseList.data.dataList[i].expectCalorie.toString() + 'kcal' : '',
                  style: TextStyle(fontSize: 32.sp, color: const Color.fromRGBO(142, 142, 143, 1)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        onTap: (){
         if(courseList != null){
           Navigator.push(context, MaterialPageRoute(
               builder: (context) => CourseDetailPage(
                 courseId: courseList.data.dataList[i].id,
                 courseDescribe: courseList.data.dataList[i].describe,
                 courseTitle: courseList.data.dataList[i].title,
                 timing: courseList.data.dataList[i].timing,
                 version: courseList.data.dataList[i].version,
                 interactiveEquipment: courseList.data.dataList[i].interactiveEquipment,
                 courseInfo: [if (courseList.data.dataList[i].level == 1) '入门' else '进阶', (courseList.data.dataList[i].during ~/ 60).toString(), courseList.data.dataList[i].expectCalorie.toString(),],
               ))).then((value){
             setState(() {
               _openStreamNotify();
             });
           });
         }
        },
      ),
    );
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