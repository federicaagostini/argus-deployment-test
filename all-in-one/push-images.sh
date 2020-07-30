#!/bin/sh

set -xe

PLATFORM=${PLATFORM:-centos7}

echo "Push images for all-in-one deployment form platform ${PLATFORM}"

image_name=argus-deployment-test:${PLATFORM}
dest=italiangrid/argus-deployment-test:${PLATFORM}

docker tag ${image_name} ${dest}
docker push ${dest}

echo "Done."
