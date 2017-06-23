var app = require('./server/app');

// Configure EVA unit 1
var eva = new app.Dictionary('EVA1', 'eva1');
eva.addMeasurement('temperature', 'prop.temperature', [
  {
    units: 'degrees',
    format: 'integer',
    min: 0,
    max: 100
  }
]);

// Start the server
var server = new app.Server({
  host: process.env.HOST || 'localhost',
  port: process.env.PORT || 8080,
  wss_port: process.env.WSS_PORT || 8082,
  broker: process.env.MSGFLO_BROKER || 'mqtt://localhost',
  dictionaries: [eva]
});
server.start(function (err) {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log('Server listening in ' + server.config.port);
});
