import 'dart:async';

import 'package:flutter/services.dart';

import 'options.dart';
import 'socket.dart';

/// Class to manage multiple socket connections
class SocketIOManager {
  static const MethodChannel _channel = MethodChannel('adhara_socket_io');

  final _sockets = <int, SocketIO>{};

  ///Create a [SocketIO] instance
  ///[options] - Options object to initialize socket instance
  ///returns [SocketIO]
  Future<SocketIO> createInstance(SocketOptions options) async {
    final index = await _channel.invokeMethod<int>('newInstance', {
      'options': options.asMap(),
      'clear': _sockets.isEmpty
    });
    final socket = SocketIO(index);
    _sockets[index] = socket;
    return socket;
  }

  ///Disconnect a socket instance and remove from stored sockets list
  Future clearInstance(SocketIO socket) async {
    await _channel.invokeMethod('clearInstance', {
      'id': socket.id,
      'clear': _sockets.length==1
      //clear of any other uncleared socket instances
    });
    _sockets.remove(socket.id);
  }
}
