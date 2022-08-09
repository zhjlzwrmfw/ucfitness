import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_bluetooth_plugin/my_bluetooth_plugin.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:flutter/foundation.dart';
import '../../common/blueUuid.dart';
import '../../common/requesrUrl.dart';
import '../../common/saveData.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:convert/convert.dart';

class OtaPage extends StatefulWidget{

  OtaPage({this.whichDevice});

  @override
  OtaPageState createState() => OtaPageState();

  final String whichDevice;

}

class OtaPageState extends State<OtaPage> with SingleTickerProviderStateMixin{

  List Data = [];
  int length;
  int baseadress;
  int Baseadress;
  int j = 0;
  int otaLength = 0;
  int count = 0;
  int progress = 0;
  double ota;

  static const EventChannel _eventChannelPlugin = EventChannel(
      'my.flutter.event/bluetooth'); //定义接收底层操作系统主动发来的消息通道
  StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息

  @override
  void initState() {
    super.initState();
    _streamSubscription = _eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
    Future.delayed(Duration.zero,(){
      Method.customDialog(context, 'OTA'.tr, 'otetip'.tr, confirm, cancel: cancel);
    });
  }

  String generateMd5(List<int> data) {
    // final Uint8List content = const Utf8Encoder().convert(data);
    final Digest digest = md5.convert(data);
    return hex.encode(digest.bytes);
  }

  void confirm(){
    if(SaveData.broadcastType == 1){
      _headGetBaseAdress();
    }else{
      _GetBaseAdress();
    }
  }

  void _headGetBaseAdress() {
    Uint8List data = new Uint8List(6);
    data[0] = 0x01;
    data[1] = 0x03;
    data[2] = 0x00;
    data[3] = 0x00;
    data[4] = 0x00;
    data[5] = 0x00;
    Map<String, Object> dataMap = {"deviceType": 1, "data": data};
    _callPlatformToSendOtaData(dataMap);
  }

