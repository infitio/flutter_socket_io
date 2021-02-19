import 'dart:async';
import 'dart:convert' show jsonDecode;

import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

import 'generated/platform_constants.dart';
import 'manager.dart';

/// A socket instance internally used by the [SocketIOManager]
class SocketIO {
  /// Socket -or- Connection identifier
  final int id;

  ///Store Completer(s) for pending Acknowledgements
  final _pendingAcknowledgements = <String, Completer>{};
  int _reqCounter = 0;

  ///Method channel to interact with android/iOS
  final MethodChannel _channel;
  final StreamsChannel _streamsChannel =
      StreamsChannel('adhara_socket_io:event_streams');

  ///Create a socket object with identifier received from platform APIs
  SocketIO(this.id)
      : _channel = MethodChannel('adhara_socket_io:socket:${id.toString()}') {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'incomingAck') {
        var arguments = call.arguments['args'] as List<dynamic>;
        final reqId = call.arguments['reqId'] as String;
        if (reqId == null) {
          return;
        }
        final completer = _pendingAcknowledgements.remove(reqId);
        if (completer == null) {
          return;
        }

        if (arguments.isEmpty) {
          arguments = [null];
        } else {
          //TODO this works around difference in ios
          // (doesn't eat nulls) and android (eats nulls)
          arguments = arguments.where((_) => _ != null).map((_) {
            try {
              return jsonDecode(_ as String);
              // ignore: avoid_catches_without_on_clauses
            } catch (e) {
              return _;
            }
          }).toList();
        }
        completer.complete(arguments);
      }
    });
  }

  ///connect this socket to server
  Future<void> connect() => _channel.invokeMethod<void>('connect');

  ///listen to an event
  Stream<dynamic> on(String eventName) =>
      _streamsChannel.receiveBroadcastStream(<String, dynamic>{
        'id': id,
        'eventName': eventName,
      }).map((arguments) => arguments.map((_) {
            try {
              return jsonDecode(_ as String);
              // ignore: avoid_catches_without_on_clauses
            } catch (e) {
              return _;
            }
          }).toList());

  ///send data to socket server
  Future<void> emit(String eventName, List<dynamic> arguments) async {
    await _channel.invokeMethod('emit', <String, dynamic>{
      'eventName': eventName,
      'arguments': arguments,
    });
  }

  ///send data to socket server, return expected Ack as a Future
  Future emitWithAck(String eventName, List<dynamic> arguments) async {
    final reqId = (++_reqCounter).toString();
    await _channel.invokeMethod(
      'emit',
      {
        'eventName': eventName,
        'arguments': arguments,
        'reqId': reqId,
      },
    );
    final completer = Completer();
    _pendingAcknowledgements[reqId] = completer;
    return completer.future;
  }

  /// checks whether connection is alive
  Future<bool> isConnected() => _channel.invokeMethod('isConnected');

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
