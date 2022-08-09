import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/services.dart';
import 'package:my_bluetooth_plugin/my_bluetooth_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/common/dioUtil.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/model/CourseDetailModel.dart';
import 'package:running_app/model/medal.dart';
import 'package:running_app/model/newMedal.dart';
import 'package:running_app/model/sportDataController.dart';
import 'package:running_app/routes/course/video_player_control.dart';
import 'package:running_app/routes/course/video_player_pan.dart';
import 'package:running_app/routes/realTimeSport/connectDevice.dart';
import 'package:running_app/routes/sportData/totalRecord.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'controller_widget.dart';
import 'package:get/get.dart';

class CourseDetailPage extends StatefulWidget {

  final String courseTitle;//课程主题
  final String courseDescribe;//课程描述
  final List<String> courseInfo;
  final int courseId;
  final bool timing;
  final int version;
  final int interactiveEquipment;

  const CourseDetailPage({
    Key key,
    this.courseDescribe,
    this.courseTitle,
    this.courseInfo,
    this.courseId,
    this.timing,
    this.version,
    this.interactiveEquipment,
  }) : super(key: key);

  @override
  CourseDetailPageState createState() => CourseDetailPageState();
}

class CourseDetailPageState extends State<CourseDetailPage> {

  /// 记录是否全屏
  bool get _isFullScreen => MediaQuery.of(context).orientation == Orientation.landscape;

  StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息
  final BlueToothChannel _blueToothChannel = BlueToothChannel();

  static int sportCount = 0;
  static double kcalCount = 0;
  static double sportProgress = 0;
  final GlobalKey<VideoPlayerControlState> _key = GlobalKey<VideoPlayerControlState>();

  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayer audioPlayer1 = AudioPlayer();
  AudioCache player;

  ///指示video资源是否加载完成，加载完成后会获得总时长和视频长宽比等信息
  bool _videoInit = false;
  bool _videoError = false;
  VideoPlayerController _controller; // video控件管理器
  Size get _window => MediaQueryData.fromWindow(window).size;
  List<String> courseInfoUnit = [' ', ' ' + 'minutes'.tr, ' kcal', ''];
  bool hasDownload = false;//课程是否下载
  CourseDetailModel courseDetailModel;
  List<String> courseIdList = [];//存储已经下载的课程id
  List<String> courseCollectList = [];//存储已经收藏的课程id
  List<String> targetAmountList = [];//存储每个运动目标个数
  List<String> actionTypeList = [];//存储课程运动类型
  List<String> duringList = [];//存储每个运动目标时间
  List<String> modeList = [];//存储每个运动模式
  bool hasCollect = false;//课程是否收藏
  int finishProgress = 0;//音视频下载成功个数
  List<String> courseInfoFlagList = ['video', 'actionVoice', 'actionIntroduceVoice', 'cover'];//用于分辨音视频
  final SportDataController c = Get.put(SportDataController());
  bool startDownLoad = false;//刷新ui时重新底部布局
  int mediaOrder = -1;//用于顺序播放音视频的标志
  Timer _timer;
  Timer _progressTimer;
  static bool hasConnectDevice = false;
  bool firstDownLoad = true;//区别是否第一次下载
  int addSportCount = 0;//运动次数累加
  String picPath = '';//课程图片路径
  bool courseEnd = true;//课程结束标志位
  bool needUpdateVersion = false;//是否需要更新音视频
  bool completeAudioPlayerState = false;
  bool initFullScreen = false;
  int videoPauseSecond = 0;//用户点击暂停时视频已经走过的秒数
  /// pauseTime - initDateTime 用于记录单个视频暂时时已经走过的时间
  DateTime initDateTime;//记录每次播放视频时的时间
  DateTime pauseTime;//点击视频暂时时的时间
  int recordSecond = 0;//记录视频暂停时走过的秒数
  NewMedal newMedal;


