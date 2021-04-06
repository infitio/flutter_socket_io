# adhara_socket_io

[![.github/workflows/flutter_integration.yaml](https://github.com/infitio/flutter_socket_io/actions/workflows/flutter_integration.yaml/badge.svg?branch=master)](https://github.com/infitio/flutter_socket_io/actions/workflows/flutter_integration.yaml)

[socket.io](https://socket.io/) for flutter by [adhara](https://github.com/infitio/)

supports both Android and iOS

socket.io version supported: v2
development in progress for v3 and v4

> If you are using v3/v4 socket on server side, you may face connection issues, please downgrade and try in such scenario.

Usage:

> See `example/lib/main.dart` for more detailed example

```dart
	final SOCKET_SERVER = 'http://192.168.1.2:7070/';	//To be modified accordingly
        SocketIO socket;
	StreamSubscription connectSubscription;
	StreamSubscription echoSubscription;

	Future<void> demonstrateSocket() async {
    	// Create a socket instance
		socket = await SocketIOManager().createInstance(
        	SocketOptions(SOCKET_SERVER),
        );

	// Listen to socket connect event
	subscription = socket.onConnect.listen((data){
	  print('connected: $data');
	  socket.emit('message', ['Hello world!']);
	});

        // Listen to an custom ("news") event
	echoSubscription = socket.on('echo', (data){
  	    print("news event recieved with data: $data");
	});

	// There are 2 ways to connect to socket server
	//  - normal: doesn't wait for connectio success
	//  - sync: ensures connection or errors out on failure

        // normal:
        //  connect to socket server - will initialize connection,
        //  but not ensure the connection yet.
        //  If this method used to connect to server, then emit events should be sent
        //  only after ensuring connection to socket server is successful by listening
        //  to onConnect events
	// await socket.connect();

	// sync:
        //  This API will ensure connection to server is successful
        //  or will throw error on connect error
        await socket.connectSync();

        // publish data - will publish to server, won't ensure the delivery
	await socket.emit('echo', ['hello']);

        // emit with acknowledgement - will publish to server
        //  and ensure delivery with ack if ack is implemented in server
        dynamic ackData = await socket.emitWithAck('echo', ['hello']);
            print('acknowledgement recieved from server: $ackData');
    	}

	Future<void> dispose() async {
	    // cancel echo and onConnect subscriptions
	    await echoSubscription.cancel();
	    await connectSubscription.cancel();

            // clear socket instance from manager
            await SocketIOManager().clearInstance(socket);
        }

	// register liteners, connect to a socket, and publish data
	demonstrateSocket();

	// will dispose listeners and socket
	dispose();
```


## Running example:


1. clone the project
2. start socket server in the background
```bash
cd socket.io.server
npm i
./node_modules/.bin/pm2/ index.js
cd ../
```

3. open `example/lib/main.dart` and edit the `URI` in #7 to point to your hosted/local socket server instances as mentioned step 2

    For example:

    ```dart
    const String URI = "http://192.168.1.2:7000/";
    ```

    ```dart
    const String URI = "http://mysite.com/";
    ```

3. run example
```
cd example
flutter run
```

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
        ...
</application>
```

[Refer to discussion here](https://github.com/infitio/flutter_socket_io/issues/42)

## Running tests

This plugin uses flutter driver to run integration tests tests. Use below command to run integration tests on Android/iOS

```bash
sh bin/run_tests.sh
```

## Sample Video - Running the example

[![Running adhara socket io for flutter, example](https://img.youtube.com/vi/rc6Kv95FJ4M/0.jpg)](https://www.youtube.com/watch?v=rc6Kv95FJ4M "Running the example")


## FAQ's

##### AdharaSocketIoPlugin.m:2:9: fatal error: 'adhara_socket_io/adhara_socket_io-Swift.h' file not found
add `use_frameworks!` to your Podfile as in the example
https://github.com/infitio/flutter_socket_io/blob/master/example/ios/Podfile#L30

Read more about this: [discussion](https://github.com/infitio/flutter_socket_io/issues/58)


## Other Packages:

Feel free to checkout our [Adhara](https://pub.dartlang.org/packages/adhara) package
