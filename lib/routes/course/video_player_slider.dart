// import 'dart:async';
// import 'package:common_utils/common_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'controller_widget.dart';
// import 'video_player_control.dart';
//
// class VideoPlayerSlider extends StatefulWidget {
//   final Function startPlayControlTimer;
//   final Timer timer;
//
//   VideoPlayerSlider({this.startPlayControlTimer, this.timer});
//
//   @override
//   _VideoPlayerSliderState createState() => _VideoPlayerSliderState();
// }
//
// class _VideoPlayerSliderState extends State<VideoPlayerSlider> {
//   VideoPlayerController get controller => ControllerWidget.of(context).controller;
//   bool get videoInit => ControllerWidget.of(context).videoInit;
//   double progressValue; //进度
//   String labelProgress; //tip内容
//   bool handle = false; //判断是否在滑动的标识
//
//   @override
//   void initState() {
//     super.initState();
//     progressValue = 0.0;
//     labelProgress = '00:00';
//     print('initState');
//   }
//
//   @override
//   void didUpdateWidget(VideoPlayerSlider oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (!handle && videoInit) {
//       int position = controller.value.position.inMilliseconds;
//       int duration = controller.value.duration.inMilliseconds;
//       if(position>=duration){
//         position=duration;
//       }
//       setState(() {
//         progressValue = position / duration * 100;
//         labelProgress = DateUtil.formatDateMs(
//           progressValue.toInt(),
//           format: 'mm:ss',
//         );
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     int position = controller.value.position.inMilliseconds;
//     int duration = controller.value.duration.inMilliseconds;
//     if(position>=duration){
//       position=duration;
//     }
//     progressValue = position / duration * 100;
//     labelProgress = DateUtil.formatDateMs(
//       progressValue.toInt(),
//       format: 'mm:ss',
//     );
//     return SliderTheme(
//       //自定义风格
//       data: SliderTheme.of(context).copyWith(
//         //进度条滑块左边颜色
//         inactiveTrackColor: Colors.white,
//         overlayShape: RoundSliderOverlayShape(
//           //可继承SliderComponentShape自定义形状
//           overlayRadius: 7, //滑块外圈大小
//         ),
//         thumbShape: RoundSliderThumbShape(
//           //可继承SliderComponentShape自定义形状
//           disabledThumbRadius: 7, //禁用是滑块大小
//           enabledThumbRadius: 7, //滑块大小
//         ),
//       ),
//       child: Slider(
//         value: progressValue,
//         label: labelProgress,
//         divisions: 100,
//         onChangeStart: _onChangeStart,
//         onChangeEnd: _onChangeEnd,
//         onChanged: _onChanged,
//         min: 0,
//         max: 100,
//         activeColor: Color.fromRGBO(249, 122, 53, 1),
//       ),
//     );
//   }
//
//   void _onChangeEnd(_) {
//     if (!videoInit) {
//       return;
//     }
//     widget.startPlayControlTimer();
//     // 关闭手动操作标识
//     handle = false;
//     // 跳转到滑动时间
//     int duration = controller.value.duration.inMilliseconds;
//     controller.seekTo(
//       Duration(milliseconds: (progressValue / 100 * duration).toInt()),
//     );
// //    if (!controller.value.isPlaying) {
// //      controller.play();
// //    }
//   }
//
//   void _onChangeStart(_) {
//     if (!videoInit) {
//       return;
//     }
//     if (widget.timer != null) {
//       widget.timer.cancel();
//     }
//     // 开始手动操作标识
//     handle = true;
// //    if (controller.value.isPlaying) {
// //      controller.pause();
// //    }
//   }
//
//   void _onChanged(double value) {
//     if (!videoInit) {
//       return;
//     }
//     if (widget.timer != null) {
//       widget.timer.cancel();
//     }
//     int duration = controller.value.duration.inMilliseconds;
//     setState(() {
//       progressValue = value;
//       labelProgress = DateUtil.formatDateMs(
//         (value / 100 * duration).toInt(),
//         format: 'mm:ss',
//       );
//     });
//   }
// }

