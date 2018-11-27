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

var app = require('http').createServer(handler)
var io = require('socket.io')(app);
console.log("listening on 7000...");
app.listen(7000);

io.on('connection', function (socket) {
	console.log("new connection");
  socket.emit('news', { hello: 'world' });
  socket.on("message", function(){
    let args = Array.prototype.slice.call(arguments);
    console.log(args, arguments.length);
    for(let arg of args){
        console.log(arg, typeof arg);
    }
  });
  socket.on("disconnect", ()=>{console.log("disconnect");})
});

process.on('SIGINT', function() {
    process.exit();
});
