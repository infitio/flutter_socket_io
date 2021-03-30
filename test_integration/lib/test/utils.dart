import 'package:adhara_socket_io/adhara_socket_io.dart';

SocketOptions getSocketOptions(Map<String, dynamic> payload) {
  final _options = Map.castFrom<dynamic, dynamic, String, dynamic>(
    payload['options'] as Map,
  );
  print('socket options: $_options');
  final socketURL = _options['url'] as String;
  return SocketOptions(socketURL,
      namespace: _options['namespace'] as String ?? '/', enableLogging: true);
}
