import 'package:get/get.dart';
// ignore: avoid_classes_with_only_static_members, avoid_classes_with_only_static_members, avoid_classes_with_only_static_members
class SaveData{
  static String deviceName;//广播名全称
  static int sportPlayRate = 10;//运动频率，用户自设运动频率
  static bool setCard = false;//显示卡片
  static String sportCount;//运动次数，用于在sportInfo.dart显示运动次数
  static String kcalCount;//运动消耗卡路里，用于在sportInfo.dart显示运动消耗卡路里
  static String minCount;//运动时间，用于在sportInfo.dart显示运动时间，小于一分钟显示分钟
  static String avgCount;//运动平均速度
  static String sportTime;//运动详细时间，用于在sportInfo.dart显示运动详细时间
  static String secondsCount;//运动时间，用于在sportInfo.dart显示运动时间，小于一分钟显示秒
  static String username = 'Username';//用户名，用于在sportInfo.dart显示用户名
  static String pictureUrl;//用户头像路径，用于在sportInfo.dart显示头像
  static String avgBmp;//用于在sportInfo.dart显示平均心率
  static bool firstEnter = false;//为了每次进入记录页不重复刷新数据，只有用户运动进入才会置为true
  static bool choseMode = false;//是否选择模式，true为已选择
  static String connectDeviceName;//用于模式选择的设备名
  static String devicePicture;//用于在运动主页显示的gif图
  static String modeName;//运动主页模式名
  static String totalBmp;//记录一连串心率的字符串
  static int choseType = 0;//用户选择运动模式
  static int choseNumber = 1;//选择计时或者计数模式下的哪个按钮
  static String totalBmpTime;//记录一连串心率时间的字符串
  static String accessToken;//用户唯一识别码
  static int userId;//用户注册id
  static String totalSeconds;//用于计算平均速度
  static bool firstDownLoad;//刚下载app标志
  static String userBirthday = '2000-01-01';//用户生日
  static String userHeight = '180';//用户身高
  static String userWeight = '70';//用户体重
  static String userSex = '男';//用户性别
  static bool openMedia = true;//是否开启语音播报
  static bool chosePhotograph;//选择拍照还是相册
  static bool openedApp = true;//用于打开app时从数据库拿用户信息，切换页面不用重复拿
  static List<String> accountList = ['', ''];//第一个元素是邮箱，第二个元素是手机号
  static bool findPwd = false;//忘记密码时使用并且区别login页面和userLogin页面
  static String userAccount;//用于用户找回密码之后进行登录
  static int sportMode = 1;//运动模式
  static double agile = 0;//敏捷值
  static double endurance = 0;//耐力值
  static double perseverance = 0;//毅力值
  static double physique = 0;//体魄值
  static double power = 0;//力量值
  static double maxAgile = 0;//最大敏捷值
  static double maxEndurance = 0;//最大耐力值
  static double maxPerseverance = 0;//最大毅力值
  static double maxPhysique = 0;//最大体魄值
  static double maxPower = 0;//最大力量值
  static double ability = 0;//战斗力
  static int rank = 3;//战斗力排名
  static bool loginPage = false;//是否登录页进入
  static int broadcastType;//区分五件套和海德的广播
  static bool setPassword = false;//标志是否设置了密码
  static String countryCode = '86';//区号
  static String sportPosture;//运动姿势
  static bool offline;
  static bool isDeleteData = false;
  static bool english = true;
  static String country = '中国';
  static bool isLoginPage = false;
  static String businessType;//区分设置密码、绑定手机号、绑定邮箱、账号注销用的标志位
  static String tokenDateTime;
  static bool changeState = true;//用于用户登录，产生运动数据时状态的改变
  static Set<String> onclickPage = <String>{};//状态改变标志位
  static int sliderMaxValue;//课程视频个数设置于滑块分段
  static bool isCourse;//课程优先设置
  static bool hasNewMedal = false; //是否有新勋章
  static bool hasPopupMedalDialog = false;//避免多次弹出对话框
  static List<Map<String, Object>> netSaveDataList = <Map<String, Object>>[];
  static String serviceUuid;
  static String writeUuid;
  static String notifyUuid;
  static bool iOSAudioPlay = true;
  static String connectDeviceTypeStr(String device){
    switch(device){
      case '跳绳':
        return 'Jump rope'.tr;
      case '拉力绳':
        return 'Resistance Band'.tr;
      case '蝴蝶绳':
        return 'Spider Resistance Band'.tr;
      case '哑铃':
        return 'Dumbbell'.tr;
      case '健腹轮':
        return 'AB Wheel'.tr;
      case '握力环':
        return 'Grip'.tr;
    }
  }
  static int connectDeviceTypeInt(String device){
    switch(device){
      case '跳绳':
        return 1;
      case '拉力绳':
        return 2;
      case '蝴蝶绳':
        return 4;
      case '哑铃':
        return 3;
      case '健腹轮':
        return 5;
      case '握力环':
        return 6;
    }
  }
}