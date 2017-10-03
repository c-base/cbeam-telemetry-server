#!/bin/sh
# prepare qemu for cross-compiling
docker run --rm --privileged multiarch/qemu-user-static:register --reset
# Build RPi3 image
docker build -t $DOCKER_IMAGE -f Dockerfile-raspberrypi3 .
