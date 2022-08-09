import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/saveData.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserAgreementPage extends StatefulWidget{

  @override
  UserAgreementPageState createState() => UserAgreementPageState();

}
class UserAgreementPageState extends State<UserAgreementPage>{
  String _title='';
  WebViewController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(249, 122, 53, 1),
        titleSpacing: 4,
        elevation: 0,
        centerTitle: false,
        title: Text(
          _title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: WebView(
          initialUrl: SaveData.english ? 'http://cloud.capstong.com:8081/otaDir/tergasy_privacy_policy_english.html' : 'http://cloud.capstong.com:8081/otaDir/tergasy_privacy_policy.html',
          //JS执行模式 是否允许JS执行
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController controller) {
            _controller = controller;
          },
          onPageFinished: (String url) {
            _controller.evaluateJavascript('document.title').then((String result){
              setState(() {
                _title = result.replaceAll('\"', '');//去除双引号
              });
            });
          },
          onWebResourceError: (WebResourceError controller){
            Method.showToast('It seems that there is no internet'.tr, context);
          },
        ),
      ),
    );
  }
}