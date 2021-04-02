import '../factory/reporter.dart';
import 'utils.dart';

Future<Map<String, dynamic>> basicTest({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  // creating socket
  final socket = await createSocket(payload);

  // connect
  await socket.connectSync();

  // disposing socket
  await disposeSocket(socket);

  return {
    'id': socket.id,
  };
}

Future<Map<String, dynamic>> listenTest({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  // creating socket
  final socket = await createSocket(payload);

  final messages = {};
  final subscriptions = [
    socket.on('namespace').listen((args) => messages['namespace'] = args[0]),
    socket
        .on('type:string')
        .listen((args) => messages['type:string'] = args[0]),
    socket.on('type:bool').listen((args) => messages['type:bool'] = args[0]),
    socket
        .on('type:number')
        .listen((args) => messages['type:number'] = args[0]),
    socket
        .on('type:object')
        .listen((args) => messages['type:object'] = args[0]),
    socket.on('type:list').listen((args) => messages['type:list'] = args[0]),
  ];

  // connect
  await socket.connectSync();

  // disposing socket
  await disposeSocket(socket);

  // attributing to the async delays from stream channel
  // waiting to receive events, and then cancelling subscription
  await Future.delayed(const Duration(seconds: 4));
  await Future.wait(subscriptions.map((_) => _.cancel()));

  return {'id': socket.id, 'messages': messages};
}
