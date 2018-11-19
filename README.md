# adhara_socket_io

socket.io for flutter by adhara

supports both Android and iOS


Usage:

See `example/lib/main.dart` for better example

```dart

    SocketIO socket = await SocketIOManager().createInstance('http://192.168.1.2:7000/');       //TODO change the port  accordingly
    socket.onConnect((data){
      print("connected...");
      print(data);
      socket.emit("message", ["Hello world!"]);
    });
    socket.on("news", (data){   //sample event
      print("news");
      print(data);
    });
    socket.connect();

```