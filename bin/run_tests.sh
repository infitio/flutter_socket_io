set -e

# setup server
cd socket.io.server/v2
npm i
./node_modules/.bin/pm2 start index.js

cd ../test_integration

# run tests
flutter drive

# Kill server
./../socket.io.server/v2/node_modules/.bin/pm2 kill
