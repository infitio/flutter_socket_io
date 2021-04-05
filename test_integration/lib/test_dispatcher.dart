import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'config/test_factory.dart';
import 'driver_data_handler.dart';
import 'factory/error_handler.dart';
import 'factory/reporter.dart';

enum _TestStatus { success, error, progress }

/// Decodes messages from the driver, invokes the test and returns the result.
class TestDispatcher extends StatefulWidget {
  final Map<String, TestFactory> testFactory;
  final DispatcherController controller;

  const TestDispatcher({
    Key key,
    this.testFactory,
    this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TestDispatcherState();
}

class _TestDispatcherState extends State<TestDispatcher> {
  /// A map of active test names vs reporters
  final _reporters = <String, Reporter>{};

  Map<String, String> _testResults;

  /// stores whether a test is success/failed/pending
  /// {'restPublish': true} => basic test passed,
  /// {'restPublish': false} => failed
  /// {} i.e., missing 'restPublish' key => test is still pending
  final _testStatuses = <String, _TestStatus>{};

  @override
  void initState() {
    super.initState();
    widget.controller.setDispatcher(this);
    _testResults = <String, String>{
      for (final key in testFactory.keys) key: '',
    };
  }

  Future<TestControlMessage> handleDriverMessage(
    TestControlMessage message,
  ) {
    final reporter = Reporter(message, widget.controller);

    Future.delayed(Duration.zero, () async {
      // check if a test is running and throw error
      if (_reporters.containsKey(reporter.testName)) {
        reporter.reportTestError(
          'Test started while the previous one is still running.',
        );
        return;
      }
      _reporters[reporter.testName] = reporter;
      if (widget.testFactory.containsKey(reporter.testName)) {
        // check if a test exists with that name
        if (widget.testFactory.containsKey(reporter.testName)) {
          setState(() {
            _testStatuses[reporter.testName] = _TestStatus.progress;
          });
          final testFunction = widget.testFactory[reporter.testName];
          await testFunction(
            reporter: reporter,
            payload: reporter.message.payload,
          )
              .timeout(
                // test driver timeout is 30s by default
                //  and max configured is 120s
                const Duration(seconds: 100),
              )
              .then((response) => reporter?.reportTestCompletion(response))
              .catchError(
                (error, stack) => reporter.reportTestCompletion({
                  TestControlMessage.errorKey: ErrorHandler.encodeException(
                    error,
                    stack as StackTrace,
                  ),
                }),
              );
        }
      } else if (reporter.testName == TestName.getFlutterErrors) {
        reporter.reportTestCompletion({'logs': _flutterErrorLogs});
        _flutterErrorLogs.clear();
      } else {
        // report error otherwise
        reporter.reportTestCompletion({
          TestControlMessage.errorKey:
              'Test ${reporter.testName} is not implemented'
        });
      }
      setState(() {});
    });

    return reporter.response.future;
  }

  final _flutterErrorLogs = <Map<String, String>>[];

  void logFlutterErrors(FlutterErrorDetails details) =>
      _flutterErrorLogs.add(ErrorHandler.encodeFlutterError(details));

  Color _getColor(String testName) {
    switch (_testStatuses[testName]) {
      case _TestStatus.success:
        return Colors.green;
      case _TestStatus.error:
        return Colors.red;
      case _TestStatus.progress:
        return Colors.blue;
    }
    return Colors.grey;
  }

  Widget _getAction(String testName) {
    final playIcon = IconButton(
      icon: const Icon(Icons.play_arrow),
      onPressed: () {
        handleDriverMessage(TestControlMessage(testName)).then((_) {
          setState(() {});
        });
        setState(() {});
      },
    );
    switch (_testStatuses[testName]) {
      case _TestStatus.success:
        return playIcon;
      case _TestStatus.error:
        return playIcon;
      case _TestStatus.progress:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(),
        );
    }
    return playIcon;
  }

  Widget _getStatus(String testName) {
    switch (_testStatuses[testName]) {
      case _TestStatus.success:
        return const Icon(Icons.check);
      case _TestStatus.error:
        return const Icon(Icons.warning_amber_rounded);
      case _TestStatus.progress:
        return Container();
    }
    return Container();
  }

  Widget getTestRow(BuildContext context, String testName) => Row(
        children: [
          Expanded(
            child: Text(
              testName,
              style: TextStyle(color: _getColor(testName)),
            ),
          ),
          _getAction(testName),
          _getStatus(testName),
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  contentPadding: const EdgeInsets.all(4),
                  insetPadding: const EdgeInsets.symmetric(vertical: 24),
                  content: SingleChildScrollView(
                    child: Text(
                      _testResults[testName] ?? 'No result yet',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => MaterialApp(
          home: Scaffold(
        appBar: AppBar(
          title: const Text('Test dispatcher'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                _reporters.isEmpty
                    ? '-'
                    : 'running ${_reporters.length} tests:'
                        ' ${_reporters.keys.toList().toString()}',
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _testResults.keys.length,
                itemBuilder: (context, idx) {
                  final testName = _testResults.keys.toList()[idx];
                  return ListTile(subtitle: getTestRow(context, testName));
                },
              ),
            ),
          ],
        ),
      ));

  void renderResponse(TestControlMessage message) {
    final testName = message.testName;
    _testResults[testName] = message.toPrettyJson();
    setState(() {
      _reporters.remove(testName);
      _testStatuses[testName] =
          message.payload.containsKey(TestControlMessage.errorKey)
              ? _TestStatus.error
              : _TestStatus.success;
    });
  }
}

class DispatcherController {
  _TestDispatcherState _dispatcher;

  // ignore: use_setters_to_change_properties
  void setDispatcher(_TestDispatcherState dispatcher) {
    _dispatcher = dispatcher;
    // more stuff
  }

  Future<String> driveHandler(String encodedMessage) async {
    final response = await _dispatcher.handleDriverMessage(
      TestControlMessage.fromJson(json.decode(encodedMessage) as Map),
    );
    return json.encode(response);
  }

  void logFlutterErrors(FlutterErrorDetails details) {
    _dispatcher.logFlutterErrors(details);
  }

  void setResponse(TestControlMessage message) {
    _dispatcher.renderResponse(message);
  }
}
