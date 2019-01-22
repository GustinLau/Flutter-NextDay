import 'dart:typed_data';

import 'package:flutter/services.dart';

class ImagePlugin {
  static const MethodChannel _channel =
      const MethodChannel('com.gustinlau.nextday/image_saver');

  static Future saveToAlbum(Uint8List imageBytes) {
    assert(imageBytes != null);
    return  _channel.invokeMethod('saveImageToAlbum', imageBytes);
  }
}
