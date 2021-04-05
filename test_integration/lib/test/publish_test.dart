import 'package:adhara_socket_io_example/data.dart';

import '../factory/reporter.dart';
import 'utils.dart';

Future<Map<String, dynamic>> publishTest(
    {Reporter reporter, Map<String, dynamic> payload}) async {
  // creating socket
  final socket = await createSocket(payload);

  // connect
  await socket.connectSync();

  var counter = 0;
  for (final message in messagesToPublish) {
    await socket.emit('data', [message]);
    counter++;
  }

  // disposing socket
  await disposeSocket(socket);

  return {'id': socket.id, 'counter': counter};
}
