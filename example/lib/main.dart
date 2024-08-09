import 'dart:convert';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';

import 'data.dart';

void main() => runApp(MyApp());

const uri = 'http://192.168.0.105:7070/';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String?> toPrint = ['trying to connect'];
  late SocketIOManager manager;
  Map<String, SocketIO> sockets = {};
  final _isProbablyConnected = <String, bool>{};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    manager = SocketIOManager();
    initSocket('default');
  }

  Future<void> initSocket(String identifier) async {
    setState(() => _isProbablyConnected[identifier] = true);
    final socket = await manager.createInstance(SocketOptions(
      //Socket IO server URI
      uri,
      namespace: (identifier == 'namespaced') ? '/adhara' : '/',
      //Query params - can be used for authentication
      query: {
        'auth': '--SOME AUTH STRING---',
        'info': 'new connection from adhara-socketio',
        'timestamp': DateTime.now().toString()
      },
      //Enable or disable platform channel logging
      enableLogging: true,
      transports: [
        Transports.webSocket,
        // Transports.polling,
      ], //Enable required transport
    ));
    socket.onConnect.listen((data) {
      pPrint('$identifier | connected...');
      pPrint(data);
      sendMessage(identifier);
    });
    socket.onConnectError.listen(pPrint);
    socket.onConnectTimeout.listen(pPrint);
    socket.onError.listen(pPrint);
    socket.onDisconnect.listen(pPrint);
    socket
        .on('type:string')
        .listen((data) => pPrint('$identifier | type:string... | $data'));
    socket
        .on('type:bool')
        .listen((data) => pPrint('$identifier | type:bool | $data'));
    socket
        .on('type:number')
        .listen((data) => pPrint('$identifier | type:number | $data'));
    socket
        .on('type:object')
        .listen((data) => pPrint('$identifier | type:object | $data'));
    socket
        .on('type:list')
        .listen((data) => pPrint('$identifier | type:list | $data'));
    socket.on('message').listen(pPrint);
    socket.on('echo').listen((data) => pPrint(
        '$identifier | echo received | ${(data as String?)?.length} | $data'));
    socket
        .on('namespace')
        .listen((data) => pPrint('$identifier | namespace: | $data'));
    //TODO add stream subscription in example
    await socket.connect();
    sockets[identifier] = socket;
  }

  bool isProbablyConnected(String identifier) =>
      _isProbablyConnected[identifier] ?? false;

  Future<void> disconnect(String identifier) async {
    await manager.clearInstance(sockets[identifier]!);
    setState(() => _isProbablyConnected[identifier] = false);
  }

  void sendMessage(String identifier) {
    if (sockets[identifier] != null) {
      pPrint("sending message from '$identifier'...");
      sockets[identifier]!.emit('data', messagesToPublish);
      pPrint("Message emitted from '$identifier'...");
    }
  }

  Future<void> sendEchoMessage(String identifier) async {
    if (sockets[identifier] != null) {
      for (final message in messagesToPublish) {
        pPrint('publishing echo message $message');
        await sockets[identifier]?.emit('echo', [message]);
      }
      pPrint('publishing echo message ${messagesToPublish.last}');
      await sockets[identifier]?.emit('echo', messagesToPublish.last as List);
    }
  }

  void sendMessageWithACK(String identifier) {
    pPrint('$identifier | Sending ACK message...');
    final msg = [
      'Hello world!',
      1,
      true,
      {'p': 1},
      [3, 'r']
    ];
    sockets[identifier]?.emitWithAck('ack-message', msg).then((data) {
      // this callback runs when this
      // specific message is acknowledged by the server
      pPrint('$identifier | ACK received | $msg -> $data');
    });
  }

  void pPrint(Object? data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }
      print(data);
      toPrint.add(data?.toString());
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    });
  }

  Widget getButtonSet(String identifier) {
    final ipc = isProbablyConnected(identifier);
    return SizedBox(
      height: 60,
      child: Container(
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: ipc ? null : () => initSocket(identifier),
                style: ButtonStyle(
                  padding: MaterialStateProperty.resolveWith(
                    (states) => const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                child: const Text('Connect'),
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: ipc ? () => sendMessage(identifier) : null,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.resolveWith(
                      (states) => const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  child: const Text('Send Message'),
                )),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: ipc ? () => sendEchoMessage(identifier) : null,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.resolveWith(
                      (states) => const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  child: const Text('Send Echo Message'),
                )),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: ipc ? () => sendMessageWithACK(identifier) : null,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.resolveWith(
                      (states) => const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  child: const Text('Send w/ ACK'), //Send message with ACK
                )),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: ipc ? () => disconnect(identifier) : null,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.resolveWith(
                      (states) => const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  child: const Text('Disconnect'),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            textTheme: const TextTheme(
              displayLarge: TextStyle(color: Colors.white),
              displayMedium: TextStyle(color: Colors.white),
              displaySmall: TextStyle(color: Colors.white),
              headlineLarge: TextStyle(color: Colors.white),
              headlineMedium: TextStyle(color: Colors.white),
              headlineSmall: TextStyle(color: Colors.white),
              titleLarge: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
              titleSmall: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
              labelLarge: TextStyle(color: Colors.white),
              labelMedium: TextStyle(color: Colors.white),
              labelSmall: TextStyle(color: Colors.white),
            ),
            buttonTheme: ButtonThemeData(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                disabledColor: Colors.lightBlueAccent.withOpacity(0.5),
                buttonColor: Colors.lightBlue,
                splashColor: Colors.cyan)),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Adhara Socket.IO example'),
            backgroundColor: Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      toPrint = [];
                    });
                  })
            ],
          ),
          body: Container(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Center(
                  child: ListView(
                    controller: _scrollController,
                    children: toPrint.map((_) => Text(_ ?? '')).toList(),
                  ),
                )),
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    'Default Connection',
                  ),
                ),
                getButtonSet('default'),
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8, top: 8),
                  child: Text(
                    'Alternate Connection',
                  ),
                ),
                getButtonSet('alternate'),
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8, top: 8),
                  child: Text(
                    'Namespace Connection',
                  ),
                ),
                getButtonSet('namespaced'),
                const SizedBox(
                  height: 12,
                )
              ],
            ),
          ),
        ),
      );
}
