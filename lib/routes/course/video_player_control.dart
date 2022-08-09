import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/routes/course/video_player_UI.dart';
import 'package:video_player/video_player.dart';
import 'controller_widget.dart';
import 'courseDetailPage.dart';
import 'package:running_app/common/saveData.dart';

class VideoPlayerControl extends StatefulWidget {

  VideoPlayerControl({
    Key key,
  }) : super(key: key);

  @override
  VideoPlayerControlState createState() => VideoPlayerControlState();
}

class VideoPlayerControlState extends State<VideoPlayerControl> with SingleTickerProviderStateMixin{
  VideoPlayerController get controller => ControllerWidget.of(context).controller;
  BlueToothChannel get blueToothChannel => ControllerWidget.of(context).blueToothChannel;
  AudioPlayer get actionAudioPlayer => ControllerWidget.of(context).actionAudioPlayer;
  AudioPlayer get bgAudioPlayer => ControllerWidget.of(context).bgAudioPlayer;
  bool get videoInit => ControllerWidget.of(context).videoInit;
  String get title=>ControllerWidget.of(context).title;
  // 记录video播放进度
  Duration _position = Duration(seconds: 0);
  Duration _totalDuration = Duration(seconds: 0);
  Timer _timer; // 计时器，用于延迟隐藏控件ui
  bool hidePlayControl = true; // 控制是否隐藏控件ui
  bool hideActionSync = true; // 控制是否隐藏控件ui
  double _playControlOpacity = 0; // 通过透明度动画显示/隐藏控件ui
  double _actionSyncOpacity = 0; // 通过透明度动画显示/隐藏控件ui
  int _sportCount = 0;//运动次数
  double _kcalCount = 0;//运动消耗卡路里
  double sportProgress = 0;
  bool timing = true;
  /// 记录是否全屏
  bool get _isFullScreen => MediaQuery.of(context).orientation == Orientation.landscape;

