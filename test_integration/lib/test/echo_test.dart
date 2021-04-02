import 'package:adhara_socket_io_example/data.dart';

import '../factory/reporter.dart';
import 'utils.dart';

Future<Map<String, dynamic>> echoTest({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  // creating socket
  final socket = await createSocket(payload);

  final messages = <Object>[];

  await socket.connectSync();
  final subscription = socket.on('echo').listen(messages.add);

  for (final message in messagesToPublish) {
    await socket.emit('echo', [message]);
  }

  await socket.emit('echo', messagesToPublish.last as List);

  // disposing socket
  await disposeSocket(socket);

  // attributing to the async delays from stream channel
  // waiting to receive events, and then cancelling subscriptions
  await Future.delayed(const Duration(seconds: 2));
  await subscription.cancel();

  return {'id': socket.id, 'messages': messages};
}
