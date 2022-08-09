import 'package:get/get.dart';

class SportDataController extends GetxController{
  Rx<SportData> sportData = SportData(second: 0).obs;
  Rx<ProgressIndicate> progressIndicate = ProgressIndicate(progress: 0).obs;
}

class SportData{
  int second;
  int minute;
  int sportCount;
  int bmpCount;
  double kcalCount;
  int eleAmount;

  SportData({int second, int minute, int sportCount, int bmpCount, double kcalCount, int eleAmount});
}

class ProgressIndicate{
  double progress;
  ProgressIndicate({double progress});
}