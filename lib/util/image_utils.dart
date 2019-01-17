import 'dart:typed_data';

import 'package:flutter/services.dart';

class ImageUtils {
  static const MethodChannel _channel =
      const MethodChannel('com.gustinlau.nextday/image_saver');

  static Future saveToAlbum(Uint8List imageBytes) async {
    assert(imageBytes != null);
    final result = await _channel.invokeMethod('saveImageToAlbum', imageBytes);
    return result;
  }
}
