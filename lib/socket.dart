import 'dart:async';

import 'package:flutter/services.dart';


class Socket{
  
  int id;
  
  Socket(this.id){
    MethodChannel channel = new MethodChannel("adhara-socket-${id.toString()}");
    channel.setMethodCallHandler((call) {
      if (call.method == 'data') {
        final String eventName = call.arguments['eventNamr'];
        final List<dynamic> arguments = call.arguments['args'];
        _handleData(eventName, arguments);
      }
    });
  }

  _handleData(String eventName, List arguments){
    
  }
  
  
}