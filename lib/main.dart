import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'package:running_app/common/blueToothChannel.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/model/abilityRank.dart';
import 'package:running_app/model/medal.dart';
import 'package:running_app/model/newMedal.dart';
import 'package:running_app/routes/about/about.dart';
import 'package:running_app/routes/about/sportSetting.dart';
import 'package:running_app/routes/course/coursePage.dart';
import 'package:running_app/routes/login/addUser.dart';
import 'package:running_app/routes/login/enLogin.dart';
import 'package:running_app/routes/login/userEnLogin.dart';
import 'package:running_app/routes/login/userLogin.dart';
import 'package:running_app/routes/realTimeSport/home.dart';
import 'package:running_app/routes/sportData/record.dart';
import 'package:running_app/routes/sportData/sportRanking.dart';
import 'package:running_app/routes/userRoutes/accountSecurity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'common/dioUtil.dart';
import 'common/requesrUrl.dart';
import 'common/international.dart';
import 'routes/realTimeSport/mainSport.dart';
import 'routes/login/login.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

void main() {
  // debugRepaintRainbowEnabled = true;
  // debugProfileBuildsEnabled = true;
  // debugProfilePaintsEnabled = true;
  // debugPaintLayerBordersEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((value){
    //用于判断用户是否是第一次进入app
    if(value.getBool('firstOpenApp') != null){
      firstOpenApp = false;
      if(value.getString('username') != null){
        SaveData.username = value.getString('username');
      }
      if(value.getString('userBirthday') != null){
        SaveData.userBirthday = value.getString('userBirthday');
      }
      if(value.getString('userWeight') != null){
        SaveData.userWeight = value.getString('userWeight');
      }
      if(value.getString('userHeight') != null){
        SaveData.userHeight = value.getString('userHeight');
      }
      if(value.getString('pictureUrl') != null){
        HomePageState.hasPicture = true;
      }
      if(value.getString('userSex') != null){
        SaveData.userSex = value.getString('userSex');
      }
      if(value.getInt('userId') != null){
        SaveData.userId = value.getInt('userId');
      }
      if(value.getString('accessToken') != null){
        SaveData.accessToken = value.getString('accessToken');
      }
      if(value.getBool('setPassword') != null){
        SaveData.setPassword = value.getBool('setPassword');
      }
      if(value.getString('tokenDateTime') != null){
        SaveData.tokenDateTime = value.getString('tokenDateTime');
      }
    }
  }).whenComplete(() => runApp(MyApp()));
}

