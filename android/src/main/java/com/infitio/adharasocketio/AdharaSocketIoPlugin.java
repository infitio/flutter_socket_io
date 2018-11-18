package com.infitio.adharasocketio;

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


/**
 * AdharaSocketIoPlugin
 */
public class AdharaSocketIoPlugin implements MethodCallHandler {

    List<AdharaSocket> instances;
    final MethodChannel channel;

    AdharaSocketIoPlugin(MethodChannel channel) {
        this.instances = new ArrayList();
        this.channel = channel;
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "adhara_socket_io");
        channel.setMethodCallHandler(new AdharaSocketIoPlugin(channel));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        AdharaSocket adharaSocket = null;
        if(call.hasArgument("id")){
            int socketIndex = (int)call.argument("id");
            if(instances.size() > socketIndex){
                adharaSocket = instances.get(socketIndex);
            }
        }
        switch (call.method) {
            case "newInstance": {
                try{
                    this.instances.add(new AdharaSocket((String)call.argument("uri")));
                    result.success(this.instances.size() - 1);
                }catch (URISyntaxException use){
                    result.error(use.toString(), null, null);
                }
            }
            case "on": {
                final String eventName = (String)call.argument("eventName");
                adharaSocket.socket.on(eventName, new Emitter.Listener() {

                    @Override
                    public void call(Object... args) {
                        Map<String, Object> arguments = new HashMap();
                        arguments.put("eventName", eventName);
                        arguments.put("args", args);
                        channel.invokeMethod("data", arguments);
                    }

                });
                result.success(null);
            }
            case "off": {
                final String eventName = (String)call.argument("eventName");
                adharaSocket.socket.off(eventName);
                result.success(null);
            }
            case "emit": {
                final String eventName = (String)call.argument("eventName");
                final List data = (List)call.argument("data");
                adharaSocket.socket.emit(eventName, data);
                result.success(null);
            }
            case "isConnected": {
                result.success(adharaSocket.socket.connected());
            }
            case "disconnect": {
                adharaSocket.socket.disconnect();
                result.success(null);
            }
            default: {
                result.notImplemented();
            }
        }
    }

}
