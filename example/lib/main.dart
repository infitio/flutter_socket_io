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
    SocketIO socket = await SocketIOManager().createInstance('http://192.168.43.168:7000/');
    socket.onConnect((data){
      pprint("connected...");
      pprint(data);
      socket.emit("message", ["Hello world!"]);
    });
    socket.onConnectError(pprint);
    socket.onConnectTimeout(pprint);
    socket.onError(pprint);
    socket.onDisconnect(pprint);
    socket.on("news", (data){
      pprint("news");
      pprint(data);
    });
    socket.connect();
  }

  pprint(data){
    setState((){
      if(data is Map){
        data = json.encode(data);
      }
      print(data);
      toPrint.add(data);
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
