import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/routes/userRoutes/updateUsername.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../userRoutes/accountSecurity.dart';
import 'package:get/get.dart';

class UpdateUserPage extends StatefulWidget{

  @override
  UpdateUserPageState createState() => UpdateUserPageState();

}

class UpdateUserPageState extends State<UpdateUserPage>{
  String updateHeight;
  String updateWeight;
  FixedExtentScrollController scrollController;//用于与修改用户身高时状态对应
  FixedExtentScrollController scrollController1;//用于与修改用户信体重状态对应
  int sex  = 2;//性别选择,1女，2男

  @override
  void initState() {
    super.initState();
    updateHeight = SaveData.userHeight;
    updateWeight = SaveData.userWeight;
    scrollController = FixedExtentScrollController(initialItem: int.parse(SaveData.userHeight) - 100);
    scrollController1 = FixedExtentScrollController(initialItem: int.parse(SaveData.userWeight) - 30);
    // _httpUpdateUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController1.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      builder: () => Material(
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
                  size: 14.w,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                "Profile".tr,
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
            ),
            body: Stack(
              children: <Widget>[
                Positioned(
                    top: 13.h,
                    child: Container(
                      width: 360.w,
                      height: 40.h,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                              EdgeInsets.only(left: 24.w),
                              child: Text(
                                'Nick name'.tr,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: Color.fromRGBO(145, 148, 160, 1)),
                              ),
                            ),
                            Container(
                              padding:
                              EdgeInsets.only(right: 24.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    SaveData.username,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.normal,
                                        color: Color.fromRGBO(0, 0, 0, 0.7)),
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Image(
                                    image: AssetImage('images/next.png'),
                                    width: 10.w,
                                    height: 14.w,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateUserNamePage())).then((value){
                            setState(() {});
                          });
                        },
                      ),
                    )),
                Positioned(
                    top: 61.h,
                    child: Container(
                      width: 360.w,
                      height: 40.h,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                              EdgeInsets.only(left: 24.w),
                              child: Text(
                                "Gender".tr,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: Color.fromRGBO(145, 148, 160, 1)),
                              ),
                            ),
                            Container(
                              padding:
                              EdgeInsets.only(right: 24.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    SaveData.userSex == '男' ? "Male".tr : "Female".tr,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.normal,
                                        color: Color.fromRGBO(0, 0, 0, 0.7)),
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Image(
                                    image: AssetImage('images/next.png'),
                                    width: 10.w,
                                    height: 14.w,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onPressed: _updateSex,
                      ),
                    )),
                Positioned(
                    top: 109.h,
                    child: Container(
                      width: 360.w,
                      height: 40.h,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                              EdgeInsets.only(left: 24.w),
                              child: Text(
                                'Date of birth'.tr,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: Color.fromRGBO(145, 148, 160, 1)),
                              ),
                            ),
                            Container(
                              padding:
                              EdgeInsets.only(right: 24.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    SaveData.userBirthday,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Color.fromRGBO(0, 0, 0, 0.7),
                                        fontWeight: FontWeight.normal
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Image(
                                    image: AssetImage('images/next.png'),
                                    width: 10.w,
                                    height: 14.w,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          var _dateTime = DateTime.parse(SaveData.userBirthday);
                          final picker = CupertinoDatePicker(
                            initialDateTime: _dateTime,
                            mode: CupertinoDatePickerMode.date,
                            minimumYear: 1920,
                            maximumDate: DateTime.now().subtract(Duration(days: 1)),
                            onDateTimeChanged: (date) {
                              _dateTime = date;
                            },
                          );
                          showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: 200,
                                  child: picker,
                                );
                              }).then((value) {
                            setState(() {
                              SaveData.userBirthday = _dateTime.toString().substring(0, 10);
                            });
                            SharedPreferences.getInstance().then((value) {
                              value.setString("userBirthday", SaveData.userBirthday);
                            });
                          });
                        },
                      ),
                    )),
                Positioned(
                    top: 157.h,
                    child: Container(
                      width: 360.w,
                      height: 40.h,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                              EdgeInsets.only(left: 24.w),
                              child: Text(
                                'Height'.tr,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: Color.fromRGBO(145, 148, 160, 1)),
                              ),
                            ),
                            Container(
                              padding:
                              EdgeInsets.only(right: 24.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    SaveData.userHeight + "cm",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Color.fromRGBO(0, 0, 0, 0.7),
                                        fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Image(
                                    image: AssetImage('images/next.png'),
                                    width: 10.w,
                                    height: 14.w,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onPressed: _updateHeight,
                      ),
                    )),
                Positioned(
                    top: 205.h,
                    child: Container(
                      width: 360.w,
                      height: 40.h,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                              EdgeInsets.only(left: 24.w),
                              child: Text(
                                'Weight'.tr,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: Color.fromRGBO(145, 148, 160, 1)),
                              ),
                            ),
                            Container(
                              padding:
                              EdgeInsets.only(right: 24.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    SaveData.userWeight + "kg",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Color.fromRGBO(0, 0, 0, 0.7),
                                        fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Image(
                                    image: AssetImage('images/next.png'),
                                    width: 10.w,
                                    height: 14.w,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onPressed: _updateWeight,
                      ),
                    )),
              ],
            ),
          )),
    );
  }

