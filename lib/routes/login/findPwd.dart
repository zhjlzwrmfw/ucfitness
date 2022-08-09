import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:flutter/services.dart';
import 'package:running_app/routes/login/updatePwd.dart';
import 'package:running_app/routes/login/zone_code_picker_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class FindPwdRoute extends StatefulWidget {

  final int accountType;

  FindPwdRoute({this.accountType});

  @override
  _FindPwdRouteState createState() => _FindPwdRouteState();
}

class _FindPwdRouteState extends State<FindPwdRoute> {

  String account = '';
  String captcha = '';
  Timer _timer;
  int second = 60;
  int isOnclick = 0;
  // bool canNext = false;//防止可以点击下一步
  bool sendCode = false;
  var emailMatcher = RegExp(r"^[\w!#$%&'*+/=?`{|}~^-]+(?:\.[\w!#$%&'*+/=?`{ |}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]+$");


  @override
  void dispose() {
    super.dispose();
    if(_timer != null){
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Material(
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
                  SaveData.userId = null;
                  Navigator.of(context).pop();
                  SaveData.findPwd = true;
                },
              ),
              title: Text(
                "Forgot password".tr,
                style: TextStyle(
                    fontSize: 42.sp, fontWeight: FontWeight.bold),
              ),
            ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 179.w,
                  child: Image(
                    image: widget.accountType == 0 ? AssetImage('images/邮箱验证.png') : AssetImage('images/重置密码流程-手机号验证01.png'),
                    width: 1080.w,
                    height: 458.w,
                  ),
                ),
                Positioned(
                  top: 757.w,
                  child: Container(
                    width: 936.w,
                    height: 138.h,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: widget.accountType == 0
                            ? "Input Email".tr
                            : "Phone number".tr,
                        hintStyle: TextStyle(
                          fontSize: 42.sp,
                          color: Color.fromRGBO(203, 207, 216, 1),
                        ),
                        // border: InputBorder.none,
                        prefixIcon: widget.accountType == 0 ? null : FlatButton.icon(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => ZoneCodePickerPage()
                            )).then((value){
                              setState(() {
                                if(value != null){
                                  SaveData.country = value.toString().split('+')[0];
                                  SaveData.countryCode = value.toString().split('+')[1];
                                  SharedPreferences.getInstance().then((value){
                                    value.setString('countryCode', SaveData.countryCode);
                                  });
                                }
                              });
                            });
                          },
                          label: Icon(
                            Icons.arrow_drop_down,
                            size: 72.w,
                            color: Colors.black,
                          ),
                          icon: Text(
                            "+" + SaveData.countryCode,
                            style: TextStyle(
                                fontSize: 48.sp,
                                color: Colors.black),
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
                      // focusNode: phoneNode,
                      keyboardType: widget.accountType == 0 ? TextInputType.visiblePassword : TextInputType.number,
                      cursorColor: Color.fromRGBO(203, 207, 216, 1),
                      inputFormatters: widget.accountType == 0 ? null : [
                        WhitelistingTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      onChanged: (str) {
                        account = str;
                        SaveData.userAccount = str;
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 952.w,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 600.w,
                        height: 138.h,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Verification code".tr,
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(203, 207, 216, 1),
                              fontSize: 42.sp,
                            ),
                            // border: InputBorder.none,
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
                          // focusNode: codeNode,
                          keyboardType: TextInputType.number,
                          cursorColor: Color.fromRGBO(203, 207, 216, 1),
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          onChanged: (str) {
                            setState(() {
                              captcha = str;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 336.w,
                        height: 138.h,
                        child: FlatButton(
                          child: Text(
                            isOnclick == 0 ? "Get code".tr
                                : isOnclick == 2 ? "Resend".tr + '(' + second.toString() + ')'
                                : "Loading".tr,
                            style: TextStyle(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.normal,
                              color: isOnclick == 0 ? Color.fromRGBO(249, 122, 53, 1) : Color.fromRGBO(203, 207, 216, 1),
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          splashColor: Colors.transparent,
                          onPressed: isOnclick != 0 ||account.length==0? null : (){
                            if(widget.accountType == 1||(widget.accountType == 0 && emailMatcher.hasMatch(account))) {
                              sendCode = true;
                              _getCaptcha();
                            }
                            else if(widget.accountType == 0 && !emailMatcher.hasMatch(account)){
                              Method.showToast('validEmail'.tr, context,position: 1);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 1221.w,
                  child: Container(
                    height: 150.w,
                    width: 960.w,
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(18.sp)),
                      color: captcha.length >0 && account.length > 0 ? Color.fromRGBO(249, 122, 53, 1) : Color.fromRGBO(203, 207, 216, 1),
                    ),
                    child: FlatButton(
                      child: Text(
                        "Next".tr,
                        style: TextStyle(
                          fontSize: 42.sp,
                          color: Colors.white,
                        ),
                      ),
                      // onPressed: canNext && captcha.length > 0 ? (){
                      onPressed: account.length>0 && captcha.length > 0 ? (){
                        if(sendCode){
                          sendCode = false;
                          _checkCaptcha();
                        }else{
                          _checkBindingAccountCaptcha();
                        }
                      } : null,
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

  //获取验证码
  _getCaptcha() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Method.showToast('It seems that there is no internet'.tr, context);
    } else {
      _checkBindingAccount();
    }
  }
  //检查是否绑定
  _checkBindingAccount() async {
    DioUtil().get(
        widget.accountType == 0 ? RequestUrl.checkBindMailUrl : RequestUrl
            .checkBindPhoneUrl,
        queryParameters: {
          widget.accountType == 0 ? "mailAddress" : "phoneNumber": account,
        },
        options: new Options(headers: {"app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      print(value);
      if(value != null){
        if(value["code"] == "200"){
          if(value["data"] != null){
            setState(() {
              isOnclick = 1;
              SaveData.userId = value["data"]["id"];
            });
            _sendCodeRequest();
          }else{
            setState(() {
              isOnclick = 0;
            });
            Method.showToast('Account does not exist'.tr, context, position: 1);
          }
        }
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }
  //发送验证码
  _sendCodeRequest() async {
    DioUtil().get(
        widget.accountType == 0 ? RequestUrl.sendMailNumberUrl : RequestUrl
            .sendPhoneNumberUrl,
        queryParameters: widget.accountType == 0 ? {"mailAddress": account, "businessType" : "findMailPwd"} : {
          "areaCode": SaveData.countryCode,
          "phoneNumber": account,
          "businessType" : "findPhonePwd"
        },
        options: new Options(headers: {"app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      print(value);
      if(value["code"] == "200"){
        // canNext = true;
        // Method.showToast('发送验证码成功', context);
        if (mounted) {
          setState(() {
            isOnclick = 2;
          });
          _timer = Timer.periodic(Duration(seconds: 1), (timer) {
            if (mounted) {
              setState(() {
                second--;
                if (second == 0) {
                  second = 60;
                  isOnclick = 0;
                  _timer.cancel();
                }
              });
            }
          });
        }
      }else{
        setState(() {
          isOnclick = 0;
        });
        // Method.showToast('发送失败', context, position: 1);
      }
    });
  }
  //验证码是否正确,仅仅验证验证码
  _checkCaptcha() async {
    FocusScope.of(context).requestFocus(FocusNode());
    DioUtil().get(RequestUrl.checkNumberUrl,
        queryParameters: {"target": account, "code": captcha, "businessType" : widget.accountType == 0 ? "findMailPwd" : "findPhonePwd"},
        options: new Options(headers: {"app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      print(value);
      if(value != null){
        if(value["code"] == "200"){
          if (mounted) {
            setState(() {
              isOnclick = 0;
              if(_timer != null){
                _timer.cancel();
              }
            });
          }
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => UpdatePwdRoute())).then((value){
            second = 60;
          });
        } else {
          Method.showToast("Incorrect verification code".tr, context);
        }
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }
  _checkBindingAccountCaptcha() async {
    DioUtil().get(
        widget.accountType == 0 ? RequestUrl.checkBindMailUrl : RequestUrl
            .checkBindPhoneUrl,
        queryParameters: {
          widget.accountType == 0 ? "mailAddress" : "phoneNumber": account,
        },
        options: new Options(headers: {"app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      print(value);
      if(value != null){
        if(value["code"] == "200"){
          if(value["data"] != null){
            setState(() {
              SaveData.userId = value["data"]["id"];
            });
            _checkCaptcha();
          }else{
            setState(() {
              isOnclick = 0;
            });
            Method.showToast('Account does not exist'.tr, context, position: 1);
          }
        }
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }
}
