import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/model/LoginInfo.dart';
import 'package:running_app/routes/userRoutes/testType.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class UserEnLoginRoute extends StatefulWidget {
  @override
  UserEnLoginRouteState createState() => UserEnLoginRouteState();
}

class UserEnLoginRouteState extends State<UserEnLoginRoute> {
  final TapGestureRecognizer recognizer = TapGestureRecognizer();
  final TapGestureRecognizer recognizer2 = TapGestureRecognizer();
  final TapGestureRecognizer recognizer3 = TapGestureRecognizer();
  TextEditingController _controller = new TextEditingController();
  TextEditingController _codeController = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  LoginInfo loginInfo;
  Timer _timer;
  int second = 60;
  int isOnclick = 0;
  String email = '';
  String code = '';
  String pwd = '';
  bool visible = false;
  bool emailEnable = false; //邮箱输入框禁用
  bool Login = false; //true为login，false为sign up
  bool illegal = false;
  bool strLength = false;
  var emailMatcher =
  RegExp(r"^[\w!#$%&'*+/=?`{|}~^-]+(?:\.[\w!#$%&'*+/=?`{ |}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]+$");
  var passwordMatcher = RegExp("[\u0021-\u007e]");
  bool agree = false;

  int flag; //用于元素位置交换
  Map<String, Object> _map = new Map(); //方便数据展示
  List<Map<String, Object>> _mapList = new List();
  List<String> _list = new List();
  int sportLength;
  String totalBmpData = '';
  String totalBmpTime = '';
  List<Map> netSaveDataList = new List();
  Map<String, dynamic> _netSportMap;
  int bmpLength;
  int avgLength;
  List bmpData = new List();
  List bmpTimes = new List();
  List<Map> totalBmpList = new List();

