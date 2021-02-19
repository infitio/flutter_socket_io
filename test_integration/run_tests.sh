set -e

# setup server
cd socket.io.server
npm i
cd ..

socket.io.server/node_modules/.bin/pm2 start socket.io.server/index.js


# run tests
flutter drive test_driver/app.dart

# Kill server
socket.io.server/node_modules/.bin/pm2 kill
