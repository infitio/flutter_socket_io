//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

// ignore_for_file: public_member_api_docs

class MethodChannelNames {
  static const String managerMethodChannel = 'adhara_socket_io';
  static const String socketMethodChannel = 'adhara_socket_io:socket:';
  static const String streamsChannel = 'adhara_socket_io:event_streams';
}

class CodecTypes {
  static const int type1 = 128;
}

class PlatformMethod {
  static const String newInstance = 'newInstance';
  static const String clearInstance = 'clearInstance';
  static const String connect = 'connect';
  static const String emit = 'emit';
  static const String isConnected = 'isConnected';
  static const String incomingAck = 'incomingAck';
}

class TxEventTypes {
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String connectError = 'connectError';
  static const String connectTimeout = 'connectTimeout';
  static const String error = 'error';
  static const String connecting = 'connecting';
  static const String reconnect = 'reconnect';
  static const String reconnectError = 'reconnectError';
  static const String reconnectFailed = 'reconnectFailed';
  static const String reconnecting = 'reconnecting';
  static const String ping = 'ping';
  static const String pong = 'pong';
}

class TxTransportModes {
  static const String websocket = 'websocket';
  static const String polling = 'polling';
}

class TxMessageDataTypes {
  static const String map = 'map';
  static const String list = 'list';
  static const String other = 'other';
}

class TxSocketMessage {
  static const String type = 'type';
  static const String message = 'message';
}
