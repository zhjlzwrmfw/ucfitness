import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/model/medal.dart';
import 'package:get/get.dart';

class MedalDetailPage extends StatefulWidget {

  final Medals medals;

  MedalDetailPage({Key key, this.medals}) : super(key: key);

  @override
  _MedalDetailPageState createState() => _MedalDetailPageState();
}

class _MedalDetailPageState extends State<MedalDetailPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => Scaffold(
        appBar: AppBar(
          title: Text('Medal Details'.tr, style: TextStyle(fontSize: 48.sp),),
          centerTitle: false,
          backgroundColor: const Color.fromRGBO(249, 122, 53, 1),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 540.w,
                height: 540.w,
                child: CachedNetworkImage(
                  imageUrl: RequestUrl.getUserPictureUrl + widget.medals.image,
                  fit: BoxFit.fill,
                  httpHeaders: {'app_pass': RequestUrl.appPass},
                  color: widget.medals.have ? const Color.fromRGBO(249, 122, 53, 1) : const Color.fromRGBO(201, 202, 202, 1),
                ),
              ),
              SizedBox(
                height: 295.h,
              ),
              Text(
                widget.medals.name,
                style: TextStyle(fontSize: 60.sp, color: const Color.fromRGBO(67, 84, 91, 1)),
              ),
              SizedBox(
                height: 30.h,
              ),
              Text(
                widget.medals.describe,
                style: TextStyle(fontSize: 40.sp, color: const Color.fromRGBO(67, 84, 91, 1)),
              ),
              SizedBox(
                height: 135.h,
              ),
              Text(
                widget.medals.have ? 'completion'.tr : 'incomplete'.tr,
                style: TextStyle(fontSize: 36.sp, color: const Color.fromRGBO(67, 84, 91, 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
