import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'config/test_factory.dart';
import 'driver_data_handler.dart';
import 'test_dispatcher.dart';


void main() {
  final dataHandler = DriverDataHandler();
  // This line enables the extension.
  enableFlutterDriverExtension(handler: dataHandler);

  final flutterErrorHandler = ErrorHandler();
  FlutterError.onError = flutterErrorHandler.onFlutterError;

  runZonedGuarded(
    () => runApp(
      TestDispatcher(
        testFactory: testFactory,
        driverDataHandler: dataHandler,
        errorHandler: flutterErrorHandler,
      ),
    ),
    flutterErrorHandler.onException,
  );
}
