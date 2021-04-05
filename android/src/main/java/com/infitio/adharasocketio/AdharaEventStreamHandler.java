package com.infitio.adharasocketio;

import android.os.Handler;
import android.os.Looper;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.socket.emitter.Emitter;

public class AdharaEventStreamHandler implements EventChannel.StreamHandler {

  private final AdharaSocketIoPlugin plugin;
  private String eventName;
  private AdharaSocket adharaSocket;
  private Emitter.Listener listener;

  AdharaEventStreamHandler(AdharaSocketIoPlugin plugin) {
    this.plugin = plugin;
  }

  /**
   * Refer to the comments on MethodCallHandler.MethodResultWrapper
   * on why this customized EventSink is required
   */
  private static class MainThreadEventSink implements EventChannel.EventSink {
    private final EventChannel.EventSink eventSink;
    private final Handler handler;

    MainThreadEventSink(EventChannel.EventSink eventSink) {
      this.eventSink = eventSink;
      handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object o) {
      handler.post(new Runnable() {
        @Override
        public void run() {
          eventSink.success(o);
        }
      });
    }

    @Override
    public void error(final String s, final String s1, final Object o) {
      handler.post(new Runnable() {
        @Override
        public void run() {
          eventSink.error(s, s1, o);
        }
      });
    }

    @Override
    public void endOfStream() {}
  }

  @Override
  public void onListen(Object o, final EventChannel.EventSink uiThreadEventSink) {
    final MainThreadEventSink eventSink = new MainThreadEventSink(uiThreadEventSink);
    Map<String, Object> params = (Map<String, Object>) o;
    eventName = (String) params.get("eventName");
    adharaSocket = plugin.instances.get((int) params.get("id"));
    listener = new Emitter.Listener() {
      @Override
      public void call(Object... args) {
        adharaSocket.log("Event triggered::" + eventName);
        List<Object> argsList = new ArrayList<>();
        for (Object arg : args) {
          if ((arg instanceof JSONObject) || (arg instanceof JSONArray)) {
            argsList.add(arg.toString());
          } else if (arg == null || arg instanceof String || arg instanceof Number || arg instanceof Boolean) {
            argsList.add(arg);
          } else {
            argsList.add(arg.toString());
          }
        }
        adharaSocket.log("Received arguments::" + argsList);
        eventSink.success(argsList);
      }
    };
    adharaSocket.socket.on(eventName, listener);
  }

  @Override
  public void onCancel(Object o) {
    adharaSocket.log("Listening cancelled on::" + eventName);
    this.adharaSocket.socket.off(eventName, listener);
  }

}
