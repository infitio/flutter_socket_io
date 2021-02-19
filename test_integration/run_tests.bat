set -e

# setup server
#cd socket.io.server
#npm i
#cd ..
socket.io.server\node_modules\.bin\pm2 start socket.io.server\index.js
flutter drive test_driver\app.dart
socket.io.server\node_modules\.bin\pm2 kill