  void cancel(){
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => Scaffold(
        appBar: AppBar(
          title: Text('OTA'.tr),
          centerTitle: false,
          titleSpacing: 4,
          elevation: 0,
          backgroundColor: Color.fromRGBO(249, 122, 53, 1),
        ),
        body: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Positioned(
                  child: Container(
                    width: 250.h,
                    height: 250.h,
                    child: CircularProgressIndicator(
                      backgroundColor: Color.fromRGBO(249, 122, 53, 0.52),
                      strokeWidth: 12,
                      value: progress / 100,
                      valueColor: AlwaysStoppedAnimation(Color.fromRGBO(249, 122, 53, 1)),
                    ),
                  ),
                ),
                Positioned(
                    child: Text(progress.toString() + '%',style: TextStyle(fontSize: 36.sp),)
                ),
              ],
            )
        ),
      ),
    );
  }

  void _GetBaseAdress(){
    Uint8List data = new Uint8List(3);
    data[0]=0x01;
    data[1]=0x00;
    data[2]=0x00;
    Map<String,Object> dataMap={"deviceType":1,"data":data};
    _callPlatformToSendOtaData(dataMap);
  }

  void _callPlatformToSendOtaData(Map<String,Object> dataMap){
    dataMap['deviceName']=SaveData.deviceName;
    dataMap['serviceUuid']=defaultTargetPlatform==TargetPlatform.android?BlueUuid.androidOtaServiceUuid:BlueUuid.iosOtaServiceUuid;
    dataMap['writeUuid']=defaultTargetPlatform==TargetPlatform.android?BlueUuid.androidOtaWriteUuid:BlueUuid.iosOtaWriteUuid;
    dataMap['notifyUuid']=defaultTargetPlatform==TargetPlatform.android?BlueUuid.androidOtaNotifyUuid:BlueUuid.iosOtaNotifyUuid;
    dataMap['isWithResult']=true;
    MyBluetoothPlugin.sendData(dataMap);//调用底层去向蓝牙设备发送消息
  }

  void _onToDart(dynamic message) {
    //底层发送成功消息时会进入到这个函数来接收
    switch (message['code']) {
      case '80005': //如果是notify传回来的数据
        Uint8List data = message['data'] as Uint8List;
        if (data[1] == 0x01 && data[2] == 0x04) {
          //如果是获取存储起始地址
          Method.showToast('OTAtips'.tr, context);
          setState(() {
            baseadress = data[4] + data[5] * 16 * 16 + data[6] * 16 * 16 * 16 * 16;
            Baseadress = baseadress;
            _LightOta();
          });
        } else if (data[1] == 0x03 && data[0] == 0x00) {
          setState(() {
            baseadress = baseadress + 0x1000;
            otaLength = otaLength + 1;
            if (otaLength < (length / 4096).ceil()) {
              addAdress(baseadress);
            } else if (otaLength == (length / 4096).ceil()) {
              // _showToast("全部数据擦除成功，开始写入数据");
              setState(() {
                j = 0;
                print("擦除最终地址： $baseadress");
                // if(baseadress < 0x26000){
                //   Baseadress = 0;
                // }else if(baseadress > 0x26000){
                //   Baseadress = 0x26000;
                // }
                addData(length, Data.sublist(0, 235), Baseadress);
              });
            }
          });
        } else if (data[0] == 0x00 && data[1] == 0x05) {
          setState(() {
            count = (length / 235).ceil();
            ota = count / 100;
            j = j + 1;
            progress = (j / ota).floor();
          });
          print("j = $j");
          if (j < count - 1) {
            Baseadress = Baseadress + 235;
            addData(length, Data.sublist(j * 235, (j + 1) * 235), Baseadress);
          } else if (j == count - 1) {
            Baseadress = Baseadress + 235;
            addData(length, Data.sublist(j * 235), Baseadress);
          }else if(data[8] == length - (j - 1) * 235){
            _OtaReset();
            if(mounted){
              setState(() {
                progress = 0;
                if(!receiveSuccess){
                  Future<void>.delayed(const Duration(seconds: 2),(){
                    Method.showToast('Successful updates'.tr, context);
                  });
                }
              });
            }
          }
        }else if(data[0] == 0x00 && data[1] == 0x09){
          Method.showToast('Successful updates'.tr, context);
          receiveSuccess = true;
        }else if(data[0] == 0x01 && data[1] == 0x09){
          Method.showToast('update failed'.tr, context);
          receiveSuccess = true;
        }
        break;
    }
  }

  bool receiveSuccess = false;

  void _onToDartError(dynamic error) {
    switch (error.code) {
      case '90002':
        Navigator.of(context)..pop()..pop();
        if(Navigator.canPop(context)){
          Navigator.of(context).pop();
        }
        break;
    }

  }

  String fileMD5;
  int crc32;

  void _LightOta() async {
    final Dio dio = Dio();
    final Response response = await dio.get(RequestUrl.otaTergasyFileUrl + widget.whichDevice,options: Options(
      responseType: ResponseType.bytes,),);
    Data = response.data as List;
    length = Data.length;
    List<int> list = <int>[];
    for(int i = 256; i < length; i++){
      list.add((response.data as List<int>)[i]);
    }
    crc32 = getCrc32(list);
    // fileMD5 = generateMd5(response.data as List<int>);
    print('crc32值：${getCrc32(list).toRadixString(16)}');
    print("长度：${length.toRadixString(16)}");
    addAdress(baseadress);
  }

  int getCrc32(List<int> list, [int crc32 = 0]){
    int i = 0;
    int len = list.length;
    while(len-- != 0)
    {
      int high;
      if(crc32.toSigned(32) < 0){
        high = (crc32.toSigned(32)/256).ceil();
      }else{
        high = (crc32/256).floor();
      }
      crc32 = crc32 << 8;
      crc32 = crc32 ^ _CRC32_TABLE[(high^list[i])&0xff];
      crc32 = crc32 & 0xFFFFFFFF;
      i++;
    }
    return crc32&0xFFFFFFFF;
  }

  final List<int> _CRC32_TABLE = [
    0, 1996959894, 3993919788, 2567524794, 124634137, 1886057615, 3915621685,
    2657392035, 249268274, 2044508324, 3772115230, 2547177864, 162941995, 2125561021,
    3887607047, 2428444049, 498536548, 1789927666, 4089016648, 2227061214, 450548861,
    1843258603, 4107580753, 2211677639, 325883990, 1684777152, 4251122042, 2321926636,
    335633487, 1661365465, 4195302755, 2366115317, 997073096, 1281953886, 3579855332,
    2724688242, 1006888145, 1258607687, 3524101629, 2768942443, 901097722, 1119000684,
    3686517206, 2898065728, 853044451, 1172266101, 3705015759, 2882616665, 651767980,
    1373503546, 3369554304, 3218104598, 565507253, 1454621731, 3485111705, 3099436303,
    671266974, 1594198024, 3322730930, 2970347812, 795835527, 1483230225, 3244367275,
    3060149565, 1994146192, 31158534, 2563907772, 4023717930, 1907459465, 112637215,
    2680153253, 3904427059, 2013776290, 251722036, 2517215374, 3775830040, 2137656763,
    141376813, 2439277719, 3865271297, 1802195444, 476864866, 2238001368, 4066508878,
    1812370925, 453092731, 2181625025, 4111451223, 1706088902, 314042704, 2344532202,
    4240017532, 1658658271, 366619977, 2362670323, 4224994405, 1303535960, 984961486,
    2747007092, 3569037538, 1256170817, 1037604311, 2765210733, 3554079995, 1131014506,
    879679996, 2909243462, 3663771856, 1141124467, 855842277, 2852801631, 3708648649,
    1342533948, 654459306, 3188396048, 3373015174, 1466479909, 544179635, 3110523913,
    3462522015, 1591671054, 702138776, 2966460450, 3352799412, 1504918807, 783551873,
    3082640443, 3233442989, 3988292384, 2596254646, 62317068, 1957810842, 3939845945,
    2647816111, 81470997, 1943803523, 3814918930, 2489596804, 225274430, 2053790376,
    3826175755, 2466906013, 167816743, 2097651377, 4027552580, 2265490386, 503444072,
    1762050814, 4150417245, 2154129355, 426522225, 1852507879, 4275313526, 2312317920,
    282753626, 1742555852, 4189708143, 2394877945, 397917763, 1622183637, 3604390888,
    2714866558, 953729732, 1340076626, 3518719985, 2797360999, 1068828381, 1219638859,
    3624741850, 2936675148, 906185462, 1090812512, 3747672003, 2825379669, 829329135,
    1181335161, 3412177804, 3160834842, 628085408, 1382605366, 3423369109, 3138078467,
    570562233, 1426400815, 3317316542, 2998733608, 733239954, 1555261956, 3268935591,
    3050360625, 752459403, 1541320221, 2607071920, 3965973030, 1969922972, 40735498,
    2617837225, 3943577151, 1913087877, 83908371, 2512341634, 3803740692, 2075208622,
    213261112, 2463272603, 3855990285, 2094854071, 198958881, 2262029012, 4057260610,
    1759359992, 534414190, 2176718541, 4139329115, 1873836001, 414664567, 2282248934,
    4279200368, 1711684554, 285281116, 2405801727, 4167216745, 1634467795, 376229701,
    2685067896, 3608007406, 1308918612, 956543938, 2808555105, 3495958263, 1231636301,
    1047427035, 2932959818, 3654703836, 1088359270, 936918000, 2847714899, 3736837829,
    1202900863, 817233897, 3183342108, 3401237130, 1404277552, 615818150, 3134207493,
    3453421203, 1423857449, 601450431, 3009837614, 3294710456, 1567103746, 711928724,
    3020668471, 3272380065, 1510334235, 755167117
  ];

  void addAdress(int addadress) {
    setState(() {
      int FirstByte;
      int SecondByte;
      int ThirdByte;
      String AddAdress;
      if(addadress > 0){
        if(addadress <= 0xf000) {
          AddAdress = "00" + addadress.toRadixString(16);
        }else{
          AddAdress = "0" + addadress.toRadixString(16);
        }
        print(AddAdress);
        FirstByte = _hexToInt(AddAdress.substring(0, 2));
        SecondByte = _hexToInt(AddAdress.substring(2, 4));
        ThirdByte = _hexToInt(AddAdress.substring(4, 6));
      }else{
        FirstByte = 0;
        SecondByte = 0;
        ThirdByte = 0;
      }
      _OtaDelete(FirstByte, SecondByte, ThirdByte);
    });
  }

  void _OtaDelete(int a, int b, int c){
    Uint8List data = new Uint8List(7);
    data[0]=0x03;
    data[1]=0x07;
    data[2]=0x00;
    data[3]=c;
    data[4]=b;
    data[5]=a;
    data[6]=0x00;
    Map<String,Object> dataMap={"deviceType":1,"data":data};
    _callPlatformToSendOtaData(dataMap);
  }

  void addData(int length, List data, int Baseadress){
    int FirstByte;
    int SecondByte;
    int ThirdByte;
    String AddAdress;
    if(Baseadress > 0){
      if(Baseadress <= 0xff){
        AddAdress = "0000" + Baseadress.toRadixString(16);
      }else if(Baseadress <= 0xfff) {
        AddAdress = "000" + Baseadress.toRadixString(16);
      }else if(Baseadress <= 0xffff) {
        AddAdress = "00" + Baseadress.toRadixString(16);
      }else{
        AddAdress = "0" + Baseadress.toRadixString(16);
      }
      print(AddAdress);
      print("写入");
      FirstByte = _hexToInt(AddAdress.substring(0, 2));
      SecondByte = _hexToInt(AddAdress.substring(2, 4));
      ThirdByte = _hexToInt(AddAdress.substring(4, 6));
    }else{
      FirstByte = 0;
      SecondByte = 0;
      ThirdByte = 0;
    }
    if(data.length == 235){
      _OtaAdd(FirstByte, SecondByte, ThirdByte, data);
    }else{
      _Otaadd(FirstByte, SecondByte, ThirdByte, data);
    }
  }

  void PushData(int Baseadress, List otaData){
    String AddAdress = "0" + Baseadress.toRadixString(16);
    int FirstByte = _hexToInt(AddAdress.substring(0, 2));
    int SecondByte = _hexToInt(AddAdress.substring(2, 4));
    int ThirdByte = _hexToInt(AddAdress.substring(4, 6));
    if(otaData.length == 235){
      _OtaAdd(FirstByte, SecondByte, ThirdByte, otaData);
    }else{
      _Otaadd(FirstByte, SecondByte, ThirdByte, otaData);
    }
  }

  void _OtaAdd(int a, int b, int c, List otaData){
    Uint8List data = new Uint8List(otaData.length + 9);
    data[0]=0x05;
    data[1]=0x09;
    data[2]=0x00;
    data[3]=c;
    data[4]=b;
    data[5]=a;
    data[6]=0x00;
    data[7]=0xEB;
    data[8]=0x00;
    for(int i = 0; i < otaData.length; i++){
      data[i+9] = otaData[i] as int;
    }
    Map<String,Object> dataMap={"deviceType":1,"data":data};
    _callPlatformToSendOtaData(dataMap);
  }

  void _OtaReset() {
    final Uint8List data = Uint8List(11);
    data[0]=0x09;
    data[1]=0x0A;
    data[2]=0x00;
    String lengthStr = '';
    String crcStr = '';
    if(length.toRadixString(16).length < 8){
      lengthStr = '0' * (8 - length.toRadixString(16).length) + length.toRadixString(16);
      print('lengthStr: $lengthStr');
    }else{
      lengthStr = length.toRadixString(16);
      print('crcStr: $crcStr');
    }
    if(crc32.toRadixString(16).length < 8){
      crcStr = '0' * (8 - crc32.toRadixString(16).length) + crc32.toRadixString(16);
      print('crcStr: $crcStr');
    }else{
      crcStr = crc32.toRadixString(16);
      print('crcStr: $crcStr');
    }
    for(int i = 0; i < 4; i++){
      data[6 - i] = _hexToInt(lengthStr.substring(i * 2 , (i + 1) * 2));
    }
    for(int i = 0; i < 4; i++){
      data[10 - i] = _hexToInt(crcStr.substring(i * 2 , (i + 1) * 2));
    }
    print(data);
    final Map<String,Object> dataMap={'deviceType':1,'data':data};
    _callPlatformToSendOtaData(dataMap);
  }

  void _Otaadd(int a, int b, int c, List otaData) {
    Uint8List data = new Uint8List(otaData.length + 9);
    data[0]=0x05;
    data[1]=0x09;
    data[2]=0x00;
    data[3]=c;
    data[4]=b;
    data[5]=a;
    data[6]=0x00;
    data[7]=otaData.length;
    data[8]=0x00;
    for(int i = 0; i < otaData.length; i++){
      data[i+9] = otaData[i] as int;
    }
    Map<String,Object> dataMap={"deviceType":1,"data":data};
    _callPlatformToSendOtaData(dataMap);
  }

  int _hexToInt(String hex) {
    int val = 0;
    int len = hex.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = hex.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        // A..F
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        // a..f
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw new FormatException("Invalid hexadecimal value");
      }
    }
    return val;
  }
}