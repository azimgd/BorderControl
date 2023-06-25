const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8881 });

wss.on('connection', (ws) => {
  console.log('A client connected.');

  ws.on('message', (message) => {
    console.log(message.toString());
  });

  ws.on('close', () => {
    console.log('A client disconnected.');
  });
});

console.log('WebSocket server is listening on port 8881.');
