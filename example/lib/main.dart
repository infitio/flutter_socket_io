import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:adhara_socket_io/adhara_socket_io.dart';

void main() => runApp(new MyApp());

const String URI = "http://192.168.1.5:7000/";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> toPrint = ["trying to conenct"];
  SocketIO socket;

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  initSocket() async {
    SocketIOManager manager = SocketIOManager();
    socket = await manager.createInstance(
        //Socket IO server URI
        URI,
        //Query params - can be used for authentication
        query: {
          "auth": "--SOME AUTH STRING---",
          "info": "new connection from adhara-socketio"
        },
        //Enable or disable platform channel logging
        enableLogging: false
    );
    socket.onConnect((data) {
      pprint("connected...");
      pprint(data);
      sendMessage();
    });
    socket.onConnectError(pprint);
    socket.onConnectTimeout(pprint);
    socket.onError(pprint);
    socket.onDisconnect(pprint);
    socket.on("news", (data) {
      pprint("news");
      pprint(data);
    });
    socket.connect();
  }

  sendMessage() {
    if (socket != null) {
      pprint("sending message...");
      socket.emit("message", ["test=!./", { "test": "=!./" }]);
      socket.emit("message", [
        "Hello world!",
        1908,
        {
          "wonder": "Woman",
          "comics": ["DC", "Marvel"]
        }
      ]);
      socket.emit("message", [
        {
          "wonder": "Woman",
          "comics": ["DC", "Marvel"]
        }
      ]);
    }
  }

  pprint(data) {
    setState(() {
      if (data is Map) {
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Center(
              child: new Text(toPrint.join('\n')),
            )),
            RaisedButton(
              child: Text("Send Message"),
              onPressed: sendMessage,
            )
          ],
        ),
      ),
    );
  }
}
