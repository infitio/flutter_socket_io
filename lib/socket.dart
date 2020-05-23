import 'package:flutter/services.dart';
import 'dart:convert' show jsonDecode;
import 'dart:async';
import 'package:streams_channel/streams_channel.dart';

class SocketIO {
  ///  Constants for default events handled by socket...
  ///  Refer [https://socket.io/docs/client-api/#Event-%E2%80%98connect%E2%80%99](https://socket.io/docs/client-api/#Event-%E2%80%98connect%E2%80%99)
  ///  Socket Connect event
  static const String CONNECT = "connect";

  ///  Socket Disconnect event
  static const String DISCONNECT = "disconnect";

  ///  Socket Connection Error event
  static const String CONNECT_ERROR = "connect_error";

  ///  Socket Connection timeout event
  static const String CONNECT_TIMEOUT = "connect_timeout";

  ///  Socket Error event
  static const String ERROR = "error";

  ///  Socket Connecting event
  static const String CONNECTING = "connecting";

  ///  Socket Reconnect event
  static const String RECONNECT = "reconnect";

  ///  Socket Reconnect Error event
  static const String RECONNECT_ERROR = "reconnect_error";

  ///  Socket Reconnect Failed event
  static const String RECONNECT_FAILED = "reconnect_failed";

  ///  Socket Reconnecting event
  static const String RECONNECTING = "reconnecting";

  ///  Socket Ping event
  static const String PING = "ping";

  ///  Socket Pong event
  static const String PONG = "pong";

  ///Socket/Connection identifier
  int id;

  ///Store Completers for pending Acks
  Map<String, Completer> _pendingAcks = {};
  int _reqCounter = 0;

  ///Method channel to interact with android/iOS
  final MethodChannel _channel;
  final StreamsChannel _streamsChannel = new StreamsChannel('adhara_socket_io:event_streams');

  ///Create a socket object with identifier received from platform API's
  SocketIO(this.id)
      : _channel = new MethodChannel("adhara_socket_io:socket:${id.toString()}")
  {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'incoming') {
        final String eventName = call.arguments['eventName'];
        final List<dynamic> arguments = call.arguments['args'];
        _handleData(eventName, arguments);
      }
      if (call.method == 'incomingAck') {
        List<dynamic> arguments = call.arguments['args'];
        final String reqId = call.arguments['reqId'];
        if (reqId == null) {
          return;
        }
        final completer = _pendingAcks.remove(reqId);
        if (completer == null) {
          return;
        }

        if (arguments.length == 0) {
          arguments = [null];
        } else {
          arguments = arguments.where((_) {
            //TODO this works around difference in ios (doesn't eat nulls) and android (eats nulls)
            return _ != null;
          }).map((_) {
            try {
              return jsonDecode(_);
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
  connect() async {
    await _channel.invokeMethod("connect");
  }

  ///listen to an event
  Stream<dynamic> on(String eventName){
    return _streamsChannel.receiveBroadcastStream(<String, dynamic>{
      "id": id,
      "eventName": eventName
    });
  }

  ///send data to socket server
  emit(String eventName, List<dynamic> arguments) async {
    await _channel.invokeMethod('emit', <String, dynamic>{
      'eventName': eventName,
      'arguments': arguments,
    });
  }

  ///send data to socket server, return expected Ack as a Future
  Future emitWithAck(String eventName, List<dynamic> arguments) async {
    String reqId = (++_reqCounter).toString();
    await _channel.invokeMethod('emit',
        {'eventName': eventName, 'arguments': arguments, 'reqId': reqId});
    var completer = new Completer();
    _pendingAcks[reqId] = completer;
    return completer.future;
  }

  Future<bool> isConnected() async {
    return await _channel.invokeMethod('isConnected');
  }

  ///Data listener called by platform API
  //TODO do this in stream modification
  Map _listeners = {};  //TODO remove this variable and below method
  _handleData(String eventName, List arguments) {
    _listeners[eventName]?.forEach((Function listener) {
      if (arguments.length == 0) {
        arguments = [null];
      } else {
        arguments = arguments.map((_) {
          try {
            return jsonDecode(_);
          } catch (e) {
            return _;
          }
        }).toList();
      }
      Function.apply(listener, arguments);
    });
  }

  //Utility methods for listeners. De-registering can be handled using off(eventName, fn)
  ///Listen to connect event
  Stream<dynamic> get onConnect => on(CONNECT);

  ///Listen to disconnect event
  Stream<dynamic> get onDisconnect => on(DISCONNECT);

  ///Listen to connection error event
  Stream<dynamic> get onConnectError => on(CONNECT_ERROR);

  ///Listen to connection timeout event
  Stream<dynamic> get onConnectTimeout => on(CONNECT_TIMEOUT);

  ///Listen to error event
  Stream<dynamic> get onError => on(ERROR);

  ///Listen to connecting event
  Stream<dynamic> get onConnecting => on(CONNECTING);

  ///Listen to reconnect event
  Stream<dynamic> get onReconnect => on(RECONNECT);

  ///Listen to reconnect error event
  Stream<dynamic> get onReconnectError => on(RECONNECT_ERROR);

  ///Listen to reconnect failed event
  Stream<dynamic> get onReconnectFailed => on(RECONNECT_FAILED);

  ///Listen to reconnecting event
  Stream<dynamic> get onReconnecting => on(RECONNECTING);

  ///Listen to ping event
  Stream<dynamic> get onPing => on(PING);

  ///Listen to pong event
  Stream<dynamic> get onPong => on(PONG);
}
