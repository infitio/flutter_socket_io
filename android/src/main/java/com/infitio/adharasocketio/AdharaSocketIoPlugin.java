package com.infitio.adharasocketio;

import android.util.Log;
import android.util.SparseArray;

import androidx.annotation.NonNull;

import java.net.URISyntaxException;
import app.loup.streams_channel.StreamsChannel;
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
//    private final MethodChannel channel;
    private final Registrar registrar;
    private static final String TAG = "Adhara:SocketIOPlugin";
    private boolean enableLogging = false;

    private void log(Object message){
        if(this.enableLogging){
            Log.d(TAG, message.toString());
        }
    }

    private AdharaSocketIoPlugin(Registrar registrar/*, MethodChannel channel*/) {
        this.instances = new SparseArray<>();
        this.currentIndex = 0;
//        this.channel = channel;
        this.registrar = registrar;
    }

    public static void registerWith(Registrar registrar) {
        AdharaSocketIoPlugin plugin = new AdharaSocketIoPlugin(registrar/*, channel*/);
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "adhara_socket_io");
        channel.setMethodCallHandler(plugin);
        final StreamsChannel streamsChannel = new StreamsChannel(registrar.messenger(), "adhara_socket_io:event_streams");
        streamsChannel.setStreamHandlerFactory(arguments -> new AdharaEventStreamHandler(plugin));
    }

    private static String[] getStringArray(List<String> arr){
        String[] str = new String[arr.size()];
        for (int j = 0; j < arr.size(); j++) {
            str[j] = arr.get(j);
        }
        return str;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "newInstance": {
                try{
                    if(call.argument("clear")){
                        for(int i = 0; i < instances.size(); i++) {
                            instances.valueAt(i).socket.disconnect();
                        }
                        instances.clear();
                    }
                    Map<String, Object> socketOptions =  call.argument("options");
                    if(socketOptions.containsKey("enableLogging")){
                        this.enableLogging = (boolean)socketOptions.get("enableLogging");
                    }
                    AdharaSocket.Options options = new AdharaSocket.Options(this.currentIndex, (String)socketOptions.get("uri"));
                    try {
                        List<String> transports = (List<String>)socketOptions.get("transports");
                        if (transports != null) {
                            options.transports = AdharaSocketIoPlugin.getStringArray(transports);
                        }
                        options.timeout = ((Number) socketOptions.get("timeout")).longValue();
                    }catch (Exception e){
                        Log.e(TAG, e.toString());
                    }
                    if (socketOptions.containsKey("namespace")) {
                        options.namespace = (String)socketOptions.get("namespace");
                    }
                    if(socketOptions.containsKey("query")) {
                        Map<String, String> _query = (Map<String, String>) socketOptions.get("query");
                        if(_query!=null) {
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
                    this.instances.put(this.currentIndex, AdharaSocket.getInstance(registrar, options));
                    result.success(this.currentIndex++);
                }catch (URISyntaxException use){
                    result.error(use.toString(), null, null);
                }
                break;
            }
            case "clearInstance": {
                if(!call.hasArgument("id") || call.argument("id") == null) {
                    result.error("Invalid instance identifier provided", null, null);
                } else {
                    Integer socketIndex = call.argument("id");
                    if (this.instances.get(socketIndex)!=null) {
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
