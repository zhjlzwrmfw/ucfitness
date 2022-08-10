import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_drag_scale/core/drag_scale_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';

class UserPicturePage extends StatefulWidget{

  final String userPicture;

  UserPicturePage(this.userPicture);

  @override
  UserPicturePageState createState() => UserPicturePageState();

}
class UserPicturePageState extends State<UserPicturePage>{
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => Material(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              child: Container(
                // width: ScreenUtil().setWidth(540),
                // height: ScreenUtil().setHeight(540),
                child: Center(
                  child: widget.userPicture == null ? Image.asset('images/home_user.png')
                      : Image.file(File(widget.userPicture)),
                ),
              ),
            ),
            Positioned(
              left: 1.w,
              top: 70.h,
              child: FlatButton(
                padding: EdgeInsets.all(0),
                child: Icon(Icons.arrow_back_ios,size: 24.w,color: Colors.white,),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        )
      ),
    );
  }

}