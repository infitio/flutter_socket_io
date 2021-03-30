/*
 * This file is derivative of work derived from original work at:
 * https://github.com/loup-v/streams_channel
 */
package com.infitio.adharasocketio;

import android.annotation.SuppressLint;
import android.util.Log;

import androidx.annotation.UiThread;

import java.nio.ByteBuffer;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler;
import io.flutter.plugin.common.BinaryMessenger.BinaryReply;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.StandardMethodCodec;


final class StreamsChannel {

  public interface StreamHandlerFactory {
    EventChannel.StreamHandler create(Object arguments);
  }

  private static final String TAG = "StreamsChannel#";

  private final BinaryMessenger messenger;
  private final String name;
  private final MethodCodec codec;
  private IncomingStreamRequestHandler incomingStreamRequestHandler;

  StreamsChannel(BinaryMessenger messenger, String name) {
    this(messenger, name, StandardMethodCodec.INSTANCE);
  }

  StreamsChannel(BinaryMessenger messenger, String name, MethodCodec codec) {
    if (BuildConfig.DEBUG) {
      if (messenger == null) {
        Log.e(TAG, "Parameter messenger must not be null.");
      }
      if (name == null) {
        Log.e(TAG, "Parameter name must not be null.");
      }
      if (codec == null) {
        Log.e(TAG, "Parameter codec must not be null.");
      }
    }
    this.messenger = messenger;
    this.name = name;
    this.codec = codec;
  }

  @UiThread
  void setStreamHandlerFactory(final StreamHandlerFactory factory) {
    incomingStreamRequestHandler = new IncomingStreamRequestHandler(factory);
    messenger.setMessageHandler(name, incomingStreamRequestHandler);
  }

  void reset() {
    incomingStreamRequestHandler.clearAll();
  }

  private final class IncomingStreamRequestHandler implements BinaryMessageHandler {
    private final StreamHandlerFactory factory;
    private final ConcurrentHashMap<Integer, StreamsChannel.Stream> streams = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<Integer, Object> listenerArguments = new ConcurrentHashMap<>();

    IncomingStreamRequestHandler(StreamHandlerFactory factory) {
      this.factory = factory;
    }

    @Override
    public void onMessage(ByteBuffer message, final BinaryReply reply) {
      final MethodCall call = codec.decodeMethodCall(message);
      final String[] methodParts = call.method.split("#");

      if (methodParts.length != 2) {
        reply.reply(null);
        return;
      }

      final int id;
      try {
        id = Integer.parseInt(methodParts[1]);
      } catch (NumberFormatException e) {
        reply.reply(codec.encodeErrorEnvelope("error", e.getMessage(), null));
        return;
      }

      final String method = methodParts[0];
      switch (method) {
        case "listen":
          onListen(id, call.arguments, reply);
          break;
        case "cancel":
          onCancel(id, call.arguments, reply);
          break;
        default:
          reply.reply(null);
          break;
      }
    }

    private void onListen(int id, Object arguments, BinaryReply callback) {
      final Stream stream = new Stream(new IncomingStreamRequestHandler.EventSinkImplementation(id), factory.create(arguments));
      streams.putIfAbsent(id, stream);
      listenerArguments.put(id, arguments);

      try {
        stream.handler.onListen(arguments, stream.sink);
        callback.reply(codec.encodeSuccessEnvelope(null));
      } catch (RuntimeException e) {
        streams.remove(id);
        logError(id, "Failed to open event stream", e);
        callback.reply(codec.encodeErrorEnvelope("error", e.getMessage(), null));
      }
    }

    private void onCancel(int id, Object arguments, BinaryReply callback) {
      final Stream oldStream = streams.remove(id);

      if (oldStream != null) {
        try {
          oldStream.handler.onCancel(arguments);
          if (callback != null) callback.reply(codec.encodeSuccessEnvelope(null));
        } catch (RuntimeException e) {
          logError(id, "Failed to close event stream", e);
          if (callback != null)
            callback.reply(codec.encodeErrorEnvelope("error", e.getMessage(), null));
        }
      } else {
        if (callback != null)
          callback.reply(codec.encodeErrorEnvelope("error", "No active stream to cancel", null));
      }
    }

    void clearAll() {
      for (ConcurrentHashMap.Entry<Integer, StreamsChannel.Stream> entry : incomingStreamRequestHandler.streams.entrySet()) {
        int id = entry.getKey();
        Object arguments = listenerArguments.get(id);
        this.onCancel(id, arguments, null);
      }
    }

    private void logError(int id, String message, Throwable e) {
      Log.e(TAG + name, String.format("%s [id=%d]", message, id), e);
    }

    private final class EventSinkImplementation implements EventChannel.EventSink {

      final int id;
      final String name;
      final AtomicBoolean hasEnded = new AtomicBoolean(false);

      @SuppressLint("DefaultLocale")
      private EventSinkImplementation(int id) {
        this.id = id;
        this.name = String.format("%s#%d", StreamsChannel.this.name, id);
      }

      @Override
      @UiThread
      public void success(Object event) {
        if (hasEnded.get() || streams.get(id)==null || streams.get(id).sink != this) {
          return;
        }
        StreamsChannel.this.messenger.send(name, codec.encodeSuccessEnvelope(event));
      }

      @Override
      @UiThread
      public void error(String errorCode, String errorMessage, Object errorDetails) {
        if (hasEnded.get() || streams.get(id)==null || streams.get(id).sink != this) {
          return;
        }
        StreamsChannel.this.messenger.send(
            name,
            codec.encodeErrorEnvelope(errorCode, errorMessage, errorDetails));
      }

      @Override
      @UiThread
      public void endOfStream() {
        if (hasEnded.getAndSet(true) || streams.get(id).sink != this) {
          return;
        }
        StreamsChannel.this.messenger.send(name, null);
      }
    }

  }

  private static class Stream {
    final EventChannel.EventSink sink;
    final EventChannel.StreamHandler handler;

    private Stream(EventChannel.EventSink sink, EventChannel.StreamHandler handler) {
      this.sink = sink;
      this.handler = handler;
    }
  }

}