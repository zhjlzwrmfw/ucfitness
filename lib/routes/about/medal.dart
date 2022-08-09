import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/fileImageEx.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'medalDetail.dart';
import 'package:get/get.dart';
import 'package:running_app/model/medal.dart';

class MedalPage extends StatefulWidget {
  const MedalPage({Key key}) : super(key: key);

  @override
  MedalPageState createState() => MedalPageState();
}

class MedalPageState extends State<MedalPage> {

  bool hasNetwork = true;
  Medal medal;
  int totalCount = 0;
  bool isExpand = false;
  List<bool> medalExpandList = <bool>[];
  static List<bool> hasReadMedal = <bool>[];
  List<List<int>> hasReadList = <List<int>>[];

  @override
  void initState() {
    super.initState();
    Method.checkNetwork(context).then((bool value){
      if(value){
        getMedalTotalCount();
      }else{
        if(mounted){
          setState(() {
            hasNetwork = false;
          });
        }
      }
    });
  }

  void getMedalTotalCount(){
    DioUtil().get(
      RequestUrl.getMedalTotalCountUrl,
      queryParameters: <String, Object>{'userId': SaveData.userId},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass':RequestUrl.appPass}),
    ).then((Map<String, Object> value){
      if(value != null && value['code'] == '200'){
        totalCount = value['data'] as int;
        Future<void>.delayed(const Duration(milliseconds: 250),(){
          getMedalPanel();
        });
      }
    });
  }

  void putReadMedal(int index){
    DioUtil().put(
      RequestUrl.putMedalReadUrl,
      data: <String, Object>{'medalIds': hasReadList[index], 'userId': SaveData.userId,},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass}),
    ).then((value){
      print(value);
      if(value != null && value['code'] == '200'){
        setState(() {
          hasReadMedal[index] = true;
        });
      }
    });
  }

  void getMedalPanel(){
    DioUtil().get(
      RequestUrl.getMedalPanelUrl,
      queryParameters: <String, Object>{'lang': SaveData.english ? 'en' : 'zh', 'userId': SaveData.userId},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass':RequestUrl.appPass}),
    ).then((Map<String, Object> value){
      print(value);
      if(mounted){
        setState(() {
          if(value != null){
            medal = Medal.fromJson(value);
            if(medal.code != '200'){
              hasNetwork = false;
              Method.showToast('It seems that there is no internet'.tr, context);
            }else{
              for(int i = 0; i < medal.data.length; i++){
                medalExpandList.add(false);
                hasReadMedal.add(true);
                hasReadList.add(<int>[]);
                for(int j = 0; j < medal.data[i].medals.length; j++){
                  if(!medal.data[i].medals[j].read){
                    hasReadMedal[i] = false;
                    hasReadList[i].add(medal.data[i].medals[j].id);
                  }
                }
              }
            }
          }else{
            hasNetwork = false;
            Method.showToast('It seems that there is no internet'.tr, context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => Scaffold(
        appBar: AppBar(
          title: Text(
            'medal'.tr,
          style: TextStyle(fontSize: 56.sp),),
          centerTitle: false,
          backgroundColor: const Color.fromRGBO(249, 122, 53, 1),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 457.h,
                width: 1080.w,
                // color: const Color.fromRGBO(249, 122, 53, 0.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 198.h,
                      height: 198.h,
                      margin: EdgeInsets.only(bottom: 18.h),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1000),
                          color: Colors.white),
                      child: SaveData.pictureUrl == null
                          ? Image.asset(
                        'images/home_user.png',
                      )
                          : ClipOval(
                        child: Image(
                          image: FileImageEx(File(SaveData.pictureUrl)),
                        ),
                      ),
                    ),
                    Text(
                      SaveData.username,
                      style: TextStyle(
                        color: const Color.fromRGBO(67, 84, 91, 1),
                        fontSize: 60.sp,
                      ),
                    ),
                    SizedBox(
                      height: 18.h,
                    ),
                    Text(
                     SaveData.english ? 'Total number of medals: ${totalCount.toString()}' : '已获得${totalCount.toString()}枚勋章',
                      style: TextStyle(
                        color: const Color.fromRGBO(67, 84, 91, 1),
                        fontSize: 44.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 42.h,
              ),
              if(hasNetwork && medal != null)
                for(int i = 0; i < medal.data.length; i++)
                  medalGroup(i),
              if(!hasNetwork)
                Container(
                  width: 432.w,
                  height: 432.h,
                  margin: EdgeInsets.only(top: 380.h),
                  child: FlatButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Image.asset('images/unconnected.png'),
                    onPressed: (){
                      getMedalPanel();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override

  List<Widget> medalBox(bool expand, int groupIndex) => List<Widget>.generate(expand ? medal.data[groupIndex].medals.length : 3, (int medalIndex) {
    return singleMedal(groupIndex, medalIndex);
  });

  IconData iconData;

  Widget medalGroup(int index){
    return GestureDetector(
      onTap: (){
        setState(() {
          if(medalExpandList[index]){
            medalExpandList[index] = false;
          }else{
            medalExpandList[index] = true;
            if(!hasReadMedal[index]){
              putReadMedal(index);
            }
          }
        });
      },
      child: Container(
        width: 984.w,
        padding: EdgeInsets.only(bottom: 48.w),
        margin: EdgeInsets.only(bottom: 48.w),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(232, 232, 232, 1),
          borderRadius: BorderRadius.all(Radius.circular(49.w)),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 48.w,top: 48.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(medal.data[index].groupName, style: TextStyle(color: const Color.fromRGBO(80, 80, 80, 1), fontSize: 49.sp),),
                      if(!hasReadMedal[index])
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              color: Colors.red
                          ),
                        ),
                    ],
                  )
                ),
                Container(
                  margin: EdgeInsets.only(right: 48.w,top: 36.w),
                  // child: Icon(!medalExpandList[index] ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                  child: AnimatedSwitcher(
                    transitionBuilder: (Widget child, Animation<double> anim) {
                      return ScaleTransition(
                        child: child,
                        scale: anim,
                      );
                    },
                    duration: const Duration(milliseconds: 400),
                    child: Icon(
                      !medalExpandList[index] ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                      key: ValueKey(!medalExpandList[index] ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.w,
            ),
            Wrap(
              runSpacing: 48.h,
              spacing: 102.w,
              children: medalBox(medalExpandList[index], index),
            ),
          ],
        ),
      ),
    );
  }

  Widget singleMedal(int groupIndex, int medalIndex){
    return InkWell(
      onTap: (){
        Navigator.push<Object>(context, MaterialPageRoute(builder: (BuildContext context) {
          return MedalDetailPage(medals: medal.data[groupIndex].medals[medalIndex],);
        }));
      },
      child: Column(
        children: <Widget>[
          Container(
            width: 228.w,
            height: 228.w,
            margin: EdgeInsets.only(bottom: 24.h),
            child: CachedNetworkImage(
              imageUrl: RequestUrl.getUserPictureUrl + medal.data[groupIndex].medals[medalIndex].image,
              fit: BoxFit.fill,
              httpHeaders: {'app_pass': RequestUrl.appPass},
              color: medal.data[groupIndex].medals[medalIndex].have ? const Color.fromRGBO(249, 122, 53, 1) : const Color.fromRGBO(202, 201, 201, 1),
            ),
          ),
          Container(
            width: 228.w,
            child: Text(
              medal.data[groupIndex].medals[medalIndex].name,
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color.fromRGBO(67, 84, 91, 1), fontSize: 36.sp),
            ),
          ),
        ],
      ),
    );
  }
}
