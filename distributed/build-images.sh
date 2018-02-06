#!/bin/sh

set -xe

DOCKER_REGISTRY_HOST=${DOCKER_REGISTRY_HOST:-"cloud-vm114.cloud.cnaf.infn.it"}
PLATFORM=${PLATFORM:-centos7}
USE_CACHE=${USE_CACHE:-false}

export REGISTRY="${DOCKER_REGISTRY_HOST}/"

docker_opts="--no-cache"

if [ $USE_CACHE == "true" ]; then
	docker_opts=""
fi

echo "Build images for distributed deployment for platform ${PLATFORM}"

docker-compose -f argus-${PLATFORM}/docker-compose.yml build ${docker_opts}

echo "Done."
