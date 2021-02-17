///Transmission protocol custom types. Will be used by codecs
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

///Platform method names
const List<Map<String, dynamic>> _platformMethods = [
  // TODO add platform methods
  {'name': 'method1', 'value': 'method1'},
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
      'webSocket',
      'polling',
    ]
  },
];

// exporting all the constants as a single map
// which can be directly fed to template as context
Map<String, dynamic> context = {
  'types': _types,
  'methods': _platformMethods,
  'objects': _objects
};
