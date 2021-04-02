import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:test_integration/config/data.dart';

import '../factory/reporter.dart';
import 'utils.dart';

Future<Map<String, dynamic>> publishWithACKTest({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  // creating socket
  final socket = await createSocket(payload);

  // connect
  await socket.connectSync();

  final messages = [];
  for (final message in messagesToPublish) {
    print('emitting ack msg loop');
    final messageAck = await socket.emitWithAck('ack-message', [message]);
    print('ack recd: $messageAck');
    messages.add(messageAck);
  }
  print('emitting last ack msg');
  final ack_message = await socket.emitWithAck(
    'ack-message',
    messagesToPublish.last as List,
  );
  print('ack recd: $ack_message');
  messages.add(ack_message);

  // disposing socket
  await disposeSocket(socket);

  return {'id': socket.id, 'messages': messages};
}
