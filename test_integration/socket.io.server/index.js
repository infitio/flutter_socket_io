var fs = require('fs');

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }
    res.writeHead(200);
    res.end(data);
  });
}

var app = require('http').createServer(handler);
var io = require('socket.io')(app);
console.log("listening on 7000...");
app.listen(7000, '0.0.0.0');

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
        console.log(args);
    });
    socket.on("echo", function(data, d2, d3){  //arguments make sense only if this is a function
        console.log("ddd", data, d2, d3);
        let args = Array.prototype.slice.call(arguments);
        console.log("args:::", args, args.length);
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
        console.log(`received ack message: "${args}". Sending back ack!`);
        fn = args.pop();
        fn(`Ack for ${args.map(_ => (_ instanceof Object)?JSON.stringify(_):_).join(", ")}`);
    });
    socket.on("disconnect", ()=>{
        _sockets.delete(socket);
        console.log(`socket disconnected at ${socket.handshake.query.timestamp} with transport: ${socket.conn.transport.name}, leaving ${_sockets.size} active sockets`);
    });
}

io.on('connection', function(socket){
    listenToASocket(socket, null);
});

var io_adhara = io.of('/adhara');
io_adhara.on('connection', function(socket){
  listenToASocket(socket, "/adhara");
});

process.on('SIGINT', function() {
    process.exit();
});
