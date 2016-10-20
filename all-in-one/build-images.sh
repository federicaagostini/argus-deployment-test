#!/bin/sh

set -xe

PLATFORM=${PLATFORM:-centos7}

echo "Build images for all-in-one deployment for platform $PLATFORM"

cd docker/
docker build --no-cache -t argus-deployment-test:$PLATFORM --file="Dockerfile.$PLATFORM" .
cd ..

echo "Done"
