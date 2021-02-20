import 'package:adhara_socket_io/adhara_socket_io.dart';

import '../test_dispatcher.dart';
import 'utils.dart';

Future<Map<String, dynamic>> basicTest({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
  final manager = SocketIOManager();
  final socket = await manager.createInstance(getSocketOptions(payload));
  await socket.connect();
  await manager.clearInstance(socket);

  return {
    'id': socket.id,
  };
}

Future<Map<String, dynamic>> connectTest({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
  final manager = SocketIOManager();
  final socket = await manager.createInstance(getSocketOptions(payload));
  final events = <String>[];

  final subscription = socket.onConnect.listen((event) {
    events.add('connect');
  });

  final messages = {};
  socket.on('namespace').listen((args) => messages['namespace'] = args[0]);
  socket.on('type:string').listen((args) => messages['type:string'] = args[0]);
  socket.on('type:bool').listen((args) => messages['type:bool'] = args[0]);
  socket.on('type:number').listen((args) => messages['type:number'] = args[0]);
  socket.on('type:object').listen((args) => messages['type:object'] = args[0]);
  socket.on('type:list').listen((args) => messages['type:list'] = args[0]);

  // connect
  await socket.connect();

  // waiting and disconnecting
  await Future.delayed(const Duration(seconds: 2));
  await manager.clearInstance(socket);

  // attributing to the async delays from stream channel
  // waiting to receive events, and then cancelling subscription
  await Future.delayed(const Duration(seconds: 2));
  await subscription.cancel();

  return {'id': socket.id, 'events': events};
}