  @override
  void initState() {
    super.initState();
    initData();
  }
  //初始化数据
  void initData(){
    player = AudioCache(fixedPlayer: audioPlayer1);
    SharedPreferences.getInstance().then((value){
      if(value.getStringList('courseCollectList') != null){
        setState(() {
          courseCollectList = value.getStringList('courseCollectList');
          if(courseCollectList.contains(widget.courseId.toString())){
            hasCollect = true;
          }else{
            hasCollect = false;
          }
        });
      }
      if(value.getInt('version${widget.courseId}') != null && widget.version > value.getInt('version${widget.courseId}')){
        needUpdateVersion = true;
        getCourseDetail();
      }
      if(value.getStringList('courseIdList') != null){
        courseIdList = value.getStringList('courseIdList');
        if(courseIdList.contains(widget.courseId.toString())){
          setState(() {
            targetAmountList = value.getStringList('targetAmountList' + widget.courseId.toString());
            duringList = value.getStringList('duringList' + widget.courseId.toString());
            actionTypeList = value.getStringList('actionTypeList' + widget.courseId.toString());
            SaveData.sliderMaxValue = targetAmountList.length;
            print('视频个数：${SaveData.sliderMaxValue}');
            print('目标：$targetAmountList');
            firstDownLoad = false;
            hasDownload = true;
            getDirectory();
          });

        }else{
          getCourseDetail();
        }
      }else{
        hasDownload = false;
        getCourseDetail();
      }
    });
    _streamSubscription = _blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
    Screen.keepOn(true); // 设置屏幕常亮
    if(courseDetailModel == null || picPath == ''){
      print('hahaisNull');
      Future.delayed(Duration(seconds: 2),(){
        if(mounted){
          setState(() {});
        }
      });
    }
  }

  void getDirectory() async {
    final Directory root = await getApplicationDocumentsDirectory();
    picPath = root.path + '/course/' + widget.courseId.toString() + '/cover';
  }
//连接设备
  void _confirm(){
    Navigator.push<Object>(context, MaterialPageRoute(
        builder: (BuildContext context) => ConnectDevicePage(courseType: widget.interactiveEquipment,))).then((value){
      if(value == null){
        hasConnectDevice = false;
        _urlChange();
      }else{
        _openStreamNotify();
        hasConnectDevice = value as bool;
        funnyCourse();
      }
    });
  }

  /**
   * 连接设备的课程模式
   */
  void funnyCourse(){
    if(widget.interactiveEquipment == 3){
      initDeviceInfo();
    }else{
      String hexSecondStr = ((DateTime.now().millisecondsSinceEpoch - DateTime.parse('1970-01-01 08:00:00').millisecondsSinceEpoch) ~/ 1000).toRadixString(16);
      _blueToothChannel.headSyncTime(hexSecondStr);
      Future.delayed(const Duration(milliseconds: 200),(){
        _blueToothChannel.setMode(0, 1);
        _urlChange();
        Future.delayed(const Duration(milliseconds: 200),(){
          _blueToothChannel.headStartSport('0');
          startDateTime = DateTime.now();
        });
      });
      Future.delayed(const Duration(seconds: 5), (){
        Method.checkNetwork(context).then((value){
          if(!value){
            Method.showToast('检测到没有网络可用，将会影响运动数据的上传', context);
          }
        });
      });
    }
  }

  void initDeviceInfo(){
    _blueToothChannel.synTime(DateTime.now());
    Future.delayed(const Duration(milliseconds: 200),(){
      _blueToothChannel.setMode(widget.interactiveEquipment, 1);
      _urlChange();
      Future.delayed(const Duration(milliseconds: 200),(){
        print('fea30101');
        _blueToothChannel.customOrder('fea30101');
      });
    });
  }

  void _cancel(){
    firstDownLoad = false;
    _urlChange();
  }

