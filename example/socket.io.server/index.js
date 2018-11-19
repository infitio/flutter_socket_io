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
  socket.on("message", console.log);
  socket.on("disconnect", ()=>{console.log("disconnect");})
});

process.on('SIGINT', function() {
    process.exit();
});
