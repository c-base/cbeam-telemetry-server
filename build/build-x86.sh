#!/bin/sh
# Build x86 image
docker build -t $DOCKER_IMAGE -f Dockerfile .
