#!/bin/sh

set -xe

PLATFORM=${PLATFORM:-centos7}
USE_CACHE=${USE_CACHE:-false}

docker_opts="--no-cache"

if [ $USE_CACHE == "true" ]; then
	docker_opts=""
fi

echo "Build images for distributed deployment for platform ${PLATFORM}"

docker-compose -f argus-${PLATFORM}/docker-compose.yml build ${docker_opts}

echo "Done."
