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
	-e TIMEOUT=600 \
	italiangrid/argus-deployment-test:$PLATFORM

## Copy reports, logs and configuration
rm -rf $PWD/argus_*
mkdir $PWD/argus_logs $PWD/argus_conf $PWD/argus_reports

docker cp $container_name:/var/log/argus/ $PWD/argus_logs
docker cp $container_name:/etc/argus/ $PWD/argus_conf
docker cp $container_name:/opt/argus-robot-testsuite/reports $PWD/argus_reports


