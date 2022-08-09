import 'dart:io';
import 'package:flutter/material.dart';


///在Flutter中，我们可以用下面的代码从文件中加载图像：Image.file(File(_fileName));
///这个时候，当_fileName这个文件名称和路径不变，文件内容变化时，Flutter并不会更新显示。
///问题产生的原因是Flutter自动使用了缓存。
/// 而FileImage这个类正是使用operator 这个方法判断图片比例与路径
class FileImageEx extends FileImage {
  int fileSize;
  FileImageEx(File file, { double scale = 1.0 })
      : assert(file != null),
        assert(scale != null),
        super(file, scale: scale) {
    fileSize = file.lengthSync();
  }

  @override
  bool operator == (dynamic other) {
    if (other.runtimeType != runtimeType)
      return false;
    final FileImageEx typedOther = other;
    return file?.path == typedOther.file?.path
        && scale == typedOther.scale && fileSize == typedOther.fileSize;
  }

}