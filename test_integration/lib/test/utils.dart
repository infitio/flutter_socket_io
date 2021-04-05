import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';

SocketOptions getSocketOptions(Map<String, dynamic> payload) {
  final _options = Map.castFrom<dynamic, dynamic, String, dynamic>(
    payload['options'] as Map,
  );
  print('socket options: $_options');
  final socketURL = _options['url'] as String;
  return SocketOptions(
    socketURL,
    namespace: _options['namespace'] as String ?? '/',
    enableLogging: true,
  );
}

final _socketSubscriptions = <int, StreamSubscription>{};
Future<SocketIO> createSocket(Map<String, dynamic> payload) async {
  final socket =
      await SocketIOManager().createInstance(getSocketOptions(payload));
  // ignore: cancel_subscriptions
  final errorListener = socket.onError.listen((args) {
    print('error event received $args');
  });
  _socketSubscriptions[socket.id] = errorListener;
  return socket;
}

Future<void> disposeSocket(SocketIO socket) async {
  await _socketSubscriptions[socket.id].cancel();
  await Future.delayed(const Duration(seconds: 2));
  await SocketIOManager().clearInstance(socket);
}
