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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../login/zone_code_picker_page.dart';


class BindingAccount1 extends StatefulWidget {

  final int bindingType;
  BindingAccount1({this.bindingType});

  @override
  _BindingAccount1State createState() => _BindingAccount1State();
}

class _BindingAccount1State extends State<BindingAccount1> {

  int isOnclick = 0;
  Timer _timer;
  int second = 60;
  String captcha = '';
  String account = '';
  bool bindingSuccess = false;
  int seconds = 3;
  bool sendCode = false;
  var emailMatcher = RegExp(r"^[\w!#$%&'*+/=?`{|}~^-]+(?:\.[\w!#$%&'*+/=?`{ |}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]+$");
  bool hasReturn = false;//用于验证是否点击立即返回按钮

  @override
  void initState() {
    super.initState();
    print(widget.bindingType);
  }

  @override
  Widget build(BuildContext context) {
    return bindingSuccess ? ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => Material(
        child: Center(
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
                  "Jump to the homepage in".tr + seconds.toString() + 's',
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
                      fontWeight: FontWeight.normal,
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
                  }else{
                    Navigator.popUntil(context, ModalRoute.withName('accountSecurity'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    )
        :
    ScreenUtilInit(
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
                  Navigator.of(context).pop();
                  SaveData.findPwd = true;
                },
              ),
              title: Text(
                widget.bindingType == 0 ? "Link email".tr : 'Link new phone number'.tr,
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
                    image: widget.bindingType == 0 ? AssetImage('images/邮箱验证.png') : AssetImage('images/重置密码流程-手机号验证01.png'),
                    width: 1080.w,
                    height: 458.w,
                  ),
                ),
                Positioned(
                  top: 757.w,
                  child: Container(
                    width: 936.w,
                    height: 138.w,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: widget.bindingType == 0
                            ? "Input Email".tr
                            : "Phone Number".tr,
                        hintStyle: TextStyle(
                          fontSize: 42.sp,
                          color: Color.fromRGBO(203, 207, 216, 1),
                        ),
                        // border: InputBorder.none,
                        prefixIcon: widget.bindingType == 0 ? null : FlatButton.icon(
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
                                fontWeight: FontWeight.normal,
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
                      keyboardType: widget.bindingType == 0 ? TextInputType.visiblePassword : TextInputType.number,
                      cursorColor: Color.fromRGBO(203, 207, 216, 1),
                      inputFormatters: widget.bindingType == 0 ? null : [
                        WhitelistingTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      onChanged: (str) {
                        account = str;
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
                        height: 138.w,
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
                        height: 138.w,
                        alignment: Alignment.centerLeft,
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
                          onPressed: isOnclick != 0 ||account.length==0? null : () {
                            if(widget.bindingType==1||(widget.bindingType == 0 && emailMatcher.hasMatch(account))) {
                              sendCode = true;
                              _getCaptcha();
                            }
                            else if(widget.bindingType == 0 && !emailMatcher.hasMatch(account)){
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
                      color: captcha.length >0 && account.length != 0 ? Color.fromRGBO(249, 122, 53, 1) : Color.fromRGBO(203, 207, 216, 1),
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
                      onPressed: account.length>0 && captcha.length > 0 ?(){
                        _bindingAccount();
                      }:null,
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
      setState(() {
        isOnclick = 1;
      });
      _checkBindingAccount();
    }
  }
  //获取验证码
  _sendCodeRequest() async {
    DioUtil().get(
        widget.bindingType == 0 ? RequestUrl.sendMailNumberUrl : RequestUrl.sendPhoneNumberUrl,
        queryParameters: widget.bindingType == 0 ? {"mailAddress": account, "businessType" : "bindMail1", "isCn" : SaveData.english ? false : true}
            : {"areaCode": SaveData.countryCode, "phoneNumber":account, "businessType" : "bindPhone1", "isCn" : SaveData.english ? false : true},
        options: new Options(headers: {"app_pass":RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      if(value != null){
        if(value["code"] == "200"){
          if(mounted){
            setState(() {
              isOnclick = 2;
            });
            _timer = Timer.periodic(Duration(seconds: 1), (timer) {
              if(mounted){
                setState(() {
                  second--;
                  if (second == 0) {
                    second = 60;
                    isOnclick = 0;
                    _timer.cancel();
                  }
                  if(hasReturn){
                    seconds--;
                    if (seconds == 0) {
                      _timer.cancel();
                      Navigator.popUntil(context, ModalRoute.withName('accountSecurity'));
                    }
                  }
                });
              }
            });
          }
        }else{
          setState(() {
            // Method.showToast('发送失败', context);
            isOnclick = 0;
          });
        }
      }else{
        setState(() {
          isOnclick = 0;
          Method.showToast('It seems that there is no internet'.tr, context);
        });
      }
    });
  }
//检查账号是否被绑定
  _checkBindingAccount() async {
    DioUtil().get(
        widget.bindingType == 0 ? RequestUrl.checkBindMailUrl : RequestUrl.checkBindPhoneUrl,
        queryParameters: widget.bindingType == 0 ? {"mailAddress": account,} : {"phoneNumber": account},
        options: new Options(headers: {"app_pass":RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      print(value);
      if(value != null){
        if(value["code"] == "200"){
          if(value["data"] == null){
            Future.delayed(Duration(seconds: 1),(){
              _sendCodeRequest();
            });
          }else{
            setState(() {
              isOnclick = 0;
            });
            Method.showToast(widget.bindingType == 0 ?"The email is already linked.Please enter another one.".tr
                : "The phone is already linked.Please enter another one.".tr, context, position: 1);
          }
        }
      }else{
        setState(() {
          isOnclick = 0;
          Method.showToast('It seems that there is no internet'.tr, context);
        });
      }
    });
  }
//绑定账号
  _bindingAccount() async {
    Method.showLessLoading(context, 'Loading2'.tr);
    DioUtil().put(
        widget.bindingType == 0 ? RequestUrl.updateMailUrl : RequestUrl.updatePhoneUrl,
        queryParameters: widget.bindingType == 0 ? {"newMail":account, "code": captcha, "userId": SaveData.userId, "businessType" : "bindMail1"}
            : {"phoneNumber":account, "code": captcha, "userId": SaveData.userId, "areaCode" : SaveData.countryCode, "businessType" : "bindPhone1"},
        options: new Options(headers: {"app_pass":RequestUrl.appPass, 'access_token': SaveData.accessToken}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      if(value != null){
        if(value["code"] == "200"){
          Navigator.of(context).pop();
          widget.bindingType == 0 ? SaveData.accountList[0]  = account : SaveData.accountList[1] = account;
          SharedPreferences.getInstance().then((value){
            value.setStringList('accountList', SaveData.accountList);
          });
          if(mounted){
            setState(() {
              bindingSuccess = true;
              hasReturn = true;
              // _timer.cancel();
              // _timer = Timer.periodic(Duration(seconds: 1), (timer) {
              //   if(mounted){
              //     setState(() {
              //       seconds--;
              //       if (seconds == 0) {
              //         _timer.cancel();
              //         Navigator.popUntil(context, ModalRoute.withName('accountSecurity'));
              //       }
              //     });
              //   }
              // });
            });
          }
        }else{
          Navigator.of(context).pop();
          Method.showToast('Operation failed'.tr, context);
        }
      }else{
        Navigator.of(context).pop();
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }
}
