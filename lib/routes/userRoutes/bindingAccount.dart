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
import 'package:running_app/routes/realTimeSport/home.dart';
import 'package:running_app/routes/userRoutes/updatePassword.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bindingAccount1.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BindingAccount extends StatefulWidget {

  final int bindingType;//绑定账号类型
  final int isBindAccount;//区分设置密码还是绑定账号
  final int checkType;//验证类型

  BindingAccount({this.bindingType, this.isBindAccount, this.checkType});

  @override
  _BindingAccountState createState() => _BindingAccountState();
}

class _BindingAccountState extends State<BindingAccount> {

  int isOnclick = 0;
  Timer _timer;
  int second = 60;
  String captcha = '';
  bool captchaSuccess = false;
  String userPhone = '';
  bool checkSuccess = false;
  bool checkAccount = false;
  bool bindingSuccess = false;
  String account = '';
  bool sendCode = false;

  @override
  void initState() {
    super.initState();
    if(widget.checkType == 1){
      account = SaveData.accountList[1].replaceRange(3, 7, '****');
    }else{
      account = SaveData.accountList[0].replaceRange(3, SaveData.accountList[0].indexOf('@'), '*' * (SaveData.accountList[0].indexOf('@') - 3));
    }
  }

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
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                widget.checkType == 1 ? "Mobile phone number verification".tr : "E-mail verification".tr,
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
                    image: widget.checkType == 1 ? AssetImage('images/重置密码流程-手机号验证02.png') : AssetImage('images/重置密码流程-邮箱验证03.png'),
                    width: 1080.w,
                    height: 458.w,
                  ),
                ),
                Positioned(
                    top: 767.w,
                    child: Container(
                      width: 936.w,
                      child: Text(
                        (widget.checkType == 1 ? "For your account security, you need to verify your phone number".tr
                            : "For your account security, you need to verify your Email".tr) + '\n$account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 42.sp,
                            color: Color.fromRGBO(58, 64, 70, 1)),
                      ),
                    )),
                // Positioned(
                //     top: ScreenUtil().setWidth(823),
                //     child: Text(
                //       account,
                //       style: TextStyle(
                //           fontSize: 42.sp,
                //           color: Color.fromRGBO(58, 64, 70, 1)),
                //     )),
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
                            border: InputBorder.none,
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
                          onChanged: (str){
                            captcha = str;
                            if(str.length > 6){
                              captcha = str.substring(0,6);
                            }
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
                              fontSize: 42.sp,
                              fontWeight: FontWeight.normal,
                              color: isOnclick == 0 ? Color.fromRGBO(249, 122, 53, 1) : Colors.grey,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          splashColor: Colors.transparent,
                          onPressed: isOnclick != 0 ? null : () {
                            sendCode = true;
                            _getCaptcha();
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
                      BorderRadius.all(Radius.circular(18.w)),
                      color: captcha.length == 6 ? Color.fromRGBO(249, 122, 53, 1) : Color.fromRGBO(203, 207, 216, 1),
                    ),
                    child: FlatButton(
                      child: Text(
                        "Next".tr,
                        style: TextStyle(
                          fontSize: 42.sp,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: (){
                        if(sendCode){
                          sendCode = false;
                          _checkCaptcha();
                        }else{
                          Method.showToast("request failed".tr, context);
                        }
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
  //检查网络
  void _getCaptcha() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Method.showToast('It seems that there is no internet'.tr, context);
    } else {
      setState(() {
        isOnclick = 1;
      });
      _sendCodeRequest();
    }
  }
  //发送验证码
  void _sendCodeRequest() async {
    DioUtil().get(
      widget.checkType == 1 ? RequestUrl.sendPhoneNumberUrl : RequestUrl.sendMailNumberUrl,
      queryParameters: widget.checkType == 1 ? {"phoneNumber" :SaveData.accountList[1], "areaCode": SaveData.countryCode, "businessType" : SaveData.businessType + "phone" , "isCn" : SaveData.english ? false : true}
          : {"mailAddress": SaveData.accountList[0], "businessType" : SaveData.businessType + "mail", "isCn" : SaveData.english ? false : true},
      options: new Options(headers: {"app_pass":RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,),
    ).then((value){
      // print(value);
      if(value != null){
        if(value["code"] == "200"){
          if(mounted){
            setState(() {
              isOnclick = 2;
            });
          }
          _timer = Timer.periodic(Duration(seconds: 1), (timer) {
            if(mounted){
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
        }else{
          setState(() {
            isOnclick = 0;
          });
        }
      }else{
        if(mounted){
          setState(() {
            isOnclick = 0;
            Method.showToast('It seems that there is no internet'.tr, context);
          });
        }
      }
    });
  }
//验证码是否正确
  void _checkCaptcha() async {
    FocusScope.of(context).requestFocus(FocusNode());
    Method.showLessLoading(context, 'Loading2'.tr);
    DioUtil().get(
        RequestUrl.checkNumberUrl,
        queryParameters: {"target": widget.checkType == 1 ? SaveData.accountList[1] : SaveData.accountList[0],"code":captcha, "businessType" : widget.checkType == 1 ? SaveData.businessType + "phone" : SaveData.businessType + "mail"},
        options: new Options(headers: {"app_pass":RequestUrl.appPass,},
          sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      // print(value);
      if(value != null){
        if(value["code"] == "200"){
          if(mounted){
            setState(() {
              isOnclick = 0;
              second = 60;
              if(_timer != null){
                _timer.cancel();
              }
            });
          }
          if(widget.isBindAccount == 0){//修改或者绑定账号
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(builder: (context) => BindingAccount1(bindingType: widget.bindingType,)));
          }else if(widget.isBindAccount == 2){//注销账号
            DioUtil().get(
                RequestUrl.deleteUserInfoUrl,
                options: Options(headers: {'access_token': SaveData.accessToken, "app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
            ).then((value){
              if(value["code"] == "200"){
                SaveData.changeState = true;
                SaveData.onclickPage.clear();
                Future.delayed(Duration(milliseconds: 500),(){
                  SaveData.userId = null;
                  SaveData.pictureUrl = null;
                  SaveData.setPassword = false;
                  HomePageState.hasPicture = false;
                  SharedPreferences.getInstance().then((value){
                    value.clear();
                  }).then((value){
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  });
                });
              }else{
                Method.showToast('Operation failed'.tr, context);
              }
            });
          }else{//修改密码
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePasswordRoute())).then((value){
              second = 60;
            });
          }
        }else{
          setState(() {
            // isOnclick = 0;
            sendCode = true;
            Navigator.of(context).pop();
          });
          Method.showToast("Incorrect verification code".tr, context);
        }
      }else{
        Navigator.of(context).pop();
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }
}
