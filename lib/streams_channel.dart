/*
 * This file is derivative of work derived from original work at:
 * https://github.com/loup-v/streams_channel
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manages multiple event listeners which would otherwise require verbose code
/// on platform side
class StreamsChannel {
  /// initializes with event channel [name] and method [codec]
  StreamsChannel(this.name, [this.codec = const StandardMethodCodec()]);

  /// The logical channel on which communication happens, not null.
  final String name;

  /// The message codec used by this channel, not null.
  final MethodCodec codec;

  int _lastId = 0;

  /// registers a listener on platform side and manages the listener
  /// with incremental identifiers
  Stream<T?> receiveBroadcastStream<T>([Object? arguments]) {
    final methodChannel = MethodChannel(name, codec);

    final id = ++_lastId;
    final handlerName = '$name#$id';

    late StreamController<T?> controller;
    controller = StreamController<T?>.broadcast(onListen: () async {
      ServicesBinding.instance.defaultBinaryMessenger
          .setMessageHandler(handlerName, (reply) async {
        if (reply == null) {
          await controller.close();
        } else {
          try {
            controller.add(codec.decodeEnvelope(reply) as T?);
          } on PlatformException catch (pe) {
            controller.addError(pe);
          }
        }

        return reply;
      });
      try {
        await methodChannel.invokeMethod('listen#$id', arguments);
      } on Exception catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'streams_channel',
          context: DiagnosticsNode.message(
            'while activating platform stream on channel $name',
          ),
        ));
      }
    }, onCancel: () async {
      ServicesBinding.instance.defaultBinaryMessenger
          .setMessageHandler(handlerName, null);
      try {
        await methodChannel.invokeMethod('cancel#$id', arguments);
      } on Exception catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'streams_channel',
          context: DiagnosticsNode.message(
            'while de-activating platform stream on channel $name',
          ),
        ));
      }
    });
    return controller.stream;
  }
}
