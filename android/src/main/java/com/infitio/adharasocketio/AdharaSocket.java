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


class AdharaSocket implements MethodCallHandler {

    public final Socket socket;
    final MethodChannel channel;

    AdharaSocket(MethodChannel channel, String uri) throws URISyntaxException {
        socket = IO.socket(uri);
        socket.on("connect", new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                System.out.println("Connected... yay!!!");
            }
        });
        this.channel = channel;
    }

    public static AdharaSocket getInstance(Registrar registrar, String uri, int index) throws URISyntaxException{
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "adhara_socket_io:socket:"+String.valueOf(index));
        AdharaSocket _socket = new AdharaSocket(channel, uri);
        channel.setMethodCallHandler(_socket);
        return _socket;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "on": {
                final String eventName = (String)call.argument("eventName");
                System.out.println("registering::"+eventName);
                socket.on(eventName, new Emitter.Listener() {

                    @Override
                    public void call(Object... args) {
                        System.out.println("Socket triggered::"+eventName);
                        System.out.println(args);
                        Map<String, Object> arguments = new HashMap<>();
                        arguments.put("eventName", eventName);
                        arguments.put("args", args);
                        channel.invokeMethod("incoming", arguments);
                    }

                });
                result.success(null);
                break;
            }
            case "off": {
                final String eventName = (String)call.argument("eventName");
                socket.off(eventName);
                result.success(null);
                break;
            }
            case "emit": {
                final String eventName = (String)call.argument("eventName");
                final List data = (List)call.argument("data");
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
