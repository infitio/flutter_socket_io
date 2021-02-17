package com.infitio.adharasocketio;

import android.os.Handler;
import android.os.Looper;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

public class AdharaEventStreamHandler implements EventChannel.StreamHandler {

    private final AdharaSocketIoPlugin plugin;
    private boolean stopListening = false;
    private String eventName;
    private AdharaSocket adharaSocket;

    AdharaEventStreamHandler(AdharaSocketIoPlugin plugin){
        this.plugin = plugin;
    }


    /**
     * Refer to the comments on MethodCallHandler.MethodResultWrapper
     * on why this customized EventSink is required
     * */
    private static class MainThreadEventSink implements EventChannel.EventSink {
        private EventChannel.EventSink eventSink;
        private Handler handler;

        MainThreadEventSink(EventChannel.EventSink eventSink) {
            this.eventSink = eventSink;
            handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object o) {
            handler.post(() -> eventSink.success(o));   //lambda for new Runnable
        }

        @Override
        public void error(final String s, final String s1, final Object o) {
            handler.post(() -> eventSink.error(s, s1, o));
        }

        @Override
        public void endOfStream() {
            //TODO work on this if required, or remove this TODO once all features are covered
        }
    }

    @Override
    public void onListen(Object o, final EventChannel.EventSink uiThreadEventSink) {
        MainThreadEventSink eventSink = new MainThreadEventSink(uiThreadEventSink);
        Map<String, Object> params = (Map<String, Object>) o;
        this.eventName = (String)params.get("eventName");
        this.adharaSocket = plugin.instances.get((int)params.get("id"));
        adharaSocket.socket.on(eventName, args -> {
            if(stopListening) return;
            adharaSocket.log("Socket triggered::"+eventName);
            final Map<String, Object> arguments = new HashMap<>();
            arguments.put("eventName", eventName);
            List<String> argsList = new ArrayList<>();
            for(Object arg : args){
                if((arg instanceof JSONObject) || (arg instanceof JSONArray)){
                    argsList.add(arg.toString());
                }else if(arg!=null){
                    argsList.add(arg.toString());
                }
            }
            arguments.put("args", argsList);
            eventSink.success(arguments);
        });
        if(!adharaSocket.eventListenerCount.containsKey(eventName)){
            adharaSocket.eventListenerCount.put(eventName, 1);
        }{
            adharaSocket.eventListenerCount.put(eventName, adharaSocket.eventListenerCount.get(eventName)+1);
        }
    }

    @Override
    public void onCancel(Object o) {
        this.stopListening = true;
        Integer count = this.adharaSocket.eventListenerCount.get(eventName);
        if(count==1){
            this.adharaSocket.socket.off(eventName);
        }else{
            this.adharaSocket.eventListenerCount.put(eventName, count-1);
        }
    }

}
