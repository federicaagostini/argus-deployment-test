#!/bin/bash

set -xe

PLATFORM="${PLATFORM:-centos7}"
TESTSUITE_BRANCH="${TESTSUITE_BRANCH:-master}"


## Run Argus service
cd docker/
docker build -t italiangrid/argus-deployment-test:$PLATFORM --file="Dockerfile.$PLATFORM" .

cd ../..

container_name=argus-ts-$PLATFORM-$$

docker run --hostname=argus-$PLATFORM.cnaf.test \
	--name=$container_name \
	-e TESTSUITE_BRANCH=$TESTSUITE_BRANCH \
	-v $PWD/certificates/__cnaf_test.cert.pem:/etc/grid-security/hostcert.pem:ro \
	-v $PWD/certificates/__cnaf_test.key.pem:/etc/grid-security/hostkey.pem:ro  \
	italiangrid/argus-deployment-test:$PLATFORM

docker cp $container_name:/opt/argus-robot-testsuite/reports $PWD

docker rm $container_name

