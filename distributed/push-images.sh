#!/bin/sh

set -xe

PLATFORM=${PLATFORM:-centos7}

echo "Push images for distributed deployment for platform ${PLATFORM}"

services="pap pdp pep bdii"

for srv in $services; do
  dest=italiangrid/argus-${srv}-${PLATFORM}:latest
  docker push ${dest}
done

echo "Done."