  void _openStreamNotify() {
    _streamSubscription = _blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError); //注册消息回调函数
  }

  int seconds = 0;

  void setSportProgress(){
    seconds = recordSecond;
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds++;
      if(seconds < int.parse(duringList[mediaOrder])){
        sportProgress = seconds / (int.parse(duringList[mediaOrder]) - 1);
        _key.currentState.setSportProgress();
      }else{
        sportProgress = 0;
        _key.currentState.setSportProgress();
      }
    });
  }

  void getCourseDetail(){
    DioUtil().get(
      RequestUrl.getCourseAction,
      queryParameters: <String, Object>{'language': SaveData.english ? 1 : 0, 'courseId': widget.courseId,},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass':RequestUrl.appPass}),
    ).then((value){
      print(value);
      if(value != null){
        courseDetailModel = CourseDetailModel.fromJson(value);
        if(courseDetailModel.code == '200'){
          if(mounted){
            setState(() {
              SaveData.sliderMaxValue = courseDetailModel.data.length;
            });
          }
        }else{
          Method.showToast('It seems that there is no internet'.tr, context);
        }
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 2208),
      builder: () => Material(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              child: RepaintBoundary(
                child: Container(
                  color: Colors.black,
                  width: _isFullScreen ? _window.width : 1080.w,
                  height: _isFullScreen ? _window.height : 643.29.h,
                  child: hasDownload && mediaOrder != -1 ? SafeArea(
                    top: !_isFullScreen,
                    bottom: false,
                    left: !_isFullScreen,
                    right: !_isFullScreen,
                    child: GestureDetector(
                      onHorizontalDragEnd: hasConnectDevice ? null : _sliderValue,
                      onHorizontalDragUpdate: hasConnectDevice ? null : _sliderUpdate,
                      child: _isHadUrl(),),
                  ) : courseDetailModel != null ? Image.network(
                    RequestUrl.getUserPictureUrl + courseDetailModel.data[0].cover,
                    headers: {'app_pass': RequestUrl.appPass},
                    fit: BoxFit.fill,
                  ) : picPath != '' ? Image.file(File(picPath + '0.jpg'), fit: BoxFit.fill,) : null,
                ),
              ),
            ),
            if(!_isFullScreen)
            Positioned(
              top: 643.29.h,
              child: RepaintBoundary(
                child: Container(
                  width: 1080.w,
                  height: 1494.71.h,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 72.w, top: 55.97.h),
                          child: Text(
                            widget.courseTitle,
                            style: TextStyle(
                              fontSize: 60.sp,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 72.w, top: 37.97.h,right: 72.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              for(int i = 0; i < widget.courseInfo.length; i++)
                                courseTextBuild(i),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 72.w, top: 37.97.h,right: 72.w),
                          child: Text(
                            widget.courseDescribe,
                            style: TextStyle(fontSize: 21.sp, color: const Color.fromRGBO(121, 122, 121, 1)),
                                  ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 72.w, top: 83.72),
                          child: Text(
                            '课程讲解',
                            style: TextStyle(fontSize: 40.sp, color: const Color.fromRGBO(52, 52, 52, 1)),
                          ),
                        ),
                        courseExplainBuild(1),
                        Padding(
                          padding: EdgeInsets.only(left: 72.w, top: 83.72),
                          child: Text(
                            '注意事项',
                            style: TextStyle(fontSize: 40.sp, color: const Color.fromRGBO(52, 52, 52, 1)),
                          ),
                        ),
                        courseExplainBuild(0),
                        const SizedBox(
                          height: 75,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if(!_isFullScreen)
            Positioned(
              bottom: 0,
              child: Container(
                width: 1080.w,
                height: 180.h,
                color: const Color.fromRGBO(245, 245, 245, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if(startDownLoad)
                      RepaintBoundary(
                        child: GetX<SportDataController>(
                          builder: (controller){
                            return Container(
                              width: 540.w,
                              height: 90.h,
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(45.h)),
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation(Color.fromRGBO(249, 122, 53, 0.5)),
                                  value: controller.progressIndicate.value.progress,
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    if(!startDownLoad)
                    RepaintBoundary(
                      child: Container(
                        width: 208.w,
                        height: 150.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.9),
                          borderRadius: const BorderRadius.all(Radius.circular(12))
                        ),
                        child: FlatButton(
                          splashColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          padding: EdgeInsets.zero,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.directions_run, size: 64.w,),
                              Text('开始训练', style: TextStyle(fontSize: 30.sp),),
                            ],
                          ),
                          onPressed: trainOrDownCourse,
                        ),
                      ),
                    ),
                    if(!startDownLoad)
                    RepaintBoundary(
                      child: Container(
                        width: 180.w,
                        height: 150.h,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.9),
                            borderRadius: const BorderRadius.all(Radius.circular(10))
                        ),
                        child: FlatButton(
                          onPressed: (){
                            if(hasCollect){
                              courseCancelRequest();
                            }else{
                              courseCollectRequest();
                            }
                          },
                          padding: EdgeInsets.zero,
                          splashColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(hasCollect ? 'images/点赞收藏.png' : 'images/未收藏.png',width: 64.w, height: 64.w,color: hasCollect ? const Color.fromRGBO(254, 0, 127, 1) : Colors.black,),
                              Text(hasCollect ? '已收藏' : '收藏', style: TextStyle(fontSize: 30.sp),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if(!startDownLoad)
                      Container(
                        width: 180.w,
                        height: 150.h,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.9),
                            borderRadius: const BorderRadius.all(Radius.circular(10))
                        ),
                        child: FlatButton(
                          onPressed: courseEnd ? (){
                            Navigator.push<Object>(context, MaterialPageRoute(
                                builder: (context) => TotalRecordPage())).then((value){
                              setState(() {
                                _openStreamNotify();
                              });
                            });
                          } : null,
                          padding: EdgeInsets.zero,
                          splashColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.bookmark_border,size: 64.w,),
                              Text('运动记录', style: TextStyle(fontSize: 30.sp),),
                            ],
                          ),
                        ),
                      ),
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 下载或者训练课程
   */
  void trainOrDownCourse(){
    courseEnd = false;
    addSportCount = 0;
    initFullScreen = true;
    if(mediaOrder == -1){
      if(hasDownload){
        if(needUpdateVersion){
          Method.customDialog(context, '资源包更新', '本次课程有新的资源包，是否需要更新?', _mediaUpdateConfirm, cancel: _updateCancel);
        } else {
          if(hasConnectDevice){
            if(widget.interactiveEquipment == 3){
              _blueToothChannel.setMode(3, 1);
              Future.delayed(const Duration(milliseconds: 200),(){
                _blueToothChannel.customOrder('fea30101');
                _urlChange();
              });
            }else{
              _blueToothChannel.setMode(0, 1);
              Future.delayed(const Duration(milliseconds: 200),(){
                _blueToothChannel.headStartSport('0');
                _urlChange();
              });
            }
          }else{
            Method.customDialog(context, '温馨提示', '检测到未连接设备，是否连接?', _confirm, cancel: _cancel);
          }
        }
      }else{
        downLoadMedia();
      }
    }else{
      Method.showToast('课程训练进行中', context, position: 1);
    }
  }

  void downLoadMedia() async {//递归调用网络请求获取音视频资源
    final Directory root = await getApplicationDocumentsDirectory();
    await DioUtil().downLoad(
        (finishProgress ~/ courseDetailModel.data.length == 0 ? RequestUrl.downVideoUrl : finishProgress ~/ courseDetailModel.data.length == 3 ? RequestUrl.downLoadPictureUrl : RequestUrl.downVoiceUrl)
            + (finishProgress ~/ courseDetailModel.data.length == 0 ? courseDetailModel.data[finishProgress % courseDetailModel.data.length].video
            : finishProgress ~/ courseDetailModel.data.length == 1 ? courseDetailModel.data[finishProgress % courseDetailModel.data.length].actionVoice
            : finishProgress ~/ courseDetailModel.data.length == 2 ? courseDetailModel.data[finishProgress % courseDetailModel.data.length].actionIntroduceVoice
            : courseDetailModel.data[finishProgress % courseDetailModel.data.length].cover),
        root.path + '/course/' + widget.courseId.toString() + '/${courseInfoFlagList[finishProgress ~/ courseDetailModel.data.length]}' + (finishProgress % courseDetailModel.data.length).toString()
            + (finishProgress ~/ courseDetailModel.data.length == 0 ? '.mp4' : finishProgress ~/ courseDetailModel.data.length == 3 ? '.jpg' : '.mp3'),
        onReceiveProgress: (int received, int total) {
          if (total != -1) {
            c.progressIndicate.update((ProgressIndicate progressIndicate) {
              progressIndicate.progress = (received / total + finishProgress) / (4 * courseDetailModel.data.length);
              print('进度: ${progressIndicate.progress}');
            });
            if(mounted && finishProgress == 0){
              setState(() {
                startDownLoad = true;
              });
            }

            if (received / total == 1) {
              finishProgress++;
              if(finishProgress < 4 * courseDetailModel.data.length){
                downLoadMedia();
              }
              if(finishProgress == 4 * courseDetailModel.data.length){
                print('下载成功');
                finishProgress = 0;
                hasDownload = true;
                needUpdateVersion = false;
                firstDownLoad = true;
                SaveData.sliderMaxValue = courseDetailModel.data.length;
                courseIdList.add(widget.courseId.toString());
                if(targetAmountList != null){
                  targetAmountList.clear();
                  duringList.clear();
                  actionTypeList.clear();
                }
                for(int i = 0; i < courseDetailModel.data.length; i++){
                  targetAmountList.add(courseDetailModel.data[i].targetAmount.toString());
                  duringList.add(courseDetailModel.data[i].during.toString());
                  actionTypeList.add(courseDetailModel.data[i].actionType.toString());
                }
                SharedPreferences.getInstance().then((value){
                  value.setStringList('courseIdList', courseIdList);
                  value.setStringList('targetAmountList' + widget.courseId.toString(), targetAmountList);
                  value.setStringList('duringList' + widget.courseId.toString(), duringList);
                  value.setStringList('actionTypeList' + widget.courseId.toString(), actionTypeList);
                  value.setInt('version' + widget.courseId.toString(), widget.version);
                });
                ///下载成功后刷新布局
                setState(() {
                  startDownLoad = false;
                });
              }
            }
          }
        },
        options: Options(
          headers: <String, Object>{'app_pass': RequestUrl.appPass,},
          responseType: ResponseType.stream,
          sendTimeout: 5000,
          receiveTimeout: 10000,
        ));
  }

  @override
  void dispose(){
    super.dispose();
    if(hasConnectDevice){
      MyBluetoothPlugin.disConnectDevice(SaveData.deviceName);
      hasConnectDevice = false;
    }
    if (_controller != null) {
      _controller.dispose();
      _controller = null;
    }
    if(audioPlayer != null){
      audioPlayer.dispose();
      if(!courseEnd){
        audioPlayer1.release();
        audioPlayer1.dispose();
        player.clearCache();
      }
      audioPlayer = null;
      audioPlayer1 = null;
      player = null;
    }
    if(_timer != null){
      _timer.cancel();
      _timer = null;
    }
    if(_progressTimer != null){
      _progressTimer.cancel();
      _progressTimer = null;
    }
    Screen.keepOn(false);
  }

  void courseCollectRequest(){
    DioUtil().post(
      RequestUrl.courseCollectUrl,
      queryParameters: <String, Object>{'courseId': widget.courseId, 'userId': SaveData.userId,},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass}),
    ).then((value){
      print(value);
      if(value != null){
        if(value['code'] == '200'){
          setState(() {
            hasCollect = true;
            courseCollectList.add(widget.courseId.toString());
            SharedPreferences.getInstance().then((value){
              value.setStringList('courseCollectList', courseCollectList);
            });
          });
        }else{
          Method.showToast('It seems that there is no internet'.tr, context);
        }
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }

  void courseCancelRequest(){
    DioUtil().put(
      RequestUrl.courseCollectUrl,
      data: <String, Object>{'courseIds': [widget.courseId], 'userId': SaveData.userId,},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass}),
    ).then((value){
      if(value != null){
        if(value['code'] == '200'){
          setState(() {
            hasCollect = false;
            courseCollectList.remove(widget.courseId.toString());
            SharedPreferences.getInstance().then((value){
              value.setStringList('courseCollectList', courseCollectList);
            });
          });
        }else{
          Method.showToast('It seems that there is no internet'.tr, context);
        }
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }

  Widget courseTextBuild(int index){
    return Text.rich(
        TextSpan(
            children: [
              TextSpan(
                  text: widget.courseInfo[index],
                  style: TextStyle(
                      fontSize: 36.sp,
                      color: const Color.fromRGBO(52, 52, 52, 1)
                  )
              ),
              TextSpan(
                  text: courseInfoUnit[index],
                  style: TextStyle(
                      fontSize: 21.sp,
                      color: const Color.fromRGBO(121, 122, 121, 1)
                  )
              )
            ]
        )
    );
  }

  Widget courseExplainBuild(int i){
    return GestureDetector(
      child: Container(
        width: 936.w,
        height: 480.h,
        margin: EdgeInsets.only(
            left: 72.w,
            right: 72.w,
            top: 28.h),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            color: const Color.fromRGBO(229, 229, 228, 1),
            border: Border.all(color: const Color.fromRGBO(116, 117, 117, 1), width: 0.5.w),
            image: courseDetailModel != null ? DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(
                  RequestUrl.getUserPictureUrl + courseDetailModel.data[i].cover,
                  headers: {'app_pass': RequestUrl.appPass},
                )
            ) : picPath != '' ? DecorationImage(
                fit: BoxFit.fill,
                image: FileImage(File(picPath + i.toString() + '.jpg'))
            ) : null
        ),
      ),
      onTap: (){

      },
    );
  }

  // 判断是否有url
  Widget _isHadUrl() {
    return ControllerWidget(
      controlKey: _key,
      controller: _controller,
      videoInit: _videoInit,
      title: widget.courseTitle,
      blueToothChannel: _blueToothChannel,
      bgAudioPlayer: audioPlayer1,
      actionAudioPlayer: audioPlayer,
      child: VideoPlayerPan(
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: _isVideoInit(),
        ),
      ),
    );
  }

// 加载url成功时，根据视频比例渲染播放器
  Widget _isVideoInit() {
    if (_videoInit) {
      return VideoPlayer(_controller);
    } else if (_controller != null && _videoError) {
      return Text(
        '加载出错',
        style: TextStyle(color: Colors.white),
      );
    } else {
      return const RepaintBoundary(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Color.fromRGBO(0, 0, 0, 1)),
          ),
        ),
      );
    }
  }

  void _initController(String link, String audioLink) async {
    final File file = File(link);
    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        Future<void>.delayed(const Duration(milliseconds: 500), (){
          _controller.addListener(_videoListener);
        });
        if(mounted){
          setState(() {
            updateSlider();
            if(_progressTimer != null){
              _progressTimer.cancel();
            }
           if(widget.timing || actionTypeList[mediaOrder] != '0' || !hasConnectDevice){
             recordSecond = 0;
             setSportProgress();
           }
            _videoInit = true;
            _videoError = false;
            _controller.setLooping(true);
            _controller.play();
            if(audioLink != null){
              audioPlayer.play(audioLink, isLocal: true);
              audioPlayer.onPlayerStateChanged.listen((AudioPlayerState event) {//视频暂停，音频也跟着暂停
                if(AudioPlayerState.COMPLETED == event || AudioPlayerState.STOPPED == event){
                  completeAudioPlayerState = true;
                }else{
                  completeAudioPlayerState = false;
                }
              });
            }
            if(mediaOrder == 0){
              player.loop('bgMusic.mp3', stayAwake: true);
            }
            ///如果是计时模式运动、其他类型以及不互动则开启定时器
            videoPauseSecond = 0;
            onlyMedia = true;
            timerSport();
          });
        }
      });
  }

  void timerSport(){
    if(widget.timing || actionTypeList[mediaOrder] != '0' || !hasConnectDevice){
      _timer = Timer(Duration(seconds: int.parse(duringList[mediaOrder]) - videoPauseSecond), (){
        if(mediaOrder < targetAmountList.length - 1){
          _urlChange();
          if(hasConnectDevice){
            if(actionTypeList[mediaOrder] != '0'){
              Future<void>.delayed(const Duration(seconds: 2), (){
                _blueToothChannel.customOrder('03040000');
              });
            }
          }
        }else{
          endCourse();
        }
        _timer.cancel();
      });
    }
  }

  Future<void> _onControllerChange(String link, String audioLink) async {
    if (_controller == null) {
      _initController(link, audioLink);
    } else {
      final oldController = _controller;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await oldController.dispose();
        _initController(link, audioLink);
      });
      if(mounted){
        setState(() {
          _controller = null;
        });
      }
    }
  }

  void _urlChange() async {
    initDateTime = DateTime.now();
    if(_controller != null){
      _controller.removeListener(_videoListener);
    }
    /// 重置组件参数
    if(mounted){
      setState(() {
        _videoInit = false;
        _videoError = false;
        if(!_isFullScreen && initFullScreen){
          initFullScreen = false;
          AutoOrientation.landscapeAutoMode();
          SystemChrome.setEnabledSystemUIOverlays([]);
        }
      });
    }
    if(mediaOrder < targetAmountList.length - 1){
      ///加载特定文件下的视频
      if(nextVideo){
        mediaOrder++;
      }else{
        mediaOrder--;
      }
      print('mediaOrder:${mediaOrder}');
      final Directory root = await getApplicationDocumentsDirectory();
      _onControllerChange(root.path + '/course/' + widget.courseId.toString() + '/${courseInfoFlagList[0]}' + mediaOrder.toString() + '.mp4', root.path + '/course/' + widget.courseId.toString() + '/${courseInfoFlagList[2]}' + mediaOrder.toString() + '.mp3');
    }else{
      endCourse();
    }
  }

  void endCourse() async {
    if(mounted){
      setState(() {
        courseEnd = true;
        videoPauseSecond = 0;
        playingFlag = false;
        sportProgress = 0;
        actionSync = false;
        videoCompleteCount = 0;
        if(hasConnectDevice && !needUpdateVersion){
          if(widget.interactiveEquipment == 3){
            _blueToothChannel.customOrder('fea90100');
          }else{
            _blueToothChannel.customOrder('03060000');

          }
          uploadSportData();
          // if(!SaveData.hasPopupMedalDialog){
          //   getNewMedal();
          // }
        }

        mediaOrder = -1;
        if(_timer != null){
          _timer.cancel();
        }
        if(_progressTimer != null){
          _progressTimer.cancel();
        }
        audioPlayer1.stop();
        audioPlayer.release();
        Future.delayed(Duration(seconds: 1),(){
          if(_controller != null){
            _controller.dispose();
            _controller = null;
          }
        });
        if (_isFullScreen) {
          /// 如果是全屏就切换竖屏
          AutoOrientation.portraitAutoMode();
          ///显示状态栏，与底部虚拟操作按钮
          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
        }
        if(!needUpdateVersion){
          Method.showToast('本次训练课程结束！', context);
        }
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
          SaveData.hasPopupMedalDialog = true;
          final double width = 1080.w;
          Method.customMedalDialog(context, newMedal, width);
        }
      }
    });
  }

  bool playingFlag = false;
  bool actionSync = false;
  int videoCompleteCount = 0;

  void _videoListener() async {
    if(!_controller.value.isPlaying){
      if(_progressTimer != null && _progressTimer.isActive){
        _progressTimer.cancel();
      }
      recordSecond = seconds;
      playingFlag = true;
      pauseTime = DateTime.now();
      videoPauseSecond = videoPauseSecond + (pauseTime.difference(initDateTime).inMilliseconds / 1000).ceil();
      if(_timer != null && _timer.isActive){
        _timer.cancel();
      }
    }else{
      if(playingFlag){//防止调用多次
        initDateTime = DateTime.now();
        playingFlag = false;
        timerSport();
        if(widget.timing){
          setSportProgress();
        }
      }
      if(widget.interactiveEquipment == 3 && hasConnectDevice){
        if(_controller.value.position.inMilliseconds + 400 >= _controller.value.duration.inMilliseconds){
          if(actionSync){
            actionSync = false;
            _key.currentState.showAnimation();
          }
        }else{
          actionSync = false;
        }
        if(_controller.value.position >= _controller.value.duration){
          videoCompleteCount++;
        }
      }
    }
  }
  ///更新视频播放位置
  void updateVideoPosition(){
    _key.currentState.setPosition(
      position: _controller.value.position,
      totalDuration: _controller.value.duration,
    );
  }

  ///更新进度条
  void updateSlider(){
    _key.currentState.setSliderPosition(
      position: mediaOrder.toDouble(),
    );
  }

  bool onlyMedia = true;

  void syncCourseInfo(){
    if(!widget.timing && mediaOrder >= 0 && actionTypeList.length > mediaOrder && actionTypeList[mediaOrder] == '0'){//计数课程
      sportProgress = (sportCount - addSportCount) / int.parse(targetAmountList[mediaOrder]);
      if(sportProgress < 0 || sportProgress > 1){
        sportProgress = 0;
      }
      if(sportCount == int.parse(targetAmountList[mediaOrder]) + addSportCount){
        addSportCount = sportCount;
        if(onlyMedia){//防止设备发送指令过快
          onlyMedia = false;
          _urlChange();
        }
        if(widget.interactiveEquipment == 3){
          _blueToothChannel.customOrder('fea0020304');
        }else{
          Future<void>.delayed(const Duration(seconds: 3), (){//休息期间暂停运动
            _blueToothChannel.customOrder('03040000');
          });
        }
      }
    }
    if(_videoInit){
      _key.currentState.setSportDate();
      if(!widget.timing){
        _key.currentState.setSportProgress(timing: widget.timing);
      }
    }
  }


  void _onToDart(dynamic message) {
    switch(message['code'] as String){
      case '80005':
        final Uint8List data = message['data'] as Uint8List;
        if(data[1] == 0x41 && data[2] == 0x08){
          if(sportCount < data[4] + data[3] * 16 * 16 && widget.interactiveEquipment == 3){
            if(videoCompleteCount == 0){
              actionSync = true;
            }else{
              videoCompleteCount = 0;
            }
          }
          sportCount = data[4] + data[3] * 16 * 16;
          if(data[8] * 16 * 16 + data[9] >= 100){
            kcalCount = data[8] * 16 * 16 + data[9] + 0.0;
          }else{
            kcalCount = data[8] * 16 * 16 + data[9] + data[10] / 100;
          }
          syncCourseInfo();
        }else if(data[0] == 0x04 && data[1] == 0x01){
          sportCount = data[5] * 16 * 16 + data[4];
          kcalCount = data[13] * 16 * 16 + data[12] + 0.0;
          second = data[2] + data[3] * 16 * 16;
          syncCourseInfo();
        }else if(data[0] == 0x0b && data[1] == 0x01){
          _blueToothChannel.customOrder('03050000');
          if(!_controller.value.isPlaying){
            _controller.play();
            audioPlayer.resume();
            audioPlayer1.resume();
          }
        }else if(data[0] == 0x0b && data[1] == 0x02){
          _blueToothChannel.customOrder('03040000');
          if(actionTypeList[mediaOrder] == '0'){
            _controller.pause();
            if(!completeAudioPlayerState){
              audioPlayer.pause();
            }
            audioPlayer1.pause();
          }
        }else if(data[0] == 0x0b && data[1] == 0x03){
          _blueToothChannel.customOrder('03060000');
          if (_isFullScreen) {
            /// 如果是全屏就切换竖屏
            AutoOrientation.portraitAutoMode();
            ///显示状态栏，与底部虚拟操作按钮
            SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
          }
          canPopPage();
        }else if(data[1] == 0x53){
          print('0x53');
          _blueToothChannel.customOrder('fea90101');
          startDateTime = DateTime.now();
        }
    }
  }

  DateTime startDateTime;
  Duration endDuration;

  void _onToDartError(dynamic error) {
    switch (error.code as String) {
      case '90002':
        uploadSportData();
        if (_isFullScreen) {
          /// 如果是全屏就切换竖屏
          AutoOrientation.portraitAutoMode();
          ///显示状态栏，与底部虚拟操作按钮
          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
        }
        canPopPage();
        break;
    }
  }

  String totalBmpData = '';//记录一连串心率
  String totalBmpTime = '';//记录一连串心率时间
  List<Map<String, Object>> netSaveDataList = <Map<String, Object>>[];//用于将数据上传至网络
  Map<String, dynamic> _netSportMap;//向云端上传运动数据的map
  int _deviceType = 1;//上传给云端的设备类型
  int second = 0;

  void uploadSportData(){
    endDuration = DateTime.now().difference(startDateTime);
    final int length = totalBmpData.split('-').length;
    int avgLength;
    if(length > 60){
      avgLength = length ~/ 60 + 1;
    }else{
      avgLength = 1;
    }
    final List<String> bmpData = totalBmpData.split('-');
    final List<String> bmpTimes = totalBmpTime.split('-');
    final List<Map<String, Object>> totalBmpList = [];
    for(int i = 0; i < length;){
      if(bmpData[i] != ''){
        totalBmpList.add(<String, Object>{
          'heartRate': int.parse(bmpData[i].toString()),
          'time': bmpTimes[i],
        });
      }
      i = i + avgLength;
    }
    _deviceType = widget.interactiveEquipment;
    _netSportMap = <String, dynamic>{
      'calories': kcalCount,
      'count': sportCount,
      'duringTime': endDuration.inSeconds,
      'equipmentType': _deviceType,
      'heartRateProcess': totalBmpList,
      'offline': false,
      'mode': SaveData.sportMode,
      'trainMode': 1,
      'startTime': startDateTime.toString().substring(0,19),
      'timeZone': DateTime.now().timeZoneOffset.inHours,
      'userId': SaveData.userId,
    };
    netSaveDataList.add(_netSportMap);
    DioUtil().post(
        RequestUrl.historySportDataUrl,
        data: netSaveDataList,
        options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass,Headers.contentTypeHeader:ContentType.json}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      print(value);
      if(value['code'] == '200'){
        netSaveDataList.clear();
      }else{
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }

  void canPopPage(){
    if(Navigator.canPop(context)){
      Navigator.of(context).pop();
      if(Navigator.canPop(context)){
        Navigator.of(context).pop();
        if(Navigator.canPop(context)){
          Navigator.of(context).pop();
          if(Navigator.canPop(context)){
            Navigator.of(context).pop();
          }
        }
      }
    }
  }

  void _sliderValue(DragEndDetails details) {
    if(_timer != null){
      _timer.cancel();
      _timer = null;
    }
    if(mediaOrder != 0 || nextVideo){
      _urlChange();
      videoPauseSecond = 0;
    }
  }

  bool nextVideo = true;
  double dx = 0;

  void _sliderUpdate(DragUpdateDetails details) {
    print(details.localPosition.dx);
    if(details.localPosition.dx < dx){
      nextVideo = false;
    }else{
      nextVideo = true;
    }
    sportProgress = 0;
    _key.currentState.setSportProgress();
    dx = details.localPosition.dx;
  }

  void _mediaUpdateConfirm(){
    endCourse();
    hasDownload = false;
    downLoadMedia();
  }

  void _updateCancel() {
    _urlChange();
  }
}
