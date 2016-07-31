c-beam telemetry server
=======================

This is a telemetry server for connecting the NASA [OpenMCT](https://nasa.github.io/openmct/) with information sources on [c-base's](https://c-base.org/) c-beam telemetry network. It is based on the OpenMCT [telemetry adapter tutorial](http://nasa.github.io/openmct/docs/tutorials/#telemetry-adapter).

## Installation

* Install OpenMCT following [its instructions](https://nasa.github.io/openmct/getting-started/)
* Make a local clone of this repository
* Copy the contents of `bundle` folder under OpenMCT `tutorials/telemetry` folder
* Add a `bundles.json` to your OpenMCT and [enable `tutorials/telemetry`](http://nasa.github.io/openmct/docs/tutorials/#step-1-add-a-top-level-object)
* `npm install` in the telemetry server root folder
* `npm start` the telemetry server
* `npm start` OpenMCT

Note: you have to be in the c-base crew network for this to work.

## Adding information sources

c-beam topics are mapped to OpenMCT data in `server/dictionary.json`.

## TODOs

* Easier OpenMCT setup
* Mapping more c-beam data
* Custom displays combining different data points (like a green/red bar status UI)
* UIs for station functionality
