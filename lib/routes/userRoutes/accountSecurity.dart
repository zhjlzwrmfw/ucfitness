import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/routes/realTimeSport/home.dart';
import 'package:running_app/routes/userRoutes/testType.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class AccountSecurityRoute extends StatefulWidget {
  @override
  _AccountSecurityRouteState createState() => _AccountSecurityRouteState();
}

class _AccountSecurityRouteState extends State<AccountSecurityRoute> {

  List<String> accountLeadingList = [
    '手机绑定', '邮箱绑定', '设置密码',
  ];
  List<String> accountTrailingList = [
    '更改', '更改', '设置'
  ];
  List<String> subTitleList = [
    '未绑定', '未绑定', '未设置'
  ];
  // List<String> thirdLeadingList = [
  //   '绑定微信', '绑定QQ', '绑定微博',
  // ];
  // List<String> thirdTrailingList = [
  //   '未绑定', '未绑定', '未绑定'
  // ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    accountLeadingList = [
      "Link phone number".tr,
      "Link email".tr,
      "Change password".tr
    ];
    accountTrailingList = [
      SaveData.accountList[1].length != 0 ? "Change".tr : "Link".tr,
      SaveData.accountList[0].length != 0 ? "Change".tr : "Link".tr,
      SaveData.setPassword ? "Change".tr : "setting".tr,

    ];
    subTitleList = [
      SaveData.accountList[1].length != 0 ? SaveData.accountList[1].replaceRange(3, 7, '****') : "None".tr,
      SaveData.accountList[0].length != 0 ? SaveData.accountList[0].replaceRange(3, SaveData.accountList[0].indexOf('@'), '*' * (SaveData.accountList[0].indexOf('@') - 3))
          : "None".tr,
      SaveData.setPassword ? "seted".tr : "notSet".tr,
    ];
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => Material(
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
              "Account amd security".tr,
              style: TextStyle(
                  fontSize: 42.sp, fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            physics:NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                width: 1080.w,
                height: 147.w,
                padding: EdgeInsets.fromLTRB(72.w, 54.w, 0, 0),
                child: Text(
                  'Account amd security'.tr,
                  style: TextStyle(
                      fontSize: 42.sp,
                      color: Color.fromRGBO(203, 207, 216, 1)),
                ),
              ),
              Container(
                width: 1080.w,
                height: 190.w,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          68.w,
                          43.w,
                          32.w,
                          0),
                      child: Image(
                        image: AssetImage('images/account_phone.png'),
                        width: 42.w,
                        height: 42.w,
                      ),
                    ),
                    Container(
                      width: 666.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0,
                                32.w,
                                0,
                                4.w),
                            child: Text(
                              accountLeadingList[0],
                              style:
                              TextStyle(fontSize: 42.sp),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Text(
                              subTitleList[0],
                              style: TextStyle(
                                  fontSize: 42.sp,
                                  color: Color.fromRGBO(203, 207, 216, 1)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 49.w),
                      child: Container(
                        width: 200.w,
                        height: 92.w,
                        decoration: BoxDecoration(
                          color: subTitleList[0] == "None".tr ? Color.fromRGBO(111, 122, 135, 1) : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(111, 122, 135, 1),
                              width: 3.w,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.all(
                              Radius.circular(12.w)),
                        ),
                        child: FlatButton(
                          padding: EdgeInsets.zero,
                          child: Text(
                            accountTrailingList[0],
                            style: TextStyle(
                                fontSize: 42.sp,
                                fontWeight: FontWeight.normal,
                                color: subTitleList[0] == "None".tr ? Colors.white : Color.fromRGBO(111, 122, 135, 1)),
                          ),
                          onPressed: () {
                            SaveData.findPwd = false;
                            SaveData.businessType = 'phone';
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return TestTypeRoute(isBindAccount: 0, bindType: 1);
                            })).then((value){
                              setState(() {
                                _setCallBack();
                              });
                            });
                          },
                          splashColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1080.w,
                height: 190.w,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          68.w,
                          43.w,
                          32.w,
                          0),
                      child: Image(
                        image: AssetImage('images/account_mail.png'),
                        width: 42.w,
                        height: 42.w,
                      ),
                    ),
                    Container(
                      width: 666.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0,
                                32.w,
                                0,
                                4.w),
                            child: Text(
                              accountLeadingList[1],
                              style:
                              TextStyle(fontSize: 42.sp),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Text(
                              subTitleList[1],
                              style: TextStyle(
                                  fontSize: 42.sp,
                                  color: Color.fromRGBO(203, 207, 216, 1)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 49.w),
                      child: Container(
                        width: 200.w,
                        height: 92.w,
                        decoration: BoxDecoration(
                          color: subTitleList[1] == "None".tr ? Color.fromRGBO(111, 122, 135, 1) : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(111, 122, 135, 1),
                              width: 3.w,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.all(
                              Radius.circular(12.w)),
                        ),
                        child: FlatButton(
                          padding: EdgeInsets.zero,
                          child: Text(
                            accountTrailingList[1],
                            style: TextStyle(
                                fontSize: 42.sp,
                                fontWeight: FontWeight.normal,
                                color: subTitleList[1] == "None".tr ? Colors.white : Color.fromRGBO(111, 122, 135, 1)),
                          ),
                          onPressed: () {
                            SaveData.findPwd = false;
                            SaveData.businessType = 'email';
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return TestTypeRoute(isBindAccount: 0, bindType: 0,);
                            })).then((value){
                              setState(() {
                                _setCallBack();
                              });
                            });
                          },
                          splashColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1080.w,
                height: 190.w,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          68.w,
                          43.w,
                          32.w,
                          0),
                      child: Image(
                        image: AssetImage('images/account_password.png'),
                        width: 42.w,
                        height: 42.w,
                      ),
                    ),
                    Container(
                      width: 666.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0,
                                32.w,
                                0,
                                4.w),
                            child: Text(
                              accountLeadingList[2],
                              style:
                              TextStyle(fontSize: 42.sp),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Text(
                              subTitleList[2],
                              style: TextStyle(
                                  fontSize: 42.sp,
                                  color: Color.fromRGBO(203, 207, 216, 1)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 49.w),
                      child: Container(
                        width: 200.w,
                        height: 92.w,
                        decoration: BoxDecoration(
                          color: subTitleList[2] == "notSet".tr ? Color.fromRGBO(111, 122, 135, 1) : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(111, 122, 135, 1),
                              width: 3.w,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.all(
                              Radius.circular(12.w)),
                        ),
                        child: FlatButton(
                          padding: EdgeInsets.zero,
                          child: Text(
                            accountTrailingList[2],
                            style: TextStyle(
                                fontSize: 42.sp,
                                fontWeight: FontWeight.normal,
                                color: subTitleList[2] == "notSet".tr ? Colors.white : Color.fromRGBO(111, 122, 135, 1)),
                          ),
                          onPressed: () {
                            SaveData.findPwd = false;
                            SaveData.businessType = 'setPwd';
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return TestTypeRoute(isBindAccount: 1);
                            })).then((value){
                              setState(() {
                                _setCallBack();
                              });
                            });
                          },
                          splashColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1080.w,
                height: 32.w,
                color: Color.fromRGBO(244, 245, 247, 1),
              ),
              Container(
                width: 1080.w,
                height: 120.w,
                child: FlatButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 68.w,
                          right: 32.w,
                        ),
                        child: Image(
                          image: AssetImage('images/account_user.png'),
                          width: 42.w,
                          height: 42.w,
                        ),
                      ),
                      Container(
                        width: 843.w,
                        child: Text(
                          "Delete account".tr,
                          style: TextStyle(fontWeight: FontWeight.normal,fontSize: 42.sp),
                        ),
                      ),
                      // Image(
                      //   image: AssetImage('images/next.png'),
                      //   width: ScreenUtil().setWidth(30),
                      //   height: 42.w,
                      // ),
                    ],
                  ),
                  onPressed: () {
                    Method.customDialog(
                        context,
                        "Delete account".tr,
                        "logoutTips".tr,
                        _confirm);
                  },
                  padding: EdgeInsets.all(0),
                  splashColor: Colors.transparent,
                  highlightColor: Color.fromRGBO(245, 246, 248,1),
                ),
              ),
              Container(
                width: 1080.w,
                height: 120.w,
                child: FlatButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 68.w,
                          right: 32.w,
                        ),
                        child: Image(
                          image: AssetImage('images/account_exit.png'),
                          width: 42.w,
                          height: 42.w,
                        ),
                      ),
                      Container(
                        width: 843.w,
                        child: Text(
                          "LOG OUT".tr,
                          style: TextStyle(fontWeight: FontWeight.normal,fontSize: 42.sp,color: Color.fromRGBO(249, 122, 53, 1)),
                        ),
                      ),
                      // Image(
                      //   image: AssetImage('images/next.png'),
                      //   width: ScreenUtil().setWidth(30),
                      //   height: 42.w,
                      // ),
                    ],
                  ),
                  onPressed: (){
                    Method.customDialog(context, "LOG OUT".tr, "signOutTips".tr, _signOutCallBack);
                  },
                  padding: EdgeInsets.all(0),
                  splashColor: Colors.transparent,
                  highlightColor: Color.fromRGBO(245, 246, 248,1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signOutCallBack(){
    _signOut();
  }

  void _setCallBack(){
    accountTrailingList = [
      SaveData.accountList[1].length != 0 ? "Change".tr : "Link".tr,
      SaveData.accountList[0].length != 0 ? "Change".tr : "Link".tr,
      SaveData.setPassword ? "Change".tr : "setting".tr,
    ];
    subTitleList = [
      SaveData.accountList[1].length != 0 ? SaveData.accountList[1].replaceRange(3, 7, '****') : "None".tr,
      SaveData.accountList[0].length != 0 ? SaveData.accountList[0].replaceRange(3, SaveData.accountList[0].indexOf('@'), '*' * (SaveData.accountList[0].indexOf('@') - 3))
          : "None".tr,
      SaveData.setPassword ? "seted".tr : "notSet".tr,
    ];
  }

  void _signOut() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Method.showToast('It seems that there is no internet'.tr, context);
    } else {
      Method.showLessLoading(context, '');
      DioUtil().get(
          RequestUrl.signOutUrl,
          options: Options(headers: {'access_token': SaveData.accessToken, "app_pass": RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
      ).then((value){
        // print(value);
        if(value['code'] == '200'){
          Navigator.of(context).pop();
          SaveData.changeState = true;
          SaveData.onclickPage.clear();
          SaveData.changeState = true;
          SaveData.onclickPage.clear();
          HomePageState.hasPicture = false;
          SaveData.userId = null;
          SaveData.pictureUrl = null;
          // SaveData.username = '取个名字吧';
          SaveData.userBirthday = '2000-01-01';
          SaveData.userHeight = '180';
          SaveData.userWeight = '70';
          SaveData.userSex = '男';
          SaveData.username = 'Username';
          SharedPreferences.getInstance().then((value){
            value.setInt('userId', null);
            value.setString('pictureUrl', SaveData.pictureUrl);
            value.setString('userBirthday', SaveData.userBirthday);
            value.setString('userHeight', SaveData.userHeight);
            value.setString('userWeight', SaveData.userWeight);
            value.setString('username', SaveData.username);
            value.setString('userSex', SaveData.userSex);
            value.setStringList('sportData', null);
          }).then((value){
            Navigator.of(context).pop();
          });
        }else{
          Navigator.of(context).pop();
          Method.showToast('It seems that there is no internet'.tr, context);
        }
      });
    }
  }

  void _confirm(){
    SaveData.businessType = 'signOut';
    SaveData.findPwd = false;
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return TestTypeRoute(isBindAccount: 2);
    })).then((value){
      setState(() {});
    });
  }

}

