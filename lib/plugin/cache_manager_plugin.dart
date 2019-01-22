import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CacheManagerPlugin {
  static const MethodChannel _channel =
      const MethodChannel('com.gustinlau.nextday/cache_manager');

  static Future<String> cacheSize() async {
    int cacheSize =
        await _channel.invokeMethod('cacheSize') + imageCache.currentSizeBytes;
    return _getFormatSize(cacheSize);
  }

  static Future<dynamic> cleanCache() {
    imageCache.clear();
    return _channel.invokeMethod('cleanCache');
  }

  static String _getFormatSize(int size) {
    if (size == 0) {
      return '';
    } else if (size < 1024) {
      return '${size}B';
    } else if (1024 <= size && size < 1024 * 1024) {
      return '${(size / 1024.0).toStringAsFixed(2)}KB';
    } else if (1024 * 1024 <= size && size < 1024 * 1024 * 1024) {
      return '${(size / 1024.0 / 1024.0).toStringAsFixed(2)}MB';
    } else {
      return '${(size / 1024.0 / 1024.0 / 1024.0).toStringAsFixed(2)}GB';
    }
  }
}
