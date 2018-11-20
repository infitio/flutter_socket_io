import 'dart:async';

import 'package:flutter/services.dart';
import 'package:adhara_socket_io/socket.dart';

class SocketIOManager {

  static const MethodChannel _channel =
  const MethodChannel('adhara_socket_io');

  Map<int, SocketIO> sockets = {};

  Future<SocketIO> createInstance(String uri, {
    String query: ""
  }) async {
    int index = await _channel
        .invokeMethod('newInstance', {'uri': uri, 'query': query});
    SocketIO socket = SocketIO(index);
    sockets[index] = socket;
    return socket;
  }

  Future clearInstance(SocketIO socket) async {
    await _channel.invokeMethod('clearInstance', {'id': socket.id});
  }

}
