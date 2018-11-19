import 'package:flutter/services.dart';

typedef void SocketEventListener(dynamic data);


class SocketIO{

  ///  Constants for default events handled by socket...
  ///  Refer [https://socket.io/docs/client-api/#Event-%E2%80%98connect%E2%80%99](https://socket.io/docs/client-api/#Event-%E2%80%98connect%E2%80%99)
  static const String CONNECT = "connect";
  static const String DISCONNECT = "disconnect";
  static const String CONNECT_ERROR = "connect_error";
  static const String CONNECT_TIMEOUT = "connect_timeout";
  static const String ERROR = "error";
  static const String CONNECTING = "connecting";
  static const String RECONNECT = "reconnect";
  static const String RECONNECT_ERROR = "reconnect_error";
  static const String RECONNECT_FAILED = "reconnect_failed";
  static const String RECONNECTING = "reconnecting";
  static const String PING = "ping";
  static const String PONG = "pong";

  int id;
  Map<String, List<Function>> listeners = {};
  final MethodChannel channel;

  SocketIO(this.id)
    :channel = new MethodChannel("adhara_socket_io:socket:${id.toString()}")
  {
    channel.setMethodCallHandler((call) {
      if (call.method == 'incoming') {
        final String eventName = call.arguments['eventName'];
        final List<dynamic> arguments = call.arguments['args'];
        _handleData(eventName, arguments);
      }
    });
  }

  connect() async {
    await channel.invokeMethod("connect");
  }

  on(String eventName, SocketEventListener listener){
    if(listeners[eventName] == null){
      listeners[eventName] = [];
    }
    listeners[eventName].add(listener);
    channel.invokeMethod("on", {
      "eventName": eventName
    });
  }

  off(String eventName, [SocketEventListener listener]){
    if(listener==null){
      listeners[eventName] = [];
    }else{
      listeners[eventName].remove(listener);
    }
    if(listeners[eventName].length == 0){
      channel.invokeMethod("off", {
        "eventName": eventName
      });
    }
  }

  emit(String eventName, List<dynamic> arguments) async {
    await channel.invokeMethod('emit', {
      'eventName': eventName,
      'arguments': arguments,
    });
  }

  _handleData(String eventName, List arguments){
    listeners[eventName]?.forEach((Function listener){
      if(arguments.length==0){
        arguments = [null];
      }
      Function.apply(listener, arguments);
    });
  }

  //Utility methods for listeners. De-registering can be handled using off(eventName, fn)
  onConnect(SocketEventListener listener) => on(CONNECT, listener);
  onDisconnect(SocketEventListener listener) => on(DISCONNECT, listener);
  onConnectError(SocketEventListener listener) => on(CONNECT_ERROR, listener);
  onConnectTimeout(SocketEventListener listener) => on(CONNECT_TIMEOUT, listener);
  onError(SocketEventListener listener) => on(ERROR, listener);
  onConnecting(SocketEventListener listener) => on(CONNECTING, listener);
  onReconnect(SocketEventListener listener) => on(RECONNECT, listener);
  onReconnectError(SocketEventListener listener) => on(RECONNECT_ERROR, listener);
  onReconnectFailed(SocketEventListener listener) => on(RECONNECT_FAILED, listener);
  onReconnecting(SocketEventListener listener) => on(RECONNECTING, listener);
  onPing(SocketEventListener listener) => on(PING, listener);
  onPong(SocketEventListener listener) => on(PONG, listener);

}