#!/bin/sh

set -xe

PLATFORM=${PLATFORM:-centos7}
DEPLOYMENT=${DEPLOYMENT:-distributed}

workdir=${PWD}

cd ${workdir}/$DEPLOYMENT

sh build-images.sh
sh push-images.sh


