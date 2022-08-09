import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/model/courseList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'courseDetailPage.dart';

class MyCoursePage extends StatefulWidget {
  const MyCoursePage({Key key}) : super(key: key);

  @override
  _MyCoursePageState createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage> {

  bool onclickDelete = false;
  List<bool> deleteFlagList = <bool>[];
  bool totalDelete = false;
  CourseList collectCourseList;
  bool hasNetwork = false;
  bool getCollectCourseSuccess = false;
  List<String> courseCollectList = [];//存储已经收藏的课程id
  List<int> deleteCourseList = [];

  @override
  void initState() {
    super.initState();
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
              onclickDelete = false;
              getCollectCourseSuccess = true;
              for(int i = 0; i < collectCourseList.data.dataList.length; i++){
                deleteFlagList.add(false);
                courseCollectList.add(collectCourseList.data.dataList[i].id.toString());
              }
            }else{
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

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 2208),
      builder: () => Scaffold(
        appBar: AppBar(
          title: Text('我的课程', style: TextStyle(fontSize: 52.sp, color: Colors.white),),
          centerTitle: false,
          backgroundColor: const Color.fromRGBO(249, 122, 53, 1),
          actions: <Widget>[
            FlatButton(
              child: onclickDelete
                  ? Text(
                'Cancel'.tr,
                style: TextStyle(
                    fontSize: 52.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
                textAlign: TextAlign.right,
              )
                  : Image.asset(
                "images/edit.png",
                width: 64.w,
                height: 64.w,
                color: Colors.white,
              ),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onPressed: () {
                setState(() {
                  if(onclickDelete){
                    onclickDelete = false;
                    deleteFlagList.fillRange(0, collectCourseList.data.dataList.length, false);
                  }else{
                    onclickDelete = true;
                  }
                });
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 24.h,
              ),
              if(collectCourseList != null)
              for(int i = 0; i < collectCourseList.data.dataList.length; i++)
                myCourseBuild(i),
              SizedBox(
                height: onclickDelete ? 75 : 50,
              ),
            ],
          ),
        ),
        bottomSheet: onclickDelete ? Container(
          width: 1080.w,
          height: 188.h,
          padding: EdgeInsets.only(left: 48.w, right: 48.w),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton.icon(
                onPressed: (){
                  setState(() {
                    if(totalDelete){
                      totalDelete = false;
                      deleteFlagList.fillRange(0, deleteFlagList.length, false);
                    }else{
                      totalDelete = true;
                      deleteFlagList.fillRange(0, deleteFlagList.length, true);
                    }
                  });
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                padding: EdgeInsets.zero,
                icon: totalDelete ? Icon(Icons.check_box, color: const Color.fromRGBO(249, 122, 53, 1),) : Icon(Icons.check_box_outline_blank),
                label: Text(
                  'Select all'.tr,
                  style: TextStyle(fontSize: 42.sp),
                  ),
              ),
              FlatButton.icon(
                onPressed: deleteFlagList.contains(true) ? (){
                  Method.customDialog(context, 'tips'.tr, '是否确定删除?', _confirm);
                } : null,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                padding: EdgeInsets.zero,
                icon: Image.asset(
                  deleteFlagList.contains(true) ? 'images/delete.png' : 'images/delete_grey.png',
                  width: 60.w,
                  height: 60.h,
                ),
                label: Text(
                  'Delete'.tr,
                  style: TextStyle(
                      fontSize: 42.sp,
                      fontWeight: FontWeight.normal,
                      color: deleteFlagList.contains(true) ? const Color.fromRGBO(237, 82, 84, 1) : const Color.fromRGBO(213, 213, 213, 1)),
                ),
              ),
            ],
          ),
        ) : null,
      ),
    );
  }

  Widget myCourseBuild(int i){
    return InkWell(
      splashColor: Colors.transparent,
      child: Container(
        width: 1032.w,
        height: 200.h,
        margin: EdgeInsets.only(
          top: 24.h,
          bottom: 24.h,
          left: onclickDelete ? 24.w : 48.w,

        ),
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 298.w,
              height: 200.h,
              child: hasNetwork && getCollectCourseSuccess ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  RequestUrl.getUserPictureUrl + collectCourseList.data.dataList[i].cover.toString(),
                  headers: {'app_pass': RequestUrl.appPass},
                  fit: BoxFit.fill,),
              ) : null,
            ),
            Container(
              margin: EdgeInsets.only(left: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 614.w,
                    child: Text(
                      hasNetwork && getCollectCourseSuccess ? collectCourseList.data.dataList[i].title : '',
                      style: TextStyle(fontSize: 36.sp, color: const Color.fromRGBO(52, 52, 52, 1), ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Container(
                    width: 614.w,
                    child: Text(
                      hasNetwork && getCollectCourseSuccess ? (collectCourseList.data.dataList[i].level == 1 ? '入门   ' : '进阶   ')
                          + (collectCourseList.data.dataList[i].during ~/ 60).toString() + 'minutes'.tr
                          + '   ' + 'Calories'.tr + collectCourseList.data.dataList[i].expectCalorie.toString() + 'kcal' : '',
                      style: TextStyle(fontSize: 28.sp, color: const Color.fromRGBO(142, 142, 143, 1)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if(onclickDelete)
            Container(
              width: 72.w,
              height: 72.w,
              margin: EdgeInsets.only(left: 24.w),
              child: Icon(Icons.check_circle, color: deleteFlagList[i] ? const Color.fromRGBO(249, 122, 53, 1) : Colors.grey.withOpacity(0.4),),
            )
          ],
        ),
      ),
      onTap: (){
        if(onclickDelete){
          setState(() {
            if(deleteFlagList[i]){
              deleteFlagList[i] = false;
            }else{
              deleteFlagList[i] = true;
            }
            if(!deleteFlagList.contains(false)){
              totalDelete = true;
            }else{
              totalDelete = false;
            }
          });
        }else{
          Navigator.push<Object>(context, MaterialPageRoute(
              builder: (context) => CourseDetailPage(
                courseId: collectCourseList.data.dataList[i].id,
                courseDescribe: collectCourseList.data.dataList[i].describe,
                courseTitle: collectCourseList.data.dataList[i].title,
                timing: collectCourseList.data.dataList[i].timing,
                interactiveEquipment: collectCourseList.data.dataList[i].interactiveEquipment,
                courseInfo: [if (collectCourseList.data.dataList[i].level == 1) '入门' else '进阶', (collectCourseList.data.dataList[i].during ~/ 60).toString(), collectCourseList.data.dataList[i].expectCalorie.toString(),],
              ))).then((value){
            setState(() {});
          });
        }
      },
    );
  }

  void courseCancelRequest(){
    DioUtil().put(
      RequestUrl.courseCollectUrl,
      data: <String, Object>{'courseIds': deleteCourseList, 'userId': SaveData.userId,},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass}),
    ).then((value){
      print(value);
      if(value != null){
        if(value['code'] == '200'){
          for(int i = deleteFlagList.length - 1; i >= 0; i--){
            if(deleteFlagList[i]){
              courseCollectList.removeAt(i);
            }
          }
          deleteCourseList.clear();
          getCollectCourseList();
          SharedPreferences.getInstance().then((value){
            value.setStringList('courseCollectList', courseCollectList);
          });
        }else{
          Method.showToast('It seems that there is no internet'.tr, context);
        }
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }

  void _confirm(){
    for(int i = 0; i < deleteFlagList.length; i++){
      if(deleteFlagList[i]){
        deleteCourseList.add(collectCourseList.data.dataList[i].id);
      }
    }
    print(deleteCourseList);
    courseCancelRequest();
  }
}
