#!/bin/bash

set -xe

if [ ! `which docker-compose` ]; then
	curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
fi

## Run Argus service in detached mode
docker-compose up --build -d

## Get testsuite
git clone https://github.com/marcocaberletti/argus-robot-testsuite.git /tmp/argus-robot-testsuite
cd /tmp/argus-robot-testsuite/docker
sh build-image.sh

docker run --net=argusel7_default --volumes-from=local_repo \
	-e T_PDP_ADMIN_PASSWORD=pdpadmin_password \
	-e PAP_HOST=argus-pap.cnaf.test \
	-e PDP_HOST=argus-pdp.cnaf.test \
	-e PEP_HOST=argus-pep.cnaf.test \
	italiangrid/argus-testsuite:latest

docker-compose stop



