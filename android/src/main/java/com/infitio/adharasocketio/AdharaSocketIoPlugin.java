package com.infitio.adharasocketio;

import android.util.Log;
import android.util.SparseArray;

import androidx.annotation.NonNull;

import java.net.URISyntaxException;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * AdharaSocketIoPlugin
 */
public class AdharaSocketIoPlugin implements MethodCallHandler {

  SparseArray<AdharaSocket> instances;
  private int currentIndex;
  private final Registrar registrar;
  private final StreamsChannel streamsChannel;
  private static final String TAG = "Adhara:SocketIOPlugin";
  private boolean enableLogging = false;

  private void log(Object message) {
    if (this.enableLogging) {
      Log.d(TAG, message.toString());
    }
  }

  private AdharaSocketIoPlugin(Registrar registrar, StreamsChannel streamsChannel) {
    this.instances = new SparseArray<>();
    this.currentIndex = 0;
    this.registrar = registrar;
    this.streamsChannel = streamsChannel;
    setupStreamsChannel();
  }

  public static void registerWith(Registrar registrar) {
    final StreamsChannel streamsChannel = new StreamsChannel(registrar.messenger(), PlatformConstants.MethodChannelNames.streamsChannel);
    final AdharaSocketIoPlugin plugin = new AdharaSocketIoPlugin(registrar, streamsChannel);
    final MethodChannel channel = new MethodChannel(registrar.messenger(), PlatformConstants.MethodChannelNames.managerMethodChannel);
    channel.setMethodCallHandler(plugin);
  }

  void setupStreamsChannel() {
    final AdharaSocketIoPlugin s = this;
    streamsChannel.setStreamHandlerFactory(new StreamsChannel.StreamHandlerFactory() {
      @Override
      public AdharaEventStreamHandler create(Object arguments) {
        return new AdharaEventStreamHandler(s);
      }
    });
  }

  void restartStreamsChannel() {
    streamsChannel.reset();
    setupStreamsChannel();
  }

  private static String[] getStringArray(List<String> arr) {
    String[] str = new String[arr.size()];
    for (int j = 0; j < arr.size(); j++) {
      str[j] = arr.get(j);
    }
    return str;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case PlatformConstants.PlatformMethod.newInstance: {
        try {
          if (call.argument("clear")) {
            Log.e(TAG, "Clearing instances");
            restartStreamsChannel();
            for (int i = 0; i < instances.size(); i++) {
              instances.valueAt(i).socket.disconnect();
            }
            instances.clear();
          }
          Map<String, Object> socketOptions = call.argument("options");
          if (socketOptions.containsKey("enableLogging")) {
            this.enableLogging = (boolean) socketOptions.get("enableLogging");
          }
          AdharaSocket.Options options = new AdharaSocket.Options(this.currentIndex, (String) socketOptions.get("uri"));
          try {
            List<String> transports = (List<String>) socketOptions.get("transports");
            if (transports != null) {
              options.transports = AdharaSocketIoPlugin.getStringArray(transports);
            }
            options.timeout = ((Number) socketOptions.get("timeout")).longValue();
          } catch (Exception e) {
            Log.e(TAG, e.toString());
          }
          if (socketOptions.containsKey("namespace")) {
            options.namespace = (String) socketOptions.get("namespace");
          }
          if (socketOptions.containsKey("query")) {
            Map<String, String> _query = (Map<String, String>) socketOptions.get("query");
            if (_query != null) {
              StringBuilder sb = new StringBuilder();
              for (Map.Entry<String, String> entry : _query.entrySet()) {
                sb.append(entry.getKey());
                sb.append("=");
                sb.append(entry.getValue());
                sb.append("&");
              }
              options.query = sb.toString();
            }
          }
          if (socketOptions.containsKey("path")) {
            options.path = (String) socketOptions.get("path");
          }
          options.enableLogging = this.enableLogging;
          Log.e(TAG, "Creating a new instance");
          this.instances.put(this.currentIndex, AdharaSocket.getInstance(registrar, options));
          result.success(this.currentIndex++);
        } catch (URISyntaxException use) {
          result.error(use.toString(), null, null);
        }
        break;
      }
      case PlatformConstants.PlatformMethod.clearInstance: {
        if (!call.hasArgument("id") || call.argument("id") == null) {
          result.error("Invalid instance identifier provided", null, null);
        } else {
          Integer socketIndex = call.argument("id");
          if (this.instances.get(socketIndex) != null) {
            this.instances.get(socketIndex).socket.disconnect();
            this.instances.remove(socketIndex);
            result.success(null);
          } else {
            result.error("Instance not found", null, null);
          }
        }
        break;
      }
      default: {
        result.notImplemented();
      }
    }
  }

}
