#!/bin/sh
# prepare qemu for cross-compiling
docker run --rm --privileged multiarch/qemu-user-static:register --reset
# Build RPi3 image
travis_wait 30 docker build -t cbase/cbeam-telemetry-server-raspberrypi3 -f Dockerfile-raspberrypi3 .
