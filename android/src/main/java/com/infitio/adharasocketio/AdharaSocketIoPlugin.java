package com.infitio.adharasocketio;

import android.util.Log;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * AdharaSocketIoPlugin
 */
public class AdharaSocketIoPlugin implements MethodCallHandler {

    private Map<Integer, AdharaSocket> instances;
    private int currentIndex;
//    private final MethodChannel channel;
    private final Registrar registrar;
    private static final String TAG = "Adhara:SocketIOPlugin";
    boolean enableLogging = false;

    private void log(Object message){
        if(this.enableLogging){
            Log.d(TAG, message.toString());
        }
    }

    private AdharaSocketIoPlugin(Registrar registrar/*, MethodChannel channel*/) {
        this.instances = new HashMap<Integer, AdharaSocket>();
        this.currentIndex = 0;
//        this.channel = channel;
        this.registrar = registrar;
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "adhara_socket_io");
        channel.setMethodCallHandler(new AdharaSocketIoPlugin(registrar/*, channel*/));
    }

    static String[] getStringArray(List<String> arr){
        String[] str = new String[arr.size()];
        for (int j = 0; j < arr.size(); j++) {
            str[j] = arr.get(j);
        }
        return str;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "newInstance": {
                try{
                    if(call.hasArgument("enableLogging")){
                        this.enableLogging = call.argument("enableLogging");
                    }
                    AdharaSocket.Options options = new AdharaSocket.Options(this.currentIndex, (String)call.argument("uri"));
                    try {
                        List<String> transports = call.argument("transports");
                        if (transports != null) {
                            options.transports = AdharaSocketIoPlugin.getStringArray(transports);
                        }
                        options.timeout = ((Number) call.argument("timeout")).longValue();
                    }catch (Exception e){
                        Log.e(TAG, e.toString());
                    }
                    if (call.hasArgument("namespace")) {
                        options.namespace = call.argument("namespace");
                    }
                    if(call.hasArgument("query")) {
                        Map<String, String> _query = call.argument("query");
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
                    if (call.hasArgument("path")) {
                        options.path = call.argument("path");
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
                    if (this.instances.containsKey(socketIndex)) {
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
