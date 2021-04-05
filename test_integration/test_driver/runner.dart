import 'package:adhara_socket_io_example/data.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:test_integration/driver_data_handler.dart';

import 'utils.dart';

export 'package:test_integration/config/test_names.dart';

Future runBasicTest(FlutterDriver driver, Map<String, dynamic> data) async {
  final message = TestControlMessage(TestName.basic, payload: data);
  final response = TestControlMessage.fromJsonEncoded(
    await driver.requestData(message.toJsonEncoded()),
  );

  expect(response.testName, message.testName);

  expect(response.payload['id'], isA<int>());
}

Future runListenTest(FlutterDriver driver, Map<String, dynamic> data) async {
  final message = TestControlMessage(TestName.listen, payload: data);
  final response = TestControlMessage.fromJsonEncoded(
    await driver.requestData(message.toJsonEncoded()),
  );

  expect(response.testName, message.testName);
  expect(response.payload['id'], isA<int>());

  final messages = response.payload['messages'];
  expect(messages, isA<Map>());
  expect(messages['namespace'], isA<bool>());
  expect(messages['namespace'], data['options']['namespace'] != null);

  expect(messages['type:string'], isA<String>());
  expect(messages['type:string'], 'String message back to client');

  expect(messages['type:bool'], isA<bool>());
  expect(messages['type:bool'], true);

  expect(messages['type:number'], isA<int>());
  expect(messages['type:number'], 123);

  expect(messages['type:object'], isA<Map>());
  expect(messages['type:object'], {'hello': 'world'});

  expect(messages['type:list'], isA<List>());
  expect(messages['type:list'], [
    'hello',
    123,
    {'key': 'value'}
  ]);
}

Future runEventsTest(FlutterDriver driver, Map<String, dynamic> data) async {
  final message = TestControlMessage(TestName.events, payload: data);
  final response = TestControlMessage.fromJsonEncoded(
    await driver.requestData(message.toJsonEncoded()),
  );

  expect(response.testName, message.testName);

  expect(response.payload['id'], isA<int>());
  expect(response.payload['events'], isA<List>());
  expect(
    response.payload['events'],
    orderedEquals(const ['connect', 'disconnect']),
  );
}

Future runPublishTest(FlutterDriver driver, Map<String, dynamic> data) async {
  final message = TestControlMessage(TestName.publish, payload: data);
  final response = TestControlMessage.fromJsonEncoded(
    await driver.requestData(message.toJsonEncoded()),
  );

  expect(response.testName, message.testName);

  expect(response.payload['id'], isA<int>());
  expect(response.payload['counter'], messagesToPublish.length);
}

Future runEchoTest(FlutterDriver driver, Map<String, dynamic> data) async {
  final message = TestControlMessage(TestName.echo, payload: data);
  final response = TestControlMessage.fromJsonEncoded(
    await driver.requestData(message.toJsonEncoded()),
  );

  expect(response.testName, message.testName);

  final messages = response.payload['messages'] as List;
  expect(response.payload['id'], isA<int>());
  matchMessages(
    [
      ...messagesToPublish.map((e) => [e]),
      messagesToPublish.last,
    ],
    messages,
  );
}

Future runPublishWithACKTest(
  FlutterDriver driver,
  Map<String, dynamic> data,
) async {
  final message = TestControlMessage(TestName.ack, payload: data);
  final response = TestControlMessage.fromJsonEncoded(
    await driver.requestData(
      message.toJsonEncoded(),
      timeout: const Duration(seconds: 120),
    ),
  );

  expect(response.testName, message.testName);

  final messages = response.payload['messages'] as List;
  expect(response.payload['id'], isA<int>());
  matchMessages(
    [
      ...messagesToPublish.map((e) => [e]),
      messagesToPublish.last,
    ],
    messages,
  );
}
