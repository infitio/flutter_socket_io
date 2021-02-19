import 'package:flutter_driver/flutter_driver.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:test_integration/config/data.dart';
import 'package:test_integration/driver_data_handler.dart';

import 'utils.dart';

export 'package:test_integration/config/test_names.dart';

void main() {
  group('Socket', () {
    FlutterDriver driver;
    String socketURL;
    Map<String, dynamic> socketOptions;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      socketURL = 'http://${await getIP()}:7000/';
      print('socketURL: $socketURL');
      socketOptions = {'url': socketURL};
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('server running', () async {
      final response = await http.get(socketURL);
      expect(response.statusCode, 200);
    });

    test('basic test', () async {
      final data = {'options': socketOptions};
      final message = TestControlMessage(TestName.basic, payload: data);
      final response = TestControlMessage.fromJsonEncoded(
        await driver.requestData(message.toJsonEncoded()),
      );

      expect(response.testName, message.testName);

      expect(response.payload['id'], isA<int>());
      // expect(response.payload['platformVersion'], isNot(isEmpty));
      // expect(response.payload['ablyVersion'], isA<String>());
      // expect(response.payload['ablyVersion'], isNot(isEmpty));
    });

    test('connect test', () async {
      final data = {'options': socketOptions};
      final message = TestControlMessage(TestName.connect, payload: data);
      final response = TestControlMessage.fromJsonEncoded(
        await driver.requestData(message.toJsonEncoded()),
      );

      expect(response.testName, message.testName);

      expect(response.payload['id'], isA<int>());
      expect(response.payload['events'], isA<List>());
      expect(response.payload['events'], orderedEquals(const ['connect']));
      // expect(response.payload['platformVersion'], isNot(isEmpty));
    });

    test('events test', () async {
      final data = {'options': socketOptions};
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
      // expect(response.payload['platformVersion'], isNot(isEmpty));
    });

    test('publish test', () async {
      final data = {'options': socketOptions};
      final message = TestControlMessage(TestName.publish, payload: data);
      final response = TestControlMessage.fromJsonEncoded(
        await driver.requestData(message.toJsonEncoded()),
      );

      expect(response.testName, message.testName);

      expect(response.payload['id'], isA<int>());
      expect(response.payload['counter'], messagesToPublish.length);
    });

    test('echo test', () async {
      final data = {'options': socketOptions};
      final message = TestControlMessage(TestName.echo, payload: data);
      final response = TestControlMessage.fromJsonEncoded(
        await driver.requestData(message.toJsonEncoded()),
      );

      expect(response.testName, message.testName);

      final messages = response.payload['messages'] as List;
      expect(response.payload['id'], isA<int>());
      expect(messages.length, messagesToPublish.length+1);
      for(var i=0; i<messagesToPublish.length; i++){
        expect(messages[i], equals([messagesToPublish[i]]));
      }
      expect(messages.last, equals(messagesToPublish.last));
    });
  });
}
