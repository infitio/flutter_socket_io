import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'config/test_factory.dart';
import 'driver_data_handler.dart';

/// Decodes messages from the driver, invokes the test and returns the result.
class TestDispatcher extends StatefulWidget {
  final DriverDataHandler driverDataHandler;
  final ErrorHandler errorHandler;
  final Map<String, TestFactory> testFactory;

  const TestDispatcher({
    Key key,
    this.testFactory,
    this.driverDataHandler,
    this.errorHandler,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TestDispatcherState();
}

class TestDispatcherState extends State<TestDispatcher> {
  /// The last message received from the driver.
  TestControlMessage _message;

  Map<String, String> _testResults;

  /// stores whether a test is success/failed/pending
  /// {'basic': true} => basic test passed,
  /// {'basic': false} => failed
  /// {} i.e., missing 'basic' key => test is still pending
  final _testStatuses = <String, bool>{};

  /// To wait for the response of the test after a received message.
  Completer<TestControlMessage> _responseCompleter;

  @override
  void initState() {
    super.initState();
    _testResults = <String, String>{
      for (final key in testFactory.keys) key: '',
    };

    widget.driverDataHandler.callback = _incomingDriverMessageHandler;
    widget.errorHandler.callback =
        _unhandledTestExceptionAndFlutterErrorHandler;
  }

  Future<TestControlMessage> _incomingDriverMessageHandler(
    TestControlMessage m,
  ) async {
    if (_responseCompleter != null) {
      _responseCompleter.completeError(
        'New test started while the previous one is still running.',
      );
      _responseCompleter = null;
      _log.clear();
    }
    _responseCompleter = Completer<TestControlMessage>();

    setState(() => _message = m);

    return _responseCompleter.future;
  }

  void _unhandledTestExceptionAndFlutterErrorHandler(
    Map<String, String> errorMessage,
  ) =>
      reportTestCompletion({TestControlMessage.errorKey: errorMessage});

  final _log = <dynamic>[];

  /// Collect log messages.to be sent with the response at the end of the test.
  void reportLog(Object log) => _log.add(log);

  /// Create a response to a message from the driver reporting the test result.
  void reportTestCompletion(Map<String, dynamic> data) {
    final testName = _message?.testName ?? 'N/A';
    final msg = TestControlMessage(
      testName,
      payload: data,
      log: _log.toList(),
    );
    _responseCompleter?.complete(msg);
    _log.clear();
    _responseCompleter = null;

    _testResults[msg.testName] = msg.toPrettyJson();
    setState(() {
      _message = null;
      _testStatuses[testName] = !data.containsKey(TestControlMessage.errorKey);
    });
  }

  Widget getTestButton(String testName) => FlatButton(
        color: _testStatuses.containsKey(testName)
            ? _testStatuses[testName]
                ? Colors.green
                : Colors.red
            : Colors.blue,
        onPressed: _responseCompleter != null
            ? null
            : () {
                widget.driverDataHandler.call(
                  TestControlMessage(testName).toJsonEncoded(),
                );
              },
        child: Text(testName),
      );

  @override
  Widget build(BuildContext context) {
    Widget testWidget;
    if (_noMessageReceivedYet) {
      testWidget = Container();
    } else {
      if (widget.testFactory.containsKey(_message.testName)) {
        testWidget = Container();
        widget.testFactory[_message.testName](
          dispatcher: this,
          payload: _message.payload,
        )
            .then(reportTestCompletion);
      } else {
        reportTestCompletion({
          TestControlMessage.errorKey:
              'Test ${_message?.testName ?? 'N/A'} is not implemented'
        });
        testWidget = Container();
      }
    }

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Test dispatcher'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(_message?.testName ?? 'N/A'),
          ),
          testWidget,
          Expanded(
            child: ListView.builder(
              itemCount: _testResults.keys.length,
              itemBuilder: (context, idx) {
                final testName = _testResults.keys.toList()[idx];
                return ListTile(
                  title: getTestButton(testName),
                  subtitle: Text(_testResults[testName] ?? 'No result yet'),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }

  bool get _noMessageReceivedYet => _message == null;
}

/// Used to wire app unhandled exceptions and Flutter errors to be reported back
/// to the test driver.
class ErrorHandler {
  void Function(Map<String, String> message) callback;

  void onFlutterError(FlutterErrorDetails details) {
    print(details.exception);
    print(details.stack);

    callback({
      'exceptionType': '${details.exception.runtimeType}',
      'exception': details.exceptionAsString(),
      'context': details.context?.toDescription(),
      'library': details.library,
      'stackTrace': '${details.stack}',
    });
  }

  void onException(Object error, StackTrace stack) {
    print(error);
    print(stack);

    callback({
      'exceptionType': '${error.runtimeType}',
      'exception': '$error',
      'stackTrace': '$stack',
    });
  }
}

typedef TestFactory = Future<Map<String, dynamic>> Function({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
});
