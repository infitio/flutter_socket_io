# test_integration

Test runner for Socket.io Tests

## Developing tests

Before running the tests a `nodejs` socket.io server should be started

```bash
cd socket.io.server
npm i
cd ..

socket.io.server/node_modules/.bin/pm2 start socket.io.server/index.js
```

Starting test application, this will be interacted by driver on the same port i.e. `8888`.

```bash
flutter run --observatory-port 8888 --disable-service-auth-codes lib/main.dart
```

Execute below commands to run tests

```bash
export VM_SERVICE_URL=http://127.0.0.1:8888/
dart test_driver/main_test.dart
```
-or-
```bash
VM_SERVICE_URL=http://127.0.0.1:8888/ dart test_driver/main_test.dart
```

stopping the `nodejs` server

```bash
socket.io.server/node_modules/.bin/pm2 kill
```