bool firstOpenApp = true;
bool notRefresh = true;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {

  // final Stream<NDEFMessage> stream = NFC.readNDEF();
  // BlueToothChannel blueToothChannel = BlueToothChannel();
  // StreamSubscription _streamSubscription; //广播流来处理EventChannel发来的消息


  // void _onToDart(dynamic message) {
  //   switch (message['code'] as String) {
  //     case '80001':
  //       Future<void>.delayed(const Duration(seconds: 2),(){
  //         Navigator.push<Object>(navigatorKey.currentState.overlay.context, MaterialPageRoute(builder: (BuildContext context) {
  //           return SportSettingPage();
  //         }));
  //       });
  //       break;
  //   }
  // }
  //
  // void _onToDartError(dynamic error) {
  //   switch (error.code) {
  //     case '90001':
  //       Navigator.of(navigatorKey.currentState.overlay.context).pop();
  //       Method.showToast('Connect failed'.tr, navigatorKey.currentState.overlay.context);
  //       break;
  //     case '90002':
  //       Navigator.of(navigatorKey.currentState.overlay.context).pop();
  //       Method.showToast('Connect failed'.tr, navigatorKey.currentState.overlay.context);
  //       break;
  //     case '90003':
  //       Method.showToast('Location permission required'.tr, navigatorKey.currentState.overlay.context);
  //       Navigator.of(navigatorKey.currentState.overlay.context).pop();
  //       break;
  //     case '90004':
  //       Method.showToast('Enable Location services'.tr, navigatorKey.currentState.overlay.context);
  //       Navigator.of(navigatorKey.currentState.overlay.context).pop();
  //       break;
  //     case '90005':
  //       Method.showToast('Enable Bluetooth'.tr, navigatorKey.currentState.overlay.context);
  //       Navigator.of(navigatorKey.currentState.overlay.context).pop();
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // _streamSubscription = blueToothChannel.eventChannelPlugin.receiveBroadcastStream().listen(_onToDart, onError: _onToDartError);
    // if(notRefresh){
    //   stream.listen((NDEFMessage message) {
    //     print(message.data);
    //     SaveData.deviceName = 'HEAD-NT930-' + message.data.substring(22, 24) + message.data.substring(25, 27);
    //     Method.showLessLoading(navigatorKey.currentState.overlay.context, 'Loading2'.tr);
    //     blueToothChannel.connectDevice(SaveData.deviceName, 1);
    //   });
    // }
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        platform: TargetPlatform.iOS,
        fontFamily: "SF",
        // textTheme: TextTheme(bodyText2: TextStyle(fontFamily: 'SF'))
      ),
      // showPerformanceOverlay: true,
      // checkerboardOffscreenLayers: true,// 使用了saveLayer的图形会显示为棋盘格式并随着页面刷新而闪烁
      // checkerboardRasterCacheImages: true, // 做了缓存的静态图片在刷新页面时不会改变棋盘格的颜色；如果棋盘格颜色变了说明被重新缓存了，这是我们要避免的
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) {
        // 此时context在Localizations的子树中
        return 'Tergasy Fitness'.tr;
      },
      translations: Messages(),
      // fallbackLocale: Locale('en', 'US'),
      locale: window.locale.languageCode == 'zh' ? Locale('zh', 'CN') : Locale('en','US'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (List<Locale> locales, Iterable<Locale> supportedLocales){
        Locale locale;
        if (locales[0].languageCode == 'en') {
          locale = const Locale('en','US');
          SaveData.english = true;
          SaveData.country = 'China';
        } else if (locales[0].languageCode == 'zh') {
          locale = const Locale('zh', 'CN');
          SaveData.english = false;
        } else {
          locale = const Locale('en','US');
          SaveData.english = true;
          SaveData.country = 'China';
        }
        return locale;
      },
      initialRoute: firstOpenApp ? '/' : 'MyHomePage',
      routes: {
        '/': (_) => SaveData.english ? EnLoginRoute() : LoginRoute(),
        'MyHomePage' : (_) => MyHomePage(),
        'userLogin' : (_) => UserLoginRoute(),
        'userEnLoginRoute' : (_) => UserEnLoginRoute(),
        'accountSecurity': (_) => AccountSecurityRoute(),
        'addUser': (_) => AddUserPage(),
      },
      // builder: (context, widget) {
      //   return MediaQuery(
      //     //设置文字大小不随系统设置改变
      //     // data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0, boldText: defaultTargetPlatform == TargetPlatform.iOS || SaveData.english ? true : false),
      //     data: MediaQuery.of(context).copyWith(boldText: false),
      //     child: widget,
      //   );
      // },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

// BlueToothChannel blueToothChannel = BlueToothChannel();

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{

  static int currentIndex = 0;
  // static List<Widget> pages = [HomePage(), RecordPage(), CoursePage(), SportRankingRoute(), AboutPage()];
  static List<Widget> pages = [HomePage(), RecordPage(), SportRankingRoute(), AboutPage()];
  final TapGestureRecognizer recognizer = TapGestureRecognizer();
  Locale locale;
  AbilityRank _abilityRank;
  DateTime _lastPressedAt;//记录点击返回键的时间
  NewMedal newMedal;

  @override
  void initState() {
    super.initState();
    if(SaveData.userId != null && SaveData.tokenDateTime != null){
      if(!SaveData.isLoginPage && DateTime.now().isAfter(DateTime.parse(SaveData.tokenDateTime).add(const Duration(hours: 18)))){
        refreshToken();
      }
      _getAbilityRank(RequestUrl.getTotalAbilityRankUrl);
      getNewMedal();
    }else if(SaveData.userId != null && !SaveData.isLoginPage){
      refreshToken();
    }
    Future<void>.delayed(const Duration(days: 1),(){
      refreshToken();
    });
    WidgetsBinding.instance.addObserver(this);
    recognizer.onTap = () {
      _launchURL();
    };
  }

  void getNewMedal(){
    DioUtil().get(
      RequestUrl.getMedalNewUrl,
      queryParameters: <String, Object>{'lang': SaveData.english ? 'en' : 'zh', 'userId': SaveData.userId},
      options: Options(headers: <String, Object>{'access_token': SaveData.accessToken, 'app_pass':RequestUrl.appPass}),
    ).then((value){
      print(value);
      if(value != null){
        newMedal = NewMedal.fromJson(value);
        if(newMedal.code == '200'){
          if(newMedal.data.isNotEmpty){
            SaveData.hasNewMedal = true;
          }
        }
      }
    });
  }

  Future _getAbilityRank(String rank) async {//第一个参数为排行榜请求地址，第二个参数为用户战斗力信息请求地址
    DioUtil().get(
        rank,
        options: Options(headers: <String, String>{'access_token': SaveData.accessToken, 'app_pass':RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,)
    ).then((value){
      // print('value:$value');
      if(value != null){
        _abilityRank = AbilityRank.fromJson(value);
        if(_abilityRank.code == '401'){
          SaveData.userId = null;
          SaveData.pictureUrl = null;
          SaveData.setPassword = false;
          HomePageState.hasPicture = false;
          SharedPreferences.getInstance().then((value){
            value.clear();
            Method.showToast('disableAccount'.tr, context, position: 1);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
    //切换前台时,可回调，初始化时，收不到回调
      case AppLifecycleState.resumed:
        notRefresh = false;
        if(Platform.isIOS){
          MainSportPageState.playCount = 0;
          MainSportPageState.playCompleted = true;
        }
        Future<void>.delayed(const Duration(seconds: 1),(){
          notRefresh = true;
        });
        Future<void>.delayed(Duration.zero,(){
          if(SaveData.english){
            locale = const Locale('en', 'US');
            Get.updateLocale(locale);
          }else{
            locale = const Locale('zh', 'CN');
            Get.updateLocale(locale);
          }
        });
        if(!SaveData.isLoginPage && SaveData.userId != null && DateTime.now().isAfter(DateTime.parse(SaveData.tokenDateTime).add(const Duration(hours: 18)))){
          refreshToken();
        }
        if(defaultTargetPlatform == TargetPlatform.iOS){
          SaveData.iOSAudioPlay = true;
        }
        break;
    //切换后台时,inactive，pause先后回调
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        if(defaultTargetPlatform == TargetPlatform.iOS){
          SaveData.iOSAudioPlay = false;
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future _launchURL() async {
    const String url = 'http://cloud.capstong.com:8081/otaDir/tergasy_privacy_policy.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void refreshToken(){
    if(MainSportPageState.eleAmount == null){
      Future.delayed(Duration.zero,(){
        Method.showLessLoading(context, 'Loading2'.tr);
      });
    }
    DioUtil().get(
      RequestUrl.refreshTokenUrl,
      options: Options(headers: <String, String>{'access_token': SaveData.accessToken, 'app_pass': RequestUrl.appPass}, sendTimeout: 5000, receiveTimeout: 10000,),
    ).then((Map<String, Object> value){
      print(value);
      if(value != null){
        if(value['code'] == '200'){
          SaveData.accessToken = value['data'] as String;
          if(MainSportPageState.eleAmount == null){
            if(Navigator.canPop(context)){
              Navigator.of(context).pop();
            }
          }
          SharedPreferences.getInstance().then((value){
            value.setString('accessToken', SaveData.accessToken);
            value.setString('tokenDateTime', DateTime.now().toString());
            SaveData.tokenDateTime = DateTime.now().toString();
          });
        }else{
          if(MainSportPageState.eleAmount == null){
            if(Navigator.canPop(context)){
              Navigator.of(context).pop();
            }
          }
        }
      }else{
        if(MainSportPageState.eleAmount == null){
          if(Navigator.canPop(context)){
            Navigator.of(context).pop();
          }
        }
        Method.showToast('It seems that there is no internet'.tr, context);
      }
    });
  }

  /*切换页面*/
  void _changePage(int index) {
    /*如果点击的导航项不是当前项  切换 */
    if (index != currentIndex) {
      setState(() {
        currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt) > const Duration(seconds: 1)) {
          //两次点击间隔超过1秒则重新计时
          _lastPressedAt = DateTime.now();
          Method.showToast('Press again to exit'.tr, context);
          return false;
        }else{
          exit(0);
          return true;
        }
      },
      child: Scaffold(
        bottomNavigationBar: Theme(
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                // backgroundColor: Colors.blue,
                icon: Icon(Icons.home,size: 30,),
                activeIcon: Icon(Icons.home,size: 30,color: const Color.fromRGBO(91, 101, 112, 1),),
                title: Text('Home'.tr),
              ),
              BottomNavigationBarItem(
                icon: Image.asset('images/jilu_disable.png',width: 30,height: 30,),
                activeIcon: Image.asset('images/jilu_normal.png',width: 30,height: 30,),
                title: Text('Status'.tr),
              ),
              // BottomNavigationBarItem(
              //   icon: Image.asset('images/课程.png',width: 26,height: 26, color: Colors.grey,),
              //   activeIcon: Image.asset('images/课程.png',width: 26,height: 26,),
              //   title: const Text('课程'),
              // ),
              BottomNavigationBarItem(
                icon: Image.asset('images/paihangbang_disable.png',width: 30,height: 30,),
                activeIcon: Image.asset('images/paihangbang_normal.png',width: 30,height: 30),
                title: Text('LeaderBoard'.tr),
              ),
              BottomNavigationBarItem(
                icon: Image.asset('images/setting_disable.png',width: 30,height: 30,),
                activeIcon: Image.asset('images/setting_normal.png',width: 30,height: 30,),
                title: Text('me'.tr),
              ),
            ],
            backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            unselectedItemColor: const Color.fromRGBO(199, 206, 214, 1),
            onTap: (int index) {
              _changePage(index);
            },
          ),
          data: ThemeData(
              brightness: Brightness.light,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent
          ),
        ),
        // body: pages[currentIndex],
        body: SaveData.changeState ? pages[currentIndex] : IndexedStack(
          index: currentIndex,
          children: pages,
        ),
      ),
    );
  }
}