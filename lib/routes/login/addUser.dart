import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_crop/image_crop.dart';
import '../../main.dart';
import 'package:get/get.dart';

class AddUserPage extends StatefulWidget{

  @override
  AddUserPageState createState() => AddUserPageState();

}

class AddUserPageState extends State<AddUserPage> with SingleTickerProviderStateMixin{
  int sex  = 2;//性别选择,1女，2男
  final picker = ImagePicker();
  // AnimationController _animationController;
  // Animation _colorAnimation;
  String userBirthday = '2000-01-01';
  String userHeight = '180';
  String userWeight = '70';
  static File image;//相片
  String username = 'Username';

  FocusNode userFocusNode = FocusNode();//用于点击屏幕任意位置隐藏键盘

  Map<String, Object> map = new Map();//存放用户信息的map

  String nameTips = '给自己取个名字吧...';//用户输入名提示

  FixedExtentScrollController scrollController;
  FixedExtentScrollController scrollController1;


  @override
  void initState(){
    super.initState();
    map["birthday"] = SaveData.userBirthday;
    map["nickName"] = username;
    map["weight"] = userWeight;
    map["height"] = userHeight;
    map["sex"] = true;
    map['id'] = SaveData.userId;
    scrollController = FixedExtentScrollController(initialItem: 80);
    scrollController1 = FixedExtentScrollController(initialItem: 40);
  }

