import 'dart:async';

import 'package:flutter/services.dart';

import 'generated/platform_constants.dart';
import 'options.dart';
import 'socket.dart';
import 'streams_channel.dart';

// Indicates whether platform side should release existing connections
//
// On hot restart this variable will be set to true, which indicates
//  platform side release the existing sockets
//  once released, the value will be updated to false
//
// See [SocketIOManager.createInstance] for usage
bool _clearExisting = true;

/// Class to manage multiple socket connections
class SocketIOManager {
  // singleton
  static final SocketIOManager _manager = SocketIOManager._internal();

  SocketIOManager._internal();

  /// factory constructor that returns same instance of [SocketIOManager] always
  factory SocketIOManager() => _manager;

  static const MethodChannel _channel = MethodChannel(
    MethodChannelNames.managerMethodChannel,
  );
  final StreamsChannel _streamsChannel = StreamsChannel(
    MethodChannelNames.streamsChannel,
  );

  final _sockets = <int?, SocketIO>{};

  ///Create a [SocketIO] instance
  ///[options] - Options object to initialize socket instance
  ///returns [SocketIO]
  Future<SocketIO> createInstance(SocketOptions options) async {
    final index = await _channel.invokeMethod<int>(
      PlatformMethod.newInstance,
      {
        'options': options.asMap(),
        'clear': _clearExisting,
      },
    );
    _clearExisting = false;
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
