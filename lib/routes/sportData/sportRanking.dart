import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/routes/login/userEnLogin.dart';
import 'package:running_app/routes/login/userLogin.dart';
import 'package:running_app/routes/realTimeSport/home.dart';
import 'package:running_app/widgets/userAbility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/fileImageEx.dart';
import '../../model/abilityRank.dart';
import 'package:get/get.dart';

class SportRankingRoute extends StatefulWidget {
  @override
  _SportRankingRouteState createState() => _SportRankingRouteState();
}

class _SportRankingRouteState extends State<SportRankingRoute> {

  bool showTitle = false;

  bool totalData = true;
  bool monthData = false;
  bool yearData = false;
  var _futureBuilderFuture;//避免重复请求刷新
  int choseDateValue = 2;//0为月，1为年，2为总
  AbilityRank _abilityRank;
  int showPage = 0;//0刚进入，1有网络，2网络错误
  bool _firstEnter = true;
  int userRankInfo;//区分自己与其他用户的排位
  double userAbility = 0;//区分自己与其他用户的战斗力
  double power;
  double agile;
  double endurance;
  double physique;
  double perseverance;
  bool popupAbility = false;
  List<bool> deviceFlag = [true, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    SaveData.onclickPage.add('SportRankingRoute');
    if(SaveData.onclickPage.contains('RecordPage') && SaveData.onclickPage.contains('CoursePage')){
      SaveData.changeState = false;
    }
    if(SaveData.userId != null){
      _futureBuilderFuture = _getAbilityRank(RequestUrl.getTotalAbilityRankUrl, RequestUrl.getTotalAbilityUrl);
    }
    _abilityRank = null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getAbilityRank(String rank, String userRank) async {//第一个参数为排行榜请求地址，第二个参数为用户战斗力信息请求地址
    await Future.delayed(Duration(milliseconds: 500),(){});
    return DioUtil().get(
        rank,
        queryParameters: choseDateValue == 2 ? {} : choseDateValue == 1 ? {"year": DateTime.now().year} : {"monthDay": DateTime.now().toString().substring(0, 10)},
        options: Options(headers: {'access_token': SaveData.accessToken, "app_pass":RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      // print('value:$value');
      _abilityRank = AbilityRank.fromJson(value);
      if(_abilityRank.code == "200"){
        _userAbilityInfo(userRank, SaveData.userId);
      }else if(_abilityRank.code == "401"){
        SaveData.userId = null;
        SaveData.pictureUrl = null;
        SaveData.setPassword = false;
        HomePageState.hasPicture = false;
        SharedPreferences.getInstance().then((value){
          value.clear();
        });
      }else {
        if(mounted){
          setState(() {
            if(!_firstEnter){
              Navigator.of(context).pop();
            }
            showPage = 2;
          });
        }
      }
    });
  }

  void _userAbilityInfo(String userRank, int userId){
    DioUtil().get(
        userRank,
        queryParameters: choseDateValue == 2 ? {"userId": userId} : choseDateValue == 1 ? {"year": DateTime.now().year, "userId": userId}
            : {"monthDay": DateTime.now().toString().substring(0, 10), "userId": userId},
        options: Options(headers: {'access_token': SaveData.accessToken, "app_pass":RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      // print(value);
      if(value != null){
        if(value["code"] == "200"){
          userAbility = value["data"]["total"];
          userRankInfo = value["data"]["rank"];
          power = value["data"]['power'];
          agile = value["data"]['agile'];
          endurance = value["data"]['endurance'];
          physique = value["data"]['physique'];
          perseverance = value["data"]['perseverance'];
          SaveData.maxPower = value["data"]['maxAbility']["maxPower"];
          SaveData.maxAgile = value["data"]['maxAbility']["maxAgile"];
          SaveData.maxEndurance = value["data"]['maxAbility']["maxEndurance"];
          SaveData.maxPhysique = value["data"]['maxAbility']["maxPhysique"];
          SaveData.maxPerseverance = value["data"]['maxAbility']["maxPerseverance"];
          if(!_firstEnter){
            Navigator.of(context).pop();
          }
          if(mounted){
            setState(() {
              showPage = 1;
            });
          }
        }else{
          if(mounted){
            setState(() {
              showPage = 2;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SaveData.userId == null ? loginBuild() : ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => Material(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(249, 122, 53, 1),
            title: Text('LeaderBoard'.tr, style: TextStyle(fontSize: 30.sp, color: Colors.white),),
            centerTitle: false,
            titleSpacing: 36.w,
            elevation: 0,
          ),
          body: FutureBuilder(
            future: _futureBuilderFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot){
              switch(snapshot.connectionState){
                case ConnectionState.waiting:
                  // print('waiting');
                  return Center(
                    child: Image.asset(
                      "images/tiger-animation-loop.gif",
                      width: 200.w,
                      height: 200.h,
                    ),
                  );
                case ConnectionState.done:
                  // print('done');
                  // print(snapshot.hasError);
                  return snapshot.hasError ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Image.asset('images/unconnected.png',width: 180.w,height: 180.w,),
                          onPressed: (){
                            setState(() {
                              _futureBuilderFuture = _getAbilityRank(RequestUrl.getTotalAbilityRankUrl, RequestUrl.getTotalAbilityUrl);
                            });
                          },
                        ),
                        FlatButton(
                          child: Text('It seems that there is no internet'.tr),
                          onPressed: (){
                            setState(() {
                              _futureBuilderFuture = _getAbilityRank(RequestUrl.getTotalAbilityRankUrl, RequestUrl.getTotalAbilityUrl);
                            });
                          },
                        ),
                      ],
                    ),
                  ) :  SaveData.userId == null ? loginBuild() : rankBuild();
                default:
                  return null;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget loginBuild(){
    return ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => Material(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('images/找回密码.png',width: 540.w,height: 229.w,),
              SizedBox(
                height: 66.h,
              ),
              Container(
                width: 360.w,
                height: 70.h,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 189, 153, 1),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    border: Border.all(color: Color.fromRGBO(255, 104, 0, 1))
                ),
                child: FlatButton(
                  child: Text('clickToLogin'.tr, style: TextStyle(color: Color.fromRGBO(38, 45, 68, 1), fontSize: 21.sp),),
                  onPressed: (){
                    if(SaveData.english){
                      Navigator.push(context, MaterialPageRoute(
                          settings: RouteSettings(name: "userEnLoginRoute"),
                          builder: (context) => UserEnLoginRoute())).then((value){
                        setState(() {
                          _futureBuilderFuture =  _getAbilityRank(RequestUrl.getTotalAbilityRankUrl, RequestUrl.getTotalAbilityUrl);
                        });
                      });
                    }else{
                      Navigator.push(context, MaterialPageRoute(
                          settings: RouteSettings(name: "userLogin"),
                          builder: (context) => UserLoginRoute())).then((value){
                        setState(() {
                          _futureBuilderFuture =  _getAbilityRank(RequestUrl.getTotalAbilityRankUrl, RequestUrl.getTotalAbilityUrl);
                        });
                      });
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget rankBuild(){
    return Scrollbar(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index){
          if(index == 0){
            return myChoseDateBuild();
          }else if(index == 1){
            return myRankingItemBuild();
          }else{
            return rankingItemBuild(index - 2);
          }
        },
        itemCount: _abilityRank.data.length + 2,
      ),
    );
  }

  // Widget rankBuild2(){
  //   return Scrollbar(
  //     child: rankBuild2(),
  //   );
  // }

  Widget myChoseDeviceBuild(){
    return Container(
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.only(left: 24.w, right: 24.w, top: 18.h),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: const Color.fromRGBO(152, 152, 151, 1), width: 1),
            color: Colors.white
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: (){
                setState(() {
                  deviceFlag = [true, false, false, false, false, false];
                });
              },
              child: Container(
                width: 40.w,
                height: 42.h,
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                child: Text(
                  'All data'.tr,
                  style: TextStyle(fontSize: 18.sp, color: deviceFlag[0] ? const Color.fromRGBO(38, 45, 68, 1) : const Color.fromRGBO(182, 188, 203, 1), fontWeight: FontWeight.normal,),),
              ),
            ),
            Container(
              width: 1,
              height: 17.h,
              color: const Color.fromRGBO(197, 196, 199, 0.43),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  deviceFlag = [false, true, false, false, false, false];
                });
              },
              child: Container(
                  width: 40.w,
                  height: 42.h,
                  margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                  child: RepaintBoundary(child: Image.asset(deviceFlag[1] ?'images/tiaosheng.png' : 'images/01.png'))
              ),
            ),
            Container(
              width: 1,
              height: 17.h,
              color: const Color.fromRGBO(197, 196, 199, 0.43),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  deviceFlag = [false, false, true, false, false, false];
                });
              },
              child: Container(
                  width: 40.w,
                  height: 42.h,
                  margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                  child: RepaintBoundary(child: Image.asset(deviceFlag[2] ? 'images/lalisheng.png' : 'images/02.png'))
              ),
            ),
            Container(
              width: 1,
              height: 17.h,
              color: const Color.fromRGBO(197, 196, 199, 0.43),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  deviceFlag = [false, false, false, true, false, false];
                });
              },
              child: Container(
                  width: 40.w,
                  height: 42.h,
                  margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                  child: RepaintBoundary(child: Image.asset(deviceFlag[3] ? 'images/hudiesheng .png' : 'images/03.png'))
              ),
            ),
            Container(
              width: 1,
              height: 17.h,
              color: const Color.fromRGBO(197, 196, 199, 0.43),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  deviceFlag = [false, false, false, false, true, false];
                });
              },
              child: Container(
                  width: 40.w,
                  height: 42.h,
                  margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                  child: RepaintBoundary(child: Image.asset(deviceFlag[4] ? 'images/yaling.png' : 'images/04.png'))
              ),
            ),
            Container(
              width: 1,
              height: 17.h,
              color: const Color.fromRGBO(197, 196, 199, 0.43),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  deviceFlag = [false, false, false, false, false, true];
                });
              },
              child: Container(
                  width: 40.w,
                  height: 42.h,
                  margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                  child: RepaintBoundary(child: Image.asset(deviceFlag[5] ? 'images/06.png' : 'images/05.png'))
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget myChoseDateBuild(){
    return Container(
      color: Colors.white,
      height: 105.h,
      child: Row(
        children: <Widget>[
          Container(
            width: 468.w,
            height: 45.h,
            margin: EdgeInsets.only(
                left: 36.w,
                right: 36.w),
            decoration: const BoxDecoration(
                borderRadius:
                BorderRadius.all(Radius.circular(22.5)),
                color: Color(0xFFEEEEEE)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 156.w,
                  height: totalData ? 45.h : 33.h,
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(22.5)),
                      color: totalData
                          ? Colors.white.withOpacity(0.87)
                          : Color(0xFFEEEEEE)),
                  child: FlatButton(
                    splashColor: Colors.white10,
                    highlightColor: Colors.white10,
                    child: Text('All Time'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                    onPressed: () {
                      if(!totalData){
                        setState(() {
                          totalData = true;
                          yearData = false;
                          monthData = false;
                          _firstEnter = false;
                          choseDateValue = 2;
                          Method.showLessLoading(context, 'Loading2'.tr);
                          _getAbilityRank(RequestUrl.getTotalAbilityRankUrl,RequestUrl.getTotalAbilityUrl);
                        });
                      }
                    },
                  ),
                ),
                Container(
                  width: 156.w,
                  height: yearData ? 45.h : 33.h,
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(22.5)),
                      color: yearData
                          ? Colors.white.withOpacity(0.87)
                          : Color(0xFFEEEEEE)),
                  child: FlatButton(
                    splashColor: Colors.white10,
                    highlightColor: Colors.white10,
                    child: Text('year'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                    onPressed: () {
                      if(!yearData){
                        setState(() {
                          totalData = false;
                          yearData = true;
                          monthData = false;
                          _firstEnter = false;
                          choseDateValue = 1;
                          Method.showLessLoading(context, 'Loading2'.tr);
                          _getAbilityRank(RequestUrl.getYearAbilityRankUrl,RequestUrl.getYearAbilityUrl);
                        });
                      }
                    },
                  ),
                ),
                Container(
                  width: 156.w,
                  height: monthData ? 45.h : 33.h,
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(22.5)),
                      color: monthData
                          ? Colors.white.withOpacity(0.87)
                          : Color(0xFFEEEEEE)),
                  child: FlatButton(
                    splashColor: Colors.white10,
                    highlightColor: Colors.white10,
                    child: Text('Month'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                    onPressed: () {
                      if(!monthData){
                        setState(() {
                          totalData = false;
                          yearData = false;
                          monthData = true;
                          _firstEnter = false;
                          choseDateValue = 0;
                          Method.showLessLoading(context, 'Loading2'.tr);
                          _getAbilityRank(RequestUrl.getMonthAbilityRankUrl,RequestUrl.getMonthAbilityUrl);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget leadPicBuild(int i){
    if(i < 3)
      return Container(
        width: 80.w,
        child: Stack(
          children: <Widget>[
            Positioned(
              child: _abilityRank.data[i].headImg == null ? RepaintBoundary(child: Image.asset('images/home_user.png',width: 70.w,height: 70.w,cacheHeight: 100,cacheWidth: 100,))
                  : RepaintBoundary(child: ClipOval(
                child: Image.network(
                  RequestUrl.getUserPictureUrl + _abilityRank.data[i].headImg,
                  headers: {'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass},
                  width: 70.w,
                  height: 70.w,
                  cacheHeight: 100,
                  cacheWidth: 100,
                ),)),
            ),
            if(i < 3)
              Positioned(
                left: 42.85.w,
                top: 40.85.w,
                child: Image.asset('images/no' + (i + 1).toString() + '.png', width: 30.w,height: 30.w,cacheWidth: 45,cacheHeight: 45,),
              ),
          ],
        ),
      );
    if(i >= 3)
      return _abilityRank.data[i].headImg == null ? RepaintBoundary(child: Image.asset('images/home_user.png',width: 70.w.toDouble(),height: 70.w.toDouble(),cacheHeight: 100,cacheWidth: 100,))
          : RepaintBoundary(child: ClipOval(
        child: Image.network(
          RequestUrl.getUserPictureUrl + _abilityRank.data[i].headImg,
          headers: {'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass},
          cacheHeight: 100,
          cacheWidth: 100,
          width: 70.w,
          height: 70.w,
          fit: BoxFit.cover,
        ),));
  }

  void _userAbility(Data data){
    SaveData.rank = data.rank;
    SaveData.power = data.power;
    SaveData.agile = data.agile;
    SaveData.endurance = data.endurance;
    SaveData.physique = data.physique;
    SaveData.perseverance = data.perseverance;
  }

  Widget rankingItemBuild(int i){
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 1.5),
      height: 85.w,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 36.w),
                  child: leadPicBuild(i),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Container(
                    // child: Text(_abilityRank.data[i].nickName),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(_abilityRank.data[i].nickName ?? 'UserName', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 22.sp, color: i == 0 || i == 1 || i == 2 ? const Color.fromRGBO(249, 122, 53, 1) : const Color.fromRGBO(0, 23, 55, 1)),),
                        Text(SaveData.english ? _abilityRank.data[i].rank == 1 ? _abilityRank.data[i].rank.toString() + 'st Place '
                            : _abilityRank.data[i].rank == 2 ? _abilityRank.data[i].rank.toString() + 'nd Place'
                            : _abilityRank.data[i].rank == 3 ? _abilityRank.data[i].rank.toString() + 'rd Place'
                            : _abilityRank.data[i].rank.toString() + 'th Place ' : '第 ' + _abilityRank.data[i].rank.toString() + ' 名' ,
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18.sp, color: const Color.fromRGBO(33, 37, 41, 1))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(_abilityRank.data[i].total.truncate().toString(), style: TextStyle(fontSize: 24.sp, color: i == 0 || i == 1 || i == 2 ? Color.fromRGBO(249, 122, 53, 1) : Color.fromRGBO(70, 60, 58, 1))),
                SizedBox(
                  width: 24.w,
                )
              ],
            )
          ],
        ),
        onPressed: (){
          if(choseDateValue == 0){
            _userAbility(_abilityRank.data[i]);
          }else if(choseDateValue == 1){
            _userAbility(_abilityRank.data[i]);
          }else{
            _userAbility(_abilityRank.data[i]);
          }
          showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (_) {
                return UserAbilityPage();
              });
        },
      ),
    );
  }

  Widget myRankingItemBuild(){
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 10),
      height: 85.w,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 36.w),
                  child: SaveData.pictureUrl == null ? Image.asset("images/home_user.png",width: 70.w,height: 70.w,)
                      : ClipOval(child: Image(image: FileImageEx(File(SaveData.pictureUrl)),width: 70.w,height: 70.w),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Container(
                    // child: Text(_abilityRank.data[i].nickName),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(SaveData.username, style: TextStyle(fontWeight: FontWeight.normal,fontSize: 22.sp, color: Color.fromRGBO(0, 23, 55, 1)),),
                        Text(SaveData.english ? userRankInfo == 1 ? userRankInfo.toString() + 'st Place '
                            : userRankInfo == 2 ? userRankInfo.toString() + 'nd Place'
                            : userRankInfo == 3 ? userRankInfo.toString() + 'rd Place'
                            : userRankInfo.toString() + 'th Place ' : '第 ' + userRankInfo.toString() + ' 名' ,
                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18.sp, color: Color.fromRGBO(33, 37, 41, 1))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(userAbility.truncate().toString(),style: TextStyle(fontWeight: FontWeight.normal,fontSize: 24.sp),),
                SizedBox(
                  width: 24.w,
                )
              ],
            )
          ],
        ),
        onPressed: (){
          SaveData.power = power;
          SaveData.physique = physique;
          SaveData.endurance = endurance;
          SaveData.perseverance = perseverance;
          SaveData.agile = agile;
          SaveData.rank = userRankInfo;
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) {
                return UserAbilityPage();
              });
        },
      ),
    );
  }
}
