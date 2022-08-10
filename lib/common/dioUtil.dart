
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/common/encapMethod.dart';
import 'package:running_app/common/saveData.dart';

class DioUtil {
  static final DioUtil _instance = DioUtil._init();
  static Dio _dio;
  Response _response;
  Map<String, dynamic> _map;

  factory DioUtil() {
    return _instance;
  }

  DioUtil._init() {
    final BaseOptions options = BaseOptions(headers: <String, Object>{'app_pass':RequestUrl.appPass}, connectTimeout: 10000, receiveTimeout: 10000);
    _dio ??= Dio(options);
  }
//get请求
  Future<Map<String, dynamic>> get(String requestUrl, {Map<String, dynamic> queryParameters, Options options}) async {
    try{
      _response = await _dio.get(requestUrl, queryParameters: queryParameters, options: options);
      _map = jsonDecode(_response.toString());
    } on DioError catch(e){
      print(e);
      return null;
    }
    return _map;
  }
  //post请求
  Future<Map<String, dynamic>> post(String requestUrl, {Map<String, dynamic> queryParameters, Options options, data}) async {
    try{
      _response = await _dio.post(requestUrl, queryParameters: queryParameters, data: data, options: options);
      _map = jsonDecode(_response.toString());
    } on DioError catch(e){
      print(e);
      return null;
    }
    return _map;
  }
  //put请求
  Future<Map<String, dynamic>> put(String requestUrl, {Map<String, dynamic> queryParameters, Options options, data}) async {
    try{
      _response = await _dio.put(requestUrl, queryParameters: queryParameters, data: data, options: options);
      _map = jsonDecode(_response.toString());
    } on DioError catch(e){
      print(e);
      return null;
    }
    return _map;
  }
//下载请求
  Future<Map<String, dynamic>> downLoad(String requestUrl, var savePath, {Map<String, dynamic> queryParameters, Options options, data, onReceiveProgress}) async {
    await _dio.download(requestUrl, savePath, queryParameters: queryParameters, data: data, options: options, onReceiveProgress: onReceiveProgress);
  }
  //删除请求
  Future<Map<String, dynamic>> delete(String requestUrl, {Map<String, dynamic> queryParameters, Options options, data}) async {
    try{
      _response = await _dio.delete(requestUrl, data: data, options: options);
      _map = jsonDecode(_response.toString());
    } on DioError catch(e){
      print(e);
      return null;
    }
    return _map;
  }
}
