import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:adhara_socket_io/adhara_socket_io.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> toPrint = ["trying to conenct"];

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  initSocket() async {
    SocketIO socket = await SocketIOManager().newInstance('http://192.168.43.78:7000/');
    socket.onConnect((data){
      pprint("connected...");
      pprint(data);
    });
    socket.onConnectError((error) => pprint(error));
    socket.onConnectTimeout((timeout) => pprint(timeout));
    socket.onError((timeout) => pprint(timeout));
    socket.onDisconnect((timeout) => pprint(timeout));
    socket.on("news", (data){
      pprint("news");
      pprint(data);
    });
    socket.emit("message", ["Hello sexy!"]);
    socket.connect();
  }

  pprint(data){
    setState((){
      if(data is Map){
        toPrint.add(json.encode(data));
      }else{
        toPrint.add(data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text(toPrint.join('\n')),
        ),
      ),
    );
  }
}
