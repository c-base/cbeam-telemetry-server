var app = require('../server/app');

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
floor2.addMeasurement('motion', 'floor2_motion', [
  {
    format: 'boolean'
  }
], {
  topic: 'public/motionsensor/lab/motion',
  timeseries: 'Floor2Motion',
  persist: true
});
/*
floor2.addMeasurement('current', 'floor2_current', [
  {
    format: 'boolean'
  }
], {
  topic: 'public/currentsensor/current',
  timeseries: 'Floor2Current',
  persist: true
});
*/
var floor3 = new app.Dictionary('3rd floor', 'floor3');
floor3.addMeasurement('window1', 'floor3_window1', [
  {
    format: 'boolean'
  }
], {
  topic: 'public/bitraf/windowsensor/workshop/sensor1',
  timeseries: 'Floor3Window1',
  persist: true
});
floor3.addMeasurement('window2', 'floor3_window2', [
  {
    format: 'boolean'
  }
], {
  topic: 'public/bitraf/windowsensor/workshop/sensor2',
  timeseries: 'Floor3Window2',
  persist: true
});
floor3.addMeasurement('window3', 'floor3_window3', [
  {
    format: 'boolean'
  }
], {
  topic: 'public/bitraf/windowsensor/workshop/sensor3',
  timeseries: 'Floor3Window3',
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
  dictionaries: [floor2, floor3, floor4, outside],
  theme: 'Snow',
  timeWindow: 24 * 60 * 60 * 1000,
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