  @override
  void initState() {
    super.initState();
    SaveData.accountList = ['', ''];
    SaveData.loginPage = false;
    recognizer.onTap = () {
      _launchURL();
    };
    recognizer2.onTap = () {
      setState(() {
        strLength = false;
        illegal = false;
        Login = true;
        _controller.clear();
        _codeController.clear();
        _pwdController.clear();
        emailEnable = false;
        email = '';
        code = '';
        pwd = '';
      });
    };
    recognizer3.onTap = () {
      setState(() {
        strLength = false;
        illegal = false;
        Login = false;
        _controller.clear();
        _codeController.clear();
        _pwdController.clear();
        emailEnable = false;
        email = '';
        code = '';
        pwd = '';
      });
    };
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  void showSoftInfo() {
    showDialog(
        barrierDismissible: false, // 表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Center(
              child: Text('Enduser Agreement and Privacy Policy'.tr),
            ),
            content: Text.rich(TextSpan(children: [
              TextSpan(
                  text: "Thank you for using Tergasy Fitness App.Please read 《".tr),
              TextSpan(
                  text: 'Enduser Agreement and Privacy Policy'.tr,
                  style: TextStyle(color: Colors.blue),
                  recognizer: recognizer),
              TextSpan(
                  text: "》 carefully,and click \"OK\" to start using our App."
                      .tr),
            ])),
            actions: <Widget>[
              Container(
                child: FlatButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Text('Cancel'.tr, style: TextStyle(fontWeight: FontWeight.normal,),),
                  onPressed: () {
                    exit(0);
                  },
                ),
              ),
              Container(
                color: Color.fromRGBO(249, 122, 53, 1),
                child: FlatButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Text(
                    "OK1".tr,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal,),
                  ),
                  onPressed: () {
                    SharedPreferences.getInstance().then((value) {
                      value.setBool("useApp", true);
                    });
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          );
        });
  }

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
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              titleSpacing: 4,
              elevation: 0,
              centerTitle: false,
              leading: FlatButton(
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Color.fromRGBO(111, 122, 135, 1),
                  size: 20,
                ),
                splashColor: Colors.transparent,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: Login
                      ? 191.w
                      : 0,
                  left: 72.w,
                  child: Text(
                    Login ? "Log in".tr : "Sign Up".tr,
                    style: TextStyle(fontSize:80.sp),
                  ),
                ),
                Positioned(
                  top: Login
                      ? 366.w
                      : 162.w,
                  child: Container(
                    width: 936.w,
                    height: 138.w,
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Input Email".tr,
                        hintStyle: TextStyle(
                          fontSize: 42.sp,
                          color: Color.fromRGBO(203, 207, 216, 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(234, 236, 243, 1),
                              width: 3.w,
                            )),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(249, 122, 53, 1),
                              width: 3.w,
                            )),
                        enabled: emailEnable ? false : true,
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      cursorColor: Color.fromRGBO(203, 207, 216, 1),
                      onChanged: (str) {
                        email = str;
                        // print("email:$email");
                      },
                    ),
                  ),
                ),
                if (Login == false)
                  Positioned(
                    top: 366.w,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 600.w,
                          height: 138.w,
                          child: TextField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              hintText: "Verification code".tr,
                              hintStyle: TextStyle(
                                color: Color.fromRGBO(203, 207, 216, 1),
                                fontSize: 42.sp,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(234, 236, 243, 1),
                                    width: 3.w,
                                  )),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(249, 122, 53, 1),
                                    width: 3.w,
                                  )),
                            ),
                            keyboardType: TextInputType.number,
                            cursorColor: Color.fromRGBO(203, 207, 216, 1),
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onChanged: (str) {
                              setState(() {
                                code = str;
                                // print("code:$code");
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 336.w,
                          height: 138.w,
                          child: FlatButton(
                            padding: EdgeInsets.zero,
                            child: Text(
                              isOnclick == 0
                                  ? "Get code".tr
                                  : isOnclick == 2
                                  ? "Resend".tr +
                                  '(' +
                                  second.toString() +
                                  ')'
                                  : "Loading".tr,
                              style: TextStyle(
                                fontSize: 48.sp,
                                fontWeight: FontWeight.normal,
                                color: Color.fromRGBO(249, 122, 53, 1),
                              ),
                            ),
                            splashColor: Colors.transparent,
                            onPressed: isOnclick != 0 || email.length == 0
                                ? null
                                : () {
                              if (emailMatcher.hasMatch(email)) {
                                _getCaptcha();
                              } else {
                                Method.showToast("validEmail".tr, context,
                                    position: 1);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                Positioned(
                  top: 570.w,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: Login
                            ? 600.w
                            : 936.w,
                        height: 138.w,
                        child: TextField(
                          controller: _pwdController,
                          obscureText: !visible,
                          decoration: InputDecoration(
                            hintText: "Password".tr,
                            hintStyle: TextStyle(
                              fontSize: 42.sp,
                              color: Color.fromRGBO(203, 207, 216, 1),
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: illegal
                                      ? Colors.red
                                      : Color.fromRGBO(234, 236, 243, 1),
                                  width: 3.w,
                                )),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: illegal
                                      ? Colors.red
                                      : Color.fromRGBO(249, 122, 53, 1),
                                  width: 3.w,
                                )),
                            suffixIcon: Container(
                              width: 100.w,
                              height: 100.w,
                              child: FlatButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Image(
                                  image: visible == true
                                      ? AssetImage('images/eye_open.png')
                                      : AssetImage('images/eye_close.png'),
                                  width: 60.w,
                                  height: 60.w,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (visible == true) {
                                      visible = false;
                                    } else
                                      visible = true;
                                  });
                                },
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: Color.fromRGBO(203, 207, 216, 1),
                          onChanged: (str) {
                            setState(() {
                              if (passwordMatcher.allMatches(str).length !=
                                  str.length) {
                                illegal = true;
                              } else {
                                illegal = false;
                              }
                              if (str.length > 7 && str.length < 17) {
                                strLength = true;
                              } else {
                                strLength = false;
                              }
                              pwd = str;
                              // print("pwd:$pwd");
                            });
                          },
                        ),
                      ),
                      if (Login == true)
                        Container(
                          width: 336.w,
                          height: 138.w,
                          child: FlatButton(
                            padding: EdgeInsets.zero,
                            child: Text(
                              'Forgot password'.tr,
                              style: TextStyle(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.normal,
                                color: Color.fromRGBO(249, 122, 53, 1),
                              ),
                            ),
                            splashColor: Colors.transparent,
                            onPressed: () {
                              SaveData.findPwd = true;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TestTypeRoute(
                                        isEnglish: true,
                                      )));
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 728.w,
                  child: Container(
                    width: 936.w,
                    child: Column(
                      children: <Widget>[
                        if (!strLength && !Login)
                          Container(
                            width: 936.w,
                            child: Text(
                              "Password must be between 8 and 16 characters.".tr,
                              style: TextStyle(
                                  color: Color.fromRGBO(232, 14, 14, 1),
                                  fontSize: 36.sp),
                            ),
                          ),
                        if (illegal && !Login)
                          Container(
                            padding:
                            EdgeInsets.only(top: 10.h),
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
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 840.w,
                  child: Container(
                    height: 150.w,
                    width: 960.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(18.sp)),
                      color: Login
                          ? (email.length > 0 && pwd.length > 0
                          ? Color.fromRGBO(249, 122, 53, 1)
                          : Color.fromRGBO(203, 207, 216, 1))
                          : (email.length > 0 &&
                          code.length > 0 &&
                          !illegal &&
                          strLength
                          ? Color.fromRGBO(249, 122, 53, 1)
                          : Color.fromRGBO(203, 207, 216, 1)),
                    ),
                    child: FlatButton(
                      child: Text(
                        Login ? "Log in".tr : "Sign Up".tr,
                        style: TextStyle(
                          fontSize: 42.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                      splashColor: Colors.transparent,
                      highlightColor: Color.fromRGBO(221, 91, 21, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(18.sp)),
                      onPressed: (Login && email.length > 0 && pwd.length > 0)
                          ? () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (agree) {
                          _captchaLogin();
                        } else {
                          Method.showToast('agreeToService'.tr, context);
                        }
                      }
                          : (!Login &&
                          email.length > 0 &&
                          code.length > 0 &&
                          !illegal &&
                          strLength
                          ? () {
                        FocusScope.of(context)
                            .requestFocus(FocusNode());
                        if (agree) {
                          if (emailMatcher.hasMatch(email) &&
                              code.length == 6) {
                            _hasEmail();
                          } else if (!emailMatcher.hasMatch(email)) {
                            Method.showToast("validEmail".tr, context,
                                position: 1);
                          } else if (code.length != 6) {
                            Method.showToast(
                                "Incorrect verification code".tr,
                                context,
                                position: 1);
                          }
                        } else {
                          Method.showToast(
                              'agreeToService'.tr, context);
                        }
                      }
                          : null),
                    ),
                  ),
                ),
                Positioned(
                  top: 1080.w,
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Login
                              ? "Not a member?".tr
                              : "Have an account already?".tr,
                          style: TextStyle(
                            color: Color.fromRGBO(145, 148, 160, 1),
                            fontSize: 42.sp,
                          ),
                        ),
                        TextSpan(
                          text: Login ? "Sign Up".tr : "Log in".tr,
                          style: TextStyle(
                            color: Color.fromRGBO(249, 122, 53, 1),
                            fontSize: 42.sp,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: Login ? recognizer3 : recognizer2,
                        ),
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //   top: ScreenUtil().setWidth(1160),
                //   child: FlatButton(
                //     splashColor:Colors.transparent,
                //     highlightColor:Colors.transparent,
                //     padding: EdgeInsets.zero,
                //     child: Text(
                //       "Sign up with the Guest Account",
                //       style: TextStyle(
                //           decoration: TextDecoration.underline,
                //           color: Color.fromRGBO(111, 122, 135, 1),
                //           fontSize: 36.sp),
                //     ),
                //     onPressed: _guestLogin,
                //   ),
                // ),
                Positioned(
                  bottom: 80.w,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: Icon(
                            agree
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: Color.fromRGBO(249, 122, 53, 1),
                            size: 58.w,
                          ),
                          onTap: () {
                            setState(() {
                              if (agree) {
                                agree = false;
                              } else {
                                agree = true;
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          width: 960.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: "By registering,you agree to the".tr,
                                      style: TextStyle(
                                        color: Color.fromRGBO(145, 148, 160, 1),
                                        fontSize: 32.sp,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Enduser Agreement and Privacy Policy'
                                          .tr,
                                      style: TextStyle(
                                        color: Color.fromRGBO(249, 122, 53, 1),
                                        fontSize: 32.sp,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: recognizer,
                                    ),
                                  ],
                                ),
                              ),
                              if (!Login)
                                Text(
                                  "Unregistered user will automatically register and sign in after authentication"
                                      .tr,
                                  style: TextStyle(
                                    color: Color.fromRGBO(145, 148, 160, 1),
                                    fontSize: 32.sp,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _hasEmail() {
    DioUtil()
        .get(RequestUrl.checkBindMailUrl,
        queryParameters: {
          "mailAddress": email,
        },
        options: new Options(
          headers: {"app_pass": RequestUrl.appPass},
          sendTimeout: 5000,
          receiveTimeout: 10000,
        ))
        .then((value) {
      // print(value);
      if (value["code"] == "200") {
        if (value["data"] != null) {
          Method.showToast('Email has already been taken.', context,
              position: 1);
        } else {
          _captchaLogin();
        }
      }
    });
  }

  _sendCodeRequest() async {
    DioUtil()
        .get(RequestUrl.sendMailNumberUrl,
        queryParameters: {
          "mailAddress": email,
          "isCn": false,
          "businessType": "userEnLogin"
        },
        options: Options(
          headers: {
            "app_pass": RequestUrl.appPass,
          },
          sendTimeout: 5000,
          receiveTimeout: 10000,
        ))
        .then((value) {
      // print(value);
      if (value != null) {
        if (value["code"] == "200") {
          emailEnable = true;
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
          if (mounted) {
            setState(() {
              isOnclick = 2;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isOnclick = 0;
              Method.showToast(
                  'It seems that there is no internet'.tr, context);
            });
          }
        }
      } else {
        setState(() {
          isOnclick = 0;
          Method.showToast('It seems that there is no internet'.tr, context);
        });
      }
    });
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
      _sendCodeRequest();
    }
  }

  //登录验证
  void _captchaLogin() async {
    final ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Method.showToast('It seems that there is no internet'.tr, context);
    } else {
      // if(pwd.length > 7 && pwd.length < 17){
      Method.showLessLoading(context, 'Loading2'.tr);
      if (Login == false) {
        await DioUtil()
            .post(RequestUrl.mailLoginUrl,
            queryParameters: <String, Object>{
              'mailAddress': email,
              'code': code,
              'businessType': 'userEnLogin'
            },
            options: Options(
              headers: <String, Object>{'app_pass': RequestUrl.appPass},
              sendTimeout: 5000,
              receiveTimeout: 10000,
            ))
            .then((value) {
          // print(value);
          // print("object");
          loginInfo = LoginInfo.fromJson(value);
        });
      } else {
        await DioUtil()
            .post(RequestUrl.pwdLoginUrl,
            queryParameters: {"bindingAccount": email, "password": pwd},
            options: new Options(
              headers: {"app_pass": RequestUrl.appPass},
              sendTimeout: 5000,
              receiveTimeout: 10000,
            ))
            .then((value) {
          // print(value);
          loginInfo = LoginInfo.fromJson(value);
        });
      }
      SaveData.isLoginPage = true;
      if (loginInfo.code == "201") {
        FocusScope.of(context).requestFocus(FocusNode());
        SaveData.changeState = true;
        SaveData.onclickPage.clear();
        SaveData.accessToken = loginInfo.data.token;
        // SaveData.tokenRefresh = DateTime.now().toString();
        SaveData.userId = loginInfo.data.userInfo.id;
        if (loginInfo.data.userInfo.mailAddress != null) {
          SaveData.accountList[0] = loginInfo.data.userInfo.mailAddress;
        }
        if (loginInfo.data.userInfo.phoneNumber != null) {
          SaveData.accountList[1] = loginInfo.data.userInfo.phoneNumber;
        }
        SharedPreferences.getInstance().then((value) {
          value.setStringList('accountList', SaveData.accountList);
          value.setBool('firstOpenApp', false);
          value.setInt('userId', SaveData.userId);
          value.setString('accessToken', SaveData.accessToken);
          value.setString('tokenDateTime', DateTime.now().toString());
        });
        Future.delayed(Duration(milliseconds: 500), () {
          setPwd();
        });
      } else if (loginInfo.code == "200") {
        FocusScope.of(context).requestFocus(FocusNode());
        syncUserInfo();
      } else if (loginInfo.code == "400") {
        Navigator.of(context).pop();
        Method.showToast("Incorrect verification code".tr, context);
      } else if (loginInfo.code == "401") {
        Navigator.of(context).pop();
        Method.showToast("incorrectIDorPassword".tr, context);
      } else if (loginInfo.code == "403") {
        Navigator.of(context).pop();
        Method.showToast("incorrectIDorPassword".tr, context);
      } else if (loginInfo.code == "412") {
        Navigator.of(context).pop();
        Method.showToast("Account disabled".tr, context);
      } else {
        Navigator.of(context).pop();
        // Method.showToast("request failed".tr, context);
        Method.showToast("incorrectIDorPassword".tr, context);
      }
      // }else{
      //   Method.showToast('Password must be between 8 and 16 characters', context, position: 1);
      // }
    }
  }

  void setPwd() {
    DioUtil()
        .put(RequestUrl.updatePwdUrl,
        queryParameters: {"newPassword": pwd, "userId": SaveData.userId},
        options: new Options(
          headers: {"app_pass": RequestUrl.appPass},
          sendTimeout: 5000,
          receiveTimeout: 10000,
        ))
        .then((value) {
      print(value);
      if (value["code"] == "200") {
        SaveData.setPassword = true;
        SharedPreferences.getInstance().then((value) {
          value.setBool('setPassword', SaveData.setPassword);
          Navigator.of(context).pop();
          Future.delayed(Duration(milliseconds: 300), () {
            Navigator.of(context).pop();
          });
        });
      }
    });
  }

  void syncUserInfo() async {
    SaveData.changeState = true;
    SaveData.onclickPage.clear();
    SaveData.accessToken = loginInfo.data.token;
    // SaveData.tokenRefresh = DateTime.now().toString();
    SaveData.userId = loginInfo.data.userInfo.id;
    SaveData.username = loginInfo.data.userInfo.nickName;
    SaveData.userBirthday = loginInfo.data.userInfo.birthday;
    SaveData.userHeight = loginInfo.data.userInfo.height.toString();
    SaveData.userWeight = loginInfo.data.userInfo.weight.toString();
    SaveData.setPassword = loginInfo.data.userInfo.hasPsw;
    if (loginInfo.data.userInfo.sex) {
      SaveData.userSex = '男';
    } else {
      SaveData.userSex = '女';
    }
    String httpImageUrl = "https://www.ucfitness.club/api/picture";
    var root = await getApplicationSupportDirectory();
    print("root:$root");
    if (loginInfo.data.userInfo.headImage != null) {
      DioUtil().downLoad(httpImageUrl, root.path + '/userImage.png',
          queryParameters: {"hash": loginInfo.data.userInfo.headImage},
          onReceiveProgress: (received, total) {
            if (total != -1) {
              if (received / total == 1) {
                SaveData.pictureUrl = root.path + '/userImage.png';
                SharedPreferences.getInstance().then((value) {
                  value.setString('pictureUrl', SaveData.pictureUrl);
                });
                _getHistoryData();
              }
              print((received / total * 100).toStringAsFixed(0) + "%");
            }
          },
          options: new Options(
            headers: {
              "app_pass": RequestUrl.appPass,
              'access_token': SaveData.accessToken
            },
            responseType: ResponseType.stream,
            sendTimeout: 5000,
            receiveTimeout: 10000,
          ));
    } else {
      _getHistoryData();
    }
    SharedPreferences.getInstance().then((value) {
      value.setBool('firstOpenApp', false);
      value.setInt('userId', SaveData.userId);
      value.setString('accessToken', SaveData.accessToken);
      value.setString('username', SaveData.username);
      value.setString('userBirthday', SaveData.userBirthday);
      value.setString('userHeight', SaveData.userHeight);
      value.setString('userWeight', SaveData.userWeight);
      value.setString('userSex', SaveData.userSex);
      value.setString('tokenDateTime', DateTime.now().toString());
      value.setBool('setPassword', SaveData.setPassword);
    });
  }

  void _getHistoryData() {
    if (loginInfo.data.userInfo.mailAddress != null) {
      SaveData.accountList[0] = loginInfo.data.userInfo.mailAddress;
    }
    if (loginInfo.data.userInfo.phoneNumber != null) {
      SaveData.accountList[1] = loginInfo.data.userInfo.phoneNumber;
    }
    SharedPreferences.getInstance().then((values) {
      values.setStringList('accountList', SaveData.accountList);
      if (values.getBool('downloadData') != null &&
          values.getStringList('sportData') != null) {
        Navigator.of(context).pop();
        Method.showLessLoading(context, 'Loading2'.tr);
        _list = values.getStringList('sportData');
        sportLength = _list.length;
        for (int i = 0; i < sportLength; i++) {
          //将拿到的字符串数组转换成map类型的数组
          _map = jsonDecode(_list[i]);
          _mapList.add(_map);
        }
        for (int i = 0; i < sportLength; i++) {
          if (_mapList[i]['totalBmpTime'] != null) {
            bmpData = _mapList[i]['totalBmpData'].toString().split('-');
            bmpTimes = _mapList[i]['totalBmpTime'].toString().split('-');
            bmpLength = bmpData.length;
            if (bmpLength > 60) {
              avgLength = bmpLength ~/ 60 + 1;
            } else {
              avgLength = 1;
            }
            for (int j = 0; j < bmpLength;) {
              if (bmpData[j] != '') {
                totalBmpList.add({
                  "heartRate": int.parse(bmpData[j].toString()),
                  "time": bmpTimes[j],
                });
              }
              j = j + avgLength;
            }
          }
          _netSportMap = {
            "offline": _mapList[i]['offline'],
            "calories": _mapList[i]['sportKCal'],
            "count": _mapList[i]['sportCount'],
            "duringTime": _mapList[i]['sportDuration'],
            "equipmentType": getDeviceType(_mapList[i]['deviceName']),
            "heartRateProcess": totalBmpList,
            "mode": _mapList[i]['mode'],
            "trainMode": _mapList[i]['trainMode'],
            "startTime": _mapList[i]['sportYMDHM'].toString() + ':00',
            "timeZone": DateTime.now().timeZoneOffset.inHours,
            "userId": SaveData.userId,
          };
          netSaveDataList.add(_netSportMap);
          totalBmpList.clear();
          bmpTimes.clear();
          bmpData.clear();
        }
        DioUtil()
            .post(RequestUrl.historySportDataUrl,
            data: netSaveDataList,
            options: Options(
              headers: {
                'access_token': SaveData.accessToken,
                "app_pass": RequestUrl.appPass
              },
              sendTimeout: 5000,
              receiveTimeout: 10000,
            ))
            .then((value) {
          print(value);
          if (value["code"] == "200") {
            values.remove('sportData');
            Navigator.of(context)..pop()..pop();
          } else {
            Navigator.of(context).pop();
            Method.showToast('It seems that there is no internet'.tr, context);
          }
        });
      } else {
        Navigator.of(context)..pop()..pop();
      }
    });
  }

  int getDeviceType(String deviceName) {
    switch (deviceName) {
      case '跳绳':
        return 1;
      case '拉力绳':
        return 2;
      case '蝴蝶绳':
        return 4;
      case '健腹轮':
        return 5;
      case '哑铃':
        return 3;
      case '握力环':
        return 6;
      default:
        return null;
    }
  }

  _launchURL() async {
    String url = SaveData.english
        ? 'http://cloud.capstong.com:8081/otaDir/tergasy_privacy_policy_english.html'
        : 'http://cloud.capstong.com:8081/otaDir/tergasy_privacy_policy.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