  @override
  void dispose() {
    // _animationController.dispose();
    super.dispose();
    scrollController.dispose();
    scrollController1.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => WillPopScope(
          onWillPop: () async {
            _defaultUserInfo();
            return true;
          },
          child: Material(
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: 1.h,
                      child: Container(
                        width: 540.w,
                        height: 960.h,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            //点击空白关闭软键盘
                            FocusScope.of(context).requestFocus(FocusNode());
                            SaveData.username = username;
                            map["nickName"] = username;
                            if(username.isEmpty || username == '取个名字吧'){
                              setState(() {
                                nameTips = '给自己取个名字吧...';
                              });
                            }
                          },
                          child: Scrollbar(
                            child: ListView(
                              padding: EdgeInsets.only(top: 55.h),
                              addRepaintBoundaries: false,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    FlatButton(
                                      child: Image.asset("images/close.png",width: 36.w,height: 36.h,),
                                      onPressed: _defaultUserInfo,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h,),
                                Center(
                                  child: Text(
                                    'Improve personal information'.tr,
                                    style: TextStyle(fontSize: 30.sp,color: Color.fromRGBO(38, 45, 68, 1)),
                                  ),
                                ),
                                SizedBox(height: 10.h,),
                                Center(
                                  child: Text(
                                    'Improving information make sports data more accurate'.tr,
                                    style: TextStyle(fontSize: 21.sp,color: Color.fromRGBO(145, 148, 160, 1)),
                                  ),
                                ),
                                SizedBox(height: 50.33.h,),
                                Center(
                                  child: ClipOval(
                                    child: FlatButton(
                                      child: SaveData.pictureUrl == null ? Image.asset("images/user.png",width: 150.w,height: 150.h,)
                                          : Image.file(File(SaveData.pictureUrl),width: 150.w,height: 150.w),
                                      onPressed: _getPictureBottomSheet,
                                      padding: EdgeInsets.all(0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 86.h,),
                                Container(
                                  margin: EdgeInsets.only(left: 50.w,right: 50.w),
                                  // height: ScreenUtil().setHeight(70),
                                  child: TextField(
                                    maxLength: 10,
                                    focusNode: userFocusNode,
                                    textInputAction: TextInputAction.done,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        hintText: 'Nick name'.tr,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        )
                                    ),
                                    onChanged: (str){
                                      username = str;
                                    },
                                    onEditingComplete: (){
                                      if(username.length != 0){
                                        map["nickName"] = username;
                                        SaveData.username = username;
                                      }else{
                                        SaveData.username = 'Username';
                                      }
                                      FocusScope.of(context).requestFocus(FocusNode());
                                    },
                                    onTap: (){
                                      setState(() {
                                        nameTips = '';
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 100.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        FlatButton(
                                          child: Image.asset("images/user_female.png",width: 150.w,height: 150.h,),
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onPressed: (){
                                            setState(() {
                                              sex = 1;
                                              SaveData.userSex = '女';
                                              map["sex"] = false;
                                            });
                                          },
                                        ),
                                        Radio(
                                          value: 1,
                                          groupValue: sex,
                                          // focusColor: Color.fromRGBO(47, 117, 220, 1),
                                          activeColor: Color.fromRGBO(255, 107, 191, 1),
                                          onChanged: (int value){
                                            setState(() {
                                              sex = value;
                                              if(sex == 1){
                                                SaveData.userSex = '女';
                                              }
                                              map["sex"] = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        FlatButton(
                                          child: Image.asset("images/user_male.png",width: 150.w,height: 150.h,),
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onPressed: (){
                                            setState(() {
                                              sex = 2;
                                              SaveData.userSex = '男';
                                              map["sex"] = true;
                                            });
                                          },
                                        ),
                                        Radio(
                                          value: 2,
                                          activeColor: Color.fromRGBO(47, 117, 220, 1),
                                          groupValue: sex,
                                          onChanged: (int value){
                                            setState(() {
                                              sex = value;
                                              if(sex == 2){
                                                SaveData.userSex = '男';
                                              }
                                              map["sex"] = true;
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 50.h,
                                ),
                                Container(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text('Date of birth'.tr,style: TextStyle(color: Color.fromRGBO(145, 148, 160, 1)),),
                                    trailing: Text(SaveData.userBirthday),
                                    onTap: () async {
                                      var _dateTime = DateTime.parse(SaveData.userBirthday);
                                      final CupertinoDatePicker picker = CupertinoDatePicker(
                                        initialDateTime: _dateTime,
                                        mode: CupertinoDatePickerMode.date,
                                        minimumYear: 1920,
                                        maximumDate: DateTime.now().subtract(Duration(days: 1)),
                                        onDateTimeChanged: (DateTime date) {
                                          _dateTime = date;
                                        },
                                      );
                                      showCupertinoModalPopup<void>(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              height: 200,
                                              color: Colors.white,
                                              child: picker,
                                            );
                                          }).then((value) {
                                        setState(() {
                                          print('object');
                                          SaveData.userBirthday = _dateTime.toString().substring(0, 10);
                                          map["birthday"] = SaveData.userBirthday;
                                        });
                                        SharedPreferences.getInstance().then((value) {
                                          value.setString("userBirthday", SaveData.userBirthday);
                                        });
                                      });
                                    },
                                  ),
                                  margin: EdgeInsets.only(left: 66.w,right: 62.w),
                                ),
                                Divider(height: 1,indent: 66.w,endIndent: 62.w,),
                                Container(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text('Height'.tr,style: TextStyle(color: Color.fromRGBO(145, 148, 160, 1)),),
                                    trailing: Text(SaveData.userHeight + 'cm'),
                                    onTap: _getHeight,
                                  ),
                                  margin: EdgeInsets.only(left: 66.w,right: 62.w),
                                ),
                                Divider(height: 1,indent: 66.w,endIndent: 62.w,),
                                Container(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text('Weight'.tr,style: TextStyle(color: Color.fromRGBO(145, 148, 160, 1)),),
                                    trailing: Text(SaveData.userWeight + 'kg'),
                                    onTap: _getWeight,
                                  ),
                                  margin: EdgeInsets.only(left: 66.w,right: 62.w),
                                ),
                                Divider(height: 1,indent: 66.w,endIndent: 62.w,),
                                SizedBox(height: 150.h,),
                              ],
                            ),
                          ),
                        ),
                      )
                  ),
                  Positioned(
                      bottom: 0,
                      child: Container(
                        width: 540.w,
                        height: 167.h,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color.fromRGBO(255, 255, 255, 0),Color.fromRGBO(255, 255, 255, 1),Color.fromRGBO(255, 255, 255, 1)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter
                            )
                        ),
                      )
                  ),
                  Positioned(
                    bottom: 18.h,
                    left: 30.w,
                    child: Container(
                      width: 480.w,
                      height: 75.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          // color: Color.fromRGBO(249, 122, 53, 1),
                          gradient: LinearGradient(
                              colors: [Colors.red, Color.fromRGBO(249, 122, 53, 1),]
                          )
                      ),
                      child: FlatButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Text('OK2'.tr, style: TextStyle(fontWeight: FontWeight.normal),),
                        onPressed: (){
                          if(SaveData.userId != null){
                            addUserInfo();
                          }else{
                            SaveData.username = username;
                            SaveData.userSex = '男';
                            SaveData.userWeight = userWeight;
                            SaveData.userHeight = userHeight;
                            SaveData.userBirthday = userBirthday;
                            SharedPreferences.getInstance().then((value){
                              value.setString("userBirthday", userBirthday);
                              value.setString("userHeight", userHeight);
                              value.setString("userWeight", userWeight);
                              value.setString("userSex", SaveData.userSex);
                              value.setString("username", username);
                            });
                            // SaveData.openUserPage = false;
                            Navigator.pushReplacement<Object, Object>(context, MaterialPageRoute(
                                settings: RouteSettings(name: "MyHomePage"),
                                builder: (context) => MyHomePage()));
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
      ),
    );
  }

  void _defaultUserInfo(){//用户不填写个人信息保存默认用户数据回调函数
    SaveData.username = 'Username';
    SaveData.pictureUrl = null;
    SaveData.userBirthday = '2000-01-01';
    SaveData.userHeight = '180';
    SaveData.userWeight = '70';
    SaveData.userSex = '男';
    SharedPreferences.getInstance().then((value){
      value.setString("pictureUrl", null);
    });
    Navigator.pushReplacement<Object, Object>(context, MaterialPageRoute(
        settings: const RouteSettings(name: 'MyHomePage'),
        builder: (BuildContext context) => MyHomePage()));
  }

  void addUserInfo() async {
    Method.showLessLoading(context, 'Loading2'.tr);
    Dio dio = new Dio();
    final Response<Object> response = await dio.put<Object>(RequestUrl.getUserInfoUrl, data: map, options: Options(headers: <String, Object>{"app_pass" : RequestUrl.appPass, 'access_token' : SaveData.accessToken}));
    final Map maps = jsonDecode(response.toString()) as Map;
    print(maps);
    print(SaveData.userId);
    if(maps["code"] == "200"){
      Navigator.of(context).pop();
      SharedPreferences.getInstance().then((value){
        value.setString('userBirthday', map['birthday'] as String);
        value.setString('userHeight', map['height'] as String);
        value.setString('userWeight', map['weight'] as String);
        value.setString('username', map['nickName'] as String);
        value.setString('userSex', SaveData.userSex);
      });
      if(SaveData.pictureUrl != null){
        final getUserImageUrl = 'https://www.ucfitness.club/api/user/headImg';
        FormData formData = FormData.fromMap({
          "newHeadImg": await MultipartFile.fromFile(SaveData.pictureUrl,
              filename: "userImage.png"),
          "userId ": SaveData.userId
        });
        DioUtil()
            .put(getUserImageUrl,
            data: formData,
            options: Options(
              headers: {
                "app_pass": RequestUrl.appPass,
                'access_token': SaveData.accessToken
              },
              sendTimeout: 5000,
              receiveTimeout: 10000,
            ))
            .then((value) {
          if (value["code"] == "200") {
            Navigator.pushReplacement<Object, Object>(context, MaterialPageRoute(
                settings: RouteSettings(name: "MyHomePage"),
                builder: (context) => MyHomePage()));
          }
        });
      }else{
        Navigator.pushReplacement<Object, Object>(context, MaterialPageRoute(
            settings: RouteSettings(name: "MyHomePage"),
            builder: (context) => MyHomePage()));
      }
    }else{
      Navigator.of(context).pop();
      Method.showToast('It seems that there is no internet'.tr, context);
    }
  }

//使用相片
  void _getPictureBottomSheet(){
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        builder: (BuildContext context){
          return ScreenUtilInit(
            designSize: const Size(360, 640),
            builder: () => Material(
              child: Container(
                  width: 360.w,
                  height: 221.67.h,
                  child:Stack(
                    children: <Widget>[
                      Positioned(
                        top: 25.h,
                        left: 24.w,
                        child: Container(
                          width: 312.w,
                          height: 55.67.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              color: Color.fromRGBO(255, 189, 153, 1),
                              border: Border.all(color: Color.fromRGBO(255, 104, 0, 0.45),width: 1.w)
                          ),
                          child: FlatButton(
                            child: Text('Take photo'.tr),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: _takePhoto,
                          ),
                        ),
                      ),
                      Positioned(
                        top:94.67.h,
                        left: 24.w,
                        child: Container(
                          width: 312.w,
                          height: 55.67.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              color: Color.fromRGBO(111, 122, 135, 0.3),
                              border: Border.all(color: Color.fromRGBO(111, 122, 135, 0.62),width: 1.w)
                          ),
                          child: FlatButton(
                            child: Text('Select image'.tr),
                            onPressed: _openGallery,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 18.h,
                        left: 140.w,
                        child: FlatButton(
                          child: Text('Cancel'.tr),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  )
              ),
            ),
          );
        });
  }
//获取身高底部弹窗
  void _getHeight(){
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Color.fromRGBO(0, 0, 0, 1),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.only(
        //     topLeft: Radius.circular(24),
        //     topRight: Radius.circular(24),
        //   ),
        // ),
        builder: (BuildContext context){
          return ScreenUtilInit(
            designSize: const Size(360, 640),
            builder: () => Material(
                child: Container(
                  width: 360.w,
                  height: 250.h,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          width: 360.w,
                          height: 42.27.h,
                          color: Color.fromRGBO(244, 245, 249, 1),
                        ),
                      ),
                      // Positioned(
                      //   top: ScreenUtil().setHeight(14),
                      //   right: 16.07w,
                      //   child: Text("完成"),
                      // ),
                      Positioned(
                        top: 12.h,
                        right: 18.w,
                        child: GestureDetector(
                          child: Text('Finish'.tr),
                          onTap: (){
                            setState(() {
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                      ),
                      Positioned(
                        top: 42.27.h,
                        child: Container(
                          width: 360.w,
                          height: 204.h,
                          child: CupertinoPicker(
                            squeeze: 1,
                            itemExtent: 40,
                            looping: true,
                            diameterRatio: 5,
                            onSelectedItemChanged: (position){
                              userHeight = (position + 100).toString();
                              map["height"] = int.parse(userHeight);
                              SaveData.userHeight = userHeight;
                              scrollController = FixedExtentScrollController(initialItem: position);
                            },
                            scrollController: scrollController,
                            children: <Widget>[
                              for(int i = 100; i <= 240; i++)
                                Center(
                                  child: Text(i.toString() + " cm"),
                                )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
            ),
          );
        }
    );
  }
//获取体重底部弹窗
  void _getWeight(){
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        builder: (BuildContext context){
          return ScreenUtilInit(
            designSize: const Size(360, 640),
            builder: () => Material(
                child: Container(
                  width: 360.w,
                  height: 250.h,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          width: 360.w,
                          height: 42.27.h,
                          color: Color.fromRGBO(244, 245, 249, 1),
                        ),
                      ),
                      Positioned(
                        top: 10.h,
                        right: 16.07.w,
                        child: GestureDetector(
                          child: Text('Finish'.tr),
                          onTap: (){
                            setState(() {
                              Navigator.of(context).pop();
                            });

                          },
                        ),
                      ),
                      Positioned(
                        top: 42.27.h,
                        child: Container(
                          width: 360.w,
                          height: 204.h,
                          child: CupertinoPicker(
                            itemExtent: 40,
                            looping: true,
                            diameterRatio: 5,
                            squeeze: 1,
                            onSelectedItemChanged: (position){
                              userWeight = (position + 30).toString();
                              map["weight"] = int.parse(userWeight);
                              SaveData.userWeight = userWeight;
                              scrollController1 = FixedExtentScrollController(initialItem: position);
                            },
                            scrollController: scrollController1,
                            children: <Widget>[
                              for(int i = 30; i <= 200; i++)
                                Center(
                                  child: Text(i.toString() + " kg"),
                                )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
            ),
          );
        }
    );
  }
  //拍照
  Future _takePhoto() async {
    SaveData.chosePhotograph = true;
    Navigator.of(context).pop();
    final pickedFile = await picker.getImage(source: ImageSource.camera).then((value){
      if(value != null){
        image = File(value.path);
        cropImage(image);
      }
    });
  }
  //相册
  Future<void>_openGallery() async {
    SaveData.chosePhotograph = false;
    Navigator.of(context).pop();
    final pickedFile = await picker.getImage(source: ImageSource.gallery).then((value){
      if(value != null){
        image = File(value.path);
        cropImage(image);
      }
    });

  }
  void cropImage(File originalImage) async {
    await Navigator.push<Object>(context, MaterialPageRoute(builder: (context) => CropImageRoute(originalImage))).then((value){
      setState(() {print("我进来了吗？");});
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
  final cropKey = GlobalKey<CropState>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => Scaffold(
          body: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Container(
              height: 960.h,
              width: 540.w,
              color: Colors.black,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 210.h),
                  Container(
                    height: 540.w,
                    width: 540.w,
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
                        child: Text('Cancel'.tr,style: TextStyle(color: Colors.white),),
                        onPressed: (){
                          AddUserPageState.image = null;
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('OK2'.tr,style: TextStyle(color: Colors.white),),
                        onPressed: (){
                          _crop(widget.image);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }

  Future<void> _crop(File originalFile) async {
    final crop = cropKey.currentState;
    final area = crop.area;
    if (area == null) {
      //裁剪结果为空
      print('裁剪不成功');
    }
    if(SaveData.chosePhotograph){
      await ImageCrop.requestPermissions().then((value) {
        ImageCrop.cropImage(
            file: originalFile,
            area: crop.area).then((value){
          AddUserPageState.image = value;
          SaveData.pictureUrl = File(AddUserPageState.image.path).path;
          _savePictureName();
        }).whenComplete((){
          Navigator.of(context).pop();
        });
      });
    }else{
      ImageCrop.cropImage(
          file: originalFile,
          area: crop.area).then((value){
        AddUserPageState.image = value;
        SaveData.pictureUrl = File(AddUserPageState.image.path).path;
        _savePictureName();
      }).whenComplete((){
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> _savePictureName() async {
    final Directory root = await getApplicationSupportDirectory();
    final File file = File(SaveData.pictureUrl);
    SaveData.pictureUrl = root.path + '/userImage.png';
    file.copy(SaveData.pictureUrl);
    SharedPreferences.getInstance().then((value){
      value.setString('pictureUrl', SaveData.pictureUrl);
    });
  }
}