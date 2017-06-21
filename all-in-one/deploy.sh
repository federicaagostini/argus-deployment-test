#!/bin/bash

set -x

PLATFORM="${PLATFORM:-centos7}"
TESTSUITE_REPO="${TESTSUITE_REPO:-https://github.com/argus-authz/argus-robot-testsuite}"
TESTSUITE_BRANCH="${TESTSUITE_BRANCH:-master}"
DOCKER_REGISTRY_HOST=${DOCKER_REGISTRY_HOST:-""}
REGISTRY=""
if [ -n "${DOCKER_REGISTRY_HOST}" ]; then
  REGISTRY=${DOCKER_REGISTRY_HOST}/
fi

container_name=argus-ts-$PLATFORM-$$
workdir=$PWD

## Clean before run
docker rm $container_name

if [ -n "${DOCKER_REGISTRY_HOST}" ]; then
	REGISTRY=${DOCKER_REGISTRY_HOST}/
	## Pull
	docker pull ${REGISTRY}italiangrid/argus-deployment-test:$PLATFORM
else
	## Build locally
	cd docker/
	docker build --no-cache -t italiangrid/argus-deployment-test:$PLATFORM --file="Dockerfile.$PLATFORM" .
	cd $workdir
fi


## Run
docker run --hostname=argus-$PLATFORM.cnaf.test \
	--name=$container_name \
	-e TESTSUITE_REPO=${TESTSUITE_REPO} \
	-e TESTSUITE_BRANCH=$TESTSUITE_BRANCH \
	-e TIMEOUT=600 \
        -e FACTER_ARGUS_REPO_BASE_URL=${FACTER_ARGUS_REPO_BASE_URL} \
	${REGISTRY}italiangrid/argus-deployment-test:$PLATFORM

## Copy reports, logs and configuration
rm -rfv $workdir/argus_*
mkdir $workdir/argus_logs $workdir/argus_conf $workdir/argus_reports

docker cp $container_name:/var/log/argus/ $workdir/argus_logs
docker cp $container_name:/etc/argus/ $workdir/argus_conf
docker cp $container_name:/opt/argus-robot-testsuite/reports $workdir/argus_reports

