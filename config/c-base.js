var app = require('../server/app');

// Configure EVA unit 1
var crew = new app.Dictionary('Crew', 'crewtracker');
crew.addMeasurement('members', 'crew.members', [
  {
    units: 'members',
    format: 'integer',
    min: 0,
    max: 1000
  }
], {
  topic: 'c-base/crew/members'
});
crew.addMeasurement('passive', 'crew.passive', [
  {
    units: 'members',
    format: 'integer',
    min: 0,
    max: 1000
  }
], {
  topic: 'c-base/crew/passive'
});
crew.addMeasurement('online', 'crew.online', [
  {
    units: 'members',
    format: 'integer',
    min: 0,
    max: 100
  }
], {
  topic: 'CrewOnline.OUT'
}, function (online) {
  return online.length
});
var bar = new app.Dictionary('Bar', 'bartracker');
bar.addMeasurement('open', 'bar.open', [
  {
    units: 'barbot',
    format: 'boolean',
    min: 0,
    max: 1
  }
], {
  topic: 'bar/state'
}, function (state) {
  return state == 'open';
});
var replicatorValue = function (dict, key, name) {
  dict.addMeasurement('replicator_' + name, 'bar.replicator.' + key, [
    {
      units: 'available',
      format: 'boolean',
      min: 0,
      max: 1
    }
  ], {
    topic: 'Replicator.OUT'
  }, function (state) {
    var keys = Object.keys(state).sort();
    var stateKey = keys[key - 1];
    return state[stateKey];
  });
};
replicatorValue(bar, 1, 'clubmate');
replicatorValue(bar, 2, 'berliner1');
replicatorValue(bar, 3, 'berliner2');
replicatorValue(bar, 4, 'flora');
replicatorValue(bar, 5, 'premiumcola');
replicatorValue(bar, 6, 'spezi');
replicatorValue(bar, 7, 'kraftmalz');

var station = new app.Dictionary('Station', 'stationtracker');
station.addMeasurement('load', 'powermon.load', [
  {
    units: 'Watts',
    format: 'integer',
    min: 0,
    max: 15000
  }
], {
  topic: 'system/powermon/load'
});
station.addMeasurement('load_low', 'powermon.load_low', [
  {
    units: 'Watts',
    format: 'integer',
    min: 0,
    max: 15000
  }
], {
  topic: 'system/powermon/load_low'
});
station.addMeasurement('load_high', 'powermon.load_high', [
  {
    units: 'Watts',
    format: 'integer',
    min: 0,
    max: 15000
  }
], {
  topic: 'system/powermon/load_high'
});
station.addMeasurement('kdg_rx', 'echelon.kdg.rx', [
  {
    units: 'bytes',
    format: 'integer',
    min: 0,
    max: 2000000
  }
], {
  topic: 'system/echelon/traffic'
}, function (traffic) {
  return traffic.interfaces[0].rx;
});
station.addMeasurement('kdg_tx', 'echelon.kdg.tx', [
  {
    units: 'bytes',
    format: 'integer',
    min: 0,
    max: 2000000
  }
], {
  topic: 'system/echelon/traffic'
}, function (traffic) {
  return traffic.interfaces[0].tx;
});
station.addMeasurement('ipb_rx', 'echelon.ipb.rx', [
  {
    units: 'bytes',
    format: 'integer',
    min: 0,
    max: 2000000
  }
], {
  topic: 'system/echelon/traffic'
}, function (traffic) {
  return traffic.interfaces[1].rx;
});
station.addMeasurement('ipb_tx', 'echelon.ipb.tx', [
  {
    units: 'bytes',
    format: 'integer',
    min: 0,
    max: 2000000
  }
], {
  topic: 'system/echelon/traffic'
}, function (traffic) {
  return traffic.interfaces[1].tx;
});
station.addMeasurement('announcement', 'c_out.announcement', [
  {
    units: 'Message',
    format: 'string'
  }
], {
  topic: 'c_out/announce_en'
});

// Start the server
var server = new app.Server({
  host: process.env.HOST || 'localhost',
  port: process.env.PORT || 8080,
  wss_port: process.env.WSS_PORT || 8082,
  broker: process.env.MSGFLO_BROKER || 'mqtt://c-beam.cbrp3.c-base.org',
  dictionaries: [bar,station,crew],
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
