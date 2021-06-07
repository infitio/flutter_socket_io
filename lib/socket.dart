import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'generated/platform_constants.dart';
import 'manager.dart';
import 'message.dart';
import 'streams_channel.dart';

/// A socket instance internally used by the [SocketIOManager]
class SocketIO {
  /// Socket -or- Connection identifier
  final int? id;

  ///Store Completer(s) for pending Acknowledgements
  final _pendingAcknowledgements = <String, Completer>{};
  int _reqCounter = 0;

  ///Method channel to interact with android/iOS
  final MethodChannel _channel;
  final StreamsChannel _streamsChannel;

  ///Create a socket object with identifier received from platform APIs
  SocketIO(this.id, this._streamsChannel)
      : _channel = MethodChannel(
          MethodChannelNames.socketMethodChannel + id.toString(),
        ) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == PlatformMethod.incomingAck) {
        var arguments = call.arguments['args'] as List<dynamic>?;
        final reqId = call.arguments['reqId'] as String?;
        if (reqId == null || !_pendingAcknowledgements.containsKey(reqId)) {
          return;
        }
        final completer = _pendingAcknowledgements.remove(reqId)!;
        arguments = arguments!.map(_decodeArgument).toList();
        completer.complete(arguments);
      }
    });
  }

  Completer? _connectSyncCompleter;

  Future<void> _connectSync() async {
    _connectSyncCompleter = Completer();
    late StreamSubscription onConnectSubscription;
    late StreamSubscription onConnectErrorSubscription;
    void cleanup() {
      onConnectSubscription.cancel();
      onConnectErrorSubscription.cancel();
      _connectSyncCompleter = null;
    }

    onConnectSubscription = onConnect.listen((args) {
      _connectSyncCompleter!.complete();
      cleanup();
    });
    onConnectErrorSubscription = onConnect.listen((args) {
      _connectSyncCompleter!.completeError(args as Object);
      cleanup();
    });
    await connect();
  }

  /// Connect and ensure connection to server by listening to
  /// first connect event.
  Future<void> connectSync() {
    if (_connectSyncCompleter == null) {
      _connectSync();
    }
    return _connectSyncCompleter!.future;
  }

  ///connect this socket to server
  Future<void> connect() => _channel.invokeMethod<void>(PlatformMethod.connect);

  Object? _decodeArgument(Object? argument) =>
      SocketMessage.fromPlatform(argument).message;

  /// Encodes data to platform understandable
  ///
  /// Currently, not encoding data for iOS as it seems
  ///  to handle all data types just fine!
  Object _encodeArgument(Object argument) =>
      Platform.isIOS ? argument : SocketMessage(argument).toPlatform();

  List<Object> _encodeMessages(List<Object> messages) =>
      messages.map(_encodeArgument).toList(growable: false);

  ///listen to an event
  Stream<dynamic> on(String eventName) =>
      _streamsChannel.receiveBroadcastStream(<String, dynamic>{
        'id': id,
        'eventName': eventName,
      }).map((arguments) => arguments.map(_decodeArgument).toList());

  ///send data to socket server
  Future<void> emit(String eventName, List<Object> arguments) async {
    await _channel.invokeMethod(PlatformMethod.emit, <String, dynamic>{
      'eventName': eventName,
      'arguments': _encodeMessages(arguments),
    });
  }

  ///send data to socket server, return expected Ack as a Future
  Future emitWithAck(String eventName, List<Object> arguments) async {
    final reqId = (++_reqCounter).toString();
    await _channel.invokeMethod(
      PlatformMethod.emit,
      {
        'eventName': eventName,
        'arguments': _encodeMessages(arguments),
        'reqId': reqId,
      },
    );
    final completer = Completer();
    _pendingAcknowledgements[reqId] = completer;
    return completer.future;
  }

  /// checks whether connection is alive
  Future<bool?> isConnected() => _channel.invokeMethod(
        PlatformMethod.isConnected,
      );

// Utility methods for listeners.
// De-registering can be handled using off(eventName, fn)
  ///Listen to connect event
  Stream<dynamic> get onConnect => on(TxEventTypes.connect);

  ///Listen to disconnect event
  Stream<dynamic> get onDisconnect => on(TxEventTypes.disconnect);

  ///Listen to connection error event
  Stream<dynamic> get onConnectError => on(TxEventTypes.connectError);

  ///Listen to connection timeout event
  Stream<dynamic> get onConnectTimeout => on(TxEventTypes.connectTimeout);

  ///Listen to error event
  Stream<dynamic> get onError => on(TxEventTypes.error);

  ///Listen to connecting event
  Stream<dynamic> get onConnecting => on(TxEventTypes.reconnect);

  ///Listen to reconnect event
  Stream<dynamic> get onReconnect => on(TxEventTypes.reconnect);

  ///Listen to reconnect error event
  Stream<dynamic> get onReconnectError => on(TxEventTypes.reconnectError);

  ///Listen to reconnect failed event
  Stream<dynamic> get onReconnectFailed => on(TxEventTypes.reconnectFailed);

  ///Listen to reconnecting event
  Stream<dynamic> get onReconnecting => on(TxEventTypes.reconnecting);

  ///Listen to ping event
  Stream<dynamic> get onPing => on(TxEventTypes.ping);

  ///Listen to pong event
  Stream<dynamic> get onPong => on(TxEventTypes.pong);
}
