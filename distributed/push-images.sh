#!/bin/sh

set -xe

DOCKER_REGISTRY_HOST=${DOCKER_REGISTRY_HOST:-"cloud-vm128.cloud.cnaf.infn.it"}
PLATFORM=${PLATFORM:-centos7}

export REGISTRY="$DOCKER_REGISTRY_HOST/"

echo "Push images for distributed deployment for platform $PLATFORM"

services="pap pdp pep bdii"

for srv in $services; do
	dest=${DOCKER_REGISTRY_HOST}/italiangrid/argus-${srv}-${PLATFORM}
	docker push $dest
done

echo "Done."