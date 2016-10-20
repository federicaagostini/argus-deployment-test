#!/bin/sh

set -xe

DOCKER_REGISTRY_HOST=${DOCKER_REGISTRY_HOST:-"cloud-vm128.cloud.cnaf.infn.it"}
PLATFORM=${PLATFORM:-centos7}
DEPLOYMENT=${DEPLOYMENT:-distributed}

workdir=${PWD}

cd ${workdir}/$DEPLOYMENT

sh build-images.sh
sh push-images.sh


