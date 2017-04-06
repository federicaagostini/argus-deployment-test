#!/bin/sh

set -xe

DOCKER_REGISTRY_HOST=${DOCKER_REGISTRY_HOST:-"cloud-vm128.cloud.cnaf.infn.it"}
PLATFORM=${PLATFORM:-centos7}

export REGISTRY="${DOCKER_REGISTRY_HOST}/"

echo "Build images for distributed deployment for platform ${PLATFORM}"

docker-compose -f argus-${PLATFORM}/docker-compose.yml build --no-cache

echo "Done."
