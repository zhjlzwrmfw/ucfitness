import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/widgets/sportIndex.dart';
import 'package:get/get.dart';

class UserAbilityPage extends StatefulWidget {
  @override
  _UserAbilityPageState createState() => _UserAbilityPageState();
}

class _UserAbilityPageState extends State<UserAbilityPage> {

  double power;
  double physique;
  double perseverance;
  double endurance;
  double agile;

  @override
  void initState() {
    super.initState();
    power = SaveData.power / SaveData.maxPower * 100 * 4 / 5 + 20;
    physique = SaveData.physique / SaveData.maxPhysique * 100 * 4 / 5 + 20;
    perseverance = SaveData.perseverance / SaveData.maxPerseverance * 100 * 4 / 5 + 20;
    endurance = SaveData.endurance / SaveData.maxEndurance * 100 * 4 / 5 + 20;
    agile = SaveData.agile / SaveData.maxAgile * 100 * 4 / 5 + 20;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => GestureDetector(
        onTap: (){
          // Navigator.of(context).pop();
        },
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: 480.w,
              height: 720.h,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),

              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 480.w,
                      height: 113.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                        color: Color.fromRGBO(255,138,101,0.24),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30.h,
                    left: 36.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('data graph'.tr, style: TextStyle(fontSize: 24.sp, color: Color.fromRGBO(0, 23, 55, 1)),),
                        Text(SaveData.rank.toString() + 'Place'.tr,style: TextStyle(fontSize: 18.sp, color: Color.fromRGBO(33, 37, 41, 1)),),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10.h,
                    right: 16.w,
                    child: Container(
                      width: 72.w,
                      height: 72.w,
                      child: FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Icon(Icons.clear,size: 36.w,color: Colors.black.withOpacity(0.2),),
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 320.h,
                    child: SportIndexWidget([SportBean(perseverance,"perseverance".tr), SportBean(endurance,"endurance".tr),  SportBean(agile,"agility".tr),
                      SportBean(physique,"physique".tr), SportBean(power,"power".tr)], r: 138.w,),
                  ),
                  Positioned(
                    top: 520.h,
                    left: 36.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(9)),
                              color: Color.fromRGBO(249, 122, 53, 1)
                          ),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text("power".tr, style: TextStyle(color: Color.fromRGBO(249, 122, 53, 1), fontSize: 18.sp),),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(SaveData.power.toString(), style: TextStyle(color: Color.fromRGBO(58, 64, 70, 1), fontSize: 21.sp),),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 570.h,
                    left: 36.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(9)),
                              color: Color.fromRGBO(249, 122, 53, 1)
                          ),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text("agility".tr, style: TextStyle(color: Color.fromRGBO(249, 122, 53, 1), fontSize: 18.sp),),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(SaveData.agile.toString(), style: TextStyle(color: Color.fromRGBO(58, 64, 70, 1), fontSize: 21.sp),),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 620.h,
                    left: 36.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(9)),
                              color: Color.fromRGBO(249, 122, 53, 1)
                          ),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text("endurance".tr, style: TextStyle(color: Color.fromRGBO(249, 122, 53, 1), fontSize: 18.sp),),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(SaveData.endurance.toString(), style: TextStyle(color: Color.fromRGBO(58, 64, 70, 1), fontSize: 21.sp),),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 570.h,
                    right: 36.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(9)),
                              color: Color.fromRGBO(249, 122, 53, 1)
                          ),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text("perseverance".tr, style: TextStyle(color: Color.fromRGBO(249, 122, 53, 1), fontSize: 18.sp),),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(SaveData.perseverance.toString(), style: TextStyle(color: Color.fromRGBO(58, 64, 70, 1), fontSize: 21.sp),),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 520.h,
                    right: 36.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(9)),
                              color: Color.fromRGBO(249, 122, 53, 1)
                          ),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text("physique".tr, style: TextStyle(color: Color.fromRGBO(249, 122, 53, 1), fontSize: 18.sp),),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(SaveData.physique.toString(), style: TextStyle(color: Color.fromRGBO(58, 64, 70, 1), fontSize: 21.sp),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
