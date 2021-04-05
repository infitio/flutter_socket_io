import '../factory/reporter.dart';
import 'utils.dart';

Future<Map<String, dynamic>> eventsTest(
    {Reporter reporter, Map<String, dynamic> payload}) async {
  // creating socket
  final socket = await createSocket(payload);

  final events = <String>[];

  final subscriptions = [
    socket.onConnect.listen((args) => events.add('connect')),
    socket.onDisconnect.listen((args) => events.add('disconnect')),
    //
    // TODO below events don't trigger on android while they trigger on iOS
    //  possibly because iOS tries to upgrade from Polling to WS always?
    //  Needs to be investigated
    //
    // socket.onConnecting.listen((args) => events.add('connecting')),
    // socket.onConnectError.listen((args) => events.add('connect_error')),
    // socket.onConnectTimeout.listen((args) => events.add('connect_timeout')),
    // socket.onError.listen((args) => events.add('error')),
    // socket.onReconnecting.listen((args) => events.add('reconnecting')),
    // socket.onReconnect.listen((args) => events.add('reconnect')),
    // socket.onReconnectError.listen((args) => events.add('reconnect_error')),
    // socket.onReconnectFailed.listen((args) => events.add(
    //   'reconnect_failed',
    // )),
    // socket.onPing.listen((args) => events.add('ping')),
    // socket.onPong.listen((args) => events.add('pong')),
  ];

  // connect
  await socket.connectSync();

  // disposing socket
  await disposeSocket(socket);

  // attributing to the async delays from stream channel
  // waiting to receive events, and then cancelling subscriptions
  await Future.delayed(const Duration(seconds: 2));
  await Future.wait(subscriptions.map((e) => e.cancel()));

  return {'id': socket.id, 'events': events};
}
