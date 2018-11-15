import 'dart:async';

import 'package:flutter/services.dart';

class AdharaSocketIo {
  static const MethodChannel _channel =
      const MethodChannel('adhara_socket_io');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

///http://localhost:5000/socket.io/?user=e4de3a04f870d0e0df9ae61214da3af6&EIO=3&transport=polling&t=MSP3ACI