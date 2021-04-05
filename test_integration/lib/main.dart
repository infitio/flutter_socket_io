import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'config/test_factory.dart';
import 'test_dispatcher.dart';

void main() {
  final testDispatcherController = DispatcherController();

  // track FlutterError's
  FlutterError.onError = testDispatcherController.logFlutterErrors;

  // enable driver extension
  enableFlutterDriverExtension(handler: testDispatcherController.driveHandler);

  runZoned(
    () => runApp(
      TestDispatcher(
        testFactory: testFactory,
        controller: testDispatcherController,
      ),
    ),
  );
}
