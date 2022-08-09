
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil_init.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:my_bluetooth_plugin/my_bluetooth_plugin.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/model/medal.dart';
import 'package:running_app/model/newMedal.dart';
import 'package:running_app/widgets/myCustomDialog.dart';
import 'package:toast/toast.dart';
import 'package:get/get.dart';
import 'package:running_app/widgets/animationMedal.dart';

class Method{

  bool hasNetwork;

  ///吐司
  static void showToast(String text, BuildContext context, {int second = 1, int position = 0}){
    Toast.show(text, context, duration: second, gravity:  position);
  }
  ///无变化的缓冲
  static void showLessLoading(BuildContext context, String str) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ScreenUtilInit(
            designSize: const Size(1080, 1920),
            builder: () => WillPopScope(
              onWillPop: () async {
                if(str == '设备连接中...'){
                  MyBluetoothPlugin.disConnectDevice(SaveData.deviceName);
                  return true;
                }else{
                  return false;
                }

              },
              child: Center(
                child: Container(
                    height: 300.h,
                    width: 300.h,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const RepaintBoundary(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Color.fromRGBO(249, 122, 53, 1)),
                          ),
                        ),
                        const SizedBox(height: 15,),
                        Text(str, style: TextStyle(
                                fontSize: 38.sp,
                                height: 1,
                                color: Colors.white70,
                                decoration: TextDecoration.none))
                      ],
                    )),
              ),
            ),
          );
        });
  }
  ///交互对话框
  static void customDialog(BuildContext context, String title, String content, Function confirm,{Function cancel, bool isCancel = true}){
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return CustomDialog(
          title: title,
          content: content,
          confirmCallback: confirm,
          isCancel: isCancel,
          dismissCallback: cancel,
          confirmColor: Colors.grey.withOpacity(0.5),);
        },
    );
  }
  ///勋章展示对话框
  static void customMedalDialog(BuildContext context, NewMedal medal, double width){
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_){
        return AnimationMedal(medal: medal, itemCount: medal.data.length, width: width,);
      }
    );
  }

  ///检查是否有网络
  static Future<bool> checkNetwork(BuildContext context) async {
    final ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showToast('It seems that there is no internet'.tr, context);
      return false;
    }
    return true;
  }
}