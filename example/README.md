# adhara_socket_io_example

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

## Running example:


1. Open `example/ios` in XCode or `example/android` in android studio. Build the code once (`cd example` & `flutter build apk` | `flutter build ios --no-codesign`)
2. cd `example/socket.io.server`

	1 run `npm i`

	2 run `npm start`

3. open `example/lib/main.dart` and edit the URI in #7 to point to your hosted/local socket server instances as mentioned step 2
4. run Android/iOS app
