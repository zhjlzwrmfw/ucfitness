import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:running_app/common/PopupMenuItemOverride.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/model/LoginInfo.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/routes/login/zone_code_picker_page.dart';
import 'package:running_app/routes/userRoutes/testType.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class LoginRoute extends StatefulWidget {
  @override
  LoginRouteState createState() => LoginRouteState();
}

class LoginRouteState extends State<LoginRoute> {
  final TapGestureRecognizer recognizer = TapGestureRecognizer();
  Timer _timer;
  int second = 60;
  int isOnclick = 0;
  String account = '';
  String countryCode = '86';
  String captcha = '';
  LoginInfo loginInfo;
  List<int> _loginTypeList = [0, 1, 2];
  int flag; //用于元素位置交换
  bool visible = false;
  TextEditingController _controller = new TextEditingController();
  TextEditingController _codeController = new TextEditingController();
  bool accountEnable = false; //账号输入框禁用
  var emailMatcher =
  RegExp(r"^[\w!#$%&'*+/=?`{|}~^-]+(?:\.[\w!#$%&'*+/=?`{ |}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]+$");
  bool agree = false;

  @override
  void initState() {
    super.initState();
    SaveData.isLoginPage = true;
    SaveData.accountList = ['', ''];
    SaveData.loginPage = true;
    SharedPreferences.getInstance().then((value) {
      if (value.getBool("useApp") != true) {
        Future.delayed(Duration(milliseconds: 100), () {
          showSoftInfo();
        });
      }
    });
    recognizer.onTap = () {
      _launchURL();
    };
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
                  text: 'Thank you for using Tergasy Fitness App.Please read 《'.tr),
              TextSpan(
                  text: 'Enduser Agreement and Privacy Policy'.tr,
                  style: TextStyle(color: Colors.blue),
                  recognizer: recognizer),
              TextSpan(
                  text: "》 carefully,and click \"OK\" to start using our App.".tr),
            ])),
            actions: <Widget>[
              Container(
                child: FlatButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Text('Cancel'.tr),
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
                    style: TextStyle(color: Colors.white),
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
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
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
            // resizeToAvoidBottomPadding: false,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              /**标题周围边距设定为0*/
              backgroundColor: Colors.transparent,
              titleSpacing: 4,
              elevation: 0,
              centerTitle: false,
              actions: [
                FlatButton.icon(
                  icon: Text(
                    "Others".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42.sp,
                      fontWeight: FontWeight.normal,
                      color: Color.fromRGBO(249, 122, 53, 1),
                    ),
                  ),
                  label: Icon(Icons.arrow_drop_down),
                  splashColor: Colors.transparent,
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(2000, 70, 36.w, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      items: <PopupMenuEntry<String>>[
                        PopupMenuItemOverride<String>(
                          value: 'value01',
                          child: FlatButton(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              setState(() {
                                flag = _loginTypeList[1];
                                _loginTypeList[1] = _loginTypeList[0];
                                _loginTypeList[0] = flag;
                                _controller.clear();
                                _codeController.clear();
                                accountEnable = false;
                                captcha = '';
                                account = '';
                                isOnclick = 0;
                                second = 60;
                                if (_timer != null) {
                                  _timer.cancel();
                                }
                                Navigator.of(context).pop();
                              });
                            },
                            child: Text(
                              _loginTypeList[1] == 0
                                  ? "Phone Number".tr
                                  : _loginTypeList[1] == 1
                                  ? "Email".tr
                                  : "Password".tr,
                              // style: TextStyle(fontSize: 42.sp),
                            ),
                            // highlightColor: Colors.transparent,
                            // splashColor: Colors.transparent,
                          ),
                        ),
                        const PopupMenuDivider(height: 1.0),
                        PopupMenuItemOverride<String>(
                          value: 'value01',
                          child: FlatButton(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              setState(() {
                                flag = _loginTypeList[2];
                                _loginTypeList[2] = _loginTypeList[0];
                                _loginTypeList[0] = flag;
                                _controller.clear();
                                _codeController.clear();
                                accountEnable = false;
                                captcha = '';
                                account = '';
                                isOnclick = 0;
                                second = 60;
                                if (_timer != null) {
                                  _timer.cancel();
                                }
                                Navigator.of(context).pop();
                              });
                            },
                            child: Text(
                              _loginTypeList[2] == 0
                                  ? "Phone Number".tr
                                  : _loginTypeList[2] == 1
                                  ? "Email".tr
                                  : "Password".tr,
                              // style: TextStyle(fontSize: 42.sp),
                            ),
                            // highlightColor: Colors.transparent,
                            // splashColor: Colors.transparent,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            body: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: 191.w,
                  left: 72.w,
                  child: Text(
                    _loginTypeList[0] == 0
                        ? "registerByPhone".tr
                        : _loginTypeList[0] == 1
                        ? "registerByEmail".tr
                        : "registerByPassword".tr,
                    style: TextStyle(fontSize: 80.sp),
                  ),
                ),
                /**手机号、邮箱号输入框*/
                Positioned(
                  top: 366.w,
                  child: Container(
                    width: 936.w,
                    height: 138.w,
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: _loginTypeList[0] == 0
                            ? "Phone number".tr
                            : _loginTypeList[0] == 1
                            ? "Input Email".tr
                            : "Input Account".tr,
                        hintStyle: TextStyle(
                          fontSize: 42.sp,
                          color: Color.fromRGBO(203, 207, 216, 1),
                        ),
                        // border: InputBorder.none,
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
                        enabled: accountEnable ? false : true,
                        /**地区选择器*/
                        prefixIcon: _loginTypeList[0] == 0
                            ? FlatButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ZoneCodePickerPage()))
                                .then((value) {
                              setState(() {
                                if (value != null) {
                                  SaveData.country =
                                  value.toString().split('+')[0];
                                  SaveData.countryCode =
                                  value.toString().split('+')[1];
                                  // SaveData.countryCode = value;
                                  SharedPreferences.getInstance()
                                      .then((value) {
                                    value.setString('countryCode',
                                        SaveData.countryCode);
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
                        )
                            : null,
                      ),
                      // focusNode: phoneNode,
                      keyboardType: _loginTypeList[0] == 0
                          ? TextInputType.number
                          : TextInputType.emailAddress,
                      cursorColor: Color.fromRGBO(203, 207, 216, 1),
                      inputFormatters: _loginTypeList[0] == 0
                          ? [
                        // FilteringTextInputFormatter.digitsOnly,
                        WhitelistingTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ]
                          : null,
                      //     : _loginTypeList[0] == 1 ? [
                      //   WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[0-9]|[@._-]")),
                      //   LengthLimitingTextInputFormatter(50),
                      // ] : [
                      //   WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[0-9]|[@._-]")),
                      //   LengthLimitingTextInputFormatter(50),
                      // ],
                      onChanged: (str) {
                        setState(() {
                          account = str;
                        });
                        // if(str.length > 11 && _loginTypeList[0] == 0){
                        //   account = str.substring(0,11);
                        // }
                      },
                    ),
                  ),
                ),
                /**验证码、密码输入框*/
                Positioned(
                  top: 570.w,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 578.w,
                        height: 138.w,
                        child: TextField(
                          controller: _codeController,
                          obscureText: _loginTypeList[0] == 2 ? !visible : false,
                          decoration: InputDecoration(
                            hintText: _loginTypeList[0] == 2
                                ? "PassWord".tr
                                : "Verification code".tr,
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
                            // border: InputBorder.none,
                            suffixIcon: _loginTypeList[0] == 2
                                ? Container(
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
                            )
                                : null,
                          ),
                          // focusNode: codeNode,
                          keyboardType: _loginTypeList[0] == 2
                              ? TextInputType.visiblePassword
                              : TextInputType.number,
                          cursorColor: Color.fromRGBO(203, 207, 216, 1),
                          inputFormatters: _loginTypeList[0] != 2
                              ?
                          // [
                          //   WhitelistingTextInputFormatter(RegExp("[\u0021-\u007e]")),
                          //   LengthLimitingTextInputFormatter(16),
                          // ] :
                          [
                            // FilteringTextInputFormatter.digitsOnly,
                            WhitelistingTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ]
                              : null,
                          onChanged: (str) {
                            setState(() {
                              captcha = str;
                              if (str.length > 6 && _loginTypeList[0] != 2) {
                                captcha = str.substring(0, 6);
                              }
                            });
                          },
                        ),
                      ),
                      /**获取验证码按钮*/
                      if (_loginTypeList[0] != 2)
                        Container(
                          width: 358.w,
                          height: 138.w,
                          // alignment: Alignment.centerLeft,
                          child: FlatButton(
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
                                fontSize: 40.sp,
                                color: isOnclick == 0
                                    ? Color.fromRGBO(249, 122, 53, 1)
                                    : Color.fromRGBO(203, 207, 216, 1),
                              ),
                            ),
                            padding: EdgeInsets.zero,
                            splashColor: Colors.transparent,
                            onPressed: isOnclick != 0 || account.length == 0
                                ? null
                                : () {
                              if (_loginTypeList[0] == 0 ||
                                  (_loginTypeList[0] == 1 &&
                                      emailMatcher.hasMatch(account)))
                                _getCaptcha();
                              else if (_loginTypeList[0] == 1 &&
                                  !emailMatcher.hasMatch(account)) {
                                Method.showToast('validEmail'.tr, context,
                                    position: 1);
                              }
                            },
                          ),
                        ),
                      /**忘记密码按钮*/
                      if (_loginTypeList[0] == 2)
                        Container(
                          width: 336.w,
                          height: 138.w,
                          child: FlatButton(
                            padding: EdgeInsets.zero,
                            child: Text(
                              "Forgot password".tr,
                              style: TextStyle(
                                fontSize: 40.sp,
                                color: Color.fromRGBO(249, 122, 53, 1),
                              ),
                            ),
                            splashColor: Colors.transparent,
                            onPressed: () {
                              SaveData.findPwd = true;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TestTypeRoute()));
                            },
                          ),
                        ),
                    ],
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
                      color: _loginTypeList[0] == 0 &&
                          account.length > 0 &&
                          captcha.length > 0
                          ? Color.fromRGBO(249, 122, 53, 1)
                          : _loginTypeList[0] == 1 &&
                          account.length > 0 &&
                          captcha.length > 0
                          ? Color.fromRGBO(249, 122, 53, 1)
                          : _loginTypeList[0] == 2 &&
                          account.length > 0 &&
                          captcha.length > 0
                          ? Color.fromRGBO(249, 122, 53, 1)
                          : Color.fromRGBO(203, 207, 216, 1),
                    ),
                    child: FlatButton(
                      child: Text(
                        _loginTypeList[0] == 2
                            ? "Log in".tr
                            : "Log in/Register".tr,
                        style: TextStyle(
                          fontSize: 42.sp,
                          color: Colors.white,
                        ),
                      ),
                      splashColor: Colors.transparent,
                      highlightColor: Color.fromRGBO(221, 91, 21, 1),
                      onPressed: account.length > 0 && captcha.length > 0
                          ? () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (agree) {
                          _captchaLogin();
                        } else {
                          Method.showToast('agreeToService'.tr, context);
                        }
                      }
                          : null,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(18.sp)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80.w,
                  child: Column(
                    children: [
                      Row(
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
                                  text: 'Enduser Agreement and Privacy Policy'.tr,
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
                        ],
                      ),
                      Text(
                        "Unregistered user will automatically register and sign in after authentication"
                            .tr,
                        textAlign:
                        SaveData.english ? TextAlign.left : TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(145, 148, 160, 1),
                          fontSize: 32.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 1026.w,
                  child: FlatButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    child: Text(
                      "Guest".tr,
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color.fromRGBO(111, 122, 135, 1),
                          fontSize: 36.sp),
                    ),
                    onPressed: _guestLogin,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//发送验证码
  _sendCodeRequest() async {
    if (_loginTypeList[0] == 1) {
      DioUtil()
          .get(RequestUrl.sendMailNumberUrl,
          queryParameters: {
            "mailAddress": account,
            "businessType": "mailLogin"
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
            accountEnable = true;
            _timer = Timer.periodic(Duration(seconds: 1), (timer) {
              setState(() {
                second--;
                if (second == 0) {
                  second = 60;
                  isOnclick = 0;
                  _timer.cancel();
                }
              });
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
    } else if (_loginTypeList[0] == 0) {
      DioUtil()
          .get(RequestUrl.sendPhoneNumberUrl,
          queryParameters: {
            "areaCode": countryCode,
            "phoneNumber": account,
            "businessType": "phoneLogin"
          },
          options: new Options(
            headers: {"app_pass": RequestUrl.appPass},
            sendTimeout: 5000,
            receiveTimeout: 10000,
          ))
          .then((value) {
        // print(value);
        if (value != null) {
          if (value["code"] == "200") {
            accountEnable = true;
            _timer = Timer.periodic(Duration(seconds: 1), (timer) {
              setState(() {
                second--;
                if (second == 0) {
                  second = 60;
                  isOnclick = 0;
                  _timer.cancel();
                }
              });
            });
            if (mounted) {
              setState(() {
                isOnclick = 2;
              });
            }
          } else if (value["code"] == "408") {
            setState(() {
              isOnclick = 0;
              Method.showToast("Invalid number".tr, context, position: 1);
            });
          } else {
            if (mounted) {
              setState(() {
                isOnclick = 0;
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
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Method.showToast('It seems that there is no internet'.tr, context);
    } else {
      Method.showLessLoading(context, 'Loading2'.tr);
      if (_loginTypeList[0] == 1 || _loginTypeList[0] == 0) {
        await DioUtil()
            .post(
            _loginTypeList[0] == 1
                ? RequestUrl.mailLoginUrl
                : RequestUrl.phoneLoginUrl,
            queryParameters: _loginTypeList[0] == 1
                ? {
              "mailAddress": account,
              "code": captcha,
              "businessType": "mailLogin"
            }
                : {
              "areaCode": countryCode,
              "code": captcha,
              "phoneNumber": account,
              "businessType": "phoneLogin"
            },
            options: new Options(
              headers: {"app_pass": RequestUrl.appPass},
              sendTimeout: 5000,
              receiveTimeout: 10000,
            ))
            .then((value) {
          // print(value);
          if (value != null) {
            loginInfo = LoginInfo.fromJson(value);
          } else {
            Navigator.of(context).pop();
            Method.showToast('It seems that there is no internet'.tr, context);
          }
        });
      } else {
        await DioUtil()
            .post(RequestUrl.pwdLoginUrl,
            queryParameters: {
              "bindingAccount": account,
              "password": captcha
            },
            options: Options(
              headers: {"app_pass": RequestUrl.appPass},
              sendTimeout: 5000,
              receiveTimeout: 10000,
            ))
            .then((value) {
          // print(value);
          if (value != null) {
            loginInfo = LoginInfo.fromJson(value);
          } else {
            Navigator.of(context).pop();
            Method.showToast('It seems that there is no internet'.tr, context);
          }
        });
      }
      if (loginInfo != null) {
        if (loginInfo.code == "201") {
          FocusScope.of(context).requestFocus(FocusNode());
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
            // value.setString('tokenRefresh', SaveData.tokenRefresh);
          });
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamedAndRemoveUntil(
                'addUser', (Route<dynamic> route) => false);
          });
        } else if (loginInfo.code == "200") {
          FocusScope.of(context).requestFocus(FocusNode());
          syncUserInfo();
        } else if (loginInfo.code == "401") {
          Navigator.of(context).pop();
          Method.showToast("incorrectIDorPassword".tr, context);
        } else if (loginInfo.code == "402") {
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
          Method.showToast("incorrectIDorPassword".tr, context);
        }
      }
    }
  }

  /* * error统一处理 */
  void formatError(DioError e) {
    Navigator.of(context).pop();
  }

  void syncUserInfo() async {
    // SaveData.loginType = 1;
    SaveData.accessToken = loginInfo.data.token;
    // SaveData.tokenRefresh = DateTime.now().toString();
    SaveData.userId = loginInfo.data.userInfo.id;
    SaveData.username = loginInfo.data.userInfo.nickName;
    SaveData.userBirthday = loginInfo.data.userInfo.birthday;
    SaveData.userHeight = loginInfo.data.userInfo.height.toString();
    SaveData.userWeight = loginInfo.data.userInfo.weight.toString();
    SaveData.setPassword = loginInfo.data.userInfo.hasPsw;
    // print(loginInfo.data.token);
    if (loginInfo.data.userInfo.sex) {
      SaveData.userSex = '男';
    } else {
      SaveData.userSex = '女';
    }
    String httpImageUrl = "https://www.ucfitness.club/api/picture";
    var root = await getApplicationSupportDirectory();
    if (loginInfo.data.userInfo.headImage != null) {
      DioUtil().downLoad(httpImageUrl, root.path + '/userImage.png',
          queryParameters: {"hash": loginInfo.data.userInfo.headImage},
          onReceiveProgress: (received, total) {
            if (total != -1) {
              if (received / total == 1) {
                if (loginInfo.data.userInfo.mailAddress != null) {
                  SaveData.accountList[0] = loginInfo.data.userInfo.mailAddress;
                }
                if (loginInfo.data.userInfo.phoneNumber != null) {
                  SaveData.accountList[1] = loginInfo.data.userInfo.phoneNumber;
                }
                // print(SaveData.accountList);
                SaveData.pictureUrl = root.path + '/userImage.png';
                SharedPreferences.getInstance().then((value) {
                  value.setStringList('accountList', SaveData.accountList);
                  value.setString('pictureUrl', SaveData.pictureUrl);
                });
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    'MyHomePage', (Route<dynamic> route) => false);
              }
              // print((received / total * 100).toStringAsFixed(0) + "%");
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
      if (loginInfo.data.userInfo.mailAddress != null) {
        SaveData.accountList[0] = loginInfo.data.userInfo.mailAddress;
      }
      if (loginInfo.data.userInfo.phoneNumber != null) {
        SaveData.accountList[1] = loginInfo.data.userInfo.phoneNumber;
      }
      Navigator.of(context).pop();
      Navigator.of(context).pushNamedAndRemoveUntil(
          'MyHomePage', (Route<dynamic> route) => false);
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
      value.setStringList('accountList', SaveData.accountList);
      value.setBool('setPassword', SaveData.setPassword);
      value.setString('tokenDateTime', DateTime.now().toString());
    });
  }

  _launchURL() async {
    const url =
        'http://cloud.capstong.com:8081/otaDir/tergasy_privacy_policy.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _guestLogin() {
    SharedPreferences.getInstance().then((value) {
      value.setBool('firstOpenApp', false);
    });
    Navigator.of(context)
        .pushNamedAndRemoveUntil('addUser', (Route<dynamic> route) => false);
  }
}
