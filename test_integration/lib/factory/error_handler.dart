import 'package:flutter/foundation.dart';

/// Used to wire app unhandled exceptions and Flutter errors to be reported back
/// to the test driver.
class ErrorHandler {
  static Map<String, String> encodeFlutterError(FlutterErrorDetails details) {
    print('Caught FlutterError::\n'
        'exception: ${details.exception}\n'
        'stack: ${details.stack}');

    return {
      'exceptionType': '${details.exception.runtimeType}',
      'exception': details.exceptionAsString(),
      'context': details.context?.toDescription(),
      'library': details.library,
      'stackTrace': '${details.stack}',
    };
  }

  static Map<String, String> encodeException(Object error, StackTrace stack) {
    print(error);
    print(stack);
    print('Caught Exception::\n'
        'error: $error\n'
        'stack: $stack');

    return {
      'exceptionType': '${error.runtimeType}',
      'exception': '$error',
      'stackTrace': '$stack',
    };
  }
}
