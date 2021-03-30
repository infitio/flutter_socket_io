import 'dart:convert';

import 'package:flutter_driver/flutter_driver.dart';

export 'config/test_names.dart';

/// Send a message to run a widget test and receive a response.
///
/// Helper to minimize repeatedly used code in driver tests.
Future<TestControlMessage> getTestResponse(
  FlutterDriver driver,
  TestControlMessage message,
) async {
  final result = await driver.requestData(message.toJsonEncoded());
  return TestControlMessage.fromJsonEncoded(result);
}

/// Used to encode and decode messages between driver test and test widget.
class TestControlMessage {
  const TestControlMessage(
    this.testName, {
    this.payload,
    this.log,
  }) : assert(testName != null && testName.length != null);

  static const testNameKey = 'testName';
  static const payloadKey = 'payload';
  static const errorKey = 'error';
  static const logKey = 'log';

  final String testName;
  final Map<String, dynamic> payload;
  final List<dynamic> log;

  factory TestControlMessage.fromJsonEncoded(String encoded) =>
      TestControlMessage.fromJson(json.decode(encoded) as Map);

  factory TestControlMessage.fromJson(Map jsonValue) => TestControlMessage(
        jsonValue[testNameKey] as String,
        payload: jsonValue[payloadKey] as Map<String, dynamic>,
        log: jsonValue[logKey] as List<dynamic>,
      );

  Map<String, dynamic> toJson() => {
        testNameKey: testName,
        payloadKey: payload,
        logKey: log,
      };

  String toJsonEncoded() => json.encode(toJson());

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
