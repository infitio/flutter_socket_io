import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:test_integration/config/data.dart';

import '../test_dispatcher.dart';
import 'utils.dart';

Future<Map<String, dynamic>> publishWithACKTest(
    {TestDispatcherState dispatcher, Map<String, dynamic> payload}) async {
  final manager = SocketIOManager();
  final socket = await manager.createInstance(getSocketOptions(payload));

  // connect
  await socket.connect();
  final messages = [];

  for (final message in messagesToPublish) {
    final messageAck = await socket.emitWithAck('ack-message', [message]);
    messages.add(messageAck);
  }
  messages.add(
    await socket.emitWithAck('ack-message', messagesToPublish.last as List),
  );

  await manager.clearInstance(socket);

  return {'id': socket.id, 'messages': messages};
}
