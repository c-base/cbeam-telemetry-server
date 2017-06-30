var app = require('./server/app');

// Configure Bitraf
var floor2 = new app.Dictionary('2nd floor', 'floor2');
floor2.addMeasurement('temperature', 'floor2_temperature', [
  {
    units: 'degrees',
    format: 'float',
    min: 0,
    max: 100
  }
], {
  topic: 'bitraf/temperature/1'
});
floor2.addMeasurement('humidity', 'floor2_humidity', [
  {
    units: 'percentage',
    format: 'float',
    min: 0,
    max: 100
  }
], {
  topic: 'bitraf/humidity/1'
});
var floor4 = new app.Dictionary('4th floor', 'floor4');
floor4.addMeasurement('temperature', 'floor4_temperature', [
  {
    units: 'degrees',
    format: 'float',
    min: 0,
    max: 100
  }
], {
  topic: 'bitraf/temperature/2/value'
});
floor4.addMeasurement('humidity', 'floor4_humidity', [
  {
    units: 'percentage',
    format: 'float',
    min: 0,
    max: 100
  }
], {
  topic: 'bitraf/humidity/2/value'
});
var outside = new app.Dictionary('Outside', 'outside');
outside.addMeasurement('temperature', 'outside_temperature', [
  {
    units: 'degrees',
    format: 'float',
    min: 0,
    max: 100
  }
], {
  topic: 'bitraf/temperature/3/value'
});

// Start the server
var server = new app.Server({
  host: process.env.HOST || 'localhost',
  port: process.env.PORT || 8080,
  wss_port: process.env.WSS_PORT || 8082,
  broker: process.env.MSGFLO_BROKER || 'mqtt://localhost',
  dictionaries: [floor2, floor4, outside],
  theme: 'Snow',
  history: {
    host: process.env.INFLUX_HOST || 'localhost',
    db: process.env.INFLUX_DB || 'cbeam'
  }
});
server.start(function (err) {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log('Server listening in ' + server.config.port);
});
