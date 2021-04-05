import 'dart:io';

import 'package:test/test.dart';

Future<String> getIP() async {
  for (final interface in await NetworkInterface.list()) {
    return interface.addresses
        .firstWhere((address) =>
            address.rawAddress[0] == 192 || address.rawAddress[0] == 10)
        ?.address;
  }
  return null;
}

void _testMessage(Object sent, Object received) {
  if (sent is List) {
    expect(received, isA<List>());
    expect((received as List).length, equals(sent.length));
    for (var i = 0; i < sent.length; i++) {
      _testMessage(sent[i], (received as List)[i]);
    }
  } else if (sent is Map) {
    for (final entry in sent.entries) {
      expect(received, isA<Map>());
      expect((received as Map).containsKey(entry.key), true);
      _testMessage(entry.value, (received as Map)[entry.key]);
    }
  } else {
    expect(sent, equals(received));
  }
}

void matchMessages(List published, List received) {
  expect(received.length, equals(published.length));
  for (var i = 0; i < published.length; i++) {
    _testMessage(published[i], received[i]);
  }
}
