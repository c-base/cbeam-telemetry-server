c-beam telemetry server [![Docker Hub x86](https://img.shields.io/docker/pulls/cbase/cbeam-telemetry-server.svg)](https://hub.docker.com/r/cbase/cbeam-telemetry-server/) [![Docker Hub Raspberry Pi3](https://img.shields.io/docker/pulls/cbase/raspberrypi3-cbeam-telemetry-server.svg)](https://hub.docker.com/r/cbase/raspberrypi3-cbeam-telemetry-server/) [![Build Status](https://travis-ci.org/c-base/cbeam-telemetry-server.svg?branch=master)](https://travis-ci.org/c-base/cbeam-telemetry-server) [![Greenkeeper badge](https://badges.greenkeeper.io/c-base/cbeam-telemetry-server.svg)](https://greenkeeper.io/)
=======================

This is a telemetry server for connecting the NASA [OpenMCT](https://nasa.github.io/openmct/) with information sources on [c-base's](https://c-base.org/) c-beam telemetry network. It is based on the OpenMCT [telemetry adapter tutorial](http://nasa.github.io/openmct/docs/tutorials/#telemetry-adapter).

![Screenshot of OpenMCT with c-beam data](https://pbs.twimg.com/media/CotctAfXYAAKCh0.jpg)

## Installation

* Install the dependencies with `npm install`
* Build OpenMCT with `npm run build`

## Running

* Start the service with `npm start`

If you want to change the MQTT broker address, set the `MSGFLO_BROKER` environment variable before starting the service.

Read more in <https://bergie.iki.fi/blog/nasa-openmct-iot-dashboard/>.

## Adding information sources

c-beam topics are mapped to OpenMCT data in the installation's runner file in `config/`.

## TODOs

* Mapping more c-beam data
* Custom displays combining different data points (like a green/red bar status UI)
* UIs for station functionality
