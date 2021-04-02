import 'package:flutter_driver/flutter_driver.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'runner.dart';
import 'utils.dart';

export 'package:test_integration/config/test_names.dart';

void main() {
  group('Socket', () {
    FlutterDriver driver;
    String socketURL;
    const namespace = '/adhara';

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      socketURL = 'http://${await getIP()}:7070/';
      print('socketURL: $socketURL');
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

    test(
        'basic test',
        () => runBasicTest(driver, {
              'options': {'url': socketURL}
            }));

    test(
      'listen test',
      () => runListenTest(driver, {
        'options': {'url': socketURL}
      }),
    );

    test(
      'events test',
      () => runEventsTest(driver, {
        'options': {'url': socketURL}
      }),
    );

    test(
      'publish test',
      () => runPublishTest(driver, {
        'options': {'url': socketURL}
      }),
    );
    test(
      'echo test',
      () => runEchoTest(driver, {
        'options': {'url': socketURL}
      }),
    );

    test(
      'ack test',
      () => runPublishWithACKTest(driver, {
        'options': {'url': socketURL}
      }),
    );

    // namespace
    test(
      'namespace listen test',
      () => runListenTest(driver, {
        'options': {'url': socketURL, 'namespace': namespace}
      }),
    );

    test(
      'namespace events test',
      () => runEventsTest(driver, {
        'options': {'url': socketURL, 'namespace': namespace}
      }),
    );

    test(
      'namespace publish test',
      () => runPublishTest(driver, {
        'options': {'url': socketURL, 'namespace': namespace}
      }),
    );

    test(
      'namespace echo test',
      () => runEchoTest(driver, {
        'options': {'url': socketURL, 'namespace': namespace}
      }),
    );

    test(
      'namespace ack test',
      () => runPublishWithACKTest(driver, {
        'options': {'url': socketURL, 'namespace': namespace}
      }),
    );
  });
}
