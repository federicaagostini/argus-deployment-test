#!/bin/bash

set -x

PLATFORM="${PLATFORM:-centos7}"
TESTSUITE_REPO="${TESTSUITE_REPO:-https://github.com/argus-authz/argus-robot-testsuite}"
TESTSUITE_BRANCH="${TESTSUITE_BRANCH:-master}"

container_name=argus-ts-$PLATFORM-$$
workdir=$PWD

## Clean before run
docker rm $container_name

# Pull
docker pull italiangrid/argus-deployment-test:$PLATFORM

## Run
docker run --hostname=argus-$PLATFORM.cnaf.test \
	--name=$container_name \
	-e TESTSUITE_REPO=${TESTSUITE_REPO} \
	-e TESTSUITE_BRANCH=$TESTSUITE_BRANCH \
	-e TIMEOUT=600 \
        -e FACTER_ARGUS_REPO_BASE_URL=${FACTER_ARGUS_REPO_BASE_URL} \
	italiangrid/argus-deployment-test:$PLATFORM

## Copy reports, logs and configuration
rm -rfv $workdir/argus_*
mkdir $workdir/argus_logs $workdir/argus_conf $workdir/argus_reports

docker cp $container_name:/var/log/argus/ $workdir/argus_logs
docker cp $container_name:/etc/argus/ $workdir/argus_conf
docker cp $container_name:/opt/argus-robot-testsuite/reports $workdir/argus_reports