//修改用户身高
  void _updateHeight() {
    // if(SaveData.userId != null){
    //   _checkNetWork();
    // }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        isDismissible: false,
        builder: (BuildContext context) {
          return ScreenUtilInit(
            designSize: const Size(360, 640),
            builder: () => Material(
                child: Container(
                  width: 360.w,
                  height: 250.h,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          width: 360.w,
                          height: 42.h,
                          color: Color.fromRGBO(244, 245, 249, 1),
                        ),
                      ),
                      Positioned(
                        top: 42.h,
                        child: Container(
                          width: 360.w,
                          height: 204.h,
                          child: CupertinoPicker(
                            squeeze: 1,
                            itemExtent: 40,
                            looping: true,
                            diameterRatio: 5,
                            onSelectedItemChanged: (position) {
                              updateHeight = (position + 100).toString();
                              scrollController =
                                  FixedExtentScrollController(initialItem: position);
                            },
                            scrollController: scrollController,
                            children: <Widget>[
                              for (int i = 100; i <= 240; i++)
                                Center(
                                  child: Text(i.toString() + "cm"),
                                )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12.h,
                        right: 18.w,
                        child: GestureDetector(
                          child: Text('Finish'.tr,style: TextStyle(fontWeight: FontWeight.normal,),),
                          onTap: () {
                            setState(() {
                              SaveData.userHeight = updateHeight;
                            });
                            SharedPreferences.getInstance().then((value) {
                              value.setString("userHeight", updateHeight);
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          );
        });
  }
//修改用户体重
  void _updateWeight() {
    showModalBottomSheet<void>(
        isDismissible: false,
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          return ScreenUtilInit(
            designSize: const Size(360, 640),
            builder: () => Material(
                child: Container(
                  width: 360.w,
                  height: 250.h,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          width: 360.w,
                          height: 42.h,
                          color: Color.fromRGBO(244, 245, 249, 1),
                        ),
                      ),
                      Positioned(
                        top: 12.h,
                        right: 18.w,
                        child: GestureDetector(
                          child: Text('Finish'.tr, style: TextStyle(fontWeight: FontWeight.normal,)),
                          onTap: () {
                            setState(() {
                              SaveData.userWeight = updateWeight;
                            });
                            SharedPreferences.getInstance().then((value) {
                              value.setString("userWeight", updateWeight);
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Positioned(
                        top: 42.h,
                        child: Container(
                          width: 360.w,
                          height: 204.h,
                          child: CupertinoPicker(
                            squeeze: 1,
                            itemExtent: 40,
                            looping: true,
                            diameterRatio: 5,
                            onSelectedItemChanged: (position) {
                              updateWeight = (position + 30).toString();
                              scrollController1 =
                                  FixedExtentScrollController(initialItem: position);
                            },
                            scrollController: scrollController1,
                            children: <Widget>[
                              for (int i = 30; i <= 200; i++)
                                Center(
                                  child: Text(i.toString() + " kg"),
                                )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          );
        });
  }

//修改用户性别
  void _updateSex(){
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        isDismissible: false,
        builder: (BuildContext context) {
          return ScreenUtilInit(
            designSize: const Size(360, 640),
            builder: () => StatefulBuilder(
              builder: (context1, sexState) {
                return Material(
                    child: Container(
                      width: 360.w,
                      height: 250.h,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            child: Container(
                              width: 360.w,
                              height: 42.h,
                              color: Color.fromRGBO(244, 245, 249, 1),
                            ),
                          ),
                          Positioned(
                            top: 42.h,
                            child: Container(
                              width: 360.w,
                              height: 204.h,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    contentPadding: EdgeInsets.only(
                                        left: 24.w,
                                        right: 12.w),
                                    title: Text("Male".tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                                    trailing: Radio(
                                      value: 2,
                                      activeColor: Color.fromRGBO(47, 117, 220, 1),
                                      groupValue: sex,
                                      onChanged: (value) {
                                        sexState(() {
                                          sex = value;
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        sex = 2;
                                      });
                                    },
                                  ),
                                  Divider(
                                    indent: 24.w,
                                    endIndent: 24.w,
                                    height: 0.5.h,
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.only(
                                        left: 24.w,
                                        right: 12.w),
                                    title: Text("Female".tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                                    trailing: Radio(
                                      value: 1,
                                      activeColor: Color.fromRGBO(255, 107, 191, 1),
                                      groupValue: sex,
                                      onChanged: (value) {
                                        sexState(() {
                                          sex = value;
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        sex = 1;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12.h,
                            right: 18.w,
                            child: GestureDetector(
                              child: Text('Finish'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                              onTap: () {
                                setState(() {
                                  if (sex == 1) {
                                    SaveData.userSex = '女';
                                  } else {
                                    SaveData.userSex = '男';
                                  }
                                });
                                SharedPreferences.getInstance().then((value) {
                                  value.setString("userSex", SaveData.userSex);
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Positioned(
                            top: 12.h,
                            left: 18.w,
                            child: GestureDetector(
                              child: Text('Cancel'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
          );
        });
  }
}