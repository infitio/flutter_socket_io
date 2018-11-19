package com.infitio.adharasocketio;

import java.net.URISyntaxException;

import io.socket.client.IO;
import io.socket.emitter.Emitter;
import io.socket.client.Socket;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.socket.emitter.Emitter;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;


class AdharaSocket implements MethodCallHandler {

    final Socket socket;
    private final MethodChannel channel;
    private static final String TAG = "Adhara:Socket";

    private AdharaSocket(MethodChannel channel, String uri) throws URISyntaxException {
        Log.d(TAG, "Connecting to... "+uri);
        socket = IO.socket(uri);
        this.channel = channel;
    }

    static AdharaSocket getInstance(Registrar registrar, String uri, int index) throws URISyntaxException{
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "adhara_socket_io:socket:"+String.valueOf(index));
        AdharaSocket _socket = new AdharaSocket(channel, uri);
        channel.setMethodCallHandler(_socket);
        return _socket;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "connect": {
                Log.d(TAG, "Connecting....");
                socket.connect();
                break;
            }
            case "on": {
                final String eventName = call.argument("eventName");
                Log.d(TAG, "registering::"+eventName);
                socket.on(eventName, new Emitter.Listener() {

                    @Override
                    public void call(Object... args) {
                        Log.d(TAG, "Socket triggered::"+eventName);
                        Map<String, Object> arguments = new HashMap<>();
                        arguments.put("eventName", eventName);
                        List<String> argsList = new ArrayList<>();
                        for(Object arg : args){
                            if((arg instanceof JSONObject)
                                    || (arg instanceof JSONArray)){
                                argsList.add(arg.toString());
                            }else if(arg!=null){
                                argsList.add(arg.toString());
                            }
                        }
                        arguments.put("args", argsList);
                        channel.invokeMethod("incoming", arguments);
                    }

                });
                result.success(null);
                break;
            }
            case "off": {
                final String eventName = call.argument("eventName");
                socket.off(eventName);
                result.success(null);
                break;
            }
            case "emit": {
                final String eventName = call.argument("eventName");
                final List data = call.argument("data");
                socket.emit(eventName, data);
                result.success(null);
                break;
            }
            case "isConnected": {
                result.success(socket.connected());
                break;
            }
            case "disconnect": {
                socket.disconnect();
                result.success(null);
                break;
            }
            default: {
                result.notImplemented();
            }
        }
    }

}
