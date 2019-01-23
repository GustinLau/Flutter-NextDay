import 'dart:ui';

import 'package:flutter/material.dart';

class AdaptationUtils {
  static AdaptationUtils _instance;

  static AdaptationUtils get instance => _getInstance();

  factory AdaptationUtils() => _getInstance();

  static AdaptationUtils _getInstance() {
    if (_instance == null) {
      _instance = new AdaptationUtils._internal();
    }
    return _instance;
  }

  AdaptationUtils._internal();

  // 尺寸设计
  Size _designSize = Size(750.0, 1344.0);

  // 设计稿倍数
  double _designRatio = 2;

  // 设备倍数
  double deviceRatio;

  // 屏幕物理宽度
  double screenWidth;

  // 屏幕物理高度
  double screenHeight;

  // 缩放比例，以宽度几基准
  double _ratio;

  // 屏幕尺寸
  Size screenSize;

  // 安全区底部
  double safeAreaBottom;

  // 安全区头部
  double safeAreaTop;

  void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    deviceRatio = mediaQuery.devicePixelRatio;
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    _ratio = screenWidth / (_designSize.width / _designRatio);
    screenSize = mediaQuery.size;
    safeAreaBottom = mediaQuery.padding.bottom;
    safeAreaTop = mediaQuery.padding.top;
  }

  double adaptWidth(double w) {
    double width = w * _ratio;
    return width > w * 1.2 ? w * 1.2 : width;
  }

  double adaptHeight(double h) {
    double height = h * _ratio;
    return height > h * 1.2 ? h * 1.2 : height;
  }
}
