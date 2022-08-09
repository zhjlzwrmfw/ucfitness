import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/common/encapMethod.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';

class FasciaGunMainPage extends StatefulWidget {
  const FasciaGunMainPage({Key key}) : super(key: key);

  @override
  _FasciaGunMainPageState createState() => _FasciaGunMainPageState();
}

class _FasciaGunMainPageState extends State<FasciaGunMainPage> {

  // double position = 0;
  bool isOpen = false;
  String modeName = '普通模式';
  int mode = 0;
  int eleAmount = 0;
  DateTime _lastPressedAt;//记录点击返回键的时间
  StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息
  final BlueToothChannel _blueToothChannel = BlueToothChannel();
  FixedExtentScrollController scrollController1;//更改语音播报次数对应
  bool firstEnter = true;
  List<String> list = ['颈', '背', '臂', '腿', '臀'];
  List<bool> choose =<bool>[false,false,false,false,false];
  int drawCount = 0;

  List<String> dataList = [];
  ScrollController _controller;
  String copyString;
  String fileName;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _streamSubscription = _blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
  }

  @override
  // void dispose() {
  //   super.dispose();
  //   MyBluetoothPlugin.disConnectDevice(SaveData.deviceName);
  // }

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.init(context, width: 375, height: 812, allowFontScaling: false);
    // return WillPopScope(
    //   onWillPop: () async {
    //     if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
    //       //两次点击间隔超过1秒则重新计时
    //       _lastPressedAt = DateTime.now();
    //       Method.showToast('Press again to exit'.tr, context);
    //       return false;
    //     }else{
    //       Navigator.of(context).pop();
    //       return true;
    //     }
    //   },
    //   child: Scaffold(
    //     appBar: AppBar(
    //       leading: FlatButton(
    //         child: Icon(
    //           Icons.arrow_back_ios,
    //           color: Colors.white,
    //         ),
    //         onPressed: () {
    //           Navigator.of(context).pop();
    //           MyBluetoothPlugin.disConnectDevice(SaveData.deviceName);
    //         },
    //       ),
    //       title: const Text('筋膜枪'),
    //       centerTitle: false,
    //       backgroundColor: const Color.fromRGBO(249, 122, 53, 1),
    //     ),
    //     body: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Column(
    //               children: [
    //                 for (int i = 0; i < list.length; i++) buildButton(i),
    //               ],
    //             ),
    //             Image.asset(
    //               'images/body_blank_man_front.png',
    //               height: ScreenUtil().setHeight(400),
    //             ),
    //           ],
    //         ),
    //         RepaintBoundary(
    //           child: GestureDetector(
    //             child: Container(
    //               width: ScreenUtil().setWidth(280),
    //               height: ScreenUtil().setHeight(50),
    //               child: CustomPaint(
    //                 painter: SliderBackground(),
    //                 foregroundPainter: SliderDraw(drawCount,mode),
    //                 isComplex: true,
    //                 willChange: false,
    //               ),
    //             ),
    //             onTapUp: isOpen?(TapUpDetails v) {
    //               setState(() {
    //                 if(mode!=0){
    //                   mode=0;
    //                   // chooseMode(mode);
    //                 }
    //                 drawCount = (v.localPosition.dx *
    //                     4 /
    //                     ScreenUtil().setWidth(280))
    //                     .truncate() +
    //                     1;
    //                 print("drawCount:$drawCount");
    //                 switch (drawCount){
    //                   case 1 : _blueToothChannel.updateFasciaNumber(30);break;
    //                   case 2 : _blueToothChannel.updateFasciaNumber(53);break;
    //                   case 3 : _blueToothChannel.updateFasciaNumber(76);break;
    //                   case 4 : _blueToothChannel.updateFasciaNumber(99);break;
    //                 }
    //               });
    //             }:null,
    //           ),
    //         ),
    //         SizedBox(
    //           height: ScreenUtil().setHeight(12),
    //         ),
    //         Container(
    //           width: ScreenUtil().setWidth(327),
    //           height: ScreenUtil().setHeight(120),
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.all(
    //                 Radius.circular(ScreenUtil().setWidth(12))),
    //             color: Color.fromRGBO(240, 240, 240, 1),
    //           ),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Container(
    //                 width: ScreenUtil().setWidth(163.5),
    //                 height: ScreenUtil().setHeight(120),
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.only(
    //                     topLeft: Radius.circular(ScreenUtil().setWidth(12)),
    //                     bottomLeft: Radius.circular(ScreenUtil().setWidth(12)),
    //                   ),
    //                 ),
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     Image.asset('images/battery.png',width: ScreenUtil().setWidth(10),),
    //                     Text(eleAmount.toString()+"%"),
    //                   ],
    //                 ),
    //               ),
    //               Container(
    //                 width: ScreenUtil().setWidth(163.5),
    //                 height: ScreenUtil().setHeight(120),
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.only(
    //                     topRight: Radius.circular(ScreenUtil().setWidth(12)),
    //                     bottomRight: Radius.circular(ScreenUtil().setWidth(12)),
    //                   ),
    //                 ),
    //                 child: FlatButton(
    //                   child: Column(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: [
    //                       Icon(Icons.power_settings_new,color: isOpen ? const Color.fromRGBO(249, 122, 53, 1) : Colors.grey.withOpacity(0.6),),
    //                       Text(isOpen ? '开' : '关',style: TextStyle(color: isOpen ? const Color.fromRGBO(249, 122, 53, 1) : Colors.grey.withOpacity(0.6),),),
    //                     ],
    //                   ),
    //                   shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.only(
    //                       topRight: Radius.circular(ScreenUtil().setWidth(12)),
    //                       bottomRight: Radius.circular(ScreenUtil().setWidth(12)),
    //                     ),
    //                   ),
    //                   onPressed: firstEnter ? null : () {
    //                     setState(() {
    //                       if (isOpen) {
    //                         isOpen = false;
    //                         drawCount=0;
    //                         // position = ScreenUtil().setHeight(202).toDouble();
    //                       } else {
    //                         isOpen = true;
    //                       }
    //                     });
    //                     _blueToothChannel.openFascia(isOpen);
    //                     },
    //                 ),
    //               ),
    //             ],
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
    return ScreenUtilInit(
      designSize: Size(360, 640),
      builder: () => Scaffold(
        appBar: AppBar(
          title: const Text('获取数据'),
          centerTitle: false,
          backgroundColor: const Color.fromRGBO(249, 122, 53, 1),
        ),
        body: Scrollbar(
          child: ListView(
              controller: _controller,
              itemExtent: ScreenUtil().setHeight(66).toDouble(),
              children: <Widget>[
                for(int i = 0; i < dataList.length; i++)
                  Container(
                    margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(9).toDouble()),
                    child: Text(dataList[i]),
                  )
              ]
          ),
        ),
        bottomSheet: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: ScreenUtil().setHeight(108).toDouble(),
              width: ScreenUtil().setWidth(120).toDouble(),
              child: FlatButton(
                  onPressed: (){
                    dataList.clear();
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context){
                        return SimpleDialog(
                          title: const Text('安装选项'),
                          children: <Widget>[
                            SimpleDialogOption(
                              child: const Text('正面安装1'),
                              onPressed: (){
                                Navigator.of(context).pop();
                                _streamSubscription = _blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
                                Future.delayed(const Duration(milliseconds: 300),(){
                                  _blueToothChannel.customOrder('FEac0100');
                                });
                                choseMode();
                              },
                            ),
                            SimpleDialogOption(
                              child: const Text('正面安装2'),
                              onPressed: (){
                                Navigator.of(context).pop();
                                _streamSubscription = _blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
                                Future.delayed(const Duration(milliseconds: 300),(){
                                  _blueToothChannel.customOrder('FEac0102');
                                });
                                choseMode();
                              },
                            ),
                            SimpleDialogOption(
                              child: const Text('侧面安装'),
                              onPressed: (){
                                Navigator.of(context).pop();
                                _streamSubscription = _blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
                                Future.delayed(const Duration(milliseconds: 300),(){
                                  _blueToothChannel.customOrder('FEac0101');
                                });
                                choseMode();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('开始')),
            ),
            Container(
              height: ScreenUtil().setHeight(108).toDouble(),
              width: ScreenUtil().setWidth(120).toDouble(),
              child: FlatButton(
                  onPressed: (){
                    _blueToothChannel.closeData();
                  },
                  child: const Text('停止')),
            ),
            Container(
              height: ScreenUtil().setHeight(108).toDouble(),
              width: ScreenUtil().setWidth(120).toDouble(),
              child: FlatButton(
                  onPressed: (){
                    // ClipboardData data = ClipboardData(text: copyString);
                    // Clipboard.setData(data);
                    copyData();
                    Method.showToast('文件生成成功！', context);
                  },
                  child: const Text('生成文件')),
            ),
          ],
        ),
      ),
    );
  }

  void choseMode(){
    showDialog<void>(
        context: context,
        builder: (context){
          return SimpleDialog(
            title: const Text('选择模式'),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text('模式一'),
                onPressed: (){
                  _blueToothChannel.setMode(1, 3);
                  Future<void>.delayed(const Duration(milliseconds: 300),(){
                    _blueToothChannel.customOrder('fea90101');
                    fileName = 'ModeOne' + DateTime.now().millisecondsSinceEpoch.toString();
                    print(fileName);
                    Future.delayed(const Duration(milliseconds: 300),(){
                      _blueToothChannel.customOrder('fea30101');
                      Future.delayed(const Duration(milliseconds: 300),(){
                        _blueToothChannel.openData();
                      });
                    });
                  });
                  Navigator.of(context).pop();
                },
              ),
              SimpleDialogOption(
                child: const Text('模式二'),
                onPressed: (){
                  _blueToothChannel.setMode(2, 3);
                  Future<void>.delayed(const Duration(milliseconds: 300),(){
                    _blueToothChannel.customOrder('fea90101');
                    fileName = 'ModeTwo' + DateTime.now().millisecondsSinceEpoch.toString();
                    print(fileName);
                    Future.delayed(const Duration(milliseconds: 300),(){
                      _blueToothChannel.customOrder('fea30101');
                      Future.delayed(const Duration(milliseconds: 300),(){
                        _blueToothChannel.openData();
                      });
                    });
                  });
                  Navigator.of(context).pop();
                },
              ),
              SimpleDialogOption(
                child: const Text('模式三'),
                onPressed: (){
                  _blueToothChannel.setMode(3, 3);
                  Future<void>.delayed(const Duration(milliseconds: 300),(){
                    _blueToothChannel.customOrder('fea90101');
                    fileName = 'ModeThree' + DateTime.now().millisecondsSinceEpoch.toString();
                    print(fileName);
                    Future.delayed(const Duration(milliseconds: 300),(){
                      _blueToothChannel.customOrder('fea30101');
                      Future.delayed(const Duration(milliseconds: 300),(){
                        _blueToothChannel.openData();
                      });
                    });
                  });
                  Navigator.of(context).pop();
                },
              ),
              SimpleDialogOption(
                child: const Text('模式四'),
                onPressed: (){
                  _blueToothChannel.setMode(4, 3);
                  Future<void>.delayed(const Duration(milliseconds: 300),(){
                    _blueToothChannel.customOrder('fea90101');
                    fileName = 'ModeFour' + DateTime.now().millisecondsSinceEpoch.toString();
                    print(fileName);
                    Future.delayed(const Duration(milliseconds: 300),(){
                      _blueToothChannel.customOrder('fea30101');
                      Future.delayed(const Duration(milliseconds: 300),(){
                        _blueToothChannel.openData();
                      });
                    });
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  void _onToDart(dynamic message) {
    switch (message['code'] as String) {
      case '80005':
        final Uint8List data = message['data'] as Uint8List;
        // if(data[1] == 0x5A){
        //   if(mounted){
        //     setState(() {
        //       firstEnter = false;
        //       eleAmount = data[6];
        //       mode = data[4];
        //       if(mode == 0){
        //         modeName = '普通模式';
        //         // mode = 1;
        //         print("mode:$mode");
        //         chooseMode(mode);
        //       }
        //       if(data[3] == 0x00){
        //         isOpen = false;
        //         drawCount=0;
        //         // position = ScreenUtil().setHeight(202).toDouble();
        //       }else{
        //         isOpen = true;
        //         print(data[5]);
        //         drawCount = ((data[5]-7)/(99-7)*4).truncate();//pwm为0-7时,电机无法转动，有效pwm为8-99，共计92份；
        //         print(drawCount);
        //         // position = (ScreenUtil().setHeight(202) * (1 - data[5] / 99)).toDouble();
        //       }
        //     });
        //   }
        //   // if(mode != 0){
        //   //   scrollController1 = FixedExtentScrollController(initialItem: mode - 1);
        //   // }
        // }else if(data[1] == 0x4A){
        //   setState(() {
        //     eleAmount = data[3];
        //   });
        // }
      if(data.length >= 20){
        if(mounted){
          setState(() {
            String getData = '';
            for(int i = 0; i < data.length; i++){
              if(data[i] < 16){
                getData =  getData + '0' + data[i].toRadixString(16).toUpperCase();
              }else{
                getData = getData + data[i].toRadixString(16).toUpperCase();
              }
            }
            dataList.add(getData);
            _controller.jumpTo(_controller.position.maxScrollExtent);
          });
        }
      }
      if(data[0] == 0x80 && data[1] == 0x00){
        copyString = '';
        _blueToothChannel.customOrder('fea30100');
        Future.delayed(const Duration(milliseconds: 300),(){
          _blueToothChannel.customOrder('fea90100');
        });
        for(int i = 0; i < dataList.length; i++){
          copyString = copyString + dataList[i] + '\n';
        }
      }
        break;
    }
  }

  void _onToDartError(dynamic error){
    switch (error.code as String) {
      case '90002':
        if(Navigator.canPop(context)){
          Navigator.of(context).pop();
          if(Navigator.canPop(context)){
            Navigator.of(context).pop();
          }
        }
        break;
    }
  }

  void chooseMode(int mode){
    setState(() {
      for(int i=0;i<choose.length;i++) {
        if(i==mode-1){
          choose[i]=true;
           _blueToothChannel.changeFasciaMode(mode);
        }
        else choose[i]=false;
      }
    });
  }

  Future<File> _getLocalFile() async {
    // 获取应用目录
    String dir = (await getExternalStorageDirectory()).path;
    print('$dir/' + fileName + '.txt');
    return File('$dir/' + fileName + '.txt');
  }

  Future<void> copyData() async {
    await (await _getLocalFile()).writeAsString(copyString);
  }

  Widget buildButton(int i) {
    return RaisedButton(
      child: Text(list[i]),
      color: choose[i]?Colors.blue:Colors.grey,
      onPressed: isOpen?() {
        if(choose[i]==true){
          mode=0;
          chooseMode(mode);
          _blueToothChannel.updateFasciaNumber(drawCount*23+7);
        }
        else{
          mode=i+1;
          chooseMode(mode);
        }
      }:null,
    );
  }
}

class SliderBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = new Paint()
      ..isAntiAlias = true
      ..color = Color.fromRGBO(228, 228, 228, 1);
    canvas.drawRect(
        Rect.fromPoints(Offset.zero, Offset(size.width, size.height)), paint);
    paint
      ..color = Colors.white
      ..strokeWidth = ScreenUtil().setWidth(4);
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
          Offset(size.width / 4 * i, 0),
          Offset(size.width / 4 * i, size.height),
          paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class SliderDraw extends CustomPainter {
  int count;
  int mode;
  SliderDraw(this.count,this.mode);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true;
    if(mode==0)
      paint.color = Color.fromRGBO(249, 122, 53, 1);
    else
      paint.color =Color.fromRGBO(255, 138, 101, 0.56);
    for (var i = 0; i < count; i++) {
        canvas.drawRect(
            Rect.fromPoints(
                Offset(size.width / 280 * 71 * i, 0),
                Offset(size.width / 280 * (67 + 71 * i),
                    size.height)),
            paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}



