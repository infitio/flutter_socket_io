import 'dart:convert' show json;

import 'generated/platform_constants.dart';

String _getType(Object object) {
  if (object is Map) {
    return TxMessageDataTypes.map;
  } else if (object is List) {
    return TxMessageDataTypes.list;
  } else {
    return TxMessageDataTypes.other;
  }
}

Object? _decodeMessage(Object? argument) {
  try {
    return json.decode(argument as String);
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    return argument;
  }
}

/// Handles messages and their data types
class SocketMessage {
  String? _type;

  /// original/json-encoded message
  final Object? message;

  /// Create socket message from a socekt payload
  SocketMessage(Object object)
      : message =
            (object is Map || object is List) ? json.encode(object) : object,
        _type = _getType(object);

  /// encodes to platform serializable object
  Map<String, dynamic> toPlatform() => {
        TxSocketMessage.type: _type,
        TxSocketMessage.message: message,
      };

  /// decodes message from platform and stores in message
  SocketMessage.fromPlatform(Object? object) : message = _decodeMessage(object);
}
