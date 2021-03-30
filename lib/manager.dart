import 'dart:async';

import 'package:flutter/services.dart';

import 'options.dart';
import 'socket.dart';
import 'streams_channel.dart';
import 'generated/platform_constants.dart';

bool _shouldHotRestart = true;

/// Class to manage multiple socket connections
class SocketIOManager {
  static const MethodChannel _channel = MethodChannel('adhara_socket_io');
  final StreamsChannel _streamsChannel =
  StreamsChannel('adhara_socket_io:event_streams');

  final _sockets = <int, SocketIO>{};

  ///Create a [SocketIO] instance
  ///[options] - Options object to initialize socket instance
  ///returns [SocketIO]
  Future<SocketIO> createInstance(SocketOptions options) async {
    final index = await _channel.invokeMethod<int>(
      PlatformMethod.newInstance,
      {
        'options': options.asMap(),
        'clear': _shouldHotRestart
      },
    );
    _shouldHotRestart = false;
    final socket = SocketIO(index, _streamsChannel);
    _sockets[index] = socket;
    return socket;
  }

  ///Disconnect a socket instance and remove from stored sockets list
  Future clearInstance(SocketIO socket) async {
    await _channel.invokeMethod(
      PlatformMethod.clearInstance,
      {'id': socket.id},
    );
    _sockets.remove(socket.id);
  }
}