// import 'dart:async';
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:running_app/common/blueToothChannel.dart';
// import 'package:running_app/common/encapMethod.dart';
//
// class CustomOrderPage extends StatefulWidget {
//   const CustomOrderPage({Key key}) : super(key: key);
//
//   @override
//   _CustomOrderPageState createState() => _CustomOrderPageState();
// }
//
// class _CustomOrderPageState extends State<CustomOrderPage> {
//
//   bool defaultOrderOne = true;
//   bool defaultOrderTwo = true;
//   bool updateOrder = false;
//   String order = '';
//   bool hasConnect = true;
//   final BlueToothChannel _blueToothChannel = BlueToothChannel();
//   StreamSubscription streamSubscriptions;
//
//   @override
//   void initState() {
//     super.initState();
//     streamSubscriptions = _blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
//     Future.delayed(Duration.zero,(){
//       Method.showToast('欢迎黄总使用！！！', context, position: 1, second: 2);
//     });
//   }
//
//   void _onToDart(dynamic message) {
//     switch (message['code'] as String) {
//       case '80001':
//
//         break;
//     }
//   }
//
//   void _onToDartError(dynamic error) {
//     switch (error.code as String) {
//       case '90002':
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context, width: 540, height: 960, allowFontScaling: false);
//     print('?????????????');
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('为黄总服务'),
//         actions: [
//           OutlineButton(
//             child: Text(hasConnect ? updateOrder ? '可以修改' : '不能修改' : '未连接', style: TextStyle(color: Colors.white),),
//             onPressed: (){
//               setState(() {
//                 if(updateOrder){
//                   updateOrder = false;
//                   defaultOrderOne = true;
//                   defaultOrderTwo = true;
//                 }else{
//                   updateOrder = true;
//                 }
//               });
//             },
//           )
//         ],
//       ),
//       body: GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onTap: () {
//           FocusScope.of(context).requestFocus(FocusNode());
//         },
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               // if(!defaultOrderOne)
//                 TextField(
//                   decoration: InputDecoration(
//                       suffixIcon: OutlineButton(
//                         child: const Text('黄总请点击'),
//                         onPressed: (){
//                           _blueToothChannel.customOrder(order);
//                         },
//                       )
//                   ),
//                   onChanged: (String val){
//                     order = val;
//                   },
//                 ),
//               // if(!defaultOrderTwo)
//               //   TextField(
//               //     decoration: InputDecoration(
//               //         suffixIcon: OutlineButton(
//               //           child: const Text('黄总请点击'),
//               //           onPressed: (){
//               //             _blueToothChannel.customOrder(order);
//               //           },
//               //         )
//               //     ),
//               //     onChanged: (String val){
//               //       order = val;
//               //     },
//               //   ),
//               // if(defaultOrderOne)
//               //   OutlineButton(
//               //     child: const Text('黄总要的默认指令一'),
//               //     onPressed: (){
//               //       if(hasConnect){
//               //         if(updateOrder){
//               //           setState(() {
//               //             defaultOrderOne = false;
//               //           });
//               //         }
//               //       }else{
//               //         Method.showToast('未连接设备', context);
//               //       }
//               //     },
//               //   ),
//               // if(defaultOrderTwo)
//               //   OutlineButton(
//               //     child: const Text('黄总要的默认指令二'),
//               //     onPressed: (){
//               //       if(hasConnect){
//               //         if(updateOrder){
//               //           setState(() {
//               //             defaultOrderTwo = false;
//               //           });
//               //         }
//               //       }else{
//               //         Method.showToast('未连接设备', context);
//               //       }
//               //     },
//               //   ),
//             ],
//           ),
//         ),
//       ),
//       bottomSheet: Container(
//         child: Row(
//           children: <Widget>[
//             Expanded(
//               child: Container(
//                 height: 50,
//                 margin: EdgeInsets.only(left: 15, bottom: 10),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: '黄总请输入',
//                     border: OutlineInputBorder()
//                   ),
//                   onChanged: (String val){
//
//                   },
//                 ),
//               ),
//             ),
//             Container(
//               margin: EdgeInsets.only(left: 10, bottom: 10, right: 15),
//               child: RaisedButton(
//                 child: Text('发送'),
//                 onPressed: () {},
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _blueToothChannel.disConnect();
//   }
// }
