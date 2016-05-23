#!/bin/bash

set -x

PLATFORM="${PLATFORM:-centos7}"
TESTSUITE_BRANCH="${TESTSUITE_BRANCH:-master}"

container_name=argus-ts-$PLATFORM-$$

## Clean before run
docker rm $container_name

## Build images
cd docker/
docker build -t italiangrid/argus-deployment-test:$PLATFORM --file="Dockerfile.$PLATFORM" .

cd ../..

## Run
docker run --hostname=argus-$PLATFORM.cnaf.test \
	--name=$container_name \
	-e TESTSUITE_BRANCH=$TESTSUITE_BRANCH \
	-v $PWD/certificates/__cnaf_test.cert.pem:/etc/grid-security/hostcert.pem:ro \
	-v $PWD/certificates/__cnaf_test.key.pem:/etc/grid-security/hostkey.pem:ro  \
	italiangrid/argus-deployment-test:$PLATFORM

## Copy reports, logs and configuration
mkdir $PWD/argus_logs $PWD/argus_conf

docker cp $container_name:/var/log/argus/ $PWD/argus_logs
docker cp $container_name:/etc/argus/ $PWD/argus_conf
docker cp $container_name:/opt/argus-robot-testsuite/reports $PWD


