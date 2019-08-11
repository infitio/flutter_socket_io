# adhara_socket_io

socket.io for flutter by adhara

supports both Android and iOS


Usage:

See `example/lib/main.dart` for better example

```dart
    SocketIOManager manager = SocketIOManager();
    SocketIO socket = manager.createInstance('http://192.168.1.2:7000/');       //TODO change the port  accordingly
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
    ///disconnect using
    ///manager.

```

To request callback on ack:
```dart
  socket.emitWithAck("message", ["Hello world!"]).then( (data) {
    // this callback runs when this specific message is acknowledged by the server
    print(data);
  });
```

## Running example:


1. Open `example/ios` in XCode or `example/android` in android studio. Build the code once (`cd example` & `flutter build apk` | `flutter build ios --no-codesign`)
2. cd `example/socket.io.server`

	1 run `npm i`

	2 run `npm start`

3. open `example/lib/main.dart` and edit the `URI` in #7 to point to your hosted/local socket server instances as mentioned step 2
    
    For example:
        
    ```dart
    const String URI = "http://192.168.1.2:7000/";
    ```
        
    ```dart
    const String URI = "http://mysite.com/";
    ```
    
4. run Android/iOS app

## iOS support 📢📢
This project uses Swift for iOS support, please enable Swift support for your project for this plugin to work


## Android support for SDK > 27

Configure `android:usesCleartextTraffic="true"` as a property of `<application ...>` tag in `android/app/src/main/AndroidManifest.xml`

For example:
    
```xml

<application
        android:name="io.flutter.app.FlutterApplication"
        android:label="adhara_socket_io_example"
        android:usesCleartextTraffic="true"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"...>...</activity>

```

[Refer to discussion here](https://github.com/infitio/flutter_socket_io/issues/42)


## Other Packages:

Feel free to checkout our [Adhara](https://pub.dartlang.org/packages/adhara) package
