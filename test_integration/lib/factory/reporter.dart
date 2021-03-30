import 'dart:async';

import '../driver_data_handler.dart';
import '../test_dispatcher.dart';

class Reporter {
  final TestControlMessage message;
  final DispatcherController controller;
  final Completer<TestControlMessage> response;

  Reporter(
    this.message,
    this.controller,
  ) : response = Completer<TestControlMessage>();

  String get testName => message?.testName;

  final _log = <dynamic>[];

  /// Collect log messages.to be sent with the response at the end of the test.
  void reportLog(Object log) => _log.add(log);

  /// Create a response to a message from the driver reporting the test result.
  void reportTestCompletion(Map<String, dynamic> data) {
    final msg = TestControlMessage(
      testName,
      payload: data,
      log: _log.toList(),
    );
    response.complete(msg);
    controller.setResponse(msg);
  }

  void reportTestError(String errorMessage) {
    response.completeError(
      'New test started while the previous one is still running.',
    );
  }
}
