import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/saveData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UpdateUserNamePage extends StatefulWidget {
  @override
  _UpdateUserNamePageState createState() => _UpdateUserNamePageState();
}

class _UpdateUserNamePageState extends State<UpdateUserNamePage> {
  TextEditingController _controller = new TextEditingController();
  String username;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Modify nick name'.tr,
              style: TextStyle(
                  fontSize: 21.sp, color: Colors.white),
            ),
            titleSpacing: 4,
            elevation: 0,
            centerTitle: true,
            leading: FlatButton(
              splashColor: Colors.transparent,
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 21.w,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            backgroundColor: Color.fromRGBO(249, 122, 53, 1),
            actions: <Widget>[
              FlatButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Text(
                  "Save".tr,
                  style: TextStyle(
                    fontSize: 21.sp, color: Colors.white, fontWeight: FontWeight.normal,),
                ),
                onPressed: () {
                  // print(username);
                  if(username == null || username.isEmpty){
                    SaveData.username = 'Username';
                    Method.showToast("success".tr, context, position: 1);
                    SharedPreferences.getInstance().then((value) {
                      value.setString("username", SaveData.username);
                    });
                  }else{
                    SaveData.username = username;
                    Method.showToast("success".tr, context, position: 1);
                    SharedPreferences.getInstance().then((value) {
                      value.setString("username", username);
                    });
                  }
                },
              )
            ],
          ),
          body: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 28.w),
                child: Container(
                  width: 488.w,
                  height: 75.h,
                  child: TextField(
                    controller: _controller,
                    cursorColor: Color.fromRGBO(249, 122, 53, 1),
                    decoration: InputDecoration(
                      hintText: 'Input nickname'.tr,
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
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          'images/quxiao.png',
                          width: 36.w,
                          height: 36.w,
                        ),
                        onPressed: () {
                          _controller.clear();
                        },
                      ),
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(10)],
                    onChanged: (str) {
                      username = str;
                      // print('length:${str.length}');
                      if (str.length > 10) {
                        username = str.substring(0, 10);
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
