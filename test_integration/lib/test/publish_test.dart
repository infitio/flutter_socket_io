import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:test_integration/config/data.dart';

import '../test_dispatcher.dart';
import 'utils.dart';

Future<Map<String, dynamic>> publishTest({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload
}) async {
  final manager = SocketIOManager();
  final socket = await manager.createInstance(getSocketOptions(payload));

  // connect
  await socket.connect();

  var counter = 0;
  for(final message in messagesToPublish) {
    await socket.emit('data', [message]);
    counter++;
  }

  await manager.clearInstance(socket);

  return {'id': socket.id, 'counter': counter};
}
