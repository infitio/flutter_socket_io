import 'package:adhara_socket_io/adhara_socket_io.dart';

import '../test_dispatcher.dart';
import 'utils.dart';

Future<Map<String, dynamic>> eventsTest({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload
}) async {
  final manager = SocketIOManager();
  final socket = await manager.createInstance(getSocketOptions(payload));
  final events = <String>[];

  final subscriptions = [
    socket.onConnect.listen((args) => events.add('connect')),
    socket.onConnecting.listen((args) => events.add('connecting')),
    socket.onConnectError.listen((args) => events.add('connect_error')),
    socket.onConnectTimeout.listen((args) => events.add('connect_timeout')),
    socket.onDisconnect.listen((args) => events.add('disconnect')),
    socket.onError.listen((args) => events.add('error')),
    socket.onReconnecting.listen((args) => events.add('reconnecting')),
    socket.onReconnect.listen((args) => events.add('reconnect')),
    socket.onReconnectError.listen((args) => events.add('reconnect_error')),
    socket.onReconnectFailed.listen((args) => events.add('reconnect_failed')),
    socket.onPing.listen((args) => events.add('ping')),
    socket.onPong.listen((args) => events.add('pong')),
  ];

  // connect
  await socket.connect();

  // waiting and disconnecting
  await Future.delayed(const Duration(seconds: 2));
  await manager.clearInstance(socket);

  // attributing to the async delays from stream channel
  // waiting to receive events, and then cancelling subscriptions
  await Future.delayed(const Duration(seconds: 2));
  await Future.wait(subscriptions.map((e) => e.cancel()));

  return {'id': socket.id, 'events': events};
}
