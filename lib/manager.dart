import 'dart:async';

import 'package:flutter/services.dart';
import 'package:adhara_socket_io/socket.dart';

class SocketIOManager {

  static const MethodChannel _channel =
  const MethodChannel('adhara_socket_io');

  Map<int, SocketIO> sockets = {};

  Future<SocketIO> newInstance(String uri) async {
    int index = await _channel.invokeMethod('newInstance', {'uri': uri});
    SocketIO socket = SocketIO(index);
    print("index>>>"); print(index);
    sockets[index] = socket;
    return socket;
  }

  Future clearInstance(SocketIO socket) async {
    int index = await _channel.invokeMethod('clearInstance', {'id': socket.id});
  }

}

///http://localhost:5000/socket.io/?user=e4de3a04f870d0e0df9ae61214da3af6&EIO=3&transport=polling&t=MSP3ACI