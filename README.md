# adhara_socket_io

Socket.IO for flutter by adhara

Supports both Android and iOS

## Usage:

See `example/lib/main.dart` for better example

```dart
SocketIOManager manager = SocketIOManager();
SocketIO socket = manager.createInstance(
  SocketOptions('http://192.168.1.12:5555', //TODO change the port  accordingly
                nameSpace: '/yournamespace',
                enableLogging: true,
                transports: [Transports.POLLING])
);

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
///manager
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
    
4. Run Android/iOS app

## iOS support 📢📢
This project uses Swift for iOS support, please enable Swift support for your project for this plugin to work

## Android support for SDK > 27

In Android `android/app/src/main/AndroidManifest.xml` file add `usesCleartextTraffic` in application tag.

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

## Sample Video - Running the example

[![Running adhara socket io for flutter, example](https://img.youtube.com/vi/rc6Kv95FJ4M/0.jpg)](http://www.youtube.com/watch?v=rc6Kv95FJ4M "Running the example")


## FAQ's

##### AdharaSocketIoPlugin.m:2:9: fatal error: 'adhara_socket_io/adhara_socket_io-Swift.h' file not found
add `use_frameworks!` to your Podfile as in the example
https://github.com/infitio/flutter_socket_io/blob/master/example/ios/Podfile#L30

[Read more about this discussion](https://github.com/infitio/flutter_socket_io/issues/58)


## Other Packages:
Feel free to checkout our [Adhara](https://pub.dartlang.org/packages/adhara) package
