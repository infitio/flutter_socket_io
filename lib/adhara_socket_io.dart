import 'dart:async';

import 'package:flutter/services.dart';
import 'package:adhara_socket_io/socket.dart';

class AdharaSocketIo {
  
  static const MethodChannel _channel =
      const MethodChannel('adhara_socket_io');
  
  List<Socket> sockets;
  
  AdharaSocketIo(){
    sockets = [];
  }

  Future<Socket> newInstance(String uri) async {
    int index = await _channel.invokeMethod('newInstance', {'uri': uri});
    Socket socket = Socket(index);
    sockets.insert(index, socket);
    return socket;
  }
  
}

///http://localhost:5000/socket.io/?user=e4de3a04f870d0e0df9ae61214da3af6&EIO=3&transport=polling&t=MSP3ACI