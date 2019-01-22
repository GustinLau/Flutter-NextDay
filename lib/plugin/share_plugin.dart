import 'dart:typed_data';

import 'package:flutter/services.dart';

class SharePlugin {
  static const MethodChannel _channel =
      const MethodChannel('com.gustinlau.nextday/share');

  static Future share(Uint8List imageBytes) {
    return _channel.invokeMethod('share', imageBytes);
  }
}
