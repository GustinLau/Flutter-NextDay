import 'dart:ui';

import 'package:flutter/material.dart';

class AdaptationUtils {
  // iPhone 6 尺寸设计
  static final Size _designSize = Size(750.0, 1344.0);

  // 设计稿倍数
  static final double _designRatio = 2;

  // 设备倍数
  static final double deviceRatio = window.devicePixelRatio;

  // 屏幕物理宽度
  static final double screenWidth = window.physicalSize.width;

  // 屏幕物理高度
  static final double screenHeight = window.physicalSize.height;

  // 缩放比例，以宽度几基准
  static final _ratio =
      (screenWidth / deviceRatio) / (_designSize.width / _designRatio);

  // 屏幕尺寸
  static Size screenSize =
      Size(screenWidth / deviceRatio, screenHeight / deviceRatio);

  // 安全区底部
  static final double safeAreaBottom = window.padding.bottom / deviceRatio;

  // 安全区头部
  static final double safeAreaTop = window.padding.top / deviceRatio;

  static double adaptWidth(double w) {
    return w * _ratio;
  }

  static double adaptHeight(double h) {
    return h * _ratio;
  }
}
