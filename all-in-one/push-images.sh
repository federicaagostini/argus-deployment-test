#!/bin/sh

set -xe

DOCKER_REGISTRY_HOST=${DOCKER_REGISTRY_HOST:-"cloud-vm128.cloud.cnaf.infn.it"}
PLATFORM=${PLATFORM:-centos7}

echo "Push images for all-in-one deployment form platform ${PLATFORM}"

image_name=argus-deployment-test:${PLATFORM}
dest=${DOCKER_REGISTRY_HOST}/italiangrid/argus-deployment-test:${PLATFORM}

docker tag ${image_name} ${dest}
docker push ${dest}

echo "Done."
