import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/fileImageEx.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/model/courseList.dart';
import 'package:running_app/routes/login/userEnLogin.dart';
import 'package:running_app/routes/login/userLogin.dart';
import 'package:running_app/routes/realTimeSport/home.dart';
import 'package:running_app/routes/userRoutes/userPicture.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'courseDetailPage.dart';
import 'myCoursePage.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key key}) : super(key: key);

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {

  List<String> myCourseTitle = [];
  List<String> myCourseSubTitle = [];
  List<bool> deviceFlag = [true, false, false, false, false, false];
  CourseList collectCourseList;
  bool getCollectCourseSuccess = false;
  List<int> sportTagList = [];

  @override
  void initState() {
    super.initState();
    sportTagList.add(0);
    myCourseTitle = ['每天三分钟跳绳挑战 瘦成闪电', '3000次跳绳挑战 嗨燃脂肪'];
    myCourseSubTitle = ['初学  5分钟  11.0万人练过', '进阶  29分钟  24.8万人练过'];
    SaveData.onclickPage.add('CoursePage');
    if(SaveData.onclickPage.contains('SportRankingRoute') && SaveData.onclickPage.contains('RecordPage')){
      SaveData.changeState = false;
    }
    if(SaveData.userId != null){
      Method.checkNetwork(context).then((value){
        if(mounted){
          setState(() {
            if(value){
              hasNetwork = value;
              getCollectCourseList();
            }
          });
        }
      });
      if(courseList == null){
        Method.checkNetwork(context).then((value){
          if(mounted){
            setState(() {
              hasNetwork = value;
            });
          }
          if(SaveData.userId != null && value){
            getCourseList();
          }
        });
      }
    }
  }

  void getSportTag(int tag){
    Method.checkNetwork(context).then((value){
      if(value){
        if(SaveData.userId != null){
          sportTagList[0] = tag;
          getCourseList();
          print('sportTagList: $sportTagList');
        }else{
          Method.showToast('注册登录即可查看课程', context);
        }
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => Material(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: 540.w,
                height: 249.h,
                color: const Color.fromRGBO(249, 122, 53, 1),
              )
            ),
            Positioned(
              left: 36.w,
              top: 98.h,
              child: Text('课程', style: TextStyle(fontSize: 25.sp, color: Colors.white),),
            ),
            Positioned(
              right: 36.w,
              top: 88.h,
              child: GestureDetector(
                onTap: () {
                  Navigator.push<Object>(context, MaterialPageRoute(builder: (context) {
                    return UserPicturePage(SaveData.pictureUrl);
                  }));
                },
                child: Container(
                    width: 57.h,
                    height: 57.h,
                    padding: EdgeInsets.all(0),
                    // color: Colors.yellow,
                    child: SaveData.pictureUrl == null ? Image.asset('images/home_user.png',width: 57.h,height: 57.h)
                        : ClipOval(
                      child: Image(image: FileImageEx(File(SaveData.pictureUrl)),),
                    )
                ),
              ),
            ),
            Positioned(
              top: 160.h,
              child: Container(
                height: 90.h,
                margin: EdgeInsets.only(left: 34.w, right: 36.w),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                  color: Colors.white
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          deviceFlag = [true, false, false, false, false, false];
                          getSportTag(0);
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
                          getSportTag(1);
                        });
                      },
                      child: Container(
                        width: 40.w,
                        height: 42.h,
                        margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                        child: Image.asset(deviceFlag[1] ?'images/tiaosheng.png' : 'images/01.png')
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
                          getSportTag(2);
                        });
                      },
                      child: Container(
                          width: 40.w,
                          height: 42.h,
                          margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                          child: Image.asset(deviceFlag[2] ? 'images/lalisheng.png' : 'images/02.png')
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
                          getSportTag(4);
                        });
                      },
                      child: Container(
                          width: 40.w,
                          height: 42.h,
                          margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                          child: Image.asset(deviceFlag[3] ? 'images/hudiesheng .png' : 'images/03.png')
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
                          getSportTag(3);
                        });
                      },
                      child: Container(
                          width: 40.w,
                          height: 42.h,
                          margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                          child: Image.asset(deviceFlag[4] ? 'images/yaling.png' : 'images/04.png')
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
                          getSportTag(5);
                        });
                      },
                      child: Container(
                          width: 40.w,
                          height: 42.h,
                          margin: EdgeInsets.only(left: 19.w, right: 18.5.w),
                          child: Image.asset(deviceFlag[5] ? 'images/06.png' : 'images/05.png')
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 245.h,
              child: RefreshIndicator(
                color: const Color.fromRGBO(249, 122, 53, 1),
                onRefresh: _pullToRefresh,
                child: SaveData.userId != null ? courseListBuild() : loginBuild(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget loginBuild(){
    return Container(
      width: 540.w,
      height: 601.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('images/找回密码.png',width: 540.w,height: 229.w,),
          SizedBox(
            height: 44.h,
          ),
          Container(
            width: 360.w,
            height: 70.h,
            decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 189, 153, 1),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(color: const Color.fromRGBO(255, 104, 0, 1))
            ),
            child: FlatButton(
              child: Text('clickToLogin'.tr, style: TextStyle(color: const Color.fromRGBO(38, 45, 68, 1), fontSize: 21.sp),),
              onPressed: (){
                if(SaveData.english){
                  Navigator.push<Object>(context, MaterialPageRoute(
                      settings: const RouteSettings(name: 'userEnLoginRoute'),
                      builder: (BuildContext context) => UserEnLoginRoute())).then((value){
                    getCourseList();
                    getCollectCourseList();
                  });
                }else{
                  Navigator.push<Object>(context, MaterialPageRoute(
                      settings: const RouteSettings(name: 'userLogin'),
                      builder: (BuildContext context) => UserLoginRoute())).then((value){
                    getCourseList();
                    getCollectCourseList();
                  });
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget courseListBuild(){
    return Container(
      width: 540.w,
      height: 761.h,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 36.w, top: 16.h,right: 36.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '我的课程',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.normal, color: const Color.fromRGBO(25, 26, 26, 1)),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push<Object>(context, MaterialPageRoute(builder: (context) {
                        return const MyCoursePage();
                      })).then((value){
                        setState(() {
                          getCollectCourseList();
                        });
                      });
                    },
                    child: Text(
                      '<<',
                      style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.normal),
                    ),
                    // splashColor: Colors.transparent,
                    // highlightColor: Colors.transparent,
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 36.w, top: 17.h,right: 36.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if(collectCourseList != null && collectCourseList.data.dataList.length > 1)
                    for(int i = 0; i < 2; i++)
                      myCourseBuild(i: i),
                  if(collectCourseList != null && collectCourseList.data.dataList.length == 1)
                    for(int i = 0; i < 1; i++)
                      myCourseBuild(i: i),
                  if(collectCourseList == null)
                    myCourseBuild(),
                ],
              ),
            ),
            if(collectCourseList != null && collectCourseList.data.dataList.isEmpty)
              Center(
                child: Text('还没有收藏课程', style: TextStyle(fontSize: 36.sp, color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.normal),),
              ),
            SizedBox(
              height: 23.h,
            ),
            Container(
              width: 540.w,
              height: 20.h,
              color: const Color.fromRGBO(229, 229, 228, 1),
            ),
            Padding(
              padding: EdgeInsets.only(left: 36.w, top: 20.h,right: 36.w),
              child: Text(
                '推荐课程',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.normal, color: const Color.fromRGBO(25, 26, 26, 1)),
              ),
            ),
            if(courseList != null)
              for(int i = 0; i < courseList.data.dataList.length; i++)
                recommendCourseBuild(i: i),
            if(courseList == null)
              recommendCourseBuild(),
            const SizedBox(
              height: 125,
            )
          ],
        ),
      ),
    );
}

  Future<void> _pullToRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    Method.checkNetwork(context).then((value){
      if(value){
        hasNetwork = value;
        if(SaveData.userId != null){
          getCourseList();
          getCollectCourseList();
        }else{
          Method.showToast('注册登录即可查看课程', context);
        }
      }
    });
  }

  void getCourseList(){
    DioUtil().post(
      RequestUrl.getCourseListUrl,
      data: <String, Object>{'language': SaveData.english ? 1 : 0, 'page': 0, 'pageLimited':0, 'tags': sportTagList[0] == 0 ? null : sportTagList},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass':RequestUrl.appPass}),
    ).then((value){
      print('value:$value');
      if(value != null){
        courseList = CourseList.fromJson(value);
        if(courseList.code == '200'){
         if(mounted){
           setState(() {
             getCourseSuccess = true;
           });
         }
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

  void getCollectCourseList(){
    DioUtil().get(
      RequestUrl.getCollectCourseListUrl,
      queryParameters: <String, Object>{'language': SaveData.english ? 1 : 0, 'page': 0, 'pageLimited': 0, 'userId': SaveData.userId},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass':RequestUrl.appPass}),
    ).then((value){
      print(value);
      if(mounted){
        setState(() {
          if(value != null){
            collectCourseList = CourseList.fromJson(value);
            if(collectCourseList.code == '200'){
              getCollectCourseSuccess = true;
            }else{
              collectCourseList = null;
              getCollectCourseSuccess = false;
            }
          }else{
            getCollectCourseSuccess = false;
            Method.showToast('It seems that there is no internet'.tr, context);
          }
        });
      }
    });
  }

  Widget myCourseBuild({int i}){
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 224.w,
            height: 133.w,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(3)),
              color: const Color.fromRGBO(229, 229, 228, 1),
              border: Border.all(color: const Color.fromRGBO(116, 117, 117, 1), width: 0.1),
                image: hasNetwork && getCollectCourseSuccess ? DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(RequestUrl.getUserPictureUrl + collectCourseList.data.dataList[i].cover.toString(),
                      headers: {'app_pass': RequestUrl.appPass},)
                ) : null
            ),
          ),
          SizedBox(
            height: 9.7.h,
          ),
          Container(
            width: 224.w,
            child: Text(
              hasNetwork && getCollectCourseSuccess ? collectCourseList.data.dataList[i].title : '',
              style: TextStyle(fontSize: 15.sp, color: const Color.fromRGBO(52, 52, 52, 1), ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 9.7.h,
          ),
          Container(
            width: 224.w,
            child: Text(
              hasNetwork && getCollectCourseSuccess ? (collectCourseList.data.dataList[i].level == 1 ? '入门   ' : '进阶   ')
                  + (collectCourseList.data.dataList[i].during ~/ 60).toString() + 'minutes'.tr
                  + '   ' + 'Calories'.tr + collectCourseList.data.dataList[i].expectCalorie.toString() + 'kcal' : '',
              style: TextStyle(fontSize: 11.sp, color: const Color.fromRGBO(142, 142, 143, 1)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      onTap: (){
        if(collectCourseList != null){
          Navigator.push<Object>(context, MaterialPageRoute(
              builder: (context) => CourseDetailPage(
                version: collectCourseList.data.dataList[i].version,
                courseId: collectCourseList.data.dataList[i].id,
                courseDescribe: collectCourseList.data.dataList[i].describe,
                courseTitle: collectCourseList.data.dataList[i].title,
                timing: collectCourseList.data.dataList[i].timing,
                interactiveEquipment: collectCourseList.data.dataList[i].interactiveEquipment,
                courseInfo: [if (collectCourseList.data.dataList[i].level == 1) '入门' else '进阶', (collectCourseList.data.dataList[i].during ~/ 60).toString(), collectCourseList.data.dataList[i].expectCalorie.toString(),],
              ))).then((value){
            setState(() {
              getCollectCourseList();
            });
          });
        }
      },
    );
  }

  Widget recommendCourseBuild({int i}){
    return RepaintBoundary(
      child: GestureDetector(
        child: Card(
          elevation: 1.3,
          margin: EdgeInsets.only(
              left: 36.w,
              right: 36.w,
              top: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 468.w,
                height: 240.h,
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
                height: 9.7.h,
              ),
              Container(
                width: 468.w,
                margin: EdgeInsets.only(
                    left: 9.w),
                child: Text(
                  hasNetwork && getCourseSuccess ? courseList.data.dataList[i].title : '',
                  style: TextStyle(fontSize: 21.sp, color: const Color.fromRGBO(52, 52, 52, 1), ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: 9.7.h,
              ),
              Container(
                width: 468.w,
                margin: EdgeInsets.only(
                    left: 9.w,
                    bottom: 9.w),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(6), bottomLeft: Radius.circular(6)),
                ),
                child: Text(
                  hasNetwork && getCourseSuccess ? (courseList.data.dataList[i].level == 1 ? '入门   ' : '进阶   ')
                      + (courseList.data.dataList[i].during ~/ 60).toString() + 'minutes'.tr
                      + '   ' + 'Calories'.tr + courseList.data.dataList[i].expectCalorie.toString() + 'kcal' : '',
                  style: TextStyle(fontSize: 16.sp, color: const Color.fromRGBO(142, 142, 143, 1)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        onTap: (){
          if(courseList != null){
            Navigator.push<Object>(context, MaterialPageRoute(
                builder: (context) => CourseDetailPage(
                  version: courseList.data.dataList[i].version,
                  courseId: courseList.data.dataList[i].id,
                  courseDescribe: courseList.data.dataList[i].describe,
                  courseTitle: courseList.data.dataList[i].title,
                  timing: courseList.data.dataList[i].timing,
                  interactiveEquipment: courseList.data.dataList[i].interactiveEquipment,
                  courseInfo: [if (courseList.data.dataList[i].level == 1) '入门' else '进阶', (courseList.data.dataList[i].during ~/ 60).toString(), courseList.data.dataList[i].expectCalorie.toString(),],
                ))).then((value){
              setState(() {
                getCollectCourseList();
              });
            });
          }
        },
      ),
    );
  }
}
