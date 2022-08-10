import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/fileImageEx.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/model/medal.dart';
import 'package:running_app/model/newMedal.dart';
import 'package:running_app/routes/about/sportSetting.dart';
import 'package:running_app/routes/about/updateUser.dart';
import 'package:running_app/routes/about/userAgreement.dart';
import 'package:running_app/routes/userRoutes/accountSecurity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import '../login/userEnLogin.dart';
import '../login/userLogin.dart';
import 'package:get/get.dart';
import 'package:running_app/routes/about/medal.dart';
import 'dart:convert';

class AboutPage extends StatefulWidget {
  @override
  AboutPageState createState() => AboutPageState();

}

class AboutPageState extends State<AboutPage> {
  final picker = ImagePicker();
  static File image; //相片
  int lightVersionInt = 106;
  Map _map;
  NewMedal newMedal;

  @override
  void initState() {
    super.initState();
    print(SaveData.userId);
    print(SaveData.accessToken);
    SharedPreferences.getInstance().then((value) {
      if (value.getStringList('accountList') != null) {
        SaveData.accountList = value.getStringList('accountList');
        print(SaveData.accountList);
      }
    });
  }

  List<String> meLeadingList = [];

  @override
  Widget build(BuildContext context) {
    meLeadingList = ['medal'.tr, 'Profile'.tr, 'Settings'.tr, 'Version'.tr, 'Enduser Agreement and Privacy Policy'.tr, 'Account amd security'.tr];
    return ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => Material(
          color: Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: Container(
                    width: 540.w,
                    height: 186.h,
                    color: const Color.fromRGBO(249, 122, 53, 1),
                  ),
                ),
                Positioned(
                  right: 30.w,
                  top: 146.h,
                  child: Container(
                    width: 100.h,
                    height: 100.h,
                    // color: Colors.yellow,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        color: Colors.white),
                    child: FlatButton(
                      padding: EdgeInsets.all(5.5),
                      child: SaveData.pictureUrl == null
                          ? Image.asset(
                        "images/home_user.png",
                      )
                          : ClipOval(
                        child: Image(
                          image: FileImageEx(File(SaveData.pictureUrl)),
                        ),
                      ),
                      onPressed: _getPictureBottomSheet,
                      highlightColor: Color.fromRGBO(255, 255, 255, 0),
                      splashColor: Color.fromRGBO(255, 255, 255, 0),
                    ),
                  ),
                ),
                Positioned(
                  top: 84.h,
                  left: 36.w,
                  child: Text(
                    'Welcome back'.tr,
                    style: TextStyle(
                        fontSize: 18.sp, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 108.h,
                  left: 36.w,
                  child: Text(
                    'me'.tr,
                    style: TextStyle(
                        fontSize: 30.sp, color: Colors.white),
                  ),
                ),
                Positioned(
                    top: 218.h,
                    left: 36.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          SaveData.userId == null ? 'unloggedIn'.tr : SaveData.username,
                          style: TextStyle(
                              fontSize: 30.sp,
                              color: Color.fromRGBO(38, 45, 68, 1)),
                        ),
                        if (SaveData.userId == null)
                          FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            padding: EdgeInsets.all(0),
                            child: Text(
                              "Log in/Register".tr,
                              style: TextStyle(
                                  fontSize: 21.sp,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(249, 122, 53, 1)),
                            ),
                            onPressed: () {
                              if(SaveData.english){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        settings: RouteSettings(name: "userEnLoginRoute"),
                                        builder: (context) => UserEnLoginRoute())).then((value) {
                                  setState(() {
                                    getNewMedal();
                                  });
                                });
                              }else{
                                Navigator.push(context, MaterialPageRoute(
                                        settings: RouteSettings(name: "userLogin"),
                                        builder: (context) =>
                                            UserLoginRoute())).then((value) {
                                  setState(() {
                                    getNewMedal();
                                  });
                                });
                              }
                            },
                          )
                      ],
                    )),
                Positioned(
                    top: 291.h,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          for(int i = 0; i < meLeadingList.length; i++)
                            if(SaveData.userId != null || (meLeadingList[i] != 'medal'.tr && meLeadingList[i] != 'Account amd security'.tr))
                            meInfoBuild(i),
                        ],
                      ),
                    ),
                ),
              ],
            ),
          )),
    );
  }

  Widget meInfoBuild(int index){
    return Container(
      width: 540.w,
      height: 60.h,
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        splashColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(left: 36.w),
              child: Row(
                children: <Widget>[
                  Text(
                    meLeadingList[index],
                    style:
                    TextStyle(fontSize: 21.sp),
                  ),
                  if(SaveData.hasNewMedal && meLeadingList[index] == 'medal'.tr)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 7),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
            if(meLeadingList[index] != 'Version'.tr)
            Container(
              padding: EdgeInsets.only(right: 31.w),
              child: Image(
                image: const AssetImage('images/next.png'),
                width: 15.w,
                height: 21.w,
              ),
            ),
            if(meLeadingList[index] == 'Version'.tr)
              Container(
                padding:
                EdgeInsets.only(right: 31.w),
                child: Text(
                  'V1.3.2',
                  style: TextStyle(fontSize: 21.sp),
                ),
              ),
          ],
        ),
        onTap: () {
          whichRoute(meLeadingList[index]);
        },
      ),
    );
  }

  void whichRoute(String route){
    if(route == 'medal'.tr){
      Navigator.push<Object>(context, MaterialPageRoute(
        builder: (BuildContext context) => const MedalPage(),)).then((value){
          setState(() {
            if(MedalPageState.hasReadMedal.contains(false)){
              SaveData.hasNewMedal = true;
            }else{
              SaveData.hasNewMedal = false;
            }
          });
      });
    }else if(route == 'Profile'.tr){
      Navigator.push<Object>(
        context,
        MaterialPageRoute(
            builder: (context) => UpdateUserPage()),).then((value) {
        setState(() {
          if (SaveData.userId != null) {
            _httpUpdateUserInfo();
          }
        });
      });
    }else if(route == 'Settings'.tr){
      Navigator.push<Object>(context, MaterialPageRoute(
          builder: (BuildContext context) => SportSettingPage()),);
    }else if(route == 'Enduser Agreement and Privacy Policy'.tr){
      Navigator.push<Object>(context, MaterialPageRoute(
        builder: (BuildContext context) => UserAgreementPage(),));
    }else if(route == 'Account amd security'.tr){
      Navigator.push<Object>(
          context,
          MaterialPageRoute(
              settings:
              const RouteSettings(name: 'accountSecurity'),
              builder: (BuildContext context) {
                return AccountSecurityRoute();
              })).then((value) {
        setState(() {});
      });
    }
  }

  void getNewMedal(){
    DioUtil().get(
      RequestUrl.getMedalNewUrl,
      queryParameters: <String, Object>{'lang': SaveData.english ? 'en' : 'zh', 'userId': SaveData.userId},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass':RequestUrl.appPass}),
    ).then((value){
      print(value);
      newMedal = NewMedal.fromJson(value);
      if(value != null && newMedal.code == '200'){
        if(newMedal.data.isNotEmpty){
          SaveData.hasNewMedal = true;
        }
      }
    });
  }

  void _httpUpdateUserInfo() async {
    _map = <String, Object>{
      'birthday': SaveData.userBirthday,
      'height': int.parse(SaveData.userHeight),
      'id': SaveData.userId,
      'nickName': SaveData.username,
      'sex': SaveData.userSex == '男' ,
      'weight': int.parse(SaveData.userWeight)
    };
    DioUtil()
        .put(RequestUrl.getUserInfoUrl,
        data: _map,
        options: Options(
          headers: <String, Object>{
            'app_pass': RequestUrl.appPass,
            'access_token': SaveData.accessToken
          },
          sendTimeout: 5000,
          receiveTimeout: 10000,
        ))
        .then((value) {
      print(value);
      if (value['code'] == '200') {
        print('用户信息修改成功，返回200');
        SharedPreferences.getInstance().then((value) {
          value.setString('userBirthday', _map["birthday"]);
          value.setString('userHeight', _map["height"].toString());
          value.setString('userWeight', _map["weight"].toString());
          value.setString('username', _map["nickName"]);
          value.setString('userSex', _map["sex"] ? '男' : '女');
        });
      } else {
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }
  //使用相片
  void _getPictureBottomSheet() {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        builder: (BuildContext context) {
          return ScreenUtilInit(
            designSize: const Size(360, 640),
            builder: () => Material(
              child: Container(
                  width: 360.w,
                  height: 221.h,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 25.h,
                        left: 24.w,
                        child: Container(
                          width: 312.w,
                          height: 55.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              color: Color.fromRGBO(255, 189, 153, 1),
                              border: Border.all(
                                  color: Color.fromRGBO(255, 104, 0, 0.45),
                                  width: 1.w)),
                          child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Text('Take photo'.tr),
                            onPressed: _takePhoto,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 94.h,
                        left: 24.w,
                        child: Container(
                          width: 312.w,
                          height: 55.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              color: Color.fromRGBO(111, 122, 135, 0.3),
                              border: Border.all(
                                  color: Color.fromRGBO(111, 122, 135, 0.62),
                                  width: 1.w)),
                          child: FlatButton(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            child: Text('Select image'.tr),
                            onPressed: _openGallery,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 18.h,
                        left: 140.w,
                        child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Text('Cancel'.tr),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  )),
            ),
          );
        });
  }
  //拍照
  Future<void> _takePhoto() async {
    Navigator.of(context).pop();
    SaveData.chosePhotograph = true;
    await picker.getImage(source: ImageSource.camera).then((value) {
      image = File(value.path);
      cropImage(image);
    });
  }
  //相册
  Future<void> _openGallery() async {
    Navigator.of(context).pop();
    SaveData.chosePhotograph = false;
    await picker.getImage(source: ImageSource.gallery).then((value) {
      image = File(value.path);
      cropImage(image);
    });
  }

  void cropImage(File originalImage) async {
    await Navigator.push<Object>(
        context,
        MaterialPageRoute(
            builder: (context) => CropImageRoute(originalImage))).then((value) {
      setState(() {});
    });
  }
}

class CropImageRoute extends StatefulWidget {
  CropImageRoute(this.image);

  File image; //原始图片路径
  @override
  _CropImageRouteState createState() => _CropImageRouteState();
}

class _CropImageRouteState extends State<CropImageRoute> {
  final GlobalKey<CropState> cropKey = GlobalKey<CropState>();
  final String getUserImageUrl = 'https://www.ucfitness.club/api/user/headImg';

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      builder: () => Scaffold(
          body: Container(
            height: 640.h,
            width: 360.w,
            color: Colors.black,
            child: Column(
              children: <Widget>[
                SizedBox(height: 150.h),
                Container(
                  height: 360.w,
                  width: 360.w,
                  child: Crop.file(
                    widget.image,
                    key: cropKey,
                    aspectRatio: 1,
                    alwaysShowGrid: false,
                  ),
                ),
                SizedBox(
                  height: 24.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        'Cancel'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text(
                        'OK2'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        _crop(widget.image);
                      },
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }

  void updateUserImage() async {
    Method.showLessLoading(context, 'Loading2'.tr);
    FormData formData = FormData.fromMap({
      "newHeadImg": await MultipartFile.fromFile(SaveData.pictureUrl,
          filename: "userImage.png"),
      "userId ": SaveData.userId
    });
    DioUtil()
        .put(getUserImageUrl,
        data: formData,
        options: new Options(
          headers: {
            "app_pass": RequestUrl.appPass,
            'access_token': SaveData.accessToken
          },
          sendTimeout: 5000,
          receiveTimeout: 10000,
        )).then((value) {
      if(value != null){
        if (value["code"] == "200") {
          Navigator.of(context).pop();
          Method.showToast("success".tr, context);
          Future.delayed(Duration(seconds: 1), () {
            print(('我是最后的'));
            Navigator.of(context).pop();
          });
        } else {
          Navigator.of(context).pop();
          Method.showToast('It seems that there is no internet'.tr, context);
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });
        }
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _crop(File originalFile) async {
    final crop = cropKey.currentState;
    final area = crop.area;
    if (area == null) {
      //裁剪结果为空
      print('裁剪不成功');
    }
    if (SaveData.chosePhotograph) {
      await ImageCrop.requestPermissions().then((value) {
        ImageCrop.cropImage(file: originalFile, area: crop.area).then((value) {
          AboutPageState.image = value;
          SaveData.pictureUrl = File(AboutPageState.image.path).path;
          _savePictureName();
          if (SaveData.userId != null) {
            updateUserImage();
          } else {
            Navigator.of(context).pop();
          }
        });
      });
    } else {
      ImageCrop.cropImage(file: originalFile, area: crop.area).then((value) {
        AboutPageState.image = value;
        SaveData.pictureUrl = File(AboutPageState.image.path).path;
        _savePictureName();
        if (SaveData.userId != null) {
          updateUserImage();
        } else {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _savePictureName() async {
    var root = await getApplicationSupportDirectory();
    File file = new File(SaveData.pictureUrl);
    SaveData.pictureUrl = root.path + '/userImage.png';
    file.copy(SaveData.pictureUrl);
    SharedPreferences.getInstance().then((value){
      value.setString('pictureUrl', SaveData.pictureUrl);
    });
  }
}
