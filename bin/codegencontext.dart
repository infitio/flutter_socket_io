/// Method channel names
const List<Map<String, dynamic>> _methodChannels = [
  {'name': 'managerMethodChannel', 'value': 'adhara_socket_io'},
  {'name': 'socketMethodChannel', 'value': 'adhara_socket_io:socket:'},
  {'name': 'streamsChannel', 'value': 'adhara_socket_io:event_streams'},
];

/// Transmission protocol custom types. Will be used by codecs
Iterable<Map<String, dynamic>> get _types sync* {
  const platformTypes = <String>[
    // TODO add platform types
    'type1'
  ];

  // https://api.flutter.dev/flutter/services/StandardMessageCodec/writeValue.html
  var index = 128;
  for (final platformType in platformTypes) {
    yield {'name': platformType, 'value': index++};
  }
}

/// Platform method names
const List<Map<String, dynamic>> _platformMethods = [
  {'name': 'newInstance', 'value': 'newInstance'},
  {'name': 'clearInstance', 'value': 'clearInstance'},
  {'name': 'connect', 'value': 'connect'},
  {'name': 'emit', 'value': 'emit'},
  {'name': 'isConnected', 'value': 'isConnected'},
  {'name': 'incomingAck', 'value': 'incomingAck'},
];

const List<Map<String, dynamic>> _objects = [
  {
    // Constants for default events handled by socket...
    // Refer [https://socket.io/docs/client-api/#Event-%E2%80%98connect%E2%80%99](https://socket.io/docs/client-api/#Event-%E2%80%98connect%E2%80%99)
    'name': 'EventTypes',
    'properties': <String>[
      'connect',
      'disconnect',
      'connectError',
      'connectTimeout',
      'error',
      'connecting',
      'reconnect',
      'reconnectError',
      'reconnectFailed',
      'reconnecting',
      'ping',
      'pong',
    ]
  },
  {
    'name': 'TransportModes',
    'properties': <String>[
      'websocket',
      'polling',
    ]
  },
  {
    'name': 'MessageDataTypes',
    'properties': <String>[
      'map',
      'list',
      'other',
    ]
  },
  {
    'name': 'SocketMessage',
    'properties': <String>[
      'type',
      'message',
    ]
  }
];

// exporting all the constants as a single map
// which can be directly fed to template as context
Map<String, dynamic> context = {
  'channels': _methodChannels,
  'types': _types,
  'methods': _platformMethods,
  'objects': _objects
};
