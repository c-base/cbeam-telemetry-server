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
  topic: 'bitraf/temperature/1',
  timeseries: 'Temperature1',
  persist: true
});
floor2.addMeasurement('humidity', 'floor2_humidity', [
  {
    units: 'percentage',
    format: 'float',
    min: 0,
    max: 100
  }
], {
  topic: 'bitraf/humidity/1',
  timeseries: 'Humidity1',
  persist: true
});
floor2.addMeasurement('isopen', 'floor2_is_open', [
  {
    format: 'boolean'
  }
], {
  topic: '/bitraf/door/2floor/isopen',
  timeseries: 'Floor2IsOpen',
  persist: true
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
  topic: 'bitraf/temperature/2/value',
  timeseries: 'Temperature2',
  persist: true
});
floor4.addMeasurement('humidity', 'floor4_humidity', [
  {
    units: 'percentage',
    format: 'float',
    min: 0,
    max: 100
  }
], {
  topic: 'bitraf/humidity/2/value',
  timeseries: 'Humidity2',
  persist: true
});
floor4.addMeasurement('isopen', 'floor4_is_open', [
  {
    format: 'boolean'
  }
], {
  topic: '/bitraf/door/4floor/isopen',
  timeseries: 'Floor4IsOpen',
  persist: true
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
  topic: 'bitraf/temperature/3/value',
  timeseries: 'Temperature3',
  persist: true
});
outside.addMeasurement('isopen', 'frontdoor_is_open', [
  {
    format: 'boolean'
  }
], {
  topic: '/bitraf/door/frontdoor/isopen',
  timeseries: 'FrontDoorIsOpen',
  persist: true
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
    db: process.env.INFLUX_DB || 'openhab'
  }
});
server.start(function (err) {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log('Server listening in ' + server.config.port);
});
