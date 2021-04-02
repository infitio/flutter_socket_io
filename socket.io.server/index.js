var fs = require('fs');

function handler (req, res) {
console.log("req.url", req.url);
  fs.readFile(
      __dirname + ((req.url == '/') ? '/index.html' : req.url),
      function (err, data) {
        if (err) {
          res.writeHead(500);
          return res.end('Error loading index.html');
        }
        res.writeHead(200);
        res.end(data);
      }
  );
}

var app = require('http').createServer(handler);
var io = require('socket.io')(app);
console.log("listening on 7070...");
app.listen(7070, '0.0.0.0');

var socketId = 0;
var counters = {};
var _sockets = new Set();

function listenToASocket(socket, namespace){
    console.log(
        `>>>>>>> new connection:\n
        namespace: ${namespace?namespace:"-NA-"}\n
        timestamp: ${socket.handshake.query.timestamp}\n
        transport: ${socket.conn.transport.name}\n
        total active sockets: ${_sockets.size}`
        );

    var _currentSocketId = ++socketId;
    _sockets.add(socket);

    socket.emit("namespace", !!namespace);
    socket.emit('type:string', "String message back to client");
    socket.emit('type:bool', true);
    socket.emit('type:number', 123);
    socket.emit('type:object', { hello: 'world' });
    socket.emit('type:list', ["hello", 123, {"key": "value"}]);
    socket.on("data", function(){
        let args = Array.prototype.slice.call(arguments);
        console.log(`data event received with ${args.length} args: ${args.map(_ => arg+' is '+(typeof arg))}`);
    });
    socket.on("echo", function(){  //`arguments` can be extracted only if this is an anonymous function and not an arrow => syntax
        let args = Array.prototype.slice.call(arguments);
        console.log(`echo event received with ${args.length} args: ${args}`);
        args.unshift('echo');
        socket.emit.apply(socket, args);
    });
    socket.on('next', function(){
        if(!counters[_currentSocketId]){
            counters[_currentSocketId] = 0;
        }
        counters[_currentSocketId] += 1;
        socket.emit('counter', counters[_currentSocketId]);
    });
    socket.on("ack-message", function(){
        let args = Array.prototype.slice.call(arguments);
        fn = args.pop();
        console.log(`received ack message with args length: ${args.length} and content: ${JSON.stringify(args)}. Sending back ack!`);
        fn.apply(fn, args);
    });
    socket.on("disconnect", ()=>{
        _sockets.delete(socket);
        console.log(`socket with transport: ${socket.conn.transport.name} disconnected, leaving ${_sockets.size} active sockets`);
    });
}

io.on('connection', function(socket){
    listenToASocket(socket, null);
});

io.of('/adhara').on('connection', function(socket){
  listenToASocket(socket, "/adhara");
});

process.on('SIGINT', function() {
    process.exit();
});