  int totalValue;
  double currentValue = 0;

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 2208),
      builder: () => GestureDetector(
        onDoubleTap: _playOrPause,
        onTap: _togglePlayControl,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: WillPopScope(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if(CourseDetailPageState.hasConnectDevice)
                Positioned(
                  right: 0,
                  child: _middle(),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearPercentIndicator(
                    backgroundColor: Colors.grey[400],
                    percent: sportProgress,
                    progressColor: Colors.grey,
                    padding: EdgeInsets.zero,
                    lineHeight: _isFullScreen ? 25 : 12,
                    animateFromLastPercent: timing,
                    animation: timing,
                    animationDuration: sportProgress == 0 ? 500 : 1000,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    if(!hidePlayControl)
                      AnimatedOpacity(
                        // 加入透明度动画
                        opacity: _playControlOpacity,
                        duration: const Duration(milliseconds: 300),
                        child: _top(),
                      ),
                    Expanded(child: Container(),),
                    if(!hidePlayControl)
                      AnimatedOpacity(
                        // 加入透明度动画
                        opacity: _playControlOpacity,
                        duration: const Duration(milliseconds: 300),
                        child: _bottom(context),
                      ),
                  ],
                ),
                if(!hideActionSync)
                Positioned(
                  child: AnimatedOpacity(
                    opacity: _actionSyncOpacity,
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset('images/GoodJob.gif', width: 1002.w, height: 404.h,),
                  ),
                ),
              ],
            ),
            onWillPop: _onWillPop,
          ),
        ),
      ),
    );
  }

  // 拦截返回键
  Future<bool> _onWillPop() async {
    if (_isFullScreen) {
      _toggleFullScreen();
      return false;
    }
    return true;
  }

  // 供父组件调用刷新页面，减少父组件的build
  void setPosition({Duration position, Duration totalDuration}) {
    setState(() {
      _position = position;
      _totalDuration = totalDuration;
    });
  }
  void setSportDate() {
    setState(() {
      _sportCount = CourseDetailPageState.sportCount;
      _kcalCount = CourseDetailPageState.kcalCount;
    });
  }

  void setSportProgress({bool timing = true}){
    setState(() {
      sportProgress = CourseDetailPageState.sportProgress;
      timing = timing;
    });
  }

  void setSliderPosition({double position, int total}) {
    setState(() {
      currentValue = position;
    });
  }

  void showAnimation(){//展示动作同步动画
    hideActionSync = false;
    _actionSyncOpacity = 1;
    setActionSyncAnimation();
  }

  void setActionSyncAnimation(){
    if (_timer != null) _timer.cancel();
    _timer = Timer(const Duration(seconds: 1), () {
      /// 延迟1s后隐藏
      if(mounted){
        setState(() {
          _actionSyncOpacity = 0;
          Future<void>.delayed(const Duration(milliseconds: 500), (){//500毫秒后隐藏UI
            if(mounted){
              setState(() {
                hideActionSync = true;
              });
            }
          });
        });
      }
    });
  }

  Widget _bottom(BuildContext context) {
    return Container(
      // 底部控件的容器
      width: double.infinity,
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          // 来点黑色到透明的渐变优雅一下
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color.fromRGBO(0, 0, 0, .5), Color.fromRGBO(0, 0, 0, 0.0)],
        ),
      ),
      child: Row(
        // 加载完成时才渲染,flex布局
        children: <Widget>[
          Container(
            width: 26,
            height: 26,
            child: FlatButton(
              padding: const EdgeInsets.only(left: 12),
              splashColor: Colors.transparent,
              child: Icon(
                // 根据控制器动态变化播放图标还是暂停
                controller != null && controller.value != null && controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: _playOrPause,
            ),
          ),
          Expanded(
            child: Slider(
              divisions: SaveData.sliderMaxValue,
              value: currentValue,
              min: 0,
              onChanged: (val){

              },
              max: SaveData.sliderMaxValue.toDouble(),
              inactiveColor: Colors.white,
              activeColor: Colors.grey,
            ),
          ),
          // Expanded(
          //   // 相当于前端的flex: 1
          //   child: VideoPlayerSlider(
          //     startPlayControlTimer: _startPlayControlTimer,
          //     timer: _timer,
          //   ),
          // ),
          // Container(
          //   // 播放时间
          //   margin: EdgeInsets.only(left: 10),
          //   child: Text(
          //     '${DateUtil.formatDateMs(
          //       _position?.inMilliseconds,
          //       format: 'mm:ss',
          //     )}/${DateUtil.formatDateMs(
          //       _totalDuration?.inMilliseconds,
          //       format: 'mm:ss',
          //     )}',
          //     style: TextStyle(color: Colors.white),
          //   ),
          // ),
          Container(
            width: 26,
            height: 26,
            child: FlatButton(
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              child: Icon(
                // 根据当前屏幕方向切换图标
                _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
              ),
              onPressed: () {
                // 点击切换是否全屏
                _toggleFullScreen();
              },
            ),
          ),
          const SizedBox(
            width: 12,
          )
        ],
      ),
    );
  }

  Widget _middle() {
    return Padding(
      padding: EdgeInsets.only(right: _isFullScreen ? 84.w : 72.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: _isFullScreen ? 122.w : 158.w,
            height: _isFullScreen ? 122.w : 158.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(_isFullScreen ? 61.w : 79.w)),
                border: Border.all(color: Colors.grey.withOpacity(0.6), width: _isFullScreen ? 4.5 : 2.5),
                gradient: RadialGradient( //背景径向渐变
                    colors: [Colors.white, Colors.grey],
                    center: Alignment.center,
                    radius: 0.8
                )
            ),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                SizedBox(height: _isFullScreen ? 16.w : 24.w,),
                Text('个数', style: TextStyle(fontSize: _isFullScreen ? 16.w : 22.w, color: Colors.black.withOpacity(0.55)),),
                Text(
                  _sportCount.toStringAsFixed(0),
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.55),
                      fontSize: _sportCount > 999 ? _isFullScreen ? 34.w : 45.w
                          : _isFullScreen ? 40.w : 56.w),)
              ],
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Container(
            width: _isFullScreen ? 122.w : 158.w,
            height: _isFullScreen ? 122.w : 158.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(_isFullScreen ? 61.w : 79.w)),
                border: Border.all(color: Colors.grey.withOpacity(0.6), width: _isFullScreen ? 4.5 : 2.5),
                gradient: RadialGradient( //背景径向渐变
                    colors: [Colors.white, Colors.grey],
                    center: Alignment.center,
                    radius: 0.8
                )
            ),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                SizedBox(height: _isFullScreen ? 24.w : 30.w,),
                Text(
                  _kcalCount.toStringAsFixed(0),
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.55),
                      fontSize: _isFullScreen ? 40.w : 58.w),),
                Text('kcal', style: TextStyle(fontSize: _isFullScreen ? 16.w : 22.w, color: Colors.black.withOpacity(0.55)),),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _top() {
    return Container(
      width: double.infinity,
      height: 40,
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          // 来点黑色到透明的渐变优雅一下
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color.fromRGBO(0, 0, 0, 0.0), Color.fromRGBO(0, 0, 0, .5)],
        ),
      ),
      child: FlatButton.icon(
          onPressed: backPress,
          icon: //在最上层或者不是横屏则隐藏按钮
          ModalRoute.of(context).isFirst && !_isFullScreen
              ? Container()
              : Icon(Icons.arrow_back_ios, color: Colors.white,size: 18,),
          label: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
      )
    );
  }


  void backPress() {
    // 如果是全屏，点击返回键则关闭全屏，如果不是，则系统返回键
    if (_isFullScreen) {
      _toggleFullScreen();
    } else if(ModalRoute.of(context).isFirst) {
      SystemNavigator.pop();
    }else{
      Navigator.pop(context);
      if(CourseDetailPageState.hasConnectDevice){
        blueToothChannel.customOrder('03060000');
      }
    }

  }

  void _playOrPause() {
    /// 同样的，点击动态播放或者暂停
    if (videoInit) {
      setState(() {
        if(controller.value.isPlaying){
          controller.pause();
          bgAudioPlayer.pause();
          actionAudioPlayer.pause();
          if(CourseDetailPageState.hasConnectDevice){
            blueToothChannel.customOrder('03040000');
          }
        }else{
          controller.play();
          actionAudioPlayer.resume();
          bgAudioPlayer.resume();
          if(CourseDetailPageState.hasConnectDevice){
            blueToothChannel.customOrder('03050000');
          }
        }
        // controller.value.isPlaying ? controller.pause() : controller.play();
        _startPlayControlTimer(); // 操作控件后，重置延迟隐藏控件的timer
      });
    }
  }

  void _togglePlayControl() {
    setState(() {
      if (hidePlayControl) {
        /// 如果隐藏则显示
        hidePlayControl = false;
        _playControlOpacity = 1;
        _startPlayControlTimer(); // 开始计时器，计时后隐藏
      } else {
        /// 如果显示就隐藏
        if (_timer != null) _timer.cancel(); // 有计时器先移除计时器
        _playControlOpacity = 0;
        Future<void>.delayed(const Duration(milliseconds: 500)).whenComplete(() {
          setState(() {
            hidePlayControl = true; // 延迟500ms(透明度动画结束)后，隐藏
          });
        });
      }
    });
  }

  void _startPlayControlTimer() {
    if (_timer != null) _timer.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      /// 延迟3s后隐藏
      if(mounted){
        setState(() {
          _playControlOpacity = 0;
          Future<void>.delayed(const Duration(milliseconds: 500)).whenComplete(() {
            if(mounted){
              setState(() {
                hidePlayControl = true;
              });
            }
          });
        });
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      if (_isFullScreen) {
        /// 如果是全屏就切换竖屏
        AutoOrientation.portraitAutoMode();

        ///显示状态栏，与底部虚拟操作按钮
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
      } else {
        AutoOrientation.landscapeAutoMode();

        ///关闭状态栏，与底部虚拟操作按钮
        SystemChrome.setEnabledSystemUIOverlays([]);
      }
      _startPlayControlTimer(); // 操作完控件开始计时隐藏
    });
  }
}