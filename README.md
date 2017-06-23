c-beam telemetry server
=======================

This is a telemetry server for connecting the NASA [OpenMCT](https://nasa.github.io/openmct/) with information sources on [c-base's](https://c-base.org/) c-beam telemetry network. It is based on the OpenMCT [telemetry adapter tutorial](http://nasa.github.io/openmct/docs/tutorials/#telemetry-adapter).

![Screenshot of OpenMCT with c-beam data](https://pbs.twimg.com/media/CotctAfXYAAKCh0.jpg)

## Installation

* Install the dependencies with `npm install`

## Running

* Start the service with `npm start`

If you want to change the MQTT broker address, set the `MSGFLO_BROKER` environment variable before starting the service.

## Adding information sources

c-beam topics are mapped to OpenMCT data in `app.js`.

## TODOs

* Make actual MsgFlo participant
* Mapping more c-beam data
* Custom displays combining different data points (like a green/red bar status UI)
* UIs for station functionality
