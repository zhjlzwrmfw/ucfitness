import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/saveData.dart';
import '../login/findPwd.dart';
import 'bindingAccount.dart';
import 'package:get/get.dart';

class TestTypeRoute extends StatefulWidget {

  final int isBindAccount;//区分设置密码和绑定账号
  final int bindType;//绑定类型
  final bool isEnglish;

  TestTypeRoute({this.isBindAccount, this.bindType, this.isEnglish = false});

  @override
  _TestTypeRouteState createState() => _TestTypeRouteState();
}

class _TestTypeRouteState extends State<TestTypeRoute> {
  @override
  Widget build(BuildContext context) {
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
              "Choose verification method".tr,
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
                  image: AssetImage('images/找回密码.png'),
                  width: 1080.w,
                  height: 458.w,
                ),
              ),
              if(SaveData.accountList[1].length != 0 || SaveData.findPwd && !widget.isEnglish)
                Positioned(
                  top: 877.w,
                  child: Container(
                    height: 150.w,
                    width: 960.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromRGBO(111,122,135,0.62),width: 2.w,style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(Radius.circular(18.w)),
                      color: Color.fromRGBO(111,122,135,0.3),
                    ),
                    child: FlatButton(
                      child: Text(
                        "Mobile phone number verification".tr,
                        style: TextStyle(
                          fontSize: 42.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      splashColor: Colors.transparent,
                      highlightColor: Color.fromRGBO(111,122,135,0.52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.w)),
                      onPressed: (){
                        if(SaveData.findPwd){
                          SaveData.findPwd = false;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FindPwdRoute(accountType: 1,))).then((value){
                            setState(() {
                              SaveData.findPwd = true;
                            });
                          });
                        }else{
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BindingAccount(bindingType: widget.bindType, checkType: 1, isBindAccount: widget.isBindAccount,)));
                        }
                      },
                    ),
                  ),
                ),
              if(SaveData.accountList[0].length != 0 || SaveData.findPwd)
                Positioned(
                  top: 1063.w,
                  child: Container(
                    height: 150.w,
                    width: 960.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromRGBO(255,104,0,0.45),width: 2.w,style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(Radius.circular(18.w)),
                      color: Color.fromRGBO(255,138,101,0.24),
                    ),
                    child: FlatButton(
                      child: Text(
                        "E-mail verification".tr,
                        style: TextStyle(
                          fontSize: 42.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      splashColor: Colors.transparent,
                      highlightColor: Color.fromRGBO(255,104,101,0.52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.w)),
                      onPressed: (){
                        if(SaveData.findPwd){
                          SaveData.findPwd = false;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FindPwdRoute(accountType: 0,))).then((value){
                            setState(() {
                              SaveData.findPwd = true;
                            });
                          });
                        }else{
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BindingAccount(bindingType: widget.bindType, checkType: 0, isBindAccount: widget.isBindAccount,)));
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
