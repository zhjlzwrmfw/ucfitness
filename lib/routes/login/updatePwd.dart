import 'dart:async';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UpdatePwdRoute extends StatefulWidget {

  @override
  _UpdatePwdRouteState createState() => _UpdatePwdRouteState();
}

class _UpdatePwdRouteState extends State<UpdatePwdRoute> {

  String account = '';
  String captcha = '';
  bool visible = false;
  bool _setSuccess = false;
  Timer _timer;
  int second = 3;
  var matcher = RegExp("[\u0021-\u007e]");
  bool illegal = false;
  bool strLength =false;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => Material(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(249, 122, 53, 1),
              titleSpacing: 4,
              elevation: 0,
              centerTitle: false,
              leading: FlatButton(
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                "Change password".tr,
                style: TextStyle(
                    fontSize: 42.sp, fontWeight: FontWeight.bold),
              ),
            ),
            body: !_setSuccess ? ListView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 72.w,
                right: 72.w,
              ),
              children: [
                SizedBox(
                  height: 90.h,
                ),
                Container(
                  width: 936.w,
                  height: 138.w,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "New password".tr,
                      hintStyle: TextStyle(
                        fontSize: 42.sp,
                        color: Color.fromRGBO(203, 207, 216, 1),
                      ),
                      border: InputBorder.none,
                      prefixIcon: Image(
                        image: AssetImage('images/account_password.png'),
                        alignment: Alignment.centerLeft,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        maxHeight: 42.w,
                        minWidth: 80.w,
                      ),
                      suffixIcon: Container(
                        width: 100.w,
                        height: 100.w,
                        child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Image(
                            image: visible==true?AssetImage('images/eye_open.png'):AssetImage('images/eye_close.png'),
                            width: 60.w,
                            height: 60.w,
                          ),
                          onPressed: () {
                            setState(() {
                              // onlyRefresh = false;
                              if(visible==true) {
                                visible = false;
                              }
                              else visible=true;
                            });
                          },
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(234, 236, 243, 1),
                            width: 3.w,
                          )
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(249, 122, 53, 1),
                            width: 3.w,
                          )
                      ),
                    ),
                    obscureText: !visible,
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: (str){
                      // print(str);
                      if (matcher.allMatches(str).length != str.length) {
                        setState(() {
                          illegal = true;
                        });
                      } else {
                        setState(() {
                          illegal = false;
                        });
                      }
                      if(str.length>7&&str.length<17){
                        setState((){
                          strLength = true;
                        });
                      } else {
                        setState(() {
                          strLength = false;
                        });
                      }
                      account = str;
                    },
                  ),
                ),
                if(!strLength)
                  Container(
                    padding: EdgeInsets.only(top: 20.h),
                    child:Text(
                      "Password must be between 8 and 16 characters.".tr,
                      style: TextStyle(
                          color: Color.fromRGBO(203, 207, 216, 1),
                          fontSize: 36.sp),
                    ),),
                if (illegal)
                  Container(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.warning,
                          size: 50.w,
                          color: Color.fromRGBO(232, 14, 14, 1),
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(
                          "Cannot contain invalid characters.".tr,
                          style: TextStyle(
                              color: Color.fromRGBO(232, 14, 14, 1),
                              fontSize: 36.sp),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  width: 936.w,
                  height: 138.w,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Confirm password".tr,
                      hintStyle: TextStyle(
                        fontSize: 42.sp,
                        color: Color.fromRGBO(203, 207, 216, 1),
                      ),
                      border: InputBorder.none,
                      prefixIcon: Image(
                        image: AssetImage('images/account_password.png'),
                        alignment: Alignment.centerLeft,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        maxHeight: 42.w,
                        minWidth: 80.w,
                      ),
                      suffixIcon: Container(
                        width: 100.w,
                        height: 100.w,
                        child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Image(
                            image: visible==true?AssetImage('images/eye_open.png'):AssetImage('images/eye_close.png'),
                            width: 60.w,
                            height: 60.w,
                          ),
                          onPressed: () {
                            setState(() {
                              // onlyRefresh = false;
                              if(visible==true) {
                                visible = false;
                              }
                              else visible=true;
                            });
                          },
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(234, 236, 243, 1),
                            width: 3.w,
                          )
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(249, 122, 53, 1),
                            width: 3.w,
                          )
                      ),
                    ),
                    obscureText: !visible,
                    // focusNode: passwordNode2,
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: (str){
                      setState(() {
                        captcha = str;
                      });
                    },
                  ),
                ),
                if(account != captcha && captcha != '')
                  Container(
                    padding:EdgeInsets.only(top: 20.h),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.warning,
                          size: 50.w,
                          color: Color.fromRGBO(232, 14, 14, 1),
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(
                          "Passwords do not match.Try again.".tr,
                          style: TextStyle(
                              color: Color.fromRGBO(232, 14, 14, 1),
                              fontSize: 36.sp),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 129.h,
                ),
                Container(
                  height: 150.w,
                  width: 960.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(18.sp)),
                    color: (account.length > 0 && captcha.length > 0)
                        ? Color.fromRGBO(249, 122, 53, 1)
                        : Color.fromRGBO(234, 236, 243, 1),
                  ),
                  child: FlatButton(
                    child: Text(
                      'OK2'.tr,
                      style: TextStyle(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (account == captcha && strLength && !illegal) {
                          _setPwm();
                        }
                      });
                    },
                  ),
                ),
              ],
            ) :
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('images/done.png'),
                    width: 480.w,
                    height: 480.w,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 7.w),
                    child:Text(
                      "success".tr,
                      style: TextStyle(
                          fontSize: 42.sp,
                          color: Color.fromRGBO(155, 165, 177, 1)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 42.6.w),
                    child: Text(
                      "Jump to the homepage in".tr + second.toString() + 's',
                      style: TextStyle(
                          fontSize: 42.sp,
                          color: Color.fromRGBO(155, 165, 177, 1)),
                    ),
                  ),
                  FlatButton(
                    splashColor: Colors.transparent,
                    child: Text(
                      "Return now".tr,
                      style: TextStyle(
                          height: 1.2,
                          fontSize: 42.sp,
                          color: Color.fromRGBO(249, 122, 53, 1)),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(12.w)),
                        side: BorderSide(
                            color: Color.fromRGBO(255, 189, 153, 1),
                            style: BorderStyle.solid,
                            width: 3.w)),
                    color: Color.fromRGBO(255, 227, 211, 1),
                    //OutlineButton中会无效
                    highlightColor: Color.fromRGBO(255, 189, 153, 1),
                    onPressed: () {
                      _timer.cancel();
                      if(SaveData.loginPage){
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      }else if(SaveData.english){
                        _timer.cancel();
                        Navigator.popUntil(context, ModalRoute.withName('userEnLoginRoute'));
                      }else{
                        Navigator.popUntil(context, ModalRoute.withName('userLogin'));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
//修改密码
  void _setPwm() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      Method.showToast('It seems that there is no internet'.tr, context);
    }else{
      // Method.showFulLoading(context, '修改中...');
      DioUtil().put(
          RequestUrl.updatePwdUrl,
          queryParameters: {"newPassword": account, "userId" : SaveData.userId},
          options: new Options(headers: {"app_pass" : RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
      ).then((value){
        // print(value);
        if(value != null){
          if(value["code"] == "200"){
            SaveData.setPassword = true;
            SaveData.userId = null;
            SharedPreferences.getInstance().then((value){
              value.setBool('setPassword', SaveData.setPassword);
              value.setInt('userId', SaveData.userId);
            });
            _setSuccess = true;
            _timer = Timer.periodic(Duration(seconds: 1), (timer) {
              if(mounted){
                setState(() {
                  second = second - 1;
                  if(second == 0){
                    _timer.cancel();
                    if(SaveData.loginPage){
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    }else if(SaveData.english){
                      _timer.cancel();
                      Navigator.popUntil(context, ModalRoute.withName('userEnLoginRoute'));
                    }else{
                      Navigator.popUntil(context, ModalRoute.withName('userLogin'));
                    }
                  }
                });
              }
            });
          }else{
            Method.showToast('请输入符合要求的密码', context);
          }
        }else{
          // Navigator.of(context).pop();
          Method.showToast('It seems that there is no internet'.tr, context);
        }
      });
    }
  }
}
