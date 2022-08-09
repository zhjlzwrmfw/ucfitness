import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:azlistview/azlistview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/common/zone_code_service.dart';
import 'package:running_app/model/zone_code.dart';
import 'package:running_app/widgets/mh_index_bar.dart';
import 'package:running_app/widgets/mh_list_tile.dart';
import 'package:get/get.dart';

// 适配完毕
class ZoneCodePickerPage extends StatefulWidget {
  ZoneCodePickerPage({Key key, @required this.value}) : super(key: key);

  /// value
  final String value;

  /// 构建部件
  _ZoneCodePickerPageState createState() => _ZoneCodePickerPageState();
}

class _ZoneCodePickerPageState extends State<ZoneCodePickerPage> {
  /// 联系人列表
  List<ZoneCode> _zoneCodeList = [];
  int _suspensionHeight = 36;
  int _itemHeight = 56;
  String _suspensionTag = "";

  @override
  void initState() {
    super.initState();
    // 请求联系人
    _fetchZoneCode();
  }

  /// 请求联系人列表
  void _fetchZoneCode() async {
    List<ZoneCode> list = [];
    if (ZoneCodeService.sharedInstance.zoneCodeList != null &&
        ZoneCodeService.sharedInstance.zoneCodeList.isNotEmpty) {
      list = ZoneCodeService.sharedInstance.zoneCodeList;
      // print('zheshi 0');
    } else {
      list = await ZoneCodeService.sharedInstance.fetchZoneCode();
      print('zheshi 1');
    }
    setState(() {
      _zoneCodeList = list;
    });
  }

  /// 索引标签被点击
  void _onSusTagChanged(String tag) {
    setState(() {
      _suspensionTag = tag;
    });
  }

  /// 构建头部
  Widget _buildHeader() {
    return Column(
      children: <Widget>[
        ListTile(
          // leading: Icon(Icons.add_location,color: Colors.yellow,),
          title: Text(SaveData.country + ' +' + SaveData.countryCode,style: TextStyle(color: Color.fromRGBO(60, 66, 72, 1)),),
          trailing: Image.asset('images/yipeidui.png', width: 28.w, height: 28.w,),
          contentPadding: EdgeInsets.only(left: 24.w, right: 66.w),
        )
      ],
    );
  }
///顶部漂浮字母
  Widget _buildSusWidget(String susTag) {
    return Container(
      height: _suspensionHeight.toDouble(),
      padding: EdgeInsets.only(
        left: 24.w,
      ),
      color: Color(0xfff3f4f5),
      alignment: Alignment.centerLeft,
      child: Text(
        '$susTag',
        softWrap: false,
        style: TextStyle(
          fontSize: 27.sp,
          color: Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildListItem(ZoneCode zoneCode) {
    String susTag = zoneCode.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: zoneCode.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        Container(
          height: _itemHeight.toDouble(),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Expanded(
                child: _buildItem(SaveData.english ? zoneCode.en : zoneCode.name, zoneCode.tel, onTap: () {
                  Navigator.of(context).pop(SaveData.english ? zoneCode.en + '+' + zoneCode.tel: zoneCode.name +  '+' + zoneCode.tel);
                }),
              )
            ],
          ),
        ),
      ],
    );
  }

  /// 返回 item
  Widget _buildItem(
    String title,
    String telCode, {
    void Function() onTap,
  }) {
    Widget middle = Padding(
      padding: EdgeInsets.only(
          right: 48.w),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 24.sp,
            color:Color.fromRGBO(60, 66, 72, 1)),
      ),
    );
    Widget trailing = Padding(
      padding: EdgeInsets.only(right: 36.w),
      child: Text(
        '+$telCode',
        style: TextStyle(
          fontSize: 24.sp,
          color: Color.fromRGBO(60, 66, 72, 1),
        ),
      ),
    );
    return MHListTile(
      onTap: onTap,
      middle: middle,
      trailing: trailing,
      height: _itemHeight.toDouble(),
      dividerIndent: 24.w,
      dividerEndIndent: 48.w,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(540, 960),
      builder: () => Scaffold(
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 4,
          elevation: 0,
          title: Text("selectcountryregion".tr),
          backgroundColor: Color.fromRGBO(249, 122, 53, 1),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: AzListView(
                  data: _zoneCodeList,
                  itemBuilder: (context, model) => _buildListItem(model),
                  suspensionWidget: _buildSusWidget(_suspensionTag),
                  isUseRealIndex: true,
                  itemHeight: _itemHeight,
                  suspensionHeight: _suspensionHeight,
                  onSusTagChanged: _onSusTagChanged,
                  header: AzListViewHeader(
                      tag: "#",
                      height: 56,
                      builder: (context) {
                        return _buildHeader();
                      }),
                  showIndexHint: false,
                  // indexHintBuilder: (context, hint) {
                  //   return Container(
                  //     alignment: Alignment.center,
                  //     width: ScreenUtil().setWidth(105),
                  //     height: ScreenUtil().setWidth(105),
                  //     decoration: BoxDecoration(
                  //         color: Colors.yellow, shape: BoxShape.circle),
                  //     child: Text(
                  //       hint,
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: ScreenUtil().setSp(60),
                  //       ),
                  //     ),
                  //   );
                  // },
                  indexBarBuilder: (context, tagList, onTouch){
                    return MHIndexBar(
                      data: tagList,
                      tag: _suspensionTag,
                      onTouch: onTouch,
                      selectedTagColor: Color.fromRGBO(249, 122, 53, 1),
                      itemHeight: 19,
                      hintImagePath: 'images/ContactIndexShape_60x50.png',
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }
}
