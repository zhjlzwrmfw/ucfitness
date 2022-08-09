import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:running_app/common/saveData.dart';
import 'package:running_app/routes/realTimeSport/mainSport.dart';

class CustomDialog extends StatefulWidget {

  final String title; //弹窗标题
  final String content; //弹窗内容
  final String confirmContent; //按钮文本
  final Color confirmTextColor; //确定按钮文本颜色
  final bool isCancel; //是否有取消按钮，默认为true true：有 false：没有
  final Color confirmColor; //确定按钮颜色
  final Color cancelColor; //取消按钮颜色
  final bool outsideDismiss; //点击弹窗外部，关闭弹窗，默认为true true：可以关闭 false：不可以关闭
  final Function confirmCallback; //点击确定按钮回调
  final Function dismissCallback; //弹窗关闭回调

  const CustomDialog({
    Key key,
    this.title,
    this.content,
    this.confirmContent,
    this.confirmTextColor,
    this.isCancel = true,
    this.confirmColor,
    this.cancelColor,
    this.outsideDismiss = true,
    this.confirmCallback,
    this.dismissCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CustomDialogState();
  }
}

class _CustomDialogState extends State<CustomDialog> {

  void _confirmDialog() {
    // _dismissDialog();
    if (widget.confirmCallback != null) {
      if(SaveData.netSaveDataList.isEmpty){
        Navigator.of(context).pop();
      }
      widget.confirmCallback();
    }
  }

  void _dismissDialog() {
    if (widget.dismissCallback != null) {
      widget.dismissCallback();
    }
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 50),(){
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Column _columnText = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 125.h,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12)),
            color: Colors.grey.withOpacity(0.5),
          ),
          alignment: Alignment.center,
          child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 60.sp)
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          margin: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            widget.content,
            style: TextStyle(fontSize: 48.sp,color: Colors.black.withOpacity(0.75)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if(widget.isCancel)
            Expanded(
              flex: 1,
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                  color: widget.cancelColor ?? const Color(0xFFFFFFFF),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12.0)),
                  border: Border.all(
                    style: BorderStyle.solid,
                    width: 0,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
                child: FlatButton(
                  child: Text(
                      'Cancel'.tr,
                      style: TextStyle(
                        fontSize: 48.sp,
                        color: widget.cancelColor == null ? Colors.black87 : const Color(0xFFFFFFFF),
                      ),
                  ),
                  onPressed: _dismissDialog,
                  splashColor: Colors.transparent,
                ),
              ),
            ),
            // SizedBox(width: 1.0, height: ScreenUtil().setHeight(60), child: Container(color: Color(0xDBDBDBDB))),
            Expanded(
              flex: 1,
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                    color: widget.confirmColor ?? const Color(0xFFFFFFFF),
                    borderRadius: widget.isCancel ? const BorderRadius.only(bottomRight: Radius.circular(12.0)) : const BorderRadius.only(bottomLeft: Radius.circular(12.0), bottomRight: Radius.circular(12.0))
                ),
                child: FlatButton(
                  onPressed: _confirmDialog,
                  child: Text(
                      widget.confirmContent ?? 'OK2'.tr,
                      style: TextStyle(
                        fontSize: 48.sp,
                        color: widget.confirmColor == null ? (widget.confirmTextColor ?? Colors.black87) : const Color(0xFFFFFFFF),
                      )
                  ),
                  splashColor: Colors.transparent,
                ),
              ),
            )
          ],
        ),
      ],
    );
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: () => WillPopScope(
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                width: 780.w,
                padding: EdgeInsets.zero,
                child:  _columnText,
                decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(12.0)
                ),
              ),
            ),
          ),
          onWillPop: () async {
            return widget.outsideDismiss;
          }
      ),
    );
  }
